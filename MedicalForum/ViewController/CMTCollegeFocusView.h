//
//  CMTCollegeFocusView.h
//  MedicalForum
//
//  Created by zhaohuan on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMTCollegeFocusView;

/// 焦点图代理
@protocol CMTCollegeFocusViewDelegate <NSObject>

- (NSUInteger)numberOfFocusInFocusPageView:(CMTCollegeFocusView *)focusPageView;
- (CMTSeriesDetails *)focusPageView:(CMTCollegeFocusView *)focusPageView focusAtIndex:(NSUInteger)index;
- (void)focusPageView:(CMTCollegeFocusView *)focusPageView didSelectFocusAtIndex:(NSInteger)index;

@end

/// 焦点图
@interface CMTCollegeFocusView : UIView <UIScrollViewDelegate>

/* input */

/// 代理
@property (nonatomic, weak) id <CMTCollegeFocusViewDelegate> delegate;
@property (nonatomic, assign) BOOL initialization;                  // 是否初始化frame

/* output */

/// 焦点图图片宽高比为16:9
/// 通过屏幕宽 计算出焦点图图片高 并以此得出焦点图总高
+ (CGFloat)heightForWidth:(CGFloat)width;

/* control */

// 刷新焦点图
- (void)reloadData;
// 刷新焦点图说明
//- (void)refreshCaption;

//图片轮播
-(void)CMT_shuffling_pic;
@end

