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
    BOOL _leaveStatusBarAlone;
    BOOL _statusBarShouldBeHidden;
    BOOL _viewHasAppearedInitially;
    
    
    BOOL _controlsHidden;
    NSTimer *_controlVisibilityTimer;
    
    
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationbarBackgroundImageLandscapePhone;

}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableSet *visibleArray;//image in window
@property (nonatomic, strong) NSMutableArray *photosArray;
@property (nonatomic, assign) NSInteger delayToHideElements;
@end

@implementation ZCPhotoViewController

#pragma mark -- ui

+ (instancetype)sharedZCPhotoViewController
{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Photo" bundle:nil];
    ZCPhotoViewController *photoViewCon = [storybord instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    [photoViewCon _initialisation];
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
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor blackColor];

    CGRect pagingScrollViewFrame = [self frameOfScrollView];
    self.scrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor  = [UIColor blackColor];
    self.scrollView.contentSize = [self contentSizeOfScrollView];
    [self.view addSubview:self.scrollView];


    [self reloadData];
    [super viewDidLoad];
}

- (void)_initialisation
{
    NSNumber *isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIVIewControllerBasedStatusBarAppearance"];
    if (isVCBasedStatusBarAppearanceNum) {
        _isVCBasedStatusBarAppearance = isVCBasedStatusBarAppearanceNum.boolValue;
    }else
    {
        _isVCBasedStatusBarAppearance = YES;
    }
    self.hidesBottomBarWhenPushed = YES;
    _previousLayoutBounds = CGRectZero;
    _performingLaout = NO;
    _skipNextPageingScrollViewPositioning = YES;
    _willLayoutSubviews = NO;
    self.navigationController.navigationBar.translucent = YES;
    _visibleArray = [[NSMutableSet alloc] init];
    _isViewActive = NO;
    _statusBarShouldBeHidden = NO;
    _delayToHideElements = 5.f;
    _controlsHidden = NO;
    _didSavePreviousStateOfNavBar = NO;
    _autoHideControls = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    _isViewActive = YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_viewHasAppearedInitially) {
        _leaveStatusBarAlone = [self presentingVIewCOntrollerPrefersStatusBarHidden];
        if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
            _leaveStatusBarAlone = YES;
        }
    }
    
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    if (!_isViewActive && [self.navigationController.viewControllers objectAtIndex:0]!=self) {
        [self storePreviousNavBarAppearance];
    }
    
    [self setNavBarAppearance:animated];
    [self hideControlsAfterDelay];
    [self jumpImageToPageAtIndex:_selectedIndex WithAnimation:NO];

}
- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers objectAtIndex:0]!=self && ![self.navigationController.viewControllers containsObject:self]) {
        _isViewActive = NO;
        [self restorePreviousNavBarAppearance:animated];
    }
    [self.navigationController.navigationBar.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setControlsHidden:NO animated:NO];
    
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZCPhotoCollection_Selected_Photo object:@(_selectedIndex)];
    [super viewWillDisappear:animated];
}


- (BOOL)presentingVIewCOntrollerPrefersStatusBarHidden
{
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        if ([presenting isKindOfClass:[UINavigationController class]]) {
            presenting = [(UINavigationController *)presenting topViewController];
        }
    }else{
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            presenting = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        }
    }
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    }else{
        return NO;
    }
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
        while (_scrollView.subviews.count) {
            [[[_scrollView subviews]lastObject] removeFromSuperview];
        }
        [self performLayout];
        [self.view setNeedsLayout];
    }
}
- (void)performLayout
{
    _performingLaout = YES;
    [_visibleArray removeAllObjects];
    _scrollView.contentOffset = [self contentOffsetForPageAtIndex:_selectedIndex];
    [self preLoadPages];
    _performingLaout = NO;
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
    _selectedIndex = pageIndex;
    _performingLaout = NO;
}
#pragma mark -- controls showing/Hiding
- (BOOL)prefersStatusBarHidden
{
    if (!_leaveStatusBarAlone) {
        return _statusBarShouldBeHidden;
    }else{
        return [self presentingVIewCOntrollerPrefersStatusBarHidden];
    }
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
    if (![self numberOfPhotosInBrowser] || !_autoHideControls) {
        hidden = NO;
    }
    [self cancleControlHiding];
//    CGFloat animationOffset = 20;
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
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGFloat alpha = hidden ? 0 : 1;
        _controlsHidden = hidden;
        [self.navigationController.navigationBar setAlpha:alpha];
        
        for (ZCScrollView *page in _visibleArray) {
            if (page.selectedButton) {
                UIButton *v = page.selectedButton;
                CGRect newFrame = [self frameForPageSelectedButton:v atIndex:page.index];
                v.frame = newFrame;
            }
        }
        
        
    }completion:^(BOOL finished){
        
    }];
}

- (void)cancleControlHiding
{
    if (_controlVisibilityTimer) {
        [_controlVisibilityTimer invalidate];
        _controlVisibilityTimer = nil;
    }
}
- (void)hideControlsAfterDelay
{
    if (!_controlsHidden) {
        [self cancleControlHiding];
        _controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:_delayToHideElements target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
    }
}
- (void)showControls
{
    [self setControlsHidden:NO animated:YES];
}
- (void)hideControls
{
    [self setControlsHidden:YES animated:YES];
}
- (void)toggleControls
{
    [self setControlsHidden:!_controlsHidden animated:YES];
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
            page.selectedButton.frame = [self frameForPageSelectedButton:page.selectedButton atIndex:i];
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
        [self updateNavigation];
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
    page.photoBrowser = self;
    
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
- (CGRect)frameOfScrollView
{
    CGRect boundsRect = self.view.bounds;
    boundsRect.origin.x -= Padding;
    boundsRect.size.width += (2 * Padding);
    return CGRectIntegral(boundsRect);
}
- (CGRect)frameForPageAtIndex:(NSUInteger) index
{
    CGRect bounds = _scrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * Padding);
    pageFrame.origin.x = (bounds.size.width * index) + Padding;
    return CGRectIntegral(pageFrame);
}
- (CGSize)contentSizeOfScrollView
{
    CGSize contentSize ;
    CGRect scrollViewFrame = self.scrollView.bounds;
    
    contentSize = CGSizeMake(scrollViewFrame.size.width * [self numberOfPhotosInBrowser], scrollViewFrame.size.height);
    return contentSize;
}

- (CGPoint)contentOffsetForPageAtIndex:(NSInteger)index
{
    CGFloat pageWidth = self.scrollView.bounds.size.width;
    CGPoint offsetPoint = CGPointMake(pageWidth * index, 0);
    return offsetPoint;
}
- (CGRect)frameForPageSelectedButton:(UIButton *)selectedButton atIndex:(NSUInteger)index
{
    CGRect pageFrame = [self frameForPageAtIndex:index];
    CGFloat padding = 20;
    CGFloat yOffset = 0;
    if (!_controlsHidden) {
        UINavigationBar *bar = self.navigationController.navigationBar;
        yOffset = bar.frame.origin.y + bar.frame.size.height;
    }
    CGRect selectedFrame = CGRectMake(pageFrame.size.width - CGRectGetWidth(selectedButton.frame) - padding, yOffset + padding, CGRectGetWidth(selectedButton.frame), CGRectGetHeight(selectedButton.frame));
    return CGRectIntegral(selectedFrame);
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
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateNavigation];
}
#pragma mark -- Nav Bar Appearance
- (void)setNavBarAppearance:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = nil;
    navBar.shadowImage = nil;
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
}
- (void)storePreviousNavBarAppearance
{
    _didSavePreviousStateOfNavBar = YES;
    _previousNavBarHidden = self.navigationController.navigationBar.hidden;
    _previousNavBarTranslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarBarTintColor = self.navigationController.navigationBar.barTintColor;
    _previousNavigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    _previousNavigationbarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone];
}
- (void)restorePreviousNavBarAppearance:(BOOL)animated
{
    if (_didSavePreviousStateOfNavBar) {
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.tintColor = _previousNavBarTintColor;
        navBar.translucent = _previousNavBarTranslucent;
        navBar.barTintColor = _previousNavBarBarTintColor;
        navBar.barStyle = _previousNavBarStyle;
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:_previousNavigationbarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsLandscapePhone];
    }
}
#pragma mark -- navigation
- (void)updateNavigation
{
    NSUInteger photoCount = [self numberOfPhotosInBrowser];
    if (photoCount > 1) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:titleForPhotoAtIndex:)]) {
            self.title = [_delegate photoBrowser:self titleForPhotoAtIndex:_selectedIndex];
        }else{
            self.title = [NSString stringWithFormat:@"%lu of %lu",(unsigned long)(_selectedIndex + 1),(unsigned long)photoCount];
        }
    }else
    {
        self.title = nil;
    }
}
#pragma mark -- selected Button 
- (void)photoSelectedWithPhoto:(ZCPhoto *)photo atIndex:(NSUInteger)index
{
    if (index < [self numberOfPhotosInBrowser] && [_delegate respondsToSelector:@selector(photoBrowser:selectedPhoto:AtIndex:)]) {
        [_delegate photoBrowser:self selectedPhoto:photo AtIndex:index];
    }

}
@end
