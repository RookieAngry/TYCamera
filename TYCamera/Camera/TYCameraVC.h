//
//  TYCameraVC.h
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, TYCameraVCType) {
    TYCameraVCTypeBoth,
    TYCameraVCTypeVideo,
    TYCameraVCTypePhoto,
};

typedef void(^ty_recordProgress)(CGFloat progress);
typedef void(^ty_recordLessMinDuration)();
typedef void(^ty_recordLargerEqualMaxDuration)();

@interface TYCameraVC : UIViewController

/**
 录制视频允许的最低时长
 */
@property(nonatomic, assign) NSTimeInterval minDuration;

/**
 录制视频允许的最大时长
 */
@property(nonatomic, assign) NSTimeInterval maxDuration;

/**
 录制一段视频时的当前进度回调
 */
@property(nonatomic, copy) ty_recordProgress progress;

/**
 录制整段视频视频小于允许的最低时长的回调
 */
@property(nonatomic, copy) ty_recordLessMinDuration lessMinDuration;

/**
 录制整段视频视频大于等于允许的最大时长的回调
 */
@property(nonatomic, copy) ty_recordLargerEqualMaxDuration largerEqualMaxDuration;

/**
 类方法 实例化TYCameraVC

 @param preset 视频质量
 @param position 前置/后置摄像头（默认前置摄像头）
 @param cameraType TYCameraVC的类型（默认TYCameraVCTypeBoth）
 @return TYCameraVC实例对象
 */
+ (instancetype)recordEngineSessionPreset:(NSString *)preset
                           devicePosition:(AVCaptureDevicePosition)position
                               recordType:(TYCameraVCType)cameraType
                             previewFrame:(CGRect)frame;

/**
 实例方法 实例化TYCameraVC

 @param preset 视频质量
 @param position 前置/后置摄像头（默认前置摄像头）
 @param cameraType TYCameraVC的类型（默认TYCameraVCTypeBoth）
 @return TYCameraVC实例对象
 */
- (instancetype)initRecordEngineSessionPreset:(NSString *)preset
                               devicePosition:(AVCaptureDevicePosition)position
                                   recordType:(TYCameraVCType)cameraType
                                 previewFrame:(CGRect)frame;

/**
 开始录制
 */
- (void)startRecord;

/**
 停止录制
 */
- (void)stopRecord;

/**
 移除对应下标的视频片段
 
 @param index 视频片段的下标
 */
- (void)removeVideoAtIndex:(NSInteger)index;

/**
 完成视频录制
 
 @param handler 视频录制成功后，返回视频封面图,视频存储的路径以及视频时长
 @param failure 视频录制失败返回的错误
 */
- (void)finishCaptureHandler:(void(^)(UIImage *coverImage, NSString *filePath, NSTimeInterval duration))handler failure:(void(^)(NSError *error))failure;

/**
 完成拍照
 
 @param handler 拍照完成后，返回照片
 */
- (void)finishTakePhotoHandler:(void(^)(UIImage *photo))handler;

/**
 设置闪光灯模式

 @param mode 为闪光灯设置的模式
 */
- (void)setupFlashLight:(AVCaptureFlashMode)mode;

/**
 切换摄像头
 */
- (void)switchCamera;

@end
