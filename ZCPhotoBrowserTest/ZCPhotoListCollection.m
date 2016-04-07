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
@interface ZCPhotoListCollection ()
@property (nonatomic, assign) CGRect  previosPreheatRect;
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
    CGFloat scale = [UIScreen mainScreen].scale;
    imageSizeWithScale = CGSizeMake(width * scale, width * scale);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.itemSize = cellSize;
    layout.minimumLineSpacing = spacing;
    layout.minimumInteritemSpacing = spacing;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ZCPhotoListCell class])];
}
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoLibraryChangedWithNotification:) name:ZCPhotoLibrary_Changed object:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
}

#pragma mark --- Datas
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZCPhotoListCell *cell = (ZCPhotoListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZCPhotoListCell class]) forIndexPath:indexPath];
    PHAsset *asset = self.fetchResult[indexPath.row];
    cell.cellAsset = asset;
    cell.localIdentifier = asset.localIdentifier;
    [cell updatePhotoOnCellWithImageSize:imageSizeWithScale content:PHImageContentModeAspectFill CompleteHandeler:nil];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZCPhotoListCell *listCell = (ZCPhotoListCell *)cell;
    [listCell cancelLoadImage];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    PHAsset *asset = self.fetchResult[indexPath.row];
    ZCPhotoViewController *photoViewCon = [ZCPhotoViewController sharedZCPhotoViewController];
    [self.navigationController pushViewController:photoViewCon animated:YES];
}
- (void)dealloc
{
    NSLog(@"%@---%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
/*
#pragma mark -- UIScroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (void)resetDecelerating
{
    decelerationRate = 1.0f;
    self.collectionView.decelerationRate = decelerationRate;
}
- (void)resetAssetedCaching
{
    [[ZCImageManager sharedImageManager] clearCachingImage];
    self.previosPreheatRect = CGRectZero;
}
- (void)updateAssetedCaching
{
    BOOL isViewDidLoad = [self isViewLoaded] && [[self view]window] != nil;
    if (!isViewDidLoad) {
        return;
    }
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0, - 0.5 * CGRectGetHeight(preheatRect));
    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previosPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) ) {
        [self computeDifferentBetweenRect:preheatRect withOldRect:self.previosPreheatRect removeHandle:^(CGRect rect){
            
            [[ZCImageManager sharedImageManager] stopCachingImage:[self assetsWithRect:rect] WithSize:imageSizeWithScale];
            
        }addHandler:^(CGRect rect)
        {
            [[ZCImageManager sharedImageManager] startCachingImage:[self assetsWithRect:rect] WithSize:imageSizeWithScale];
            
        }];
        self.previosPreheatRect = preheatRect;
    }

}
- (void)computeDifferentBetweenRect:(CGRect)newRect withOldRect:(CGRect)oldRect removeHandle:(void (^)(CGRect removeRect))removeHandler addHandler:(void (^)(CGRect addRect)) addHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        if (newMaxY > oldMaxY) {
            addHandler(CGRectMake(newRect.origin.x, oldMaxY, CGRectGetWidth(newRect), (newMaxY - oldMaxY)));
        }
        if (oldMinY > newMinY) {
            addHandler(CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY)));
        }
        if (newMaxY < oldMaxY) {
            removeHandler(CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY)));
        }
        if (oldMinY < newMinY) {
            removeHandler(CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY)));
        }

    }else
    {
        removeHandler(oldRect);
//        addHandler(newRect);
    }
    
}
- (NSArray *)assetsWithRect:(CGRect)rect
{
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0 ) {
        return nil;
    }
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attributes in allLayoutAttributes) {
        [indexPaths addObject:attributes.indexPath];
    }
    if (indexPaths.count == 0) {
        return nil;
    }
    
    NSMutableArray *assets = [NSMutableArray array];
    for (NSIndexPath *path in indexPaths) {
        [assets addObject:self.fetchResult[path.row]];
    }
    return assets;
}
 */
#pragma mark -- LibraryChanged
- (void)photoLibraryChangedWithNotification:(NSNotification *)notification
{
    PHChange *changeInfo = notification.object;
    PHFetchResultChangeDetails *fetchResult = [changeInfo changeDetailsForFetchResult:self.fetchResult];

    if (fetchResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
/*
             self.fetchResult = [fetchResult fetchResultAfterChanges];
            UICollectionView *collectionView = self.collectionView;
            if (fetchResult.hasMoves || !fetchResult.hasIncrementalChanges) {
                [collectionView reloadData];
            }else
            {
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removeSet = [fetchResult removedIndexes];
                    if (removeSet.count) {
                        [self.collectionView deleteItemsAtIndexPaths:[self indexPathFromIndex:removeSet WithSection:0]];
                    }
                    NSIndexSet *insertSet = [fetchResult insertedIndexes];
                    if (insertSet.count) {
                        [self.collectionView insertItemsAtIndexPaths:[self indexPathFromIndex:insertSet WithSection:0]];
                    }
                    NSIndexSet *changedSet = [fetchResult changedIndexes];
                    if (changedSet) {
                        [self.collectionView reloadItemsAtIndexPaths:[self indexPathFromIndex:changedSet WithSection:0]];
                    }
                }completion:NULL];
            }
*/
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
@end
