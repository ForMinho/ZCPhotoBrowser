//
//  ZCPhotoSubCollectionList.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCPhotoSubCollectionList.h"

@implementation ZCPhotoSubCollectionList
+ (ZCPhotoSubCollectionList *) zcPhotoSubCollectionList
{
    UIStoryboard *bord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZCPhotoSubCollectionList *collectionList = [bord instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return collectionList;
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
@end
