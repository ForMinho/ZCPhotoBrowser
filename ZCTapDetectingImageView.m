//
//  ZCTapDetectingImageView.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/20.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCTapDetectingImageView.h"

@implementation ZCTapDetectingImageView
- (id)init
{
    self = [super init];
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
- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
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
            [self handleDoubleTap:touch];
            break;
        case 3:
            [self handleTripleTap:touch];
            break;
        default:
            break;
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch
{
    if ([_delegate respondsToSelector:@selector(imageView:singleTapDetected:)]) {
        [_delegate imageView:self singleTapDetected:touch];
    }
}
- (void)handleDoubleTap:(UITouch *)touch
{
    if ([_delegate respondsToSelector:@selector(imageView:doubleTapDetected:)]) {
        [_delegate imageView:self doubleTapDetected:touch];
    }
}
- (void)handleTripleTap:(UITouch *)touch
{
    if ([_delegate respondsToSelector:@selector(imageView:tripleTapDetected:)]) {
        [_delegate imageView:self tripleTapDetected:touch];
    }
}
@end
