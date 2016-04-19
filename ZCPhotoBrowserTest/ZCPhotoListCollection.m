//
//  ZCPhotoListCollection.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoListCollection.h"

static const CGFloat spacing = 2.f;
static const int     cellNum = 4;
static CGSize imageSizeWithScale;
@interface ZCPhotoListCollection ()<ZCPhotoViewControllerDelegate>
{
    CGFloat scale;
}
@property (nonatomic, assign) CGRect  previosPreheatRect;
@property (nonatomic, strong) NSMutableArray *photosArray;
@end

@implementation ZCPhotoListCollection
+ (ZCPhotoListCollection *)zcPhtoListCollection
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Photo" bundle:nil];
    ZCPhotoListCollection *listCollection = [board instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return listCollection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat width = (CGRectGetWidth(self.view.frame) - spacing * (cellNum - 1))/cellNum;
    CGSize cellSize = CGSizeMake(width, width);
    scale = [UIScreen mainScreen].scale;
    imageSizeWithScale = CGSizeMake(width * scale, width * scale);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.itemSize = cellSize;
    layout.minimumLineSpacing = spacing;
    layout.minimumInteritemSpacing = spacing;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ZCPhotoListCell class])];
    [self photosArrayWithFetchResult];
}
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoLibraryChangedWithNotification:) name:ZCPhotoLibrary_Changed object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZCPhotoLibrary_Changed object:nil];
}
- (void)photosArrayWithFetchResult
{
    if (self.fetchResult && self.fetchResult.count) {
        if (_photosArray == nil) {
            _photosArray = [[NSMutableArray alloc] initWithCapacity:self.fetchResult.count];
        }
        CGSize size = CGSizeZero;
        for (PHAsset *asset in self.fetchResult) {
            size = imageSizeWithScale;
            if ((asset.pixelHeight / asset.pixelWidth ) > 4) {
                size = CGSizeMake(size.width/scale, size.height/2);
            }

            ZCPhoto *photo = [ZCPhoto photoWithAsset:asset ImageSize:size];
            [_photosArray addObject:photo];
        }
    }
}

#pragma mark --- Datas
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_photosArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZCPhotoListCell *cell = (ZCPhotoListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZCPhotoListCell class]) forIndexPath:indexPath];
    cell.image.image = nil;
    ZCPhoto *photo = _photosArray[indexPath.row];
    [cell updatePhotoCellWithPhoto:photo WithImageSize:imageSizeWithScale];
    if ([photo photoImage]) {
        cell.image.image = [photo photoImage];
    }else{
        [photo loadImageAndNotification];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZCPhoto *photo = _photosArray[indexPath.row];
    [photo cancelLoadImage];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZCPhotoViewController *photoViewCon = [ZCPhotoViewController sharedZCPhotoViewController];
    photoViewCon.delegate = self;
  
    [self.navigationController pushViewController:photoViewCon animated:YES];
      photoViewCon.selectedIndex = indexPath.row;
    
}
- (void)dealloc
{
    NSLog(@"%@---%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
#pragma mark -- LibraryChanged
- (void)photoLibraryChangedWithNotification:(NSNotification *)notification
{
    PHChange *changeInfo = notification.object;
    PHFetchResultChangeDetails *fetchResult = [changeInfo changeDetailsForFetchResult:self.fetchResult];

    if (fetchResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self.fetchResult = [fetchResult fetchResultAfterChanges];
            UICollectionView *collectionView = self.collectionView;
            
            NSArray *deleteIndexPathes, *insertIndexPathes, *reloadIndexPathes;
            if ([fetchResult hasIncrementalChanges]) {
                deleteIndexPathes = [self indexPathFromIndex:[fetchResult removedIndexes] WithSection:0];
                insertIndexPathes = [self indexPathFromIndex:[fetchResult insertedIndexes] WithSection:0];
                reloadIndexPathes = [self indexPathFromIndex:[fetchResult changedIndexes] WithSection:0];
                
                BOOL shouldReload = NO;
                if (reloadIndexPathes && deleteIndexPathes) {
                    for (NSIndexPath *reloadPath in reloadIndexPathes) {
                        if ([deleteIndexPathes containsObject:reloadPath]) {
                            shouldReload = YES;
                            break;
                        }
                    }
                    
                    if (deleteIndexPathes.lastObject && [(NSIndexPath *)deleteIndexPathes.lastObject item]> self.fetchResult.count)
                    {
                        shouldReload = YES;
                    }
                    if (shouldReload) {
                        [collectionView reloadData];
                    }else
                    {
                        [collectionView performBatchUpdates:^{
                            if (deleteIndexPathes) {
                                [collectionView deleteItemsAtIndexPaths:deleteIndexPathes];
                            }
                            if (insertIndexPathes) {
                                [collectionView insertItemsAtIndexPaths:insertIndexPathes];
                            }
                            if (reloadIndexPathes) {
                                [collectionView reloadItemsAtIndexPaths:reloadIndexPathes];
                            }
                        }completion:NULL];
                    }
                    
                    
                }
                
            }
            else
            {
                [collectionView reloadData];
            }


        });
    }
}
- (NSArray *)indexPathFromIndex:(NSIndexSet *)indexSet WithSection:(NSInteger)section
{
    NSMutableArray *indexPathes = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx,BOOL *stop)
     {
         NSIndexPath *path = [NSIndexPath indexPathForItem:idx inSection:section];
         [indexPathes addObject:path];
     }];
    return indexPathes;
}


#pragma mark -- ZCPhotoViewControllerDelegate
- (NSInteger)numberOfPhotosInBrowser:(ZCPhotoViewController *)photoController
{
    return [self.fetchResult count];
}
- (id)photoBrowser:(ZCPhotoViewController *)viewController atIndexPath:(NSInteger)index
{
    if (!self.fetchResult.count) {
        return nil;
    }
    if (index < 0) {
        index = 0;
    }
    if ( index >= [self.fetchResult count]) {
        index = self.fetchResult.count - 1;
    }
    static CGSize imageSize;
    if (imageSize.width == 0 && imageSize.height == 0) {
        imageSize.width = CGRectGetWidth(self.view.frame) * scale;
        imageSize.height = CGRectGetHeight(self.view.frame) * scale;
    }
    ZCPhoto *photo = [ZCPhoto photoWithAsset:self.fetchResult[index] ImageSize:imageSize];
    return photo;
}

#pragma mark -- Notification
- (void)loadImageCompleteWithNotification:(NSNotification *)notification
{
    ZCPhoto *photo = notification.object;
    BOOL isDisplay = NO;
    for (ZCPhotoListCell *cell in self.collectionView.visibleCells) {
        if (cell.photo == photo) {
            cell.image.image = [photo photoImage];
            isDisplay = YES;
            break;
        }
    }
    if (!isDisplay) {
        [photo cancelLoadImage];
    }
}
@end
