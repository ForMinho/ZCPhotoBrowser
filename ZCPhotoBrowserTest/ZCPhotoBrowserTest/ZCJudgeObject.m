//
//  ZCJudgeObject.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCJudgeObject.h"

@implementation ZCJudgeObject
+ (void)judgeToTheViewControllerWithObjects:(id)objects FromViewController:(UIViewController *)viewController
{
    if ([objects isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)objects;
        if ([fetchResult.firstObject isKindOfClass:[PHAsset class]]) {
            [ZCJudgeObject jumpToPhotoListControllerWithObjects:fetchResult FromViewController:viewController];
        }
        else if([fetchResult.firstObject isKindOfClass:[PHCollection class]] || [fetchResult.firstObject isKindOfClass:[PHAssetCollection class]])
        {
            ZCPhotoSubCollectionList *list = [ZCPhotoSubCollectionList zcPhotoSubCollectionList];
            list.collectionList = fetchResult;
            if (viewController.navigationController) {
                [viewController.navigationController pushViewController:list animated:YES];
            }else
            {
                [viewController presentViewController:list animated:YES completion:nil];
            }
            
        }
    }else if ([objects isKindOfClass:[PHAssetCollection class]])
    {
        PHAssetCollection *collection = (PHAssetCollection *)objects;
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        [ZCJudgeObject jumpToPhotoListControllerWithObjects:result FromViewController:viewController];
    }
    
}
+ (void)jumpToPhotoListControllerWithObjects:(PHFetchResult*)result FromViewController:(UIViewController *)viewController
{
    ZCPhotoListCollection *list = [ZCPhotoListCollection zcPhtoListCollection];
    list.fetchResult = result;
    if (viewController.navigationController) {
        [viewController.navigationController pushViewController:list animated:YES];
    }else
    {
        [viewController presentViewController:list animated:YES completion:nil];
    }
}
@end
