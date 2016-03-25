//
//  ViewController.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ViewController.h"
#import "ZCPhoto.h"
@interface ViewController ()
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *photoArray;

@property (nonatomic, strong) ZCPhotoManager *photoManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)",self.titleArray[indexPath.row],[self.photoArray[indexPath.row] count]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PHFetchResult *result = self.photoArray[indexPath.row];
    [ZCJudgeObject judgeToTheViewControllerWithObjects:result FromViewController:self];
}
#pragma mark --- Datas

- (ZCPhotoManager *)photoManager
{
    if (_photoManager == nil) {
        _photoManager = [ZCPhotoManager sharedPhotoManager];
    }
    return _photoManager;
}
- (NSArray *)titleArray
{
    if (_titleArray == nil ) {
        _titleArray = @[@"All Photos",@"Album",@"Smart Album"];
    }
    return _titleArray;
}
- (NSArray *)photoArray
{
    if (_photoArray == nil) {
        _photoArray = [self.photoManager fetchPhotoArrayWithPhotoType:@[@(ZCPhotoFetchTypeAllPhotos),@(ZCPhotoFetchTypeAlbum),@(ZCPhotoFetchTypeSmartAlbum)]];
    }
    return _photoArray;
}
@end
