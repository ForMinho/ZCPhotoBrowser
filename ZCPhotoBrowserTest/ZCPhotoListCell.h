//
//  ZCPhotoListCell.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCPhoto.h"
//typedef void (^ZCPhotoListCellCompletedHandler)(UIImage *image,NSDictionary *info,NSIndexPath *path);
@interface ZCPhotoListCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, strong) PHAsset *cellAsset;
//@property (nonatomic, strong) NSIndexPath *cellIndexPath;
@property (nonatomic, copy) NSString *localIdentifier;
- (void)updatePhotoOnCellWithImageSize:(CGSize)imageSize content:(PHImageContentMode)contentMode CompleteHandeler:(ZCImageManagerCompletionBlock) handler;
@end
