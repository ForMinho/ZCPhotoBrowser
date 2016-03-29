//
//  ZCPhotoListCollection.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoListCollection.h"

static const CGFloat spacing = 2.f;
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
    [[ZCImageManager sharedImageManager] clearCachingImage];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[ZCImageManager sharedImageManager] stopImageManager];
}
- (void)didReceiveMemoryWarning
{
    [[ZCImageManager sharedImageManager] clearCachingImage];
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
    cell.image.image = nil;
    [cell updatePhotoOnCellWithImageSize:imageSizeWithScale content:PHImageContentModeAspectFill CompleteHandeler:^(UIImage *image,NSDictionary *info)
     {
        cell.image.image = image;
     }];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
