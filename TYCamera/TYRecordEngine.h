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

- (void)recordProgress:(NSTimeInterval)progress;

@end

typedef NS_ENUM(NSUInteger, TYRecordEngineType) {
    TYRecordEngineTypeBoth,
    TYRecordEngineTypeVideo,
    TYRecordEngineTypePhoto,
};

@interface TYRecordEngine : NSObject

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, copy, readonly) NSString *videoPath;
@property (nonatomic, assign) NSTimeInterval maxRecordTime;
@property (nonatomic, assign) NSTimeInterval minRecordTime;
@property (nonatomic, weak) id<TYRecordEngineDelegate> delegate;

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
 暂停录制
 */
- (void)pauseRecord;

/**
 恢复录制
 */
- (void)resumeRecord;

/**
 结束录制
 */
- (void)stopRecord;

/**
 完成视频录制

 @param handler 视频录制成功后，返回视频封面图
 */
- (void)finishCaptureHandler:(void(^)(UIImage *coverImage))handler;

/**
 完成拍照

 @param handler 拍照完成后，返回照片
 */
- (void)finishTakePhotoHandler:(void(^)(UIImage *photo))handler;

/**
 是否开启闪光灯

 @param open 是否开启
 */
- (void)openFlashLight:(BOOL)open;

/**
 切换摄像头
 */
- (void)switchCamera;

@end
