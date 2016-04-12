//
//  PHFetchResult+ZCPhotoFetch.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <Photos/Photos.h>
#import "ZCPhotoKit.h"
@interface PHFetchResult (ZCPhotoFetch)
@property (nonatomic,strong) NSString *FetchResultSubClass;//tag，方便之后获取集合数据方便
@end
