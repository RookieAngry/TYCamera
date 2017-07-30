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

@interface TYTakeVideoVC () <TYNavigationVCDelegate>

@property(nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *takePhotoBtn;

@property(nonatomic, strong) UILongPressGestureRecognizer *pressGesture;

@property(nonatomic, strong) UIButton *cancelBtn;

@property(nonatomic, strong) UIButton *sureBtn;

@property(nonatomic, strong) CAShapeLayer *totalProgressLayer;

@property(nonatomic, strong) CAShapeLayer *breakPointWhiteLayer;

@property(nonatomic, strong) CAShapeLayer *breakPointGrayLayer;

@property(nonatomic, strong) CAShapeLayer *progressHeadLayer;

@property(nonatomic, strong) CAShapeLayer *progressLayer;

@property(nonatomic, strong) UIBezierPath *progressPath;

@property(nonatomic, strong) dispatch_source_t timer;

@property(nonatomic, assign) CGFloat lastProgress;

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
    
    [self.bottomView addSubview:self.takePhotoBtn];
    CGSize btnSize = [UIImage imageNamed:@"record"].size;
    self.takePhotoBtn.frame = CGRectMake((self.bottomView.frame.size.width - btnSize.width) * 0.5, (self.bottomView.frame.size.height - btnSize.height) * 0.5, btnSize.width, btnSize.height);
    
    [self.bottomView addSubview:self.cancelBtn];
    CGSize cancelBtnSize = self.cancelBtn.imageView.frame.size;
    self.cancelBtn.frame = CGRectMake(self.takePhotoBtn.frame.origin.x - cancelBtnSize.width - 30.f, (self.bottomView.frame.size.height - cancelBtnSize.height) * 0.5, cancelBtnSize.width, cancelBtnSize.height);
    
    [self.bottomView addSubview:self.sureBtn];
    CGSize sureBtnSize = self.sureBtn.imageView.frame.size;
    self.sureBtn.frame = CGRectMake(CGRectGetMaxX(self.takePhotoBtn.frame) + 30.f, (self.bottomView.frame.size.height - sureBtnSize.height) * 0.5, sureBtnSize.width, sureBtnSize.height);
    
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
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 2.f, 2.f)];
    self.progressHeadLayer.path = progressPath.CGPath;
    [self.totalProgressLayer addSublayer:self.progressHeadLayer];
    
    [self.totalProgressLayer addSublayer:self.progressLayer];
}

- (void)aboutViewRecord {
    __weak typeof(self) weakSelf = self;
    self.progress = ^(CGFloat progress) {

    };
    
    self.lessMinDuration = ^{
        NSLog(@"less");
    };
    
    self.largerEqualMaxDuration = ^{
        NSLog(@"larger");
    };
}

#pragma mark - Actions

- (void)pressGestureAction {
    if (self.pressGesture.state == UIGestureRecognizerStateBegan) {
        [self startRecord];
    }
    
    if (self.pressGesture.state == UIGestureRecognizerStateEnded) {
        [self stopRecord];
    }
}

- (void)cancelBtnClick {
    self.cancelBtn.selected = !self.cancelBtn.selected;
}

- (void)sureBtnClick {
    NSLog(@"===");
}

#pragma mark - TYNavigationVCDelegate

- (void)switchCameraAction {
    [self switchCamera];
}

- (void)flashButtonAction:(AVCaptureFlashMode)mode {
    [self setupFlashLight:mode];
}

#pragma mark - Tool Functions

- (void)progressHeaderStartShowHide {
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        self.progressHeadLayer.hidden = !self.progressHeadLayer.hidden;
    });
    dispatch_resume(_timer);
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

- (UIButton *)takePhotoBtn {
    if (!_takePhotoBtn) {
        _takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePhotoBtn setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [_takePhotoBtn setTitle:@"按住拍" forState:UIControlStateNormal];
        _takePhotoBtn.titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightThin];
        [_takePhotoBtn addGestureRecognizer:self.pressGesture];
    }
    return _takePhotoBtn;
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

- (CAShapeLayer *)progressHeadLayer {
    if (!_progressHeadLayer) {
        _progressHeadLayer = [CAShapeLayer layer];
        _progressHeadLayer.strokeColor = [UIColor colorWithHexString:@"444444"].CGColor;
        _progressHeadLayer.lineWidth = 2.f;
    }
    return _progressHeadLayer;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = [UIColor orangeColor].CGColor;
        _progressLayer.lineWidth = 4.f;
    }
    return _progressLayer;
}

- (UIBezierPath *)progressPath {
    if (!_progressPath) {
        _progressPath = [UIBezierPath bezierPath];
    }
    return _progressPath;
}

@end
