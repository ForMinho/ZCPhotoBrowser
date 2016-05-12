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
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, assign) CGRect  previosPreheatRect;
@property (nonatomic, strong) NSMutableArray *photosArray;
@property (nonatomic, strong) NSMutableSet *selectedSet;
@end

@implementation ZCPhotoListCollection
+ (ZCPhotoListCollection *)zcPhtoListCollection
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Photo" bundle:nil];
    ZCPhotoListCollection *listCollection = [board instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    [listCollection _initialisation];
    return listCollection;
}
- (void)_initialisation
{
    _isImageCanSelect = YES;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionViewShouldSelectedPhotoAtIndexWithNotification:) name:ZCPhotoCollection_Selected_Photo object:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoLibraryChangedWithNotification:) name:ZCPhotoLibrary_Changed object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZCPhotoLibrary_Changed object:nil];
    NSLog(@"%@",_selectedSet);
}
- (void)photosArrayWithFetchResult
{
    if (_photosArray == nil) {
        _photosArray = [NSMutableArray array];
    }
    [_photosArray removeAllObjects];
    
    if ([_photosResource isKindOfClass:[PHFetchResult class]])
    {
        _fetchResult = (PHFetchResult *)_photosResource;
        _photosResource = nil;

        CGSize size = CGSizeZero;
        for (PHAsset *asset in _fetchResult) {
            size = imageSizeWithScale;
            if ((asset.pixelHeight / asset.pixelWidth ) > 4) {
                size = CGSizeMake(size.width/scale, size.height/2);
            }
            ZCPhoto *photo = [ZCPhoto photoWithAsset:asset ImageSize:size];
            [_photosArray addObject:photo];
        }
    }
    if ([_photosResource isKindOfClass:[NSArray class]]) {
        NSArray *tmpArray = (NSArray *)_photosResource;
        if (tmpArray.firstObject && [tmpArray.firstObject isKindOfClass:[ZCPhoto class]]) {
            [_photosArray addObjectsFromArray:tmpArray];
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
    __weak ZCPhotoListCollection *weakSelf = self;
    [cell updatePhotoCellWithPhoto:photo WithImageSize:imageSizeWithScale withPhotoSelectedHandle:^(ZCPhoto *photo,BOOL isSelected){
        [weakSelf changeSelectedSetWithPhoto:photo WithSelected:isSelected];
    }];
    cell.selectedBtn.hidden = !_isImageCanSelect;
    if ([photo photoImage]) {
        cell.image.image = [photo photoImage];
    }else{
        [photo loadImageAndNotification];
    }
    [cell.image setBackgroundColor:[UIColor redColor]];
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
    photoViewCon.imageCanSelect = YES;
//    photoViewCon.autoHideControls = NO;
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
    return [_photosArray count];
}
- (id)photoBrowser:(ZCPhotoViewController *)viewController atIndexPath:(NSInteger)index
{
    if (!_photosArray.count) {
        return nil;
    }
    if (index < 0) {
        index = 0;
    }
    if ( index >= [_photosArray count]) {
        index = _photosArray.count - 1;
    }
    static CGSize imageSize;
    if (imageSize.width == 0 && imageSize.height == 0) {
        imageSize.width = CGRectGetWidth(self.view.frame) * scale;
        imageSize.height = CGRectGetHeight(self.view.frame) * scale;
    }
    ZCPhoto *thumbPhoto = _photosArray[index];
    ZCPhoto *photo = nil;
    if (thumbPhoto.asset) {
        photo = [ZCPhoto photoWithAsset:thumbPhoto.asset ImageSize:imageSize];
    }else if (thumbPhoto.photoUrl)
    {
        photo = [ZCPhoto photowithUrlFromWeb:thumbPhoto.photoUrl];
    }

    photo.isPhotoSelected = thumbPhoto.isPhotoSelected;
    return photo;
}
- (void)photoBrowser:(ZCPhotoViewController *)viewController selectedPhoto:(ZCPhoto *)photo AtIndex:(NSInteger)index
{
    if (index < _photosArray.count) {
        ZCPhoto *thumbPhoto = _photosArray[index];
        thumbPhoto.isPhotoSelected = photo.isPhotoSelected;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        BOOL currentVisible = NO;
        NSArray *visibleArray = [self.collectionView indexPathsForVisibleItems];
        for (NSIndexPath *path in visibleArray) {
            if ([path isEqual:indexPath]) {
                currentVisible = YES;
                break;
            }
        }
        
        ZCPhotoListCell *cell = (ZCPhotoListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.selectedBtn.selected = photo.isPhotoSelected;
    }
}
- (NSString *)photoBrowser:(ZCPhotoViewController *)viewController titleForPhotoAtIndex:(NSUInteger)index
{
    NSString *title = nil;
    PHAsset *asset = self.fetchResult[index];
    title = asset.localIdentifier;

    return title;
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
- (void)collectionViewShouldSelectedPhotoAtIndexWithNotification:(NSNotification *)notification
{
    NSUInteger index = [notification.object integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    NSArray *visibleArray = [self.collectionView indexPathsForVisibleItems];
    BOOL currentVisible = NO;
    for (NSIndexPath *tempPath in visibleArray) {
        if ([tempPath isEqual: indexPath]) {
            currentVisible = YES;
            break;
        }
    }
    if (!currentVisible) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

#pragma mark -- Block
- (void)changeSelectedSetWithPhoto:(ZCPhoto *)photo WithSelected:(BOOL)isSelected
{
    if (_selectedSet == nil) {
        _selectedSet = [[NSMutableSet alloc] init];
    }
    [_selectedSet minusSet:[NSSet setWithObject:photo]];
    if (isSelected) {
        [_selectedSet addObject:photo];
    }
}
@end
