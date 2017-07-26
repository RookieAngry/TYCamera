//
//  TYCameraVC.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYCameraVC.h"
#import "TYRecordEngine.h"

@interface TYCameraVC ()

@property (nonatomic, strong) TYRecordEngine *recordEngine;

@end

@implementation TYCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.recordEngine startRecord];
    [self.view.layer addSublayer:self.recordEngine.previewLayer];
    self.recordEngine.previewLayer.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.recordEngine openRecordFunctions];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.recordEngine stopRecord];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.recordEngine switchCamera];
}

#pragma mark - Lazy Load

- (TYRecordEngine *)recordEngine {
    if (!_recordEngine) {
        _recordEngine = [[TYRecordEngine alloc] initRecordEngineSessionPreset:AVCaptureSessionPresetHigh devicePosition:AVCaptureDevicePositionFront recordType:TYRecordEngineTypeBoth];
    }
    return _recordEngine;
}

@end
