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
}

#pragma mark - Initialization

+ (instancetype)recordEncoderPath:(NSString *)filePath {
    return [[[self class] alloc] initPath:filePath];
}

- (instancetype)initPath:(NSString *)filePath {
    if (self = [super init]) {
        _filePath = filePath;
    }
    return self;
}

#pragma mark - Public Functions

- (void)encoderFrame:(CMSampleBufferRef)sampleBuffer {
    if (self.cameraWriter.status == AVAssetWriterStatusUnknown) {
        [self.cameraWriter startWriting];
        [self.cameraWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
    }
    if (self.cameraWriter.status == AVAssetWriterStatusWriting) {
        if (self.videoInput.isReadyForMoreMediaData) {
            [self.videoInput appendSampleBuffer:sampleBuffer];
        }
        
        if (self.audioInput.isReadyForMoreMediaData) {
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
                                  nil];
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:setting];
        _videoInput.expectsMediaDataInRealTime = YES;
        [self.cameraWriter addInput:_videoInput];
    }
    return _videoInput;
}

- (AVAssetWriterInput *)audioInput {
    if (!_audioInput) {
        NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                  [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                                  nil];
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:setting];
        _audioInput.expectsMediaDataInRealTime = YES;
        [self.cameraWriter addInput:_audioInput];
    }
    return _audioInput;
}

@end
