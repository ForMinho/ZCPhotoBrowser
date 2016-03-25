//
//  PHFetchResult+ZCPhotoFetch.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "PHFetchResult+ZCPhotoFetch.h"
#import <objc/runtime.h>
static char ResultSubClass;
@implementation PHFetchResult (ZCPhotoFetch)
- (void)setFetchResultSubClass:(NSString *)FetchResultSubClass
{
    objc_setAssociatedObject(self, &ResultSubClass, FetchResultSubClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)FetchResultSubClass
{
   return objc_getAssociatedObject(self, &ResultSubClass);
}
@end
