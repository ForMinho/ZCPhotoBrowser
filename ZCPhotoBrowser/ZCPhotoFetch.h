//
//  ZCPhotoFetch.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCPhotoKit.h"
@interface ZCPhotoFetch : PHFetchResult
@property (nonatomic, strong) PHFetchResult *allPhotos;//返回所有照片合集
@property (nonatomic, strong) PHFetchResult *albumCollection;// 用户自定义照片存储集合
@property (nonatomic, strong) PHFetchResult *smartAlbumCollection;//智能相册集合

+ (instancetype) sharedPhotoFetch;

@end
