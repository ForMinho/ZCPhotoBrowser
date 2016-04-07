//
//  ZCPhotoViewController.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/6.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoViewController.h"
@interface ZCPhotoViewController()
@property (nonatomic,strong) IBOutlet ZCScrollView *scrollView;
@end

@implementation ZCPhotoViewController
+ (instancetype)sharedZCPhotoViewController
{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Photo" bundle:nil];
    ZCPhotoViewController *photoViewCon = [storybord instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return photoViewCon;
}
- (void)viewDidLoad
{
    self.navigationController.navigationBar.translucent = NO;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
}
- (void)updateScrollViews
{
    BOOL isViewDidLoad = [self isViewLoaded] && [[self view]window];
    if (!isViewDidLoad) {
        return;
    }
}
@end
