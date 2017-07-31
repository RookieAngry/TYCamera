//
//  TYTakeVideoVC.m
//  TYCamera
//
//  Created by Samueler on 2017/7/28.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYTakeVideoVC.h"
#import "TYNavigationVC.h"
#import "UIColor+TYHexColor.h"
#import "TYPlayerVC.h"

@interface TYTakeVideoVC () <TYNavigationVCDelegate>

@property(nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *takeVideoBtn;

@property(nonatomic, strong) UILongPressGestureRecognizer *pressGesture;

@property(nonatomic, strong) UIButton *cancelBtn;

@property(nonatomic, strong) UIButton *sureBtn;

@property(nonatomic, strong) CAShapeLayer *totalProgressLayer;

@property(nonatomic, strong) CAShapeLayer *breakPointWhiteLayer;

@property(nonatomic, strong) CAShapeLayer *breakPointGrayLayer;

@property(nonatomic, strong) CAShapeLayer *currentProgressLayer;

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *progressLayerArray;

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *whiteProgressLayerArray;

@end

@implementation TYTakeVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    
    [self aboutViewRecord];
}

#pragma mark - Private Functions

- (void)setupView {
    
    TYNavigationVC *navc = (TYNavigationVC *)self.navigationController;
    navc.navigationDelegate = self;
    self.title = @"录制";
    
    [self.view addSubview:self.bottomView];
    self.bottomView.frame = CGRectMake(0, self.view.bounds.size.height - 223.f, self.view.bounds.size.width, 223.f);
    
    [self.bottomView addSubview:self.takeVideoBtn];
    CGSize btnSize = [UIImage imageNamed:@"record"].size;
    self.takeVideoBtn.frame = CGRectMake((self.bottomView.frame.size.width - btnSize.width) * 0.5, (self.bottomView.frame.size.height - btnSize.height) * 0.5, btnSize.width, btnSize.height);
    
    [self.bottomView addSubview:self.cancelBtn];
    CGSize cancelBtnSize = self.cancelBtn.imageView.frame.size;
    self.cancelBtn.frame = CGRectMake(self.takeVideoBtn.frame.origin.x - cancelBtnSize.width - 30.f, (self.bottomView.frame.size.height - cancelBtnSize.height) * 0.5, cancelBtnSize.width, cancelBtnSize.height);
    
    [self.bottomView addSubview:self.sureBtn];
    CGSize sureBtnSize = self.sureBtn.imageView.frame.size;
    self.sureBtn.frame = CGRectMake(CGRectGetMaxX(self.takeVideoBtn.frame) + 30.f, (self.bottomView.frame.size.height - sureBtnSize.height) * 0.5, sureBtnSize.width, sureBtnSize.height);
    
    UIBezierPath *totalLinePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width, 2.f)];
    self.totalProgressLayer.path = totalLinePath.CGPath;
    [self.bottomView.layer addSublayer:self.totalProgressLayer];
    
    CGFloat breakPointX = self.view.frame.size.width / self.maxDuration * self.minDuration;
    UIBezierPath *breakPointWhitePath = [UIBezierPath bezierPathWithRect:CGRectMake(breakPointX, 0, 2.f, 2.f)];
    self.breakPointWhiteLayer.path = breakPointWhitePath.CGPath;
    [self.totalProgressLayer addSublayer:self.breakPointWhiteLayer];
    
    UIBezierPath *breakPointGrayPath = [UIBezierPath bezierPathWithRect:CGRectMake(breakPointX + 2, 0, 2.f, 2.f)];
    self.breakPointGrayLayer.path = breakPointGrayPath.CGPath;
    [self.totalProgressLayer addSublayer:self.breakPointGrayLayer];
}

- (void)aboutViewRecord {
    __weak typeof(self) weakSelf = self;
    self.progress = ^(CGFloat progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIBezierPath *progressPath = [UIBezierPath bezierPath];
        CGFloat startX = strongSelf.videoDuration * strongSelf.view.frame.size.width / strongSelf.maxDuration + strongSelf.whiteProgressLayerArray.count;
        [progressPath moveToPoint:CGPointMake(startX, 1)];
        CGFloat targetX = strongSelf.view.frame.size.width / strongSelf.maxDuration * progress + startX;
        [progressPath addLineToPoint:CGPointMake(targetX, 1)];
        strongSelf.currentProgressLayer.path = progressPath.CGPath;
    };
    
    self.lessMinDuration = ^{
        NSLog(@"less");
    };
    
    self.largerEqualMaxDuration = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.takeVideoBtn.enabled = NO;
        [strongSelf finishCaptureHandler:^(UIImage *coverImage, NSString *filePath, NSTimeInterval duration) {
            TYPlayerVC *playervc = [[TYPlayerVC alloc] init];
            playervc.coverImage = coverImage;
            playervc.videoPath = filePath;
            [strongSelf.navigationController pushViewController:playervc animated:YES];
        } failure:^(NSError *error) {
            NSLog(@"Compound Videos Failure! Error:%@", error);
        }];
    };
}

#pragma mark - Actions

- (void)pressGestureAction {
    if (self.pressGesture.state == UIGestureRecognizerStateBegan) {
        [self startRecord];
        self.currentProgressLayer = [self progressLayer];
        [self.totalProgressLayer addSublayer:self.currentProgressLayer];
        [self.progressLayerArray addObject:self.currentProgressLayer];
    }
    
    if (self.pressGesture.state == UIGestureRecognizerStateEnded) {
        if (self.videoDuration < self.maxDuration) {
            [self stopRecord];
            UIBezierPath *whiteBreakPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.videoDuration * self.view.frame.size.width / self.maxDuration + self.whiteProgressLayerArray.count, -0.5, 1.f, 4.f)];
            CAShapeLayer *whiteLayer = [CAShapeLayer layer];
            whiteLayer.strokeColor = [UIColor colorWithHexString:@"ffffff"].CGColor;
            whiteLayer.lineWidth = 1.f;
            whiteLayer.path = whiteBreakPath.CGPath;
            [self.bottomView.layer addSublayer:whiteLayer];
            [self.whiteProgressLayerArray addObject:whiteLayer];
        }
    }
}

- (void)cancelBtnClick {
    if (self.videosPath.count) {
        if (self.cancelBtn.selected) {
            [self removeVideoAtIndex:self.videosPath.count - 1];
            [self.progressLayerArray.lastObject removeFromSuperlayer];
            [self.progressLayerArray removeLastObject];
            [self.whiteProgressLayerArray.lastObject removeFromSuperlayer];
            [self.whiteProgressLayerArray removeLastObject];
            self.takeVideoBtn.enabled = YES;
        }
        self.cancelBtn.selected = !self.cancelBtn.selected;
    }
}

- (void)sureBtnClick {
    if (self.videoDuration < self.minDuration) {
        UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:nil message:@"时间不能少于3s" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertvc addAction:sureAction];
        [self presentViewController:alertvc animated:YES completion:nil];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self finishCaptureHandler:^(UIImage *coverImage, NSString *filePath, NSTimeInterval duration) {
        TYPlayerVC *playervc = [[TYPlayerVC alloc] init];
        playervc.coverImage = coverImage;
        playervc.videoPath = filePath;
        [weakSelf.navigationController pushViewController:playervc animated:YES];
    } failure:^(NSError *error) {
        NSLog(@"Compound Videos Failure! Error:%@", error);
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

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
        _bottomView.userInteractionEnabled = YES;
    }
    return _bottomView;
}

- (UIButton *)takeVideoBtn {
    if (!_takeVideoBtn) {
        _takeVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takeVideoBtn setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [_takeVideoBtn setTitle:@"按住拍" forState:UIControlStateNormal];
        _takeVideoBtn.titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightThin];
        [_takeVideoBtn addGestureRecognizer:self.pressGesture];
    }
    return _takeVideoBtn;
}

- (UILongPressGestureRecognizer *)pressGesture {
    if (!_pressGesture) {
        _pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressGestureAction)];
    }
    return _pressGesture;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:[UIImage imageNamed:@"arrow_back"] forState:UIControlStateNormal];
        [_cancelBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateSelected];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn sizeToFit];
    }
    return _cancelBtn;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setImage:[UIImage imageNamed:@"arrow_next"] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_sureBtn sizeToFit];
    }
    return _sureBtn;
}

- (CAShapeLayer *)totalProgressLayer {
    if (!_totalProgressLayer) {
        _totalProgressLayer = [CAShapeLayer layer];
        _totalProgressLayer.strokeColor = [UIColor colorWithHexString:@"929292"].CGColor;
        _totalProgressLayer.lineWidth = 2.f;
    }
    return _totalProgressLayer;
}

- (CAShapeLayer *)breakPointWhiteLayer {
    if (!_breakPointWhiteLayer) {
        _breakPointWhiteLayer = [CAShapeLayer layer];
        _breakPointWhiteLayer.strokeColor = [UIColor colorWithHexString:@"ffffff"].CGColor;
        _breakPointWhiteLayer.lineWidth = 2.f;
    }
    return _breakPointWhiteLayer;
}

- (CAShapeLayer *)breakPointGrayLayer {
    if (!_breakPointGrayLayer) {
        _breakPointGrayLayer = [CAShapeLayer layer];
        _breakPointGrayLayer.strokeColor = [UIColor colorWithHexString:@"6a6a6a"].CGColor;
        _breakPointGrayLayer.lineWidth = 2.f;
    }
    return _breakPointGrayLayer;
}

- (CAShapeLayer *)progressLayer {
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.strokeColor = [UIColor orangeColor].CGColor;
    progressLayer.lineWidth = 4.f;
    return progressLayer;
}

- (NSMutableArray<CAShapeLayer *> *)progressLayerArray {
    if (!_progressLayerArray) {
        _progressLayerArray = [NSMutableArray array];
    }
    return _progressLayerArray;
}

- (NSMutableArray<CAShapeLayer *> *)whiteProgressLayerArray {
    if (!_whiteProgressLayerArray) {
        _whiteProgressLayerArray = [NSMutableArray array];
    }
    return _whiteProgressLayerArray;
}

@end
