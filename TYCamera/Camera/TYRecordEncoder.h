//
//  TYRecordEncoder.h
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TYRecordEncoder : NSObject

+ (instancetype)recordEncoderPath:(NSString *)filePath videoWidth:(int)videoWidth videoHeight:(int)videoHeight audioChannel:(UInt32)channel audioRate:(Float64)rate;

- (instancetype)initPath:(NSString *)filePath videoWidth:(int)videoWidth videoHeight:(int)videoHeight audioChannel:(UInt32)channel audioRate:(Float64)rate;

- (void)encoderFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo;

- (void)encoderFinishCompletionHandler:(void(^)())handler;

@end
