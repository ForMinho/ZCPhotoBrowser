//
//  ZCPhotoListCell.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCPhotoKit.h"
typedef void(^ZCPhotoSelectedHandle)(ZCPhoto *photo,BOOL isSelected);
@interface ZCPhotoListCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UIButton *selectedBtn;

@property (nonatomic, strong) ZCPhoto *photo;

- (void)updatePhotoCellWithPhoto:(ZCPhoto*)photo WithImageSize:(CGSize)imageSize withPhotoSelectedHandle:(ZCPhotoSelectedHandle)selectedHandle;
- (IBAction)selectedBtnClicked:(id)sender;
@end

