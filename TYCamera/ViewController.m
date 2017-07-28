//
//  ViewController.m
//  TYCamera
//
//  Created by 陈天宇 on 2017/7/24.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "ViewController.h"
#import "TYCameraVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    TYCameraVC *cameravc = [[TYCameraVC alloc] init];
//    cameravc.type = TYCameraVCTypeVideo;
    [self.navigationController pushViewController:cameravc animated:YES];
}


@end
