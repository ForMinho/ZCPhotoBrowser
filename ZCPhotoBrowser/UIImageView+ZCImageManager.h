//
//  UIImageView+ZCImageManager.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/25.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCPhoto.h"
@import Photos;
@interface UIImageView (ZCImageManager)
- (PHAsset *)zc_Asset;
- (void) zc_setImageWithAsset:(PHAsset *)asset;
- (void) zc_setImageWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize;
- (void) zc_setImageWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize contentMode:(PHImageContentMode)contentMode;
- (void) zc_setImageWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize contentMode:(PHImageContentMode)contentMode completedHandler:(ZCImageManagerCompletionBlock) handler;
@end
