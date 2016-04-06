//
//  ZCImageManager.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/25.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;

typedef void(^ZCImageManagerCompletionBlock)(PHAsset *asset,UIImage *image,NSDictionary * info);
@interface ZCImageManager : NSObject
+ (ZCImageManager *)sharedImageManager;
- (PHImageRequestID)requestImageWithAsset:(PHAsset *)asset
                    imageSize:(CGSize)imageSize
                  contentMode:(PHImageContentMode)contentMode
                      options:(PHImageRequestOptions *)options
              completeHandler:(ZCImageManagerCompletionBlock)completion;
- (void)cancelLoadImage:(PHImageRequestID)requestId;
- (void)stopImageManager;
- (void)startCachingImage:(NSArray *)assets;
- (void)startCachingImage:(NSArray *)assets WithSize:(CGSize)imageSize;
- (void)stopCachingImage:(NSArray *)assets;
- (void)stopCachingImage:(NSArray *)assets WithSize:(CGSize)imageSize;

- (void)clearCachingImage;
@end

