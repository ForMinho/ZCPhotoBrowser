//
//  ViewController.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ViewController.h"
#import "ZCPhotoKit.h"
@interface ViewController ()
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *photoArray;

@property (nonatomic, strong) ZCPhotoManager *photoManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoLibraryChangedWithNotification:) name:ZCPhotoLibrary_Changed object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 1;
    }
    return self.photoArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.section == 1) {
        cell.textLabel.text = @"Photos From Web";
        return cell;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",self.titleArray[indexPath.row],(unsigned long)[self.photoArray[indexPath.row] count]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSMutableArray *photosArray = [NSMutableArray array];
        [photosArray addObject:[ZCPhoto photowithUrlFromWeb:@"http://10.101.136.201/AppIconMaker/CartPlaceholder@2x.png"]];
        [photosArray addObject:[ZCPhoto photowithUrlFromWeb:@"http://10.101.136.201/AppIconMaker/Fu733ONpoivUpcQ3LtM1iMNmfOSy.jpg/Fu733ONpoivUpcQ3LtM1iMNmfOSy.imageset/Fu733ONpoivUpcQ3LtM1iMNmfOSy@3x.png"]];
        [photosArray addObject:[ZCPhoto photowithUrlFromWeb:@"http://10.101.136.201/AppIconMaker/SettleAccountsBalance@2x.png"]];
        [photosArray addObject:[ZCPhoto photowithUrlFromWeb:@"http://10.101.136.201/AppIconMaker/btn_weibo_n@2x.png"]];
        [photosArray addObject:[ZCPhoto photowithUrlFromWeb:@"http://10.101.136.201/AppIconMaker/btn_weixin_n@3x.png"]];
        [ZCJudgeObject judgeToTheViewControllerWithObjects:photosArray FromViewController:self];
        return;
    }
    PHFetchResult *result = self.photoArray[indexPath.row];
    [ZCJudgeObject judgeToTheViewControllerWithObjects:result FromViewController:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Library";
            break;
        case 1:
            return @"Http Web";
            break;
        default:
            break;
    }
    return nil;
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

#pragma mark -- PhotoLibraryChanged
- (void)photoLibraryChangedWithNotification:(NSNotification*)notification
{
    PHChange *fetchResultChange = notification.object;
    if (fetchResultChange) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __block BOOL isChanged = NO;
            NSMutableArray *changedArray = [self.photoArray mutableCopy];
            [self.photoArray enumerateObjectsUsingBlock:^(PHFetchResult *result ,NSUInteger idx,BOOL *stop){
                PHFetchResultChangeDetails *details = [fetchResultChange changeDetailsForFetchResult:result];
                if (details) {
                    [changedArray replaceObjectAtIndex:idx withObject:[details fetchResultAfterChanges]];
                    isChanged = YES;
                }
            }];
            if (isChanged) {
                self.photoArray = changedArray;
                [self.tableView reloadData];
            }
        });
        
    }
}
@end
