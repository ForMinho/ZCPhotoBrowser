//
//  ZCPhotoListCollection.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoListCollection.h"

static const CGFloat spacing = 0.5f;
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
    CGFloat width = (CGRectGetWidth(self.view.frame) - spacing * 3)/4;
    CGSize cellSize = CGSizeMake(width, width);
    CGFloat scale = [UIScreen mainScreen].scale * 2;
    imageSizeWithScale = CGSizeMake(width * scale, width * scale);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.itemSize = cellSize;
    layout.minimumLineSpacing = 0.5f;
    layout.minimumInteritemSpacing = 0.5f;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ZCPhotoListCell class])];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self resetAssetedCaching];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[ZCImageManager sharedImageManager] stopImageManager];
}
- (void)didReceiveMemoryWarning
{
    [self resetAssetedCaching];
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
    [cell updatePhotoOnCellWithImageSize:imageSizeWithScale content:PHImageContentModeAspectFill CompleteHandeler:^(UIImage *image,NSDictionary *info)
     {
         if ([cell.localIdentifier isEqualToString:asset.localIdentifier]) {
             cell.image.image = image;
         }
     }];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -- UIScroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateAssetedCaching];
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
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3) {
        [self computeDifferentBetweenRect:preheatRect withOldRect:self.previosPreheatRect removeHandle:^(CGRect rect){
            
            [[ZCImageManager sharedImageManager] stopCachingImage:[self assetsWithRect:rect]];
            
        }addHandler:^(CGRect rect)
        {
            [[ZCImageManager sharedImageManager] startCachingImage:[self assetsWithRect:rect]];
            
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
        addHandler(newRect);
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
@end
