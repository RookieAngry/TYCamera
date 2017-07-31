//
//  ViewController.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "ViewController.h"
#import "TYTakePhotoVC.h"
#import "TYTakeVideoVC.h"
#import "TYCustomCameraVC.h"

@interface ViewController ()

@property(nonatomic, strong) UIButton *takePhotoBtn;

@property(nonatomic, strong) UIButton *takeVideoBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

#pragma mark - Private Functions

- (void)setupView {
    
    self.title = @"TYCamera";
    
    CGFloat kUIScreenW = self.view.bounds.size.width;
    CGFloat kUIScreenH = self.view.bounds.size.height;
    CGFloat buttonW = 100.f;
    CGFloat buttonH = 50.f;
    CGFloat buttonMargin = 10.f;
    CGFloat buttonX = (kUIScreenW - buttonW) * 0.5;
    CGFloat buttonOriginY = (kUIScreenH - 2 * buttonH - 2 * buttonMargin) * 0.5;
    
    [self.view addSubview:self.takePhotoBtn];
    self.takePhotoBtn.frame = CGRectMake(buttonX, buttonOriginY, buttonW, buttonH);
    
    [self.view addSubview:self.takeVideoBtn];
    self.takeVideoBtn.frame = CGRectMake(buttonX, CGRectGetMaxY(self.takePhotoBtn.frame) + buttonMargin, buttonW, buttonH);
}

#pragma mark - Actions

- (void)takePhotoBtnClick {
    TYTakePhotoVC *takePhotovc = [TYTakePhotoVC recordEngineSessionPreset:AVCaptureSessionPresetHigh devicePosition:AVCaptureDevicePositionFront recordType:TYCameraVCTypePhoto previewFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height - 223.f)];
    [self.navigationController pushViewController:takePhotovc animated:YES];
}

- (void)takeVideoBtnClick {
    TYTakeVideoVC *takeVideovc = [TYTakeVideoVC recordEngineSessionPreset:AVCaptureSessionPresetHigh devicePosition:AVCaptureDevicePositionFront recordType:TYCameraVCTypeVideo previewFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height - 223.f)];
    takeVideovc.minDuration = 3.f;
    takeVideovc.maxDuration = 15.f;
    [self.navigationController pushViewController:takeVideovc animated:YES];
}

- (void)customCameraBtnClick {
    TYCustomCameraVC *customCameravc = [TYCustomCameraVC recordEngineSessionPreset:AVCaptureSessionPresetHigh devicePosition:AVCaptureDevicePositionFront recordType:TYCameraVCTypeBoth previewFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height - 223.f)];
    [self.navigationController pushViewController:customCameravc animated:YES];
}

#pragma mark - Lazy Load

- (UIButton *)takePhotoBtn {
    if (!_takePhotoBtn) {
        _takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePhotoBtn setTitle:@"拍照" forState:UIControlStateNormal];
        _takePhotoBtn.backgroundColor = [UIColor orangeColor];
        [_takePhotoBtn addTarget:self action:@selector(takePhotoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takePhotoBtn;
}

- (UIButton *)takeVideoBtn {
    if (!_takeVideoBtn) {
        _takeVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takeVideoBtn setTitle:@"拍摄" forState:UIControlStateNormal];
        _takeVideoBtn.backgroundColor = [UIColor purpleColor];
        [_takeVideoBtn addTarget:self action:@selector(takeVideoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takeVideoBtn;
}


@end
