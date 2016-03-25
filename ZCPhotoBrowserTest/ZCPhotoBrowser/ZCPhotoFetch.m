//
//  ZCPhotoFetch.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoFetch.h"
@interface ZCPhotoFetch()<PHPhotoLibraryChangeObserver>
@end

@implementation ZCPhotoFetch

+ (instancetype) sharedPhotoFetch
{
    static ZCPhotoFetch *sharedPhotoFetch = nil;
    static dispatch_once_t once ;
    dispatch_once(&once, ^{
        sharedPhotoFetch = [[ZCPhotoFetch alloc] init];
    });
    return sharedPhotoFetch;
}
- (instancetype) init
{
    self = [super init];
    if (self) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}
- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
#pragma mark -- Datas
- (PHFetchResult *)allPhotoswithAscending:(BOOL) ascending
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending];
    options.sortDescriptors = @[descriptor];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:options];
    return fetchResult;
}

- (PHFetchResult *)allPhotos
{
    PHFetchResult *photos = [self allPhotoswithAscending:YES];
    photos.FetchResultSubClass = NSStringFromClass([photos.firstObject class])?:nil;
    return photos;
}
- (PHFetchResult *)albumCollection
{
    if (_albumCollection == nil) {
        _albumCollection = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
        _albumCollection.FetchResultSubClass = NSStringFromClass([_albumCollection.firstObject class])?:nil;
    }
    return _albumCollection;
}
- (PHFetchResult *)smartAlbumCollection
{
    if (_smartAlbumCollection == nil) {
        _smartAlbumCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        _smartAlbumCollection.FetchResultSubClass = NSStringFromClass([_smartAlbumCollection.firstObject class])?:nil;
    }
    return _smartAlbumCollection;
}

#pragma mark -- Changes
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    
}
@end
