//
//  TYNavigationVC.m
//  TYCamera
//
//  Created by Samueler on 2017/7/29.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYNavigationVC.h"
#import "UIColor+TYHexColor.h"
#import "TYTakePhotoVC.h"
#import "TYTakeVideoVC.h"

@interface TYNavigationVC ()

@property(nonatomic, strong) UIButton *backBtn;

@property(nonatomic, strong) UIButton *switchCameraBtn;

@property(nonatomic, strong) UIButton *flashBtn;

@property(nonatomic, assign) AVCaptureFlashMode currentMode;

@end

@implementation TYNavigationVC

#pragma mark - Override Functions

+ (void)initialize {
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18.f], NSForegroundColorAttributeName: [UIColor colorWithHexString:@"333333"]}];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count && ([viewController isKindOfClass:[TYTakePhotoVC class]] || [viewController isKindOfClass:[TYTakeVideoVC class]])) {
        [self setupNavigationWithVC:viewController];
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark - Private Functions

- (void)setupNavigationWithVC:(UIViewController *)viewController {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    viewController.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *swithItem = [[UIBarButtonItem alloc] initWithCustomView:self.switchCameraBtn];
    UIBarButtonItem *flashItem = [[UIBarButtonItem alloc] initWithCustomView:self.flashBtn];
    viewController.navigationItem.rightBarButtonItems = @[swithItem, flashItem];
}

#pragma mark - Actions

- (void)backBtnClick {
    [self popViewControllerAnimated:YES];
}

- (void)switchCameraBtnClick {
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(switchCameraAction)]) {
        [self.navigationDelegate switchCameraAction];
    }
}

- (void)flashBtnClick {
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    self.currentMode == AVCaptureFlashModeAuto ? (self.currentMode = AVCaptureFlashModeOff) : (self.currentMode += 1);
    switch (self.currentMode) {
        case AVCaptureFlashModeAuto: {
            [self.flashBtn setImage:[UIImage imageNamed:@"autoFlash"] forState:UIControlStateNormal];
        }
            break;
            
        case AVCaptureFlashModeOn: {
            [self.flashBtn setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
        }
            break;
            
        case AVCaptureFlashModeOff: {
            [self.flashBtn setImage:[UIImage imageNamed:@"closeFlash"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(flashButtonAction:)]) {
        [self.navigationDelegate flashButtonAction:self.currentMode];
    }
}

#pragma mark - Lazy Load

- (UIButton *)backBtn {
    if (!_backBtn) {
        UIImage *backImg = [UIImage imageNamed:@"close"];
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImg.size.width, backImg.size.height)];
        [_backBtn setImage:backImg forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        UIImage *img = [UIImage imageNamed:@"switchCamera"];
        _switchCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, 44.f)];
        [_switchCameraBtn setImage:img forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (UIButton *)flashBtn {
    if (!_flashBtn) {
        UIImage *img = [UIImage imageNamed:@"autoFlash"];
        _flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44.f)];
        [_flashBtn setImage:img forState:UIControlStateNormal];
        [_flashBtn addTarget:self action:@selector(flashBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.currentMode = AVCaptureFlashModeAuto;
    }
    return _flashBtn;
}

@end
