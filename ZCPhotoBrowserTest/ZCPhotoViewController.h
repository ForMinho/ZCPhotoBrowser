//
//  ZCPhotoViewController.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/6.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZCPhotoViewController;
@protocol ZCPhotoViewControllerDelegate <NSObject>



@end

@interface ZCPhotoViewController : UIViewController
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, assign) NSInteger selectedIndex;
+ (instancetype)sharedZCPhotoViewController;
@end
