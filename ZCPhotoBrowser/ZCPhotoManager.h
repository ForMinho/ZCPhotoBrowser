//
//  ZCPhtoManager.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCPhotoKit.h"
@interface ZCPhotoManager : NSObject

+ (instancetype)sharedPhotoManager;
- (NSArray <PHFetchResult *> *)fetchPhotoArrayWithPhotoType:(NSArray *)photoFetchTypes;
@end
