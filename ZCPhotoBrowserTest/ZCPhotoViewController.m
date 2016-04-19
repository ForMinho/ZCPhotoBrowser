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
{
    BOOL _isViewActive ;
    CGRect _previousLayoutBounds ;
    
    BOOL _performingLaout;
    BOOL _skipNextPageingScrollViewPositioning;
    BOOL _willLayoutSubviews;
    
    BOOL _isVCBasedStatusBarAppearance;
    BOOL _statusBarShouldBeHidden;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableSet *visibleArray;//image in window
@property (nonatomic, strong) NSMutableArray *photosArray;
@end

@implementation ZCPhotoViewController

#pragma mark -- ui

+ (instancetype)sharedZCPhotoViewController
{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Photo" bundle:nil];
    ZCPhotoViewController *photoViewCon = [storybord instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return photoViewCon;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@" -------- %@",NSStringFromSelector(_cmd));
    }
    return self;
}
- (void)viewDidLoad
{
    [self _initialisation];
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.frame = [self frameOfScrollView];
        self.scrollView.delegate = self;
        [self.scrollView setContentSize:[self contentSizeOfScrollView]];
        self.scrollView.pagingEnabled = YES;
        [self.scrollView setBackgroundColor:[UIColor redColor]];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.scrollView];

    }

    [self reloadData];
    [super viewDidLoad];
}

- (void)_initialisation
{
    self.view.clipsToBounds = YES;
    
    NSNumber *isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIVIewControllerBasedStatusBarAppearance"];
    if (isVCBasedStatusBarAppearanceNum) {
        _isVCBasedStatusBarAppearance = isVCBasedStatusBarAppearanceNum.boolValue;
    }else
    {
        _isVCBasedStatusBarAppearance = YES;
    }
    
    _previousLayoutBounds = CGRectZero;
    _performingLaout = NO;
    _skipNextPageingScrollViewPositioning = YES;
    _willLayoutSubviews = NO;
//    self.navigationController.navigationBar.translucent = YES;
    _visibleArray = [[NSMutableSet alloc] init];
    _isViewActive = NO;
    _statusBarShouldBeHidden = NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    _isViewActive = YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self jumpImageToPageAtIndex:_selectedIndex WithAnimation:NO];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)reloadData
{
    if (!_visibleArray) {
        _visibleArray = [[NSMutableSet alloc] init];
    }
    [_visibleArray removeAllObjects];
    
    [self resetPhotosArray];
    if ([self isViewLoaded])
    {
        _performingLaout = YES;
        [self.scrollView setContentOffset:[self contentOffsetForPageAtIndex:_selectedIndex]];
        [self preLoadPages];
        _performingLaout = NO;
        [self.view setNeedsLayout];
    }
}
#pragma mark --- layout
- (void)viewWillLayoutSubviews
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [super viewWillLayoutSubviews];
    if (!_willLayoutSubviews) {
        [self layoutVisiblePages];
        _willLayoutSubviews = YES;
    }
}

- (void)layoutVisiblePages
{
    _performingLaout = YES;
    
    NSUInteger pageIndex = _selectedIndex;
    
    CGRect scrollViewFrame = [self frameOfScrollView];
    if (!_skipNextPageingScrollViewPositioning) {
        _scrollView.frame = scrollViewFrame;
    }
    _skipNextPageingScrollViewPositioning = NO;

    _scrollView.contentSize =[self contentSizeOfScrollView];
    for (ZCScrollView *page in _visibleArray) {
        NSUInteger index = page.index;
        page.frame = [self frameForPageAtIndex:index];
        if (!CGRectEqualToRect(_previousLayoutBounds, self.view.bounds)) {
            [page setMaxMinZoomScalesForImage];
            _previousLayoutBounds = self.view.bounds;
        }
    }
    
//    self.scrollView.contentOffset = [self contentOffsetForPageAtIndex:pageIndex];
//    [self didStartPagingViewAtIndex:_selectedIndex];
    _selectedIndex = pageIndex;
    _performingLaout = NO;
}
#pragma mark -- controls
- (BOOL)prefersStatusBarHidden
{
    return _statusBarShouldBeHidden;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (![self numberOfPhotosInBrowser]) {
        hidden = NO;
    }
    CGFloat animationOffset = 20;
    CGFloat animationDuration = animated? 0.35f:0;
    
    
    if (!_isVCBasedStatusBarAppearance) {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated?UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
    }else {
        [UIView animateWithDuration:animationDuration animations:^{
            _statusBarShouldBeHidden = hidden;
            [self setNeedsStatusBarAppearanceUpdate];
        }completion:^(BOOL finished){
            
        }];
    }
    
//    if (!hidden && animated) {
//     
//        for (ZCScrollView *page in _visibleArray) {
//            
//        }
//    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGFloat alpha = hidden ? 0 : 1;
        [self.navigationController.navigationBar setAlpha:alpha];
    }completion:^(BOOL finished){
        
    }];
}

#pragma mark ---  pages

- (void)preLoadPages
{
    NSInteger numberOfPhotos = [self numberOfPhotosInBrowser];
    
    CGRect bounds = self.scrollView.bounds;
    NSInteger firstIndex = (NSInteger)floorf((CGRectGetMinX(bounds) + Padding * 2) / CGRectGetWidth(bounds)) ;
    NSInteger lastIndex = (NSInteger)floorf((CGRectGetMaxX(bounds) - Padding * 2 - 1) / CGRectGetWidth(bounds)) ;
    
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

- (void)jumpImageToPageAtIndex:(NSInteger)index WithAnimation:(BOOL)animation
{
    if (index < [self numberOfPhotosInBrowser]) {
        CGPoint contentOffset = [self contentOffsetForPageAtIndex:index];
        [self.scrollView setContentOffset:contentOffset animated:NO];
    }
}
- (void)didStartPagingViewAtIndex:(NSUInteger)index
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
    [self preloadPhotosIfNeed:index];

}
- (void)configuePage:(ZCScrollView *)page AtIndex:(NSInteger)index
{
    page.frame = [self frameForPageAtIndex:index];
    page.photo = [_delegate photoBrowser:self atIndexPath:index];
    page.index = index;
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

#pragma mark --- photos
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


#pragma mark -- frame & size
- (CGRect)frameForPageAtIndex:(NSUInteger) index
{
    CGRect bounds = self.scrollView.bounds;
    CGRect pageFrame = bounds;
//    pageFrame.origin.y = 0;
    pageFrame.size.width -= (2 * Padding);
    pageFrame.origin.x = (bounds.size.width * index) + Padding;
    return CGRectIntegral(pageFrame);
}
- (CGRect)frameOfScrollView
{
    CGRect boundsRect = [[UIScreen mainScreen] bounds];//self.view.bounds;
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
- (CGSize)contentSizeOfScrollView
{
    CGSize contentSize ;
    CGRect scrollViewFrame = self.scrollView.bounds;//[self frameOfScrollView];
    
    contentSize = CGSizeMake(scrollViewFrame.size.width * [self numberOfPhotosInBrowser], scrollViewFrame.size.height);//scrollViewFrame.size.height);
    return contentSize;
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
    
    if ([self isViewLoaded]) {
        [self jumpImageToPageAtIndex:_selectedIndex WithAnimation:NO];
        if (_isViewActive) {
            [self preLoadPages];
        }
    }
}
#pragma mark -- UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isViewActive || _performingLaout) {
        return;
    }
    [self preLoadPages];
    
    CGRect visbleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(CGRectGetMidX(visbleBounds) / CGRectGetWidth(visbleBounds));
    index = MIN(MAX(index, 0), [self numberOfPhotosInBrowser] - 1);
    NSInteger previousCurrentIndex = _selectedIndex;
    _selectedIndex = index;
    if (_selectedIndex != previousCurrentIndex) {
        [self didStartPagingViewAtIndex:index];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setControlsHidden:YES animated:YES];
}
@end
