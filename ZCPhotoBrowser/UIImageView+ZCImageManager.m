//
//  UIImageView+ZCImageManager.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/25.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "UIImageView+ZCImageManager.h"
#import <objc/runtime.h>
static char ZCImageAsset;

@implementation UIImageView (ZCImageManager)

- (PHAsset *)zc_Asset
{
    return objc_getAssociatedObject(self, &ZCImageAsset);
}
- (void) zc_setImageWithAsset:(PHAsset *)asset
{
    [self zc_setImageWithAsset:asset ImageSize:[self defaultImageSize] contentMode:PHImageContentModeAspectFill completedHandler:nil];
}
- (void) zc_setImageWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize
{
    [self zc_setImageWithAsset:asset ImageSize:imageSize contentMode:PHImageContentModeAspectFill completedHandler:nil];
}
- (void) zc_setImageWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize contentMode:(PHImageContentMode)contentMode
{
    [self zc_setImageWithAsset:asset ImageSize:imageSize contentMode:contentMode completedHandler:nil];
}
- (void) zc_setImageWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize contentMode:(PHImageContentMode)contentMode completedHandler:(ZCImageManagerCompletionBlock)handler
{
    
    if (!asset) {
        return;
    }
    objc_setAssociatedObject(self, &ZCImageAsset, asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoScreenshot || asset.mediaSubtypes == PHAssetMediaSubtypePhotoPanorama) {
        imageSize = CGSizeMake(imageSize.width / 2, imageSize.height / 2);
    }

    dispatch_async(ZCImageManager_Image_Queue, ^{
        [[ZCImageManager sharedImageManager] requestImageWithAsset:asset imageSize:imageSize contentMode:contentMode options:nil completeHandler:^(UIImage *image,NSDictionary *info)
         {
             if ([[[self zc_Asset] localIdentifier] isEqualToString:asset.localIdentifier]) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.image = image;
                     self.contentMode = UIViewContentModeScaleAspectFill;
                     if (handler) {
                         handler(image,info);
                     }
  
                 });
             }
         }];

    });
    /*
    dispatch_async(ZCImageManager_Image_Queue, ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        
        [[ZCImageManager sharedImageManager] requestImageWithAsset:asset
                                                         imageSize:imageSize
                                                       contentMode:contentMode
                                                           options:options
                                                   completeHandler:^(UIImage *image,NSDictionary *info)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([[[self zc_Asset] localIdentifier] isEqualToString:asset.localIdentifier]) {
                     self.image = image;
                     self.contentMode = UIViewContentModeScaleAspectFill;
                     if (handler) {
                         handler(image,info);
                     }

                 }
             });
             
         }];

    });
     */
    
}

- (CGSize)defaultImageSize
{
    static CGSize imageSize;
    if (!imageSize.width || !imageSize.height) {
        CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]) / 4 ;
        CGFloat scale = [UIScreen mainScreen].scale;
        imageSize = CGSizeMake(width * scale, width * scale);
    }
    return imageSize;
}
@end
