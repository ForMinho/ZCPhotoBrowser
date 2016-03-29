//
//  ZCPhotoListCollection.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/24.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZCRootCollectionViewController;
@interface ZCPhotoListCollection : ZCRootCollectionViewController
@property (nonatomic , strong) PHFetchResult *fetchResult;
+ (ZCPhotoListCollection *)zcPhtoListCollection;
@end
