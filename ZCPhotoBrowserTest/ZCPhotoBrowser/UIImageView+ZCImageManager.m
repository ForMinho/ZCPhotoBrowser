//
//  UIImageView+ZCImageManager.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/25.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "UIImageView+ZCImageManager.h"

@implementation UIImageView (ZCImageManager)
- (void) zc_setImageWithAsset:(PHAsset *)asset
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    [[ZCImageManager sharedImageManager] requestImageWithAsset:asset
                                                     imageSize:CGSizeMake(160, 160)
                                                   contentMode:PHImageContentModeAspectFill
                                                       options:nil
                                               completeHandler:^(UIImage *image,NSDictionary *info)
    {
        self.image = image;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }];
    
}

@end
