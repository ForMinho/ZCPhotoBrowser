//
//  ZCPhoto.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/12.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCPhoto : NSObject
@property (nonatomic, assign) BOOL  isPhotoSelected;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSString *photoUrl;
+ (instancetype) photoWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize;
+ (instancetype) photowithUrlFromWeb:(NSString *)webUrl;
- (void)loadImageAndNotification;
- (void)cancelLoadImage;
- (UIImage *)photoImage;

@end
