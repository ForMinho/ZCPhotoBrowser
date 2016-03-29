//
//  ZCPhotoListCell.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoListCell.h"

@implementation ZCPhotoListCell

-(void)setCellAsset:(PHAsset *)cellAsset
{
    _cellAsset = cellAsset;
}
- (void)updatePhotoOnCellWithImageSize:(CGSize)imageSize content:(PHImageContentMode)contentMode CompleteHandeler:(ZCImageManagerCompletionBlock) handler
{
    [self.image zc_setImageWithAsset:self.cellAsset ImageSize:imageSize contentMode:contentMode completedHandler:^(UIImage *image,NSDictionary *info)
    {
        if (handler) {
            handler(image,info);
        }
    }];
}
@end
