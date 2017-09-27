//
//  CMTSideBar.h
//  MedicalForum
//
//  Created by fenglei on 15/5/2.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMTSideBar;

/// 侧边栏 代理
@protocol CMTSideBarDelegate <NSObject>
@optional
- (void)sidebar:(CMTSideBar *)sidebar willShowAnimated:(BOOL)animated;
- (void)sidebar:(CMTSideBar *)sidebar didShowAnimated:(BOOL)animated;
- (void)sidebar:(CMTSideBar *)sidebar willDismissAnimated:(BOOL)animated;
- (void)sidebar:(CMTSideBar *)sidebar didDismissAnimated:(BOOL)animated;
@end

/// 侧边栏
@interface CMTSideBar : UIViewController <UIGestureRecognizerDelegate>

/* input */

/// 侧边栏宽
/// 默认 SCREEN_WIDTH * (2.0 / 3.0)
@property (nonatomic, assign) CGFloat sideBarWidth;
/// 从右边出现, 默认从左边出现
@property (nonatomic, assign) BOOL showFromRight;
/// 动画时间, 默认0.25
@property (nonatomic, assign) CGFloat animationDuration;
/// 内容背景视图着色
/// 默认 COLOR(c_f5f5f5f5)
@property (nonatomic, strong) UIColor *blurTintColor;

/* output */

/// 内容视图
@property (nonatomic, strong, readonly) UIView *contentView;
/// 内容背景视图
@property (nonatomic, strong, readonly) UIImageView *contentBlurView;
/// 代理
@property (nonatomic, weak) id <CMTSideBarDelegate> delegate;

/* control */

/// 显示侧边栏
- (void)showAnimated:(BOOL)animated;
/// 隐藏侧边栏
- (void)dismissAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
/// 需要再次打开侧边栏
@property (nonatomic, assign) BOOL needReOpen;

@end
