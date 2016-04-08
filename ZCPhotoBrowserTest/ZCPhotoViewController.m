//
//  ZCPhotoViewController.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/6.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoViewController.h"
#define Padding 10
@interface ZCPhotoViewController()<UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *visibleArray;//image in window
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
    self.scrollView.frame = [self frameOfScrollView];
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.bounds)*[self.delegate numberOfPhotosInBrowser:self], 0)];
    _visibleArray = [NSMutableArray array];
}
- (void)viewDidAppear:(BOOL)animated
{

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect pageFrame = [self frameForPageAtIndex:_selectedIndex];
    [self.scrollView setContentOffset:CGPointMake(pageFrame.origin.x - Padding, 0) animated:NO];
    [self jumpImageToPageAtIndex:_selectedIndex WithAnimation:NO];
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
#pragma mark --- UI Update

- (void)jumpImageToPageAtIndex:(NSInteger)index WithAnimation:(BOOL)animation
{
    CGSize imageSize = self.view.frame.size;
    PHAsset *imgAsset = (PHAsset *)[self.delegate photoBrowser:self atIndexPath:index];
    imageSize.width = imgAsset.pixelWidth;
    imageSize.height = imgAsset.pixelHeight;
    
    [[ZCImageManager sharedImageManager] requestImageWithAsset:imgAsset imageSize:imageSize contentMode:PHImageContentModeAspectFill options: nil completeHandler:^(PHAsset *asset , UIImage * image , NSDictionary *dic){
        if ([imgAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
            [self updateImageViewWithImageView:nil withImage:image AtIndex:index];
        }
    }];
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
#pragma mark -- data
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    NSInteger numberOfPhotos = [self.delegate numberOfPhotosInBrowser:self];
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

#pragma mark -- UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"__%@",NSStringFromSelector(_cmd));
    CGRect visbleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(CGRectGetMidX(visbleBounds) / CGRectGetWidth(visbleBounds));
    if (index < 0) {
        index = 0;
    }
    if (index > [self.delegate numberOfPhotosInBrowser:self]) {
        index = [self.delegate numberOfPhotosInBrowser:self];
    }
    NSInteger previousCurrentIndex = _selectedIndex;
    _selectedIndex = index;
    if (_selectedIndex != previousCurrentIndex) {
        [self jumpImageToPageAtIndex:_selectedIndex WithAnimation:YES];
    }
}
@end
