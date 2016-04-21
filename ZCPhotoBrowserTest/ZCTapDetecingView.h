//
//  ZCTapDetecingView.h
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/20.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZCTapDetecingView;
@protocol ZCTapDetectingViewDelegate <NSObject>

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end
@interface ZCTapDetecingView : UIView
@property (nonatomic,assign) id<ZCTapDetectingViewDelegate> delegate;
@end
