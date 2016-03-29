//
//  ZCImageManager.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/25.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;

typedef void(^ZCImageManagerCompletionBlock)(UIImage *image,NSDictionary * info);
@interface ZCImageManager : NSObject
+ (ZCImageManager *)sharedImageManager;
- (PHImageRequestID)requestImageWithAsset:(PHAsset *)asset
                    imageSize:(CGSize)imageSize
                  contentMode:(PHImageContentMode)contentMode
                      options:(PHImageRequestOptions *)options
              completeHandler:(ZCImageManagerCompletionBlock)completion;
- (void)stopImageManager;
- (void)startCachingImage:(NSArray *)assets;
- (void)stopCachingImage:(NSArray *)assets;
- (void)clearCachingImage;
@end

