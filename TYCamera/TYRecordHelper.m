//
//  TYRecordHelper.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYRecordHelper.h"

@implementation TYRecordHelper

#pragma mark - Public Functions

+ (NSString *)videoPath {
    NSString *videoDirectory = [NSTemporaryDirectory() stringByAppendingString:@"Videos"];
    NSFileManager *fileM = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExist = [fileM fileExistsAtPath:videoDirectory isDirectory:&isDirectory];
    if (!isDirectory && !isExist) {
        NSError *error = nil;
        BOOL result = [fileM createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error || !result) {
            NSLog(@"Create Videos Directory Failure");
            return nil;
        }
    }
    return [videoDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%zd.mp4",(int)[[NSDate date] timeIntervalSince1970]]];
}

+ (void)transformFormatToMp4WithPath:(NSString *)mediaPath presetName:(NSString *)presetName success:(void (^)(UIImage *, NSString *))success failure:(void (^)(NSError *))failure {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:mediaPath]];
    [self transformFormatToMp4WithAsset:asset presetName:presetName success:^(UIImage *coverImage, NSString *filePath) {
        if (success) {
            success(coverImage, filePath);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)transformFormatToMp4WithAsset:(AVAsset *)asset
                           presetName:(NSString *)presetName
                              success:(void (^)(UIImage *, NSString *))success
                              failure:(void (^)(NSError *))failure {
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:presetName];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    NSString *finalPath = [self videoPath];
    exportSession.outputURL = [NSURL fileURLWithPath:finalPath];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.error) {
            if (failure) {
                failure(exportSession.error);
            }
            return;
        }
        [self videoCoverImage:finalPath success:^(UIImage *coverImage) {
            if (success) {
                NSLog(@"%zd",coverImage.imageOrientation);
                success(coverImage, finalPath);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }];
}

+ (void)videoCoverImage:(NSString *)mediaPath
                success:(void (^)(UIImage *))success
                failure:(void (^)(NSError *))failure {
    NSURL *mediaUrl = [NSURL fileURLWithPath:mediaPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:mediaUrl options:nil];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   failure(error);
                });
            }
            return;
        }
        UIImage *coverImage = [UIImage imageWithCGImage:image];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
               success(coverImage);
            });
        }
    }];
}

+ (AVMutableComposition *)combineVideosWithAssetArray:(NSArray<AVAsset *> *)assetArray {
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    __block NSTimeInterval temDuration = 0.f;
    [assetArray enumerateObjectsUsingBlock:^(AVAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, obj.duration);
        NSError *error = nil;
        [track insertTimeRange:timeRange ofTrack:[obj tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:CMTimeMakeWithSeconds(temDuration, 0) error:&error];
        temDuration += CMTimeGetSeconds(obj.duration);
    }];
    return composition;
}

@end
