//
//  ZCImageManager.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/25.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCImageManager.h"
@interface ZCImageManager()<PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSMutableArray *assetArray;
@property (nonatomic, strong) NSMutableArray *requestIdArray;
@end

static CGSize cachingImageSize;

@implementation ZCImageManager
+ (ZCImageManager *)sharedImageManager
{
    static ZCImageManager *imageManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        imageManager = [[ZCImageManager alloc] init];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:imageManager];
    });
    return imageManager;
}
- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
- (PHImageManager *)imageManager
{
    if (_imageManager == nil) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}
- (NSMutableArray *)requestIdArray
{
    if (_requestIdArray == nil) {
        _requestIdArray = [NSMutableArray array];
    }
    return _requestIdArray;
}
- (void)stopImageManager
{
    for (NSNumber *number in self.requestIdArray) {
        PHImageRequestID requestId = [number intValue];
        [self.imageManager cancelImageRequest:requestId];
    }
}
- (PHImageRequestID)requestImageWithAsset:(PHAsset *)asset
                                imageSize:(CGSize)imageSize
                              contentMode:(PHImageContentMode)contentMode
                                  options:(PHImageRequestOptions *)options
                          completeHandler:(ZCImageManagerCompletionBlock)completion;

{
    PHImageRequestID requestId = [self.imageManager requestImageForAsset:asset targetSize:imageSize contentMode:contentMode options:options resultHandler:^(UIImage *image,NSDictionary *info){
        if (completion) {
            completion(image,info);
        }
        [self.requestIdArray removeObject:@(requestId)];
    }];
    
    [self.requestIdArray addObject:@(requestId)];
    if (cachingImageSize.width != imageSize.width) {
        cachingImageSize = imageSize;
    }
    return requestId;
}
- (void)startCachingImage:(NSArray *)assets
{
    if (cachingImageSize.width <= 0 ) {
        cachingImageSize = CGSizeMake(160, 160);
    }
    if ([self stopCachingImageWithAssets:assets]) {
        return;
    }
    [self.imageManager startCachingImagesForAssets:assets targetSize:cachingImageSize contentMode:PHImageContentModeAspectFill options:nil];
}
- (void)stopCachingImage:(NSArray *)assets
{
//    if ([self stopCachingImageWithAssets:assets]) {
//        return;
//    }
    [self.imageManager stopCachingImagesForAssets:assets targetSize:cachingImageSize contentMode:PHImageContentModeAspectFill options:nil];
}
- (void)clearCachingImage
{
    [self.imageManager stopCachingImagesForAllAssets];
}
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self clearCachingImage];
}
- (PHImageRequestOptions *)options
{
    static PHImageRequestOptions *options;
    if (!options) {
        options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
    }

    return options;
}

- (BOOL)stopCachingImageWithAssets:(NSArray *)assets
{
    BOOL isStop = NO;
    for (PHAsset *asset in assets) {
        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoScreenshot || asset.mediaSubtypes == PHAssetMediaSubtypePhotoPanorama) {
            isStop = YES;
            break;
        }
    }
    return isStop;
}
@end
