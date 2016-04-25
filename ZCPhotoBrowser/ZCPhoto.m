//
//  ZCPhoto.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/12.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhoto.h"
@interface ZCPhoto()
@property (nonatomic, strong) UIImage *image;


@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end
@implementation ZCPhoto
#pragma mark --
+ (instancetype) photoWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize;
{
    return [[ZCPhoto alloc] initWithAsset:asset ImageSize:imageSize];
}

#pragma mark ---
- (id)initWithAsset:(PHAsset *)asset ImageSize:(CGSize)imageSize
{
    self = [super init];
    if (self) {
        self.asset = asset;
        if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
            imageSize.width = asset.pixelWidth;
            imageSize.height = asset.pixelHeight;
        }
        self.imageSize = imageSize;
        self.isPhotoSelected = NO;
    }
    return self;
}

#pragma mark -- loadAndNotification
- (void)loadingImageComplete
{
    NSAssert([[NSThread mainThread] isMainThread], @"This method must be on main thread");
    [[NSNotificationCenter defaultCenter] postNotificationName:ZCPhoto_Loaded_Successed object:self];
}
- (void)loadImageAndNotification;
{
    if (_image) {
        [self loadingImageComplete];
        return;
    }
    if (_asset) {
        __weak ZCPhoto *weakSelf = self;
      _imageRequestID = [[ZCImageManager sharedImageManager] requestImageWithAsset:_asset imageSize:_imageSize contentMode:PHImageContentModeAspectFill options:nil completeHandler:^(PHAsset *asset,UIImage *image,NSDictionary *info)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([asset.localIdentifier isEqualToString:_asset.localIdentifier]) {
                    weakSelf.image = image;
                    [weakSelf loadingImageComplete];
                }
            });
            
        }];
    }
}
- (void)cancelLoadImage;
{
    self.image = nil;
    if (_imageRequestID != PHInvalidImageRequestID) {
        [[ZCImageManager sharedImageManager] cancelLoadImage:_imageRequestID];
        _imageRequestID = PHInvalidImageRequestID;
    }
}
- (UIImage *)photoImage
{
    return _image? : nil;
}
@end
