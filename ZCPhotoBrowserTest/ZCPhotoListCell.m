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
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadImageSuccessedWithNotification:) name:ZCPhoto_Loaded_Successed object:nil];
}
- (void)updatePhotoCellWithPhoto:(ZCPhoto*)photo WithImageSize:(CGSize)imageSize
{
    self.photo = photo;
}
//- (void)cancelLoadImage
//{
//    [self.photo cancelLoadImage];
//}
- (void)loadImageSuccessedWithNotification:(NSNotification *)notification
{
    ZCPhoto *photo = notification.object;
    if (_photo == photo) {
        self.image.image = [photo photoImage];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZCPhoto_Loaded_Successed object:nil];
}
@end
