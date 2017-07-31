//
//  TYPlayerVC.m
//  TYCamera
//
//  Created by Douqu on 2017/7/31.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "TYPlayerVC.h"
#import <AVFoundation/AVFoundation.h>

@interface TYPlayerVC ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation TYPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:self.videoPath]];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.view.layer addSublayer:self.playerLayer];
    self.playerLayer.frame = self.view.bounds;
    [self.player play];
}


@end
