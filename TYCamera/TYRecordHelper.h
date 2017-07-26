//
//  TYRecordHelper.h
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TYRecordHelper : NSObject

/**
 获取最终视频的地址

 @return 视频地址
 */
+ (NSString *)videoPath;

/**
 将视频转换为MP4格式

 @param mediaPath 视频文件的地址
 @param presetName 转换后的视频质量
 @param success 转换成功的回调（封面图， 转换后的视频地址）
 @param failure 转换失败后的回调
 */
+ (void)transformFormatToMp4:(NSString *)mediaPath
                  presetName:(NSString *)presetName
                     success:(void(^)(UIImage *coverImage, NSString *filePath))success
                     failure:(void(^)(NSError *error))failure;

/**
 获取视频封面图（第一帧）

 @param mediaPath 视频文件的地址
 @param success 成功的回调（封面图）
 @param failure 失败的回调
 */
+ (void)videoCoverImage:(NSString *)mediaPath
                success:(void(^)(UIImage *coverImage))success
                failure:(void(^)(NSError *error))failure;

/**
 将视频片段进行整合

 @param assetArray 需要整合的视频资源对象数组
 */
+ (AVMutableComposition *)combineVideosWithAssetArray:(NSArray<AVAsset *>*)assetArray;

@end
