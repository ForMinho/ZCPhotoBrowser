//
//  ZCPhotoListCell.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCPhotoKit.h"
@interface ZCPhotoListCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, strong) PHAsset *cellAsset;
@property (nonatomic, copy) NSString *localIdentifier;

@property (nonatomic, strong) ZCPhoto *photo;

- (void)updatePhotoOnCellWithImageSize:(CGSize)imageSize content:(PHImageContentMode)contentMode CompleteHandeler:(ZCImageManagerCompletionBlock) handler;
- (void)cancelLoadImage;
//

- (void)updatePhotoCellWithPhoto:(ZCPhoto*)photo WithImageSize:(CGSize)imageSize;
@end

