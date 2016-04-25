//
//  ZCPhotoListCollection.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ZCPhotoCollection_Selected_Photo @"ZCPhotoCollection_Selected_Photo"
@class ZCRootCollectionViewController;
@interface ZCPhotoListCollection : ZCRootCollectionViewController
@property (nonatomic , strong) PHFetchResult *fetchResult;
@property (nonatomic, assign) BOOL isImageCanSelect;
+ (ZCPhotoListCollection *)zcPhtoListCollection;
@end
