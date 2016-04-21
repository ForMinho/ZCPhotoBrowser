//
//  ZCTapDetectingImageView.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/20.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZCTapDetectingImageView;
@protocol ZCTapDetectingImageViewDelegate <NSObject>

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;
@end
@interface ZCTapDetectingImageView : UIImageView
@property (nonatomic, assign) id<ZCTapDetectingImageViewDelegate> delegate;
@end
