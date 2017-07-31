//
//  TYCameraVC.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYCameraVC.h"
#import "TYRecordEngine.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TYCameraVC () <TYRecordEngineDelegate>

@property (nonatomic, strong) TYRecordEngine *recordEngine;

@end

@implementation TYCameraVC {
    NSString *_preset;
    AVCaptureDevicePosition _position;
    TYCameraVCType _cameraType;
    CGRect _previewFrame;
}

#pragma mark - Initialization Functions

- (instancetype)init {
    if (self = [super init]) {
        _preset = AVCaptureSessionPreset1280x720;
        _position = AVCaptureDevicePositionFront;
        _cameraType = TYCameraVCTypeBoth;
        _previewFrame = self.view.bounds;
    }
    return self;
}

+ (instancetype)recordEngineSessionPreset:(NSString *)preset devicePosition:(AVCaptureDevicePosition)position recordType:(TYCameraVCType)cameraType
                             previewFrame:(CGRect)frame {
    return [[[self class] alloc] initRecordEngineSessionPreset:preset devicePosition:position recordType:cameraType previewFrame:frame];
}

- (instancetype)initRecordEngineSessionPreset:(NSString *)preset
                               devicePosition:(AVCaptureDevicePosition)position recordType:(TYCameraVCType)cameraType
                                 previewFrame:(CGRect)frame {
    if (self = [super init]) {
        _preset = preset;
        _position = position;
        _cameraType = cameraType;
        _previewFrame = frame;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view.layer addSublayer:self.recordEngine.previewLayer];
    self.recordEngine.previewLayer.frame = _previewFrame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.recordEngine openRecordFunctions];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.recordEngine closeRecordFunctions];
}

- (void)dealloc {
    NSLog(@"%@ %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Public Functions

- (void)startRecord {
    [self.recordEngine startRecord];
}

- (void)stopRecord {
    [self.recordEngine stopRecord];
}

- (void)removeVideoAtIndex:(NSInteger)index {
    [self.recordEngine removeVideoAtIndex:index];
}

- (void)finishCaptureHandler:(void (^)(UIImage *, NSString *, NSTimeInterval))handler
                     failure:(void (^)(NSError *))failure {
    [self.recordEngine finishCaptureHandler:^(UIImage *coverImage, NSString *filePath, NSTimeInterval duration) {
        if (handler) {
            handler(coverImage, filePath, duration);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)finishTakePhotoHandler:(void (^)(UIImage *))handler {
    [self.recordEngine finishTakePhotoHandler:^(UIImage *photo) {
        if (handler) {
            handler(photo);
        }
    }];
}

- (void)setupFlashLight:(AVCaptureFlashMode)mode {
    [self.recordEngine setupFlashLight:mode];
}

- (void)switchCamera {
    [self.recordEngine switchCamera];
}

#pragma mark - TYRecordEngineDelegate

- (void)recordProgress:(CGFloat)progress {
    if (self.progress) {
        self.progress(progress);
    }
}

- (void)recordDurationLessMinRecordDuration {
    if (self.lessMinDuration) {
        self.lessMinDuration();
    }
}

- (void)recordDurationLargerEqualMaxRecordDuration {
    if (self.largerEqualMaxDuration) {
        self.largerEqualMaxDuration();
    }
}

#pragma mark - Getter

- (NSTimeInterval)videoDuration {
    return self.recordEngine.videoDuration;
}

- (NSArray *)videosPath {
    return self.recordEngine.videosPath;
}

- (NSMutableArray *)durations {
    return self.recordEngine.durations;
}

#pragma mark - Lazy Load

- (TYRecordEngine *)recordEngine {
    if (!_recordEngine) {
        _recordEngine = [[TYRecordEngine alloc] initRecordEngineSessionPreset:_preset devicePosition:_position recordType:(TYRecordEngineType)_cameraType];
        _recordEngine.delegate = self;
        if (self.minDuration) {
            _recordEngine.minRecordTime = self.minDuration;
        }
        if (self.maxDuration) {
            _recordEngine.maxRecordTime = self.maxDuration;
        }
    }
    return _recordEngine;
}

@end
