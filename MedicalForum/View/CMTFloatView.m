//
//  CMTFloatView.m
//  MedicalForum
//
//  Created by fenglei on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTFloatView.h"

@implementation CMTFloatView

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    
    self.backgroundColor = COLOR(c_clear);
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]init];
    panGestureRecognizer.delegate=self;
    [self addGestureRecognizer:panGestureRecognizer];
    return self;
}
#pragma mark 禁止手势滑动关闭音频
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        NSLog(@"禁止底部视图滑动影响音频播放");
        return YES;
        
    }
    return NO;
}
- (void)didMoveToSuperview {
    [self.superview bringSubviewToFront:self];
}

@end
