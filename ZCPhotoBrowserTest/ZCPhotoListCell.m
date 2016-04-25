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
@property (nonatomic, strong) ZCPhotoSelectedHandle selectedHandle;
@end
@implementation ZCPhotoListCell
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadImageSuccessedWithNotification:) name:ZCPhoto_Loaded_Successed object:nil];
}
- (void)updatePhotoCellWithPhoto:(ZCPhoto*)photo WithImageSize:(CGSize)imageSize withPhotoSelectedHandle:(ZCPhotoSelectedHandle)selectedHandle{
    self.photo = photo;
    _selectedHandle = selectedHandle;
}
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
- (IBAction)selectedBtnClicked:(id)sender
{
    _photo.isPhotoSelected = !_photo.isPhotoSelected;
    _selectedBtn.selected = _photo.isPhotoSelected;
    if (_selectedHandle) {
        _selectedHandle(_photo,_photo.isPhotoSelected);
    }
}
@end
