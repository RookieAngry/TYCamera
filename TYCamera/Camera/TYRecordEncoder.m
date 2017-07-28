//
//  TYRecordEncoder.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYRecordEncoder.h"
#import "TYRecordHelper.h"

@interface TYRecordEncoder ()

@property (nonatomic, strong) AVAssetWriter *cameraWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;

@end

@implementation TYRecordEncoder {
    NSString *_filePath;
    int _videoW;
    int _videoH;
    UInt32 _channel;
    Float64 _rate;
}

#pragma mark - Initialization

+ (instancetype)recordEncoderPath:(NSString *)filePath videoWidth:(int)videoWidth videoHeight:(int)videoHeight audioChannel:(UInt32)channel audioRate:(Float64)rate {
    return [[[self class] alloc] initPath:filePath videoWidth:videoWidth videoHeight:videoHeight audioChannel:channel audioRate:rate];
}

- (instancetype)initPath:(NSString *)filePath videoWidth:(int)videoWidth videoHeight:(int)videoHeight audioChannel:(UInt32)channel audioRate:(Float64)rate {
    if (self = [super init]) {
        _filePath = filePath;
        _videoW = videoWidth;
        _videoH = videoHeight;
        _channel = channel;
        _rate = rate;
    }
    return self;
}

#pragma mark - Public Functions

- (void)encoderFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo {
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        if (self.cameraWriter.status == AVAssetWriterStatusUnknown) {
            
            if ([self.cameraWriter canAddInput:self.videoInput]) {
                [self.cameraWriter addInput:self.videoInput];
            }
            
            if ([self.cameraWriter canAddInput:self.audioInput]) {
                [self.cameraWriter addInput:self.audioInput];
            }
            
            [self.cameraWriter startWriting];
            [self.cameraWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        }
        
        if (self.videoInput.isReadyForMoreMediaData && isVideo) {
            [self.videoInput appendSampleBuffer:sampleBuffer];
        }
        
        if (self.audioInput.isReadyForMoreMediaData  && !isVideo) {
            [self.audioInput appendSampleBuffer:sampleBuffer];
        }
    }
}

- (void)encoderFinishCompletionHandler:(void (^)())handler {
    [self.cameraWriter finishWritingWithCompletionHandler:handler];
}

#pragma mark - Lazy Load

- (AVAssetWriter *)cameraWriter {
    if (!_cameraWriter) {
        NSError *error = nil;
        _cameraWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:_filePath] fileType:AVFileTypeMPEG4 error:&error];
        if (error) {
            NSLog(@"Create CameraWriter Failure! Error:%@", error);
        }
    }
    return _cameraWriter;
}

- (AVAssetWriterInput *)videoInput {
    if (!_videoInput) {
        NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:
                                  AVVideoCodecH264, AVVideoCodecKey,
                                 [NSNumber numberWithInteger: _videoW], AVVideoWidthKey,
                                 [NSNumber numberWithInteger: _videoH], AVVideoHeightKey,
                                  nil];
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:setting];
        _videoInput.expectsMediaDataInRealTime = YES;
    }
    return _videoInput;
}

- (AVAssetWriterInput *)audioInput {
    if (!_audioInput) {
        NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @(kAudioFormatMPEG4AAC), AVFormatIDKey,
                                  @(_channel), AVNumberOfChannelsKey,
                                  @(_rate), AVSampleRateKey,
                                  nil];
        NSLog(@"setting:%@", setting);
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:setting];
        _audioInput.expectsMediaDataInRealTime = YES;
    }
    return _audioInput;
}

@end
