//
//  TYCameraVC.h
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TYCameraVCType) {
    TYCameraVCTypeBoth,
    TYCameraVCTypeVideo,
    TYCameraVCTypePhoto,
};

@interface TYCameraVC : UIViewController

@property (nonatomic, assign) TYCameraVCType type;

@end
