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

+ (instancetype)recordEncoderPath:(NSString *)filePath;

- (instancetype)initPath:(NSString *)filePath;

- (void)encoderFrame:(CMSampleBufferRef)sampleBuffer;

- (void)encoderFinishCompletionHandler:(void(^)())handler;

@end
