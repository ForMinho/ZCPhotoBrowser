//
//  ZCPhotoSubCollectionList.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoSubCollectionList.h"
@interface ZCPhotoSubCollectionList() //<PHPhotoLibraryChangeObserver>
@end
@implementation ZCPhotoSubCollectionList
+ (ZCPhotoSubCollectionList *) zcPhotoSubCollectionList
{
    UIStoryboard *bord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZCPhotoSubCollectionList *collectionList = [bord instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return collectionList;
}
- (void)viewDidLoad
{

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoChangedWithNotification:) name:ZCPhotoLibrary_Changed object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectionList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self.collectionList[indexPath.row] localizedTitle];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PHAssetCollection *collection = self.collectionList[indexPath.row];
    [ZCJudgeObject judgeToTheViewControllerWithObjects:collection FromViewController:self];
}
- (void)photoChangedWithNotification:(NSNotification *)notification
{
    PHChange *changeInstance = notification.object;
    if (changeInstance) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:self.collectionList];
            self.collectionList = [changeDetails fetchResultAfterChanges];
            [self.tableView reloadData];
        });

    }
}
@end
