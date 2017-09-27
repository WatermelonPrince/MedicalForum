//
//  UIView+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 14/12/16.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CMTExtension)

#pragma mark 布局

// 列表等 填充父视图 根据各方向内嵌 重设frame 并加载到父视图 Left及Right通过RATIO放大
- (void)fillinContainer:(UIView *)container WithTop:(CGFloat)topInset Left:(CGFloat)leftInset Bottom:(CGFloat)bottomInset Right:(CGFloat)rightInset;

// 按钮等 嵌入父视图 固定frame 并加载到父视图 Left通过RATIO放大
- (void)builtinContainer:(UIView *)container WithLeft:(CGFloat)pointX Top:(CGFloat)pointY Width:(CGFloat)width Height:(CGFloat)height;

- (void)sizeToFillinContainer:(UIView *)container WithTop:(CGFloat)topInset Left:(CGFloat)leftInset Bottom:(CGFloat)bottomInset Right:(CGFloat)rightInset;
- (void)sizeToBuiltinContainer:(UIView *)container WithLeft:(CGFloat)pointX Top:(CGFloat)pointY Width:(CGFloat)width Height:(CGFloat)height;
- (void)sizeToFillinContainer:(UIView *)container;
- (void)sizeToFitWithinSize:(CGSize)size;

- (CGFloat)left;
- (void)setLeft:(CGFloat)x;
- (CGFloat)top;
- (void)setTop:(CGFloat)y;
- (CGFloat)right;
- (void)setRight:(CGFloat)right;
- (CGFloat)bottom;
- (void)setBottom:(CGFloat)bottom;
- (CGFloat)centerX;
- (void)setCenterX:(CGFloat)centerX;
- (CGFloat)centerY;
- (void)setCenterY:(CGFloat)centerY;
- (CGFloat)width;
- (void)setWidth:(CGFloat)width;
- (CGFloat)height;
- (void)setHeight:(CGFloat)height;
- (CGSize)size;
- (void)setSize:(CGSize)size;

- (void)changeScaleWithAnimate;

@property (nonatomic, assign) BOOL visible;

#pragma mark 图像

// 截图
@property (nonatomic, copy, readonly) UIImage *screenshot;

@end
