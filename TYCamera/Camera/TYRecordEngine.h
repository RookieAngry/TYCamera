//
//  TYRecordEngine.h
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol TYRecordEngineDelegate <NSObject>

@optional

- (void)recordDurationLessMinRecordDuration;

- (void)recordDurationLargerEqualMaxRecordDuration;

- (void)recordProgress:(CGFloat)progress;

@end

typedef NS_ENUM(NSUInteger, TYRecordEngineType) {
    TYRecordEngineTypeBoth,
    TYRecordEngineTypeVideo,
    TYRecordEngineTypePhoto,
};

@interface TYRecordEngine : NSObject

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/**
 允许录制视频的最长时间
 */
@property (nonatomic, assign) NSTimeInterval maxRecordTime;
/**
 允许录制视频的最短时间
 */
@property (nonatomic, assign) NSTimeInterval minRecordTime;
/**
 当前录制视频的总时长
 */
@property (nonatomic, assign) NSTimeInterval videoDuration;
/**
 存储视频片段地址的数组
 */
@property (nonatomic, strong) NSMutableArray *videosPath;

@property (nonatomic, strong) NSMutableArray *durations;

@property (nonatomic, weak) id<TYRecordEngineDelegate> delegate;

/**
 初始化TYRecordEngines实例对象

 @param preset 设置录制视频的质量
 @param position 设置摄像头（前置摄像头/后置摄像头）
 @param recordType 录制视频的类型
 @return 返回TYRecordEngines实例对象
 */
- (instancetype)initRecordEngineSessionPreset:(NSString *)preset
                            devicePosition:(AVCaptureDevicePosition)position
                                recordType:(TYRecordEngineType)recordType;


/**
 开启录制/拍照功能
 */
- (void)openRecordFunctions;

/**
 关闭录制/拍照功能
 */
- (void)closeRecordFunctions;

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
 设置闪光灯的模式

 @param mode 为闪光灯设置的模式
 */
- (void)setupFlashLight:(AVCaptureFlashMode)mode;

/**
 切换摄像头
 */
- (void)switchCamera;

@end
