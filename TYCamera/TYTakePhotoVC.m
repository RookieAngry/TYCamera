//
//  TYTakePhotoVC.m
//  TYCamera
//
//  Created by Samueler on 2017/7/28.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYTakePhotoVC.h"
#import "TYNavigationVC.h"
#import "UIColor+TYHexColor.h"

@interface TYTakePhotoVC () <TYNavigationVCDelegate>

@property (nonatomic, strong) UIButton *takePhotoBtn;

@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, strong) UIImageView *displayImgView;

@end

@implementation TYTakePhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

#pragma mark - Private Functions

- (void)setupView {
    
    TYNavigationVC *navc = (TYNavigationVC *)self.navigationController;
    navc.navigationDelegate = self;
    
    [self.view addSubview:self.displayImgView];
    
    [self.view addSubview:self.bottomView];
    self.bottomView.frame = CGRectMake(0, self.view.bounds.size.height - 223.f, self.view.bounds.size.width, 223.f);
    
    self.displayImgView.frame = CGRectMake(self.view.bounds.size.width - 130, 100, 100, 150);
    
    [self.bottomView addSubview:self.takePhotoBtn];
    CGSize btnSize = [UIImage imageNamed:@"record"].size;
    self.takePhotoBtn.frame = CGRectMake((self.bottomView.frame.size.width - btnSize.width) * 0.5, (self.bottomView.frame.size.height - btnSize.height) * 0.5, btnSize.width, btnSize.height);
}

- (void)takePhotoBtnClick {
    __weak typeof(self) weakSelf = self;
    [self finishTakePhotoHandler:^(UIImage *photo) {
        weakSelf.displayImgView.image = photo;
        weakSelf.displayImgView.hidden = NO;
    }];
}

#pragma mark - TYNavigationVCDelegate

- (void)switchCameraAction {
    [self switchCamera];
}

- (void)flashButtonAction:(AVCaptureFlashMode)mode {
    [self setupFlashLight:mode];
}

#pragma mark - Lazy Load

- (UIButton *)takePhotoBtn {
    if (!_takePhotoBtn) {
        _takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePhotoBtn setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [_takePhotoBtn setTitle:@"按下拍" forState:UIControlStateNormal];
        _takePhotoBtn.titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightThin];
        [_takePhotoBtn addTarget:self action:@selector(takePhotoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takePhotoBtn;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    }
    return _bottomView;
}

- (UIImageView *)displayImgView {
    if (!_displayImgView) {
        _displayImgView = [[UIImageView alloc] init];
        _displayImgView.hidden = YES;
    }
    return _displayImgView;
}

@end
