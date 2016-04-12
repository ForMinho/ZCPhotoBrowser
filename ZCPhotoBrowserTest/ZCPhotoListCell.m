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

- (void)updatePhotoCellWithPhoto:(ZCPhoto*)photo WithImageSize:(CGSize)imageSize
{
//    [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(photoImageWithNotification:) name:ZCPhoto_Loaded_Successed object:nil];
    self.photo = photo;
    [photo loadImageAndNotification];
}

- (void)photoImageWithNotification:(NSNotification *)notification
{
    ZCPhoto *objPhoto = notification.object;
    if (objPhoto == _photo) {
        self.image.image = [objPhoto photoImage];
    }
}

- (void)updatePhotoOnCellWithImageSize:(CGSize)imageSize content:(PHImageContentMode)contentMode CompleteHandeler:(ZCImageManagerCompletionBlock) handler
{
    __weak ZCPhotoListCell *weakSelf = self;
    CGSize size = imageSize;

    _requestID = [[ZCImageManager sharedImageManager] requestImageWithAsset:self.cellAsset imageSize:size contentMode:PHImageContentModeAspectFill options:nil completeHandler:^(PHAsset *asset,UIImage *image ,NSDictionary *dic)
     {
         if ([weakSelf.cellAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
             weakSelf.image.image = image;
         }
     }];
}
- (void)cancelLoadImage
{
    
    [self.photo cancelLoadImage];
}


@end
