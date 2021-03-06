//
//  ZCImageManager.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/25.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCImageManager.h"
@interface ZCImageManager()
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
    });
    return imageManager;
}
- (void)dealloc
{
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
- (void)cancelLoadImage:(PHImageRequestID)requestId
{
    [self.imageManager cancelImageRequest:requestId];
}
- (void)stopImageManager
{
    for (NSNumber *number in self.requestIdArray) {
        PHImageRequestID requestId = [number intValue];
        [self cancelLoadImage:requestId];
    }
}
- (PHImageRequestID)requestImageWithAsset:(PHAsset *)asset
                                imageSize:(CGSize)imageSize
                              contentMode:(PHImageContentMode)contentMode
                                  options:(PHImageRequestOptions *)options
                          completeHandler:(ZCImageManagerCompletionBlock)completion;

{
    CGSize size = imageSize;
    if ((asset.pixelHeight / asset.pixelWidth ) > 4) {
        CGFloat scale = [UIScreen mainScreen].scale;
        size = CGSizeMake(size.width/scale, size.height/2);
    }

    PHImageRequestID requestId = [self.imageManager requestImageForAsset:asset targetSize:size contentMode:contentMode options:options resultHandler:^(UIImage *image,NSDictionary *info){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(asset,image,info);
            }else
            {
                NSMutableDictionary *imageInfo = [NSMutableDictionary dictionary];
                [imageInfo setObject:image forKey:ZCPhoto_Loaded_Successed_Image];
                [imageInfo setObject:asset forKey:ZCPhoto_Loaded_Successed_Asset];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZCPhoto_Loaded_Successed object:imageInfo];
            }
        });
    }];
    
    return requestId;
}
/*
- (void)startCachingImage:(NSArray *)assets
{
//    [self startCachingImage:assets WithSize:CGSizeMake(160, 160)];
}
- (void)startCachingImage:(NSArray *)assets WithSize:(CGSize)imageSize
{
    if (cachingImageSize.width != imageSize.width ) {
        cachingImageSize = imageSize;
    }
    if ([self stopCachingImageWithAssets:assets]) {
        return;
    }
    [self.imageManager startCachingImagesForAssets:assets targetSize:cachingImageSize contentMode:PHImageContentModeAspectFill options:nil];
}
- (void)stopCachingImage:(NSArray *)assets
{
    [self stopCachingImage:assets WithSize:cachingImageSize];
}

- (void) stopCachingImage:(NSArray *)assets WithSize:(CGSize)imageSize
{
    [self.imageManager stopCachingImagesForAssets:assets targetSize:imageSize contentMode:PHImageContentModeAspectFill options:nil];
}
*/
- (void)clearCachingImage
{
    [self.imageManager stopCachingImagesForAllAssets];
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
