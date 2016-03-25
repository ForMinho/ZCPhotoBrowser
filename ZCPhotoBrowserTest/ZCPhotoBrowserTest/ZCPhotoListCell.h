//
//  ZCPhotoListCell.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCPhoto.h"
@interface ZCPhotoListCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, strong) PHAsset *cellAsset;
- (void)updatePhotoOnCell;
@end

