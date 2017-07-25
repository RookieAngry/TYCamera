//
//  TYRecordHelper.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYRecordHelper.h"
#import <AVFoundation/AVFoundation.h>

@implementation TYRecordHelper

#pragma mark - Public Functions

+ (void)transformFormatToMp4:(NSString *)mediaPath
                  presetName:(NSString *)presetName
                     success:(void (^)(UIImage *, NSString *))success
                     failure:(void (^)(NSError *))failure {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:mediaPath]];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:presetName];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = [NSURL fileURLWithPath:self.videoPath];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.error) {
            if (failure) {
                failure(exportSession.error);
            }
            return;
        }
        [self videoCoverImage:self.videoPath success:^(UIImage *coverImage) {
            if (success) {
                success(coverImage, self.videoPath);
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
                failure(error);
            }
            return;
        }
        UIImage *coverImage = [UIImage imageWithCGImage:image];
        if (success) {
            success(coverImage);
        }
    }];
}

+ (NSString *)videoPath {
    NSString *videoDirectory = [NSTemporaryDirectory() stringByAppendingString:@"Videos"];
    NSFileManager *fileM = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExist = ![fileM fileExistsAtPath:videoDirectory isDirectory:&isDirectory];
    if (!isDirectory && !isExist) {
        NSError *error = nil;
        BOOL result = [fileM createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error || !result) {
            NSLog(@"Create Videos Directory Failure");
            return nil;
        }
    }
    return [videoDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[NSDate date]]];
}

@end
