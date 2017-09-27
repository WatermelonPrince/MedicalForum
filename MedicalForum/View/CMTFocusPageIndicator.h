//
//  CMTFocusPageIndicator.h
//  MedicalForum
//
//  Created by fenglei on 15/4/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const CGFloat CMTFocusPageIndicatorDefaultHeight;

/// 焦点图分页提示器
@interface CMTFocusPageIndicator : UIView

/* input */

/// 页面数量
@property (nonatomic, assign) NSInteger numberOfPages;
/// 当前页面
@property (nonatomic, assign) NSInteger currentPage;

/* control */

/// 只有一页时 隐藏提示器
@property (nonatomic, assign) BOOL hidesForSinglePage;

@end
