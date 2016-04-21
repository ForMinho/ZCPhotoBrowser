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
@required
- (NSInteger)numberOfPhotosInBrowser:(ZCPhotoViewController *)photoController;
- (id)photoBrowser:(ZCPhotoViewController *)viewController atIndexPath:(NSInteger)index;

@optional
- (NSString *)photoBrowser:(ZCPhotoViewController *)viewController titleForPhotoAtIndex:(NSUInteger)index;
@end

@interface ZCPhotoViewController : UIViewController
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) id<ZCPhotoViewControllerDelegate> delegate;
+ (instancetype)sharedZCPhotoViewController;
- (void)cancleControlHiding;
- (void)hideControlsAfterDelay;
- (void)toggleControls;
@end
