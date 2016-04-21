//
//  ZCTapDetecingView.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/20.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCTapDetecingView.h"

@implementation ZCTapDetecingView
- (id)init
{
    self =[super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            [self handleSingleTap:touch];
            break;
        case 2:
            [self handleDounleTap:touch];
            break;
        case 3:
            [self handleTripTap:touch];
            break;
            
        default:
            break;
    }
}
- (void)handleSingleTap:(UITouch *)touch
{
    if ([_delegate respondsToSelector:@selector(view:singleTapDetected:)]) {
        [_delegate view:self singleTapDetected:touch];
    }
}
- (void)handleDounleTap:(UITouch *)touch
{
    if ([_delegate respondsToSelector:@selector(view:doubleTapDetected:)]) {
        [_delegate view:self doubleTapDetected:touch];
    }
 
}
- (void)handleTripTap:(UITouch *)touch
{
    if ([_delegate respondsToSelector:@selector(view:tripleTapDetected:)]) {
        [_delegate view:self tripleTapDetected:touch];
    }

}
@end
