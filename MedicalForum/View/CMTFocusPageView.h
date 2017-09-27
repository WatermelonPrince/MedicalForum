//
//  CMTFocusPageView.h
//  MedicalForum
//
//  Created by fenglei on 15/4/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMTFocusPageView;

/// 焦点图代理
@protocol CMTFocusPageViewDelegate <NSObject>

- (NSUInteger)numberOfFocusInFocusPageView:(CMTFocusPageView *)focusPageView;
- (CMTSeriesDetails *)focusPageView:(CMTFocusPageView *)focusPageView focusAtIndex:(NSUInteger)index;
- (void)focusPageView:(CMTFocusPageView *)focusPageView didSelectFocusAtIndex:(NSInteger)index;

@end

/// 焦点图
@interface CMTFocusPageView : UIView <UIScrollViewDelegate>

/* input */

/// 代理
@property (nonatomic, weak) id <CMTFocusPageViewDelegate> delegate;

/* output */

/// 焦点图图片宽高比为16:9
/// 通过屏幕宽 计算出焦点图图片高 并以此得出焦点图总高
+ (CGFloat)heightForWidth:(CGFloat)width;

/* control */

// 刷新焦点图
- (void)reloadData;
// 刷新焦点图说明
- (void)refreshCaption;

//图片轮播
-(void)CMT_shuffling_pic;
@end
