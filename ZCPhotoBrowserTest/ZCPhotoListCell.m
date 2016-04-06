//
//  ZCPhotoListCell.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoListCell.h"
@interface ZCPhotoListCell ()
@property (assign,nonatomic) PHImageRequestID requestID;
@end
@implementation ZCPhotoListCell
- (void)updatePhotoOnCellWithImageSize:(CGSize)imageSize content:(PHImageContentMode)contentMode CompleteHandeler:(ZCImageManagerCompletionBlock) handler
{
    __weak ZCPhotoListCell *weakSelf = self;
    CGSize size = imageSize;
//    if ((self.cellAsset.pixelHeight / self.cellAsset.pixelWidth ) > 4) {
//        CGFloat scale = [UIScreen mainScreen].scale;
//        size = CGSizeMake(size.width/scale, size.height/2);
//    }
    _requestID = [[ZCImageManager sharedImageManager] requestImageWithAsset:self.cellAsset imageSize:size contentMode:PHImageContentModeAspectFill options:nil completeHandler:^(PHAsset *asset,UIImage *image ,NSDictionary *dic)
     {
         if ([weakSelf.cellAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
             weakSelf.image.image = image;
         }
     }];
}
- (void)cancelLoadImage
{
    [[ZCImageManager sharedImageManager] cancelLoadImage:self.requestID];
    self.cellAsset = nil;
    self.localIdentifier = nil;
    self.image.image = nil;
}
@end
