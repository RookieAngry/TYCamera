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

@interface TYRecordEngine () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraInput;
@property (nonatomic, strong) AVCaptureDeviceInput *microInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *cameraOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *microOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *photoOutput;
@property (nonatomic, strong) AVCaptureConnection *cameraConnection;
@property (nonatomic, strong) AVCaptureConnection *microConnection;

@property (nonatomic, strong) dispatch_queue_t captureQueue;

@end

@implementation TYRecordEngine {
    NSString *_presetName;
    AVCaptureDevicePosition _position;
    TYRecordEngineType _recordType;
}

#pragma mark - Initialization Functions

- (instancetype)init {
    if (self = [super init]) {
        _maxRecordTime = 60.f;
        _minRecordTime = 3.f;
    }
    return self;
}

- (instancetype)initRecordEnginePresetName:(NSString *)presetName devicePosition:(AVCaptureDevicePosition)position recordType:(TYRecordEngineType)recordType {
    if (self = [super init]) {
        _presetName = presetName;
        _position = position;
        _recordType = recordType;
    }
    return self;
}

#pragma mark - Public Functions

- (void)startRecord {
    @synchronized (self) {
        [self.captureSession startRunning];
    }
}

- (void)stopRecord {
    @synchronized (self) {
        [self.captureSession stopRunning];
    }
}

#pragma mark - Private Functions

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
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

- (void)addInputOutput {
    if ([self.captureSession canAddInput:self.cameraInput]) {
        [self.captureSession addInput:self.cameraInput];
    }
    
    switch (_recordType) {
        case TYRecordEngineTypeBoth: {
            [self addVideoInputOutput];
        }
            break;
            
        case TYRecordEngineTypeVideo: {
            [self addVideoInputOutput];
        }
            break;
            
        case TYRecordEngineTypePhoto: {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)addVideoInputOutput {
    if (![self.captureSession canAddInput:self.microInput]) {
        [self.captureSession addInput:self.microInput];
    }
}

#pragma mark - Getter

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
        AVCaptureDevice *device = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].firstObject;
        NSError *error = nil;
        _microInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
        if (error) {
            NSLog(@"Get MircoInput Failure! Error:%@", error);
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
        [_cameraOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _cameraOutput;
}

- (AVCaptureVideoDataOutput *)microOutput {
    if (_microOutput) {
        _microOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_microOutput setSampleBufferDelegate:self queue:self.captureQueue];
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
    if (!_cameraConnection) {
        _cameraConnection = [self.cameraOutput connectionWithMediaType:AVMediaTypeVideo];
    }
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

- (NSString *)videoPath {
    return [TYRecordHelper videoPath];
}

@end
