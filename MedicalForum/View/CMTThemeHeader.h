//
//  CMTThemeHeader.h
//  MedicalForum
//
//  Created by fenglei on 15/4/18.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMTThemeHeader;

/// 顶部视图代理
@protocol CMTThemeHeaderDelegate <NSObject>
@optional
// 点击订阅
- (void)themeHeaderFocusButtonTouched:(CMTThemeHeader *)themeHeader;
// 点击分享
- (void)themeHeaderShareButtonTouched:(CMTThemeHeader *)themeHeader;
// 点击求助
- (void)themeHeaderHelpButtonTouched:(CMTThemeHeader *)themeHeader;
// 点击全文
- (void)themeHeaderShowContentButtonTouched:(CMTThemeHeader *)themeHeader;
@end

/// 专题/'单个疾病标签'顶部视图
@interface CMTThemeHeader : UIView

/* init */

// 专题顶部视图
- (instancetype)initWithTheme:(CMTTheme *)theme
              andLimitedWidth:(CGFloat)limitedWidth;

// '单个疾病标签'顶部视图
- (instancetype)initWithDisease:(NSString *)disease
                         module:(NSString *)module
                andLimitedWidth:(CGFloat)limitedWidth;

/* input */

/// 代理
@property (nonatomic, weak) id <CMTThemeHeaderDelegate> delegate;

/* output */

/// 订阅图标
@property (nonatomic, strong, readonly) UIImageView *focusImage;
/// 订阅按钮
@property (nonatomic, strong, readonly) UIButton *focusButton;

/// 专题
@property (nonatomic, copy, readonly) CMTTheme *theme;
/// 疾病名
@property (nonatomic, copy, readonly) NSString *disease;
/// 文章module
@property (nonatomic, copy, readonly) NSString *module;

@end
