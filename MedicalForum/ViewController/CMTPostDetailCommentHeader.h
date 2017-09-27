//
//  CMTPostDetailCommentHeader.h
//  MedicalForum
//
//  Created by fenglei on 15/6/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTTapToRefresh.h"         // 点击刷新

/// 简单文章详情 + 点击刷新
@interface CMTPostDetailCommentHeader : UIView

/* init */

- (instancetype)initWithFrame:(CGRect)frame showTapToRefresh:(BOOL)showTapToRefresh;

/* input */

/// 使用文章详情数据刷新
- (void)reloadHeaderWithPostDetail:(CMTPost *)postDetail;

/// 使用简单文章详情数据刷新
- (void)reloadHeaderWithSimplePostDetail:(CMTPostStatistics *)simplePostDetail;

/* output */

// 回调高度
// block中刷新tableViewHeader
@property (nonatomic, copy) void (^updateHeaderHeight)(CGFloat);

// 回调简单文章详情点击链接
// block中响应点击链接
@property (nonatomic, copy) void (^shouldStartLoadWithRequest)(NSURLRequest *);

/// 点击刷新
@property (nonatomic, strong, readonly) CMTTapToRefresh *tapToRefresh;

/* control */

/// 隐藏点击刷新
- (void)hideTapToRefresh;

@end



