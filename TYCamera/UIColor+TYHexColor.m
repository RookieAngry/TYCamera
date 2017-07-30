//
//  UIColor+TYHexColor.m
//  TYCamera
//
//  Created by Samueler on 2017/7/29.
//  Copyright © 2017年 陈天宇. All rights reserved.
//

#import "UIColor+TYHexColor.h"

@implementation UIColor (TYHexColor)

+ (UIColor *)colorWithHexString:(NSString *)hexColorString {
    if ([hexColorString length] < 6) {
        return [UIColor blackColor];
    }
    NSString *tempString = [hexColorString lowercaseString];
    if ([tempString hasPrefix:@"0x"]) {
        tempString = [tempString substringFromIndex:2];
    } else if ([tempString hasPrefix:@"#"]) {
        tempString = [tempString substringFromIndex:1];
    }
    if ([tempString length] != 6) {
        return [UIColor blackColor];
    }

    NSRange range = NSMakeRange(0, 2);
    NSString *rString = [tempString substringWithRange:range];
    range.location = 2;
    NSString *gString = [tempString substringWithRange:range];
    range.location = 4;
    NSString *bString = [tempString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:1.0f];
}

@end
