//
//  TYCameraVC.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYCameraVC.h"
#import "TYRecordEngine.h"

@interface TYCameraVC () <TYRecordEngineDelegate>

@property (nonatomic, strong) TYRecordEngine *recordEngine;

@property (nonatomic, strong) UIButton *recordBtn;

@property (nonatomic, strong) UILongPressGestureRecognizer *pressGesture;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation TYCameraVC

- (void)dealloc {
    NSLog(@"%@ %@",[self class], NSStringFromSelector(_cmd));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view.layer addSublayer:self.recordEngine.previewLayer];
    self.recordEngine.previewLayer.frame = self.view.bounds;
    
    [self.view addSubview:self.recordBtn];
    self.recordBtn.frame = CGRectMake(0, 100, 100, 100);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"完成录制" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(0, 250, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    
    UIButton *switchbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchbtn setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [switchbtn addTarget:self action:@selector(switchbtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchbtn];
    switchbtn.frame = CGRectMake(0, 400, 100, 100);
    switchbtn.backgroundColor = [UIColor orangeColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.recordEngine openRecordFunctions];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.recordEngine closeRecordFunctions];
}

#pragma mark - Actions

- (void)pressGestureAction {
    if (self.pressGesture.state == UIGestureRecognizerStateBegan) {
        [self.recordEngine startRecord];
    } else if (self.pressGesture.state == UIGestureRecognizerStateEnded) {
        [self.recordEngine stopRecord];
    }
}

- (void)btnClick {
    [self.recordEngine finishCaptureHandler:^(UIImage *coverImage, NSString *filePath, NSTimeInterval duration) {
        NSLog(@"coverImage:%@,filePath:%@,duration:%f", coverImage, filePath, duration);
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filePath]];
        self.player = [AVPlayer playerWithPlayerItem:item];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.view.layer addSublayer:self.playerLayer];
        self.playerLayer.frame = CGRectMake(150, 0, 300, 300);
        [self.player play];
        
        UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(100, 400, 200, 200)];
        imgview.image = coverImage;
        [self.view addSubview:imgview];
    } failure:^(NSError *error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)recordBtnClick {
    self.recordBtn.selected = !self.recordBtn.selected;
    self.recordBtn.selected ? [self.recordEngine startRecord] : [self.recordEngine stopRecord];
}

- (void)switchbtnClick {
    [self.recordEngine switchCamera];
}

#pragma mark - TYRecordEngineDelegate

- (void)recordProgress:(NSTimeInterval)progress {
    NSLog(@"progress:%f", progress);
}

- (void)recordDurationLessMinRecordDuration {
    NSLog(@"时间过短");
}

- (void)recordDurationLargerEqualMaxRecordDuration {
    NSLog(@"时间过长");
}

#pragma mark - Lazy Load

- (TYRecordEngine *)recordEngine {
    if (!_recordEngine) {
        _recordEngine = [[TYRecordEngine alloc] initRecordEngineSessionPreset:AVCaptureSessionPresetHigh devicePosition:AVCaptureDevicePositionFront recordType:TYRecordEngineTypeBoth];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}

- (UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordBtn setTitle:@"按住录制" forState:UIControlStateNormal];
        [_recordBtn addGestureRecognizer:self.pressGesture];
        _recordBtn.backgroundColor = [UIColor greenColor];
        [_recordBtn addTarget:self action:@selector(recordBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}

- (UILongPressGestureRecognizer *)pressGesture {
    if (!_pressGesture) {
        _pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressGestureAction)];
    }
    return _pressGesture;
}

@end
