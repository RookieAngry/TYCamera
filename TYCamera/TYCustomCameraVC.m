//
//  TYCustomCameraVC.m
//  TYCamera
//
//  Created by Samueler on 2017/7/28.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYCustomCameraVC.h"
#import "TYNavigationVC.h"

@interface TYCustomCameraVC () <TYNavigationVCDelegate>

@end

@implementation TYCustomCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
}

#pragma mark - Private Functions

- (void)setupView {
    self.title = @"拍摄";
    
    TYNavigationVC *navc = (TYNavigationVC *)self.navigationController;
    navc.navigationDelegate = self;
    
}

#pragma mark - Actions

- (void)backBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TYNavigationVCDelegate

- (void)switchCameraAction {
    [self switchCamera];
}

- (void)flashButtonAction:(AVCaptureFlashMode)mode {
    [self setupFlashLight:mode];
}

#pragma mark - Lazy Load

@end
