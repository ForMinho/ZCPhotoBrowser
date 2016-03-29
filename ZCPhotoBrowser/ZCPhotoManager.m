//
//  ZCPhtoManager.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoManager.h"

@interface ZCPhotoManager()
@property (nonatomic, strong) PHImageManager *imageManager;
@property (nonatomic, strong) ZCPhotoFetch *photoFetch;
@end

@implementation ZCPhotoManager

+ (instancetype)sharedPhotoManager
{
    static ZCPhotoManager *sharedManager = nil;
    static dispatch_once_t once ;
    dispatch_once(&once, ^{
        sharedManager = [[ZCPhotoManager alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (PHImageManager *)imageManager
{
    if (_imageManager == nil) {
        _imageManager = [PHImageManager defaultManager];
    }
    return _imageManager;
}
- (ZCPhotoFetch *)photoFetch
{
    if (_photoFetch == nil) {
        _photoFetch = [ZCPhotoFetch sharedPhotoFetch];
    }
    return _photoFetch;
}
- (PHFetchResult *)allPhotoswithAscending:(BOOL) ascending
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending];
    options.sortDescriptors = @[descriptor];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:options];
    return fetchResult;
}
#pragma mark -- Datas
- (NSArray <PHFetchResult *> *)fetchPhotoArrayWithPhotoType:(NSArray *)photoFetchTypes
{
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    
    [photoFetchTypes enumerateObjectsUsingBlock:^(id type,NSUInteger idx , BOOL *stop)
    {
        ZCPhotoFetchType photoType = [(NSNumber *)type integerValue];
        switch (photoType) {
            case ZCPhotoFetchTypeAllPhotos:
                [photoArray addObject:self.photoFetch.allPhotos];
                break;
            case ZCPhotoFetchTypeAlbum:
                [photoArray addObject:self.photoFetch.albumCollection];
                break;
            case ZCPhotoFetchTypeSmartAlbum:
                [photoArray addObject:self.photoFetch.smartAlbumCollection];
                break;
            default:
                break;
        }
    }];
    return photoArray;
}
@end
