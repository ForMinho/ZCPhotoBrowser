//
//  ZCPhotoDefines.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/3/28.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#ifndef ZCPhotoDefines_h
#define ZCPhotoDefines_h

#define ZCImageManager_Image_Queue dispatch_queue_create("com.ZCImageManager_GetImage", DISPATCH_QUEUE_PRIORITY_DEFAULT)

#define ZCPhotoLibrary_Changed     @"com.ZCPhotoLibrary.Changed"

#define ZCPhoto_Loaded_Successed       @"ZCPhoto.Loaded.Successed"
#define ZCPhoto_Loaded_Successed_Image @"ZCPhoto.Loaded.Successed.Image"
#define ZCPhoto_Loaded_Successed_Index @"ZCPhoto.Loaded.Successed.Index"
#define ZCPhoto_Loaded_Successed_Asset @"ZCPhoto.Loaded.Successed.Asset"

#define ZCPhoto_PHAssetClass   NSClassFromString(@"PHAsset")



#endif /* ZCPhotoDefines_h */

#if DEBUG
#define  NSLog(x,...) NSLog(x,## __VA_ARGS__);
#else
#define NSLog(x,...)
#endif