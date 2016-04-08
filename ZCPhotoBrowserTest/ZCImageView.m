//
//  ZCImageView.m
//  ZCPhotoBrowserTest
//
//  Created by For_Minho on 16/4/8.
//  Copyright © 2016年 For_Minho. All rights reserved.
//

#import "ZCImageView.h"

@implementation ZCImageView
- (instancetype) initWithFrame:(CGRect)frame AndImage:(UIImage *)image;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = image;
    }
    return self;
}
- (void)layoutSubviews
{
    
}

@end
