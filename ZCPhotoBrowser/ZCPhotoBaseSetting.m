//
//  ZCPhotoBaseSetting.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/30.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoBaseSetting.h"

@implementation ZCPhotoBaseSetting
+ (instancetype)sharedZCPhotoBaseSetting
{
    static ZCPhotoBaseSetting *baseSetting = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        baseSetting = [[ZCPhotoBaseSetting alloc] init];
    });
    return baseSetting;
}
@end
