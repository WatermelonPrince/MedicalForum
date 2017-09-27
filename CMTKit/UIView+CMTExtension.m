//
//  UIView+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 14/12/16.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "UIView+CMTExtension.h"
#import <objc/runtime.h>

@implementation UIView (CMTExtension)

#pragma mark - 布局

- (void)fillinContainer:(UIView *)container WithTop:(CGFloat)topInset Left:(CGFloat)leftInset Bottom:(CGFloat)bottomInset Right:(CGFloat)rightInset {
    [self sizeToFillinContainer:container WithTop:topInset Left:leftInset Bottom:bottomInset Right:rightInset];
    [container addSubview:self];
}

- (void)builtinContainer:(UIView *)container WithLeft:(CGFloat)pointX Top:(CGFloat)pointY Width:(CGFloat)width Height:(CGFloat)height {
    [self sizeToBuiltinContainer:container WithLeft:pointX Top:pointY Width:width Height:height];
    [container addSubview:self];
}

- (void)sizeToFillinContainer:(UIView *)container WithTop:(CGFloat)topInset Left:(CGFloat)leftInset Bottom:(CGFloat)bottomInset Right:(CGFloat)rightInset {
    CGRect frame = self.frame;
    frame = container.bounds;
    frame.origin.y += topInset, frame.size.height -= topInset;
    frame.origin.x += leftInset, frame.size.width -= leftInset;
    frame.size.height -= bottomInset;
    frame.size.width -= rightInset;
    self.frame = frame;
}

- (void)sizeToBuiltinContainer:(UIView *)container WithLeft:(CGFloat)pointX Top:(CGFloat)pointY Width:(CGFloat)width Height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.origin.x = pointX;
    frame.origin.y = pointY;
    frame.size.width = width;
    frame.size.height = height;
    self.frame = frame;
}

- (void)sizeToFillinContainer:(UIView *)container {
    CGRect frame = self.frame;
    frame = container.bounds;
    self.frame = frame;
}

- (void)sizeToFitWithinSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = [self sizeThatFits:size];
    self.frame = frame;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setVisible:(BOOL)value {
    self.hidden = !value;
}

- (BOOL)visible {
    return !self.hidden;
}

#pragma mark - 图像

- (UIImage *)screenshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else{
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];
    return image;
}

#pragma mark - 收藏动画效果

- (void)changeScaleWithAnimate{
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}



@end
