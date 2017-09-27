//
//  CMTTapToRefresh.h
//  MedicalForum
//
//  Created by fenglei on 15/1/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const CGFloat CMTTapToRefreshDefaultHeight;

/// 点击刷新
@interface CMTTapToRefresh : UIView

/* input */

/// 活动状态,
/// 为YES, 显示activityIndicatorView,
/// 为NO, 显示refreshButton
@property (nonatomic, assign) BOOL active;

/* control */

/// 底部分隔线
/// 显示/隐藏 底部分隔线
@property (nonatomic, strong, readonly) UIView *bottomLine;

/* output */

/// 点击刷新按钮
@property (nonatomic, strong, readonly) RACSignal *refreshButtonSignal;

@end
