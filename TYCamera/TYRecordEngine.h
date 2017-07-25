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

- (instancetype)initRecordEnginePresetName:(NSString *)presetName
                            devicePosition:(AVCaptureDevicePosition)position recordType:(TYRecordEngineType)recordType;


- (void)openRecordFunctions;

- (void)closeRecordFunctions;

- (void)startRecord;

- (void)pauseRecord;

- (void)resumeRecord;

- (void)stopRecord;

- (void)openFlashLight:(BOOL)open;

- (void)switchCamera;

@end
