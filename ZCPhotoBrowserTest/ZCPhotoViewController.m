//
//  ZCPhotoViewController.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/6.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoViewController.h"
#define Padding 10

#define ZCPhotoViewController_GetPhoto_Notification @"ZCPhotoViewController_GetPhoto_Notification"
#define ZCPhotoImage @"ZCPhotoImage"
#define ZCPhotoAsset @"ZCPhotoAsset"
#define ZCPhotoIndex @"ZCPhotoIndex"
@interface ZCPhotoViewController()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableSet *visibleArray;//image in window
@property (nonatomic, strong) NSMutableArray *photosArray;
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
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.frame = [self frameOfScrollView];
        self.scrollView.delegate = self;
        [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.bounds)*[self numberOfPhotosInBrowser], 0)];
        self.scrollView.pagingEnabled = YES;
        [self.scrollView setBackgroundColor:[UIColor grayColor]];
        [self.view addSubview:self.scrollView];

    }
    [self resetPhotosArray];
    
    _visibleArray = [[NSMutableSet alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhotoImageViewWithNotification:) name:ZCPhotoViewController_GetPhoto_Notification object:nil];
}
- (void)viewDidAppear:(BOOL)animated
{

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGPoint contentOffset = [self contentOffsetForPageAtIndex:_selectedIndex];
    [self.scrollView setContentOffset:contentOffset animated:NO];
    [self jumpImageToPageAtIndex:_selectedIndex WithAnimation:NO];
    [self preLoadPages];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
}
#pragma mark --- UI Update

- (void)jumpImageToPageAtIndex:(NSInteger)index WithAnimation:(BOOL)animation
{
    NSUInteger numberOfPhotos = [self numberOfPhotosInBrowser];
    if (!numberOfPhotos) {
        return;
    }
    NSInteger i;
    id tempObj;
    if (index > 0) {
        for (i = 0; i < index - 1; i ++) {
            tempObj = _photosArray[i];
            if (tempObj != [NSNull null]) {
                [(ZCPhoto *)tempObj cancelLoadImage];
                [_photosArray replaceObjectAtIndex:i withObject:tempObj];
            }
        }
    }
    if (index < numberOfPhotos - 1) {
        for (i = index + 2; i < numberOfPhotos; i ++) {
            tempObj = _photosArray[i];
            if (tempObj != [NSNull null]) {
                [(ZCPhoto *)tempObj cancelLoadImage];
                [_photosArray replaceObjectAtIndex:i withObject:tempObj];
            }
        }
    }
    
    ZCPhoto *photo = [self photoAtIndex:index];
    if ([photo photoImage] == nil) {
        [photo loadImageAndNotification];
    }
//    else
    {
        [self preloadPhotosIfNeed:index];
    }
}
- (ZCPhoto *)photoAtIndex:(NSInteger)index
{
    ZCPhoto *photo = nil;
    if (index >= 0 && index < [self numberOfPhotosInBrowser] - 1) {
        if (_photosArray[index] == [NSNull null]) {
            photo = [self.delegate photoBrowser:self atIndexPath:index];
            if (photo) {
                [_photosArray replaceObjectAtIndex:index withObject:photo];
            }
        }else
        {
            photo = _photosArray[index];
        }
    }
    return photo;
}
-(void)preloadPhotosIfNeed:(NSInteger)index
{
    if (index > 0) {
        ZCPhoto *photo = [self photoAtIndex:index - 1];
        if (![photo photoImage]) {
            [photo loadImageAndNotification];
        }
    }
    if (index < [self numberOfPhotosInBrowser] - 1) {
        ZCPhoto * photo = [self photoAtIndex:index + 1];
        if (![photo photoImage]) {
            [photo loadImageAndNotification];
        }
    }
}
- (void)updateImageViewWithImageView:(ZCScrollView *)imageView withImage:(UIImage *)image AtIndex:(NSUInteger) index
{
    if (!imageView) {
        imageView = [[ZCScrollView alloc] init];
    }
    [imageView setFrame:[self frameForPageAtIndex:index]];
    [imageView setImage:image];
    [self.scrollView addSubview:imageView];

}
- (CGRect)frameForPageAtIndex:(NSUInteger) index
{
    CGRect bounds = self.scrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * Padding);
    pageFrame.origin.x = (bounds.size.width * index) + Padding;
    return CGRectIntegral(pageFrame);
}
- (CGRect)frameOfScrollView
{
    CGRect boundsRect = self.view.bounds;
    boundsRect.origin.x -= Padding;
    boundsRect.size.width += (2 * Padding);
    return boundsRect;
}
- (CGPoint)contentOffsetForPageAtIndex:(NSInteger)index
{
    CGFloat pageWidth = self.scrollView.bounds.size.width;
    CGPoint offsetPoint = CGPointMake(pageWidth * index, 0);
    return offsetPoint;
}
- (void)configuePage:(ZCScrollView *)page AtIndex:(NSInteger)index
{
    page.frame = [self frameForPageAtIndex:index];
    page.photo = [_delegate photoBrowser:self atIndexPath:index];
    page.index = index;
}
#pragma mark -- data
- (NSInteger)numberOfPhotosInBrowser
{
    if (_delegate) {
       return [_delegate numberOfPhotosInBrowser:self];
    }
    return 0;
}
- (void)resetPhotosArray
{
    NSUInteger numberOfPhotos = [self numberOfPhotosInBrowser];
    if (!_photosArray) {
        _photosArray = [[NSMutableArray alloc] initWithCapacity:numberOfPhotos];
    }
    [_photosArray removeAllObjects];
    for (NSInteger i = 0; i < numberOfPhotos; i ++) {
        [_photosArray addObject:[NSNull null]];
    }
}
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    NSInteger numberOfPhotos = [self numberOfPhotosInBrowser];
    if (numberOfPhotos == 0) {
        selectedIndex = 0;
    }
    if (selectedIndex < 0) {
        selectedIndex = 0;
    }
    if (selectedIndex >= numberOfPhotos) {
        selectedIndex = numberOfPhotos - 1;
    }
    _selectedIndex = selectedIndex;
}

- (void)preLoadPages
{
    NSInteger numberOfPhotos = [self numberOfPhotosInBrowser];
    
    CGRect bounds = self.scrollView.bounds;
    NSInteger firstIndex = (NSInteger)floorf((CGRectGetMinX(bounds) + Padding * 2) / CGRectGetWidth(bounds)) - 1;
    NSInteger lastIndex = (NSInteger)floorf((CGRectGetMaxX(bounds) - Padding * 2 - 1) / CGRectGetWidth(bounds))  + 1;
    
    if (firstIndex <= 0) {
        firstIndex = 0;
    }
    if (firstIndex >= numberOfPhotos - 1) {
        firstIndex = numberOfPhotos - 1;
    }
    if (lastIndex <= 0) {
        lastIndex = 0;
    }
    if (lastIndex >= numberOfPhotos - 1) {
        lastIndex = numberOfPhotos - 1;
    }
    NSMutableSet *removeSet = [[NSMutableSet alloc] init];;
    for(ZCScrollView *tempView in _visibleArray) {
        NSInteger tempIndex = tempView.index;
        if (tempIndex < firstIndex || tempIndex > lastIndex) {
            [removeSet addObject:tempView];
            [tempView removeFromSuperview];
        }
    }
    [_visibleArray minusSet:removeSet];
    
    NSInteger i;

    for (i = firstIndex; i <= lastIndex; i ++) {
        if (![self isDisplayingPageAtIndex:i]) {
            ZCScrollView *page = [[ZCScrollView alloc] init];
            [self configuePage:page AtIndex:i];
            [self.scrollView addSubview:page];
            [_visibleArray addObject:page];
        }
    }
    
}
- (BOOL)isDisplayingPageAtIndex:(NSInteger)index
{
    BOOL isDisplaying = NO;
    for (ZCScrollView *tempView in _visibleArray) {
        if (tempView.index == index) {
            isDisplaying = YES;
            break;
        }
    }
    return isDisplaying;
}
#pragma mark -- UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self preLoadPages];
    
    CGRect visbleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(CGRectGetMidX(visbleBounds) / CGRectGetWidth(visbleBounds));
    if (index < 0) {
        index = 0;
    }
    if (index > [self numberOfPhotosInBrowser]) {
        index = [self numberOfPhotosInBrowser];
    }
    NSInteger previousCurrentIndex = _selectedIndex;
    _selectedIndex = index;
    if (_selectedIndex != previousCurrentIndex) {
        [self jumpImageToPageAtIndex:_selectedIndex WithAnimation:YES];
    }
}
@end
