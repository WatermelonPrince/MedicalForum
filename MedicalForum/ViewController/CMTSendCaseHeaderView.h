//
//  CMTSendCaseHeaderView.h
//  MedicalForum
//
//  Created by fenglei on 15/8/6.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTSendCaseType.h"
#import "CMTSetLiveTagViewController.h"
#import "CMTSendCaseViewController.h"

@class CMTSendCaseHeaderView;

/// 发帖顶部视图类型
typedef NS_ENUM(NSInteger, CMTSendCaseHeaderViewType) {
    CMTSendCaseHeaderViewTypeUnDefined = 0,
    CMTSendCaseHeaderViewTypeAddPost,               // 发帖
    CMTSendCaseHeaderViewTypeAddPostDescribe,       // 追加描述
    CMTSendCaseHeaderViewTypeAddPostConclusion,     // 追加结论
};

@protocol CMTSendCaseHeaderViewDelegate <NSObject>
@optional
- (void)presentMediaPicker:(UIViewController *)mediaPicker animated:(BOOL)animated;
- (void)mediaPickerDidFinishPickingAssets:(NSArray *)assets;
- (void)dismissMediaPickerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)refreshSendCaseHeaderView;
@end

/// 发帖顶部视图
@interface CMTSendCaseHeaderView : UIView

/* init */

/// designated initializer
- (instancetype)initWithFrame:(CGRect)frame live:(CMTLive*)live viewController:(UIViewController*)controller;
- (instancetype)initWithFrame:(CGRect)frame headerViewType:(CMTSendCaseHeaderViewType)headerViewType sendCaseType:(CMTSendCaseType)sendCaseType viewController:(UIViewController*)controller;

/// delegate
@property (nonatomic, weak) id<CMTSendCaseHeaderViewDelegate> delegate;

/* output */

/// 正文输入区
@property (nonatomic, strong, readonly) UITextView *contentTextView;
/// 标题内容
@property (nonatomic, strong) UITextField *titleField;                              // 标题输入框
@property (nonatomic, strong, readonly) RACSignal *titleTextSignal;
/// 正文内容
@property (nonatomic, strong, readonly) RACSignal *contentTextSignal;
//直播间信息
@property(nonatomic,strong)CMTLive *mylive;
@property(nonatomic,weak)UIViewController *myController;


@end
