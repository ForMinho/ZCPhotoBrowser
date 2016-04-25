//
//  ZCScrollView.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/6.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ZCScrollView : UIScrollView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) ZCPhoto *photo;
@property (nonatomic, weak) ZCPhotoViewController *photoBrowser;
- (void)startLoadingImage;
- (void)cancleLoadingImage;
- (void)setMaxMinZoomScalesForImage;
@end
