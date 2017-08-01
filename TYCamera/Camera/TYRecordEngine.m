//
//  TYRecordEngine.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYRecordEngine.h"
#import "TYRecordEncoder.h"
#import "TYRecordHelper.h"

@interface TYRecordEngine () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, CAAnimationDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraInput;
@property (nonatomic, strong) AVCaptureDeviceInput *microInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *cameraOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *microOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *photoOutput;
@property (nonatomic, strong) AVCaptureConnection *cameraConnection;
@property (nonatomic, strong) AVCaptureConnection *microConnection;

@property (nonatomic, strong) TYRecordEncoder *recordEncoder;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, strong) dispatch_queue_t captureQueue;
@property (atomic, assign) BOOL isCapturing;

@end

@implementation TYRecordEngine {
    NSString *_presetName;
    AVCaptureDevicePosition _position;
    TYRecordEngineType _recordType;
    Float64 _rate;
    UInt32 _channel;
    int _videoW;
    int _videoH;
}

#pragma mark - Initialization Functions

- (instancetype)init {
    if (self = [super init]) {
        self.maxRecordTime = 60.f;
        self.minRecordTime = 3.f;
        _videoW = 720;
        _videoH = 1280;
    }
    return self;
}

- (instancetype)initRecordEngineSessionPreset:(NSString *)preset
                               devicePosition:(AVCaptureDevicePosition)position
                                   recordType:(TYRecordEngineType)recordType {
    if (self = [self init]) {
        _presetName = preset;
        _position = position;
        _recordType = recordType;
        [self addInputOutput];
    }
    return self;
}

#pragma mark - Override Functions

- (void)dealloc {
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
    if (self.cameraInput) {
        [self.captureSession removeInput:self.cameraInput];
    }
    if (self.microInput) {
        [self.captureSession removeInput:self.microInput];
    }
    
    if (self.microOutput) {
        [self.captureSession removeOutput:self.microOutput];
    }
    
    if (self.cameraOutput) {
        [self.captureSession removeOutput:self.cameraOutput];
    }
    
    if (self.photoOutput) {
        [self.captureSession removeOutput:self.photoOutput];
    }

    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    self.cameraInput = nil;
    self.microInput = nil;
    self.cameraOutput = nil;
    self.microOutput = nil;
    self.microOutput = nil;
    self.photoOutput = nil;
    self.cameraConnection = nil;
    self.microConnection = nil;
    self.captureSession =  nil;
    self.captureQueue = nil;
    NSLog(@"%@ %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Public Functions

- (void)openRecordFunctions {
    if (![self.captureSession isRunning]) {
        [self.captureSession startRunning];
    }
}

- (void)closeRecordFunctions {
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
    self.isCapturing = NO;
}

- (void)startRecord {
    self.isCapturing = YES;
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.captureQueue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        self.currentDuration += 0.1;
    });
    dispatch_resume(_timer);
}

- (void)stopRecord {
    self.isCapturing = NO;
    
    self.videoDuration += self.currentDuration;
    [self.durations addObject:@(self.currentDuration)];
    dispatch_source_cancel(self.timer);
    self.timer = nil;
    self.currentDuration = 0.f;
    
    [self.recordEncoder encoderFinishCompletionHandler:^{
        self.recordEncoder = nil;
        
        if (self.videoDuration < self.minRecordTime) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordDurationLessMinRecordDuration)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.delegate recordDurationLessMinRecordDuration];
                });
            }
        } else if (self.videoDuration >= self.maxRecordTime) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordDurationLargerEqualMaxRecordDuration)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.delegate recordDurationLargerEqualMaxRecordDuration]; 
                });
            }
        }
    }];
}

- (void)switchCamera {
    AVCaptureDevicePosition currentDevicePositon = [self.cameraInput device].position;
    if (currentDevicePositon == AVCaptureDevicePositionBack) {
        currentDevicePositon = AVCaptureDevicePositionFront;
    } else {
        currentDevicePositon = AVCaptureDevicePositionBack;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *newCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:[self captureDeviceInput:currentDevicePositon] error:&error];
    if (error) {
        NSLog(@"Get New Camera Input Failure! Error:%@", error);
        return;
    }
    
    [self.captureSession beginConfiguration];
    
    [self.captureSession removeInput:self.cameraInput];
    if ([self.captureSession canAddInput:newCameraInput]) {
        [self.captureSession addInput:newCameraInput];
        self.cameraInput = newCameraInput;
    } else {
        [self.captureSession addInput:self.cameraInput];
    }
    
    [self.captureSession commitConfiguration];
    
    [self switchCameraAnimation];
}

- (void)removeVideoAtIndex:(NSInteger)index {
    if (index >= self.videosPath.count) {
        NSLog(@"Index Beyond VideosPath Array Count! Array Count:%zd, index:%zd", self.videosPath.count , index);
        return;
    }
    
    [self.videosPath removeObjectAtIndex:index];
    self.videoDuration -= [self.durations[index] floatValue];
    [self.durations removeObjectAtIndex:index];
}

- (void)finishCaptureHandler:(void (^)(UIImage *, NSString *, NSTimeInterval))handler failure:(void (^)(NSError *))failure {
    NSMutableArray *avassets = [NSMutableArray array];
    for (NSString *videoPath in self.videosPath) {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
        [avassets addObject:asset];
    }
    AVMutableComposition *compisition = [TYRecordHelper combineVideosWithAssetArray:avassets];
    [TYRecordHelper transformFormatToMp4WithAsset:compisition presetName:AVAssetExportPreset1280x720 success:^(UIImage *coverImage, NSString *filePath) {
        if (handler) {
            handler(coverImage, filePath, self.videoDuration);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)finishTakePhotoHandler:(void (^)(UIImage *))handler {
    AVCaptureConnection *captureConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
    [captureConnection setVideoMirrored:[self isFrontFacingCameraPreset]];
    [self.photoOutput captureStillImageAsynchronouslyFromConnection:[self.photoOutput connectionWithMediaType:AVMediaTypeVideo]
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (!error && imageDataSampleBuffer) {
            NSData *photoData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *photo = [UIImage imageWithData:photoData];
            handler(photo);
        } else {
            NSLog(@"Take Photo Failure! Error:%@", error);
        }
    }];
}

- (void)setupFlashLight:(AVCaptureFlashMode)mode {
    AVCaptureDevice *backCamera = [self captureDeviceInput:AVCaptureDevicePositionBack];
    if (backCamera.hasFlash) {
        [backCamera lockForConfiguration:nil];
        backCamera.flashMode = mode;
        [backCamera unlockForConfiguration];
    }
    
    [self.captureSession startRunning];
}

#pragma mark - Private Functions

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    self.cameraConnection.videoMirrored = [self isFrontFacingCameraPreset];
    if (!self.isCapturing) {  return; }
    
    if (!self.recordEncoder && captureOutput == self.microOutput) {
        self.filePath  = [TYRecordHelper videoPath];
        [self.videosPath addObject:self.filePath];
        [self setAudioFormat:sampleBuffer];
        self.recordEncoder = [TYRecordEncoder recordEncoderPath:self.filePath videoWidth:_videoW videoHeight:_videoH audioChannel:_channel audioRate:_rate];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordProgress:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.delegate recordProgress:self.currentDuration];
        });
    }
    
    if (self.currentDuration >= (self.maxRecordTime - self.videoDuration)) {
        [self closeRecordFunctions];
        return;
    }
    [self.recordEncoder encoderFrame:sampleBuffer isVideo:captureOutput != self.microOutput];
}

#pragma mark - Tool Functions

- (AVCaptureDevice *)captureDeviceInput:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (BOOL)isFrontFacingCameraPreset {
    return [self.cameraInput device].position == AVCaptureDevicePositionFront ? YES : NO;
}

- (void)addInputOutput {
    [self.captureSession beginConfiguration];
    
    if ([self.captureSession canAddInput:self.cameraInput]) {
        [self.captureSession addInput:self.cameraInput];
    }
    
    switch (_recordType) {
        case TYRecordEngineTypeBoth: {
            [self addVideoInputOutput];
            if ([self.captureSession canAddOutput:self.photoOutput]) {
                [self.captureSession addOutput:self.photoOutput];
            }
        }
            break;
            
        case TYRecordEngineTypeVideo: {
            [self addVideoInputOutput];
        }
            break;
            
        case TYRecordEngineTypePhoto: {
            if ([self.captureSession canAddOutput:self.photoOutput]) {
                [self.captureSession addOutput:self.photoOutput];
            }
        }
            break;
            
        default:
            break;
    }
    
    [self.captureSession commitConfiguration];
}

- (void)addVideoInputOutput {
    if ([self.captureSession canAddInput:self.microInput]) {
        [self.captureSession addInput:self.microInput];
    }
    
    if ([self.captureSession canAddOutput:self.cameraOutput]) {
        [self.captureSession addOutput:self.cameraOutput];
        [self.cameraOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    
    if ([self.captureSession canAddOutput:self.microOutput]) {
        [self.captureSession addOutput:self.microOutput];
        [self.microOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    
    self.cameraConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
}

- (void)switchCameraAnimation {
    CATransition *switchAnimation = [CATransition animation];
    switchAnimation.delegate = self;
    switchAnimation.duration = 0.45f;
    switchAnimation.type = @"oglFlip";
    switchAnimation.subtype = [self isFrontFacingCameraPreset] ? kCATransitionFromRight : kCATransitionFromLeft;
    switchAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.previewLayer addAnimation:switchAnimation forKey:@"changeAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim {
    self.cameraConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.captureSession startRunning];
}

- (void)setAudioFormat:(CMSampleBufferRef)sampleBuffer {
    CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
    _rate = asbd->mSampleRate;
    _channel = asbd->mChannelsPerFrame;
}

#pragma mark - Lazy Load

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (AVCaptureDeviceInput *)cameraInput {
    if (!_cameraInput) {
        NSError *error = nil;
        _cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self captureDeviceInput:_position] error:&error];
        if (error) {
            NSLog(@"Get CameraInput Failure! Error:%@", error);
        }
    }
    return _cameraInput;
}

- (AVCaptureDeviceInput *)microInput {
    if (!_microInput) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _microInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"Get microInput Failure! Error:%@", error);
        }
    }
    return _microInput;
}

- (AVCaptureVideoDataOutput *)cameraOutput {
    if (!_cameraOutput) {
        _cameraOutput = [[AVCaptureVideoDataOutput alloc] init];
        NSDictionary* setting = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _cameraOutput.videoSettings = setting;
    }
    return _cameraOutput;
}

- (AVCaptureAudioDataOutput *)microOutput {
    if (!_microOutput) {
        _microOutput = [[AVCaptureAudioDataOutput alloc] init];
    }
    return _microOutput;
}

- (AVCaptureStillImageOutput *)photoOutput {
    if (!_photoOutput) {
        _photoOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
        _photoOutput.outputSettings = setting;
    }
    return _photoOutput;
}

- (AVCaptureConnection *)cameraConnection {
    _cameraConnection = [self.cameraOutput connectionWithMediaType:AVMediaTypeVideo];
    return _cameraConnection;
}

- (AVCaptureConnection *)microConnection {
    if (!_microConnection) {
        _microConnection = [self.microOutput connectionWithMediaType:AVMediaTypeAudio];
    }
    return _microConnection;
}

- (dispatch_queue_t)captureQueue {
    if (!_captureQueue) {
        _captureQueue = dispatch_queue_create("queue.tycamera.com", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

- (NSMutableArray *)videosPath {
    if (!_videosPath) {
        _videosPath = [NSMutableArray array];
    }
    return _videosPath;
}

- (NSMutableArray *)durations {
    if (!_durations) {
        _durations = [NSMutableArray array];
    }
    return _durations;
}

@end
