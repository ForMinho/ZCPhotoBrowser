//
//  ZCScrollView.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/6.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCScrollView.h"

@interface ZCScrollView()<UIScrollViewDelegate,ZCTapDetectingImageViewDelegate,ZCTapDetectingViewDelegate>

@property (nonatomic,strong) ZCTapDetectingImageView *photoView;
@property (nonatomic, strong)ZCTapDetecingView *bgTapView;

@end
@implementation ZCScrollView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialisation];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialisation];
    }
    return self;
}
- (void)initialisation
{
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setImageWithNotification:) name:ZCPhoto_Loaded_Successed object:nil];
    
    CGRect frame = self.bounds;
    frame.origin.x = frame.origin.y = 0;
    _bgTapView = [[ZCTapDetecingView alloc] initWithFrame:frame];
    _bgTapView.backgroundColor = [UIColor blackColor];
    _bgTapView.delegate = self;
    [self addSubview:_bgTapView];
    
    _photoView = [[ZCTapDetectingImageView alloc] init];
    _photoView.delegate = self;
    _photoView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_photoView];

    frame.origin = CGPointZero;
    frame.size.width = frame.size.height = 44;
    _selectedButton = [[UIButton alloc] initWithFrame:frame];
    [_selectedButton setImage:[UIImage imageNamed:@"ImageSelectedOff"] forState:UIControlStateNormal];
    [_selectedButton setImage:[UIImage imageNamed:@"ImageSelectedOn"] forState:UIControlStateSelected];
    [_selectedButton addTarget:self action:@selector(changePhotoImageSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectedButton];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZCPhoto_Loaded_Successed object:nil];
}
- (void)setImage:(UIImage *)image
{
    _image = image;
    if ((_image.size.width < self.frame.size.width) && (image.size.height < self.frame.size.height)) {
        return;
    }
    [self displayImage];
}
- (void) setPhoto:(id)photo
{
    if (_photo == photo) {
        return;
    }
    _photo = photo;
    [self startLoadingImage];
    _selectedButton.selected = _photo.isPhotoSelected;
}
- (void)displayImage
{
    if (_image) {
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 1;
        self.zoomScale = 1;
        self.contentSize = CGSizeMake(0, 0);
        
        _photoView.image = _image;
        
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = _image.size;
        _photoView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        [self setMaxMinZoomScalesForImage];
    }
    [self setNeedsDisplay];
}
- (void)setMaxMinZoomScalesForImage
{
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 1;
    self.zoomScale = 1;
    
    if (_photoView.image == nil) {
        return;
    }
    _photoView.frame = CGRectMake(0, 0, _photoView.frame.size.width, _photoView.frame.size.height);
    
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoView.image.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    CGFloat maxScale = 3;
    if (xScale >= 1 && yScale >=1 ) {
        minScale = 1;
    }
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = maxScale;
    self.zoomScale = [self initZoomScaleWithMinScale];
    if (self.zoomScale != minScale) {
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2, (imageSize.height * self.zoomScale - boundsSize.height) / 2);
    }
    
    self.scrollEnabled = NO;
    [self setNeedsDisplay];
    
}
- (CGFloat)initZoomScaleWithMinScale
{
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoView) {
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;
        CGFloat yScale = boundsSize.height / imageSize.height;
        
        if (fabs(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            zoomScale = MIN(MAX(self.minimumZoomScale,zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize boundsSize = self.bounds.size;
    _bgTapView.frame = self.bounds;
    CGRect frameToCenter = _photoView.frame;
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2);
    }else
    {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2);
    }else{
        frameToCenter.origin.y = 0;
    }
    if (!CGRectEqualToRect(_photoView.frame, frameToCenter)) {
        _photoView.frame = frameToCenter;
    }
    
}
#pragma mark -- ScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _photoView;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.scrollEnabled = YES;
    [_photoBrowser cancleControlHiding];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_photoBrowser hideControlsAfterDelay];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

#pragma  mark --
- (void)setImageWithNotification:(NSNotification *)notification
{
    ZCPhoto *objectPhoto = notification.object;
    if (objectPhoto == _photo) {
        if ([objectPhoto photoImage]) {
            self.image = [objectPhoto photoImage];
        }
    }
}
- (void)startLoadingImage
{
    [_photo loadImageAndNotification];
}
- (void)cancleLoadingImage
{
    [_photo cancelLoadImage];
}

#pragma mark -- TapDelegate
- (void)handleSingleTap:(CGPoint)touchPoint
{
    [_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2f];
}
- (void)handleDoubleTap:(CGPoint)touchPoint
{
    [NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale !=[self initZoomScaleWithMinScale]) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }else
    {
        CGFloat newZoomScale = (self.minimumZoomScale + self.maximumZoomScale) / 2;
        CGFloat xSize = self.bounds.size.width / newZoomScale;
        CGFloat ySize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake((touchPoint.x - xSize / 2), (touchPoint.y - ySize / 2), xSize, ySize) animated:YES];
    }
    [_photoBrowser hideControlsAfterDelay];
}

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch
{
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch
{
    [self handleDoubleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch
{
    
}
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch
{
    [self handleSingleTap:[touch locationInView:view]];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch
{
    
}
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch
{
    
}

#pragma mark -- button Delegate
- (void)changePhotoImageSelected
{
    _selectedButton.selected = !_selectedButton.selected;
    _photo.isPhotoSelected = _selectedButton.selected;
    [self.photoBrowser photoSelectedWithPhoto:_photo atIndex:self.index];
}
@end
