//
//  TYNavigationVC.h
//  TYCamera
//
//  Created by Samueler on 2017/7/29.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol TYNavigationVCDelegate <NSObject>

@optional

- (void)switchCameraAction;

- (void)flashButtonAction:(AVCaptureFlashMode)mode;

@end

@interface TYNavigationVC : UINavigationController

@property(nonatomic, weak) id<TYNavigationVCDelegate> navigationDelegate;

@end
