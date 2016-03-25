//
//  UIImageView+ZCImageManager.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/25.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;
@interface UIImageView (ZCImageManager)
- (void) zc_setImageWithAsset:(PHAsset *)asset;
@end
