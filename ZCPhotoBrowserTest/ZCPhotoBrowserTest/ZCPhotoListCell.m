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
    [self updatePhotoOnCell];
}
- (void)updatePhotoOnCell
{
    [self.image zc_setImageWithAsset:self.cellAsset];

}
@end
