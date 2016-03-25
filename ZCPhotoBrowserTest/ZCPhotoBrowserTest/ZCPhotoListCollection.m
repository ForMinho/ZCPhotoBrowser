//
//  ZCPhotoListCollection.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoListCollection.h"

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
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.itemSize = CGSizeMake(80, 80);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ZCPhotoListCell class])];
//    [self.collectionView registerClass:[ZCPhotoListCell class] forCellWithReuseIdentifier:NSStringFromClass([ZCPhotoListCell class])];
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
    [cell updatePhotoOnCell];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
