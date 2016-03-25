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
@end
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

- (PHImageManager *)imageManager
{
    if (_imageManager == nil) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
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
    }];
    [self.imageManager startCachingImagesForAssets:@[asset] targetSize:imageSize contentMode:contentMode options:options];
    return requestId;
}

////- (void)startCachingImage:(NSArray *)assetArray WithSize:()
//{
//    self.imageManager startCachingImagesForAssets:assetArray targetSize:<#(CGSize)#> contentMode:<#(PHImageContentMode)#> options:<#(nullable PHImageRequestOptions *)#>
//}
@end
