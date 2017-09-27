//
//  CMTReplyView.h
//  MedicalForum
//
//  Created by fenglei on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTFloatView.h"
#import "CMTTextField.h"                // 文本框

FOUNDATION_EXPORT const CGFloat CMTReplyViewDefaultHeight;

/// 回复框类型
typedef NS_ENUM(NSInteger, CMTReplyViewModel) {
    CMTReplyViewModelPostDetail = 0,        // 文章详情类型
    CMTReplyViewModelLiveDetail,            // 直播详情类型
};

/// 回复框作用域
typedef NS_ENUM(NSInteger, CMTReplyViewDomain) {
    CMTReplyViewDomainPostDetail = 0,       // 文章详情作用域
    CMTReplyViewDomainCommentList,          // 评论列表作用域
};

/// 评论回复框
@interface CMTReplyView : CMTFloatView <UITextFieldDelegate>

/* init */

- (instancetype)initWithContentView:(UIScrollView *)contentView
                   contentmaxlength:(NSInteger)contentmaxlength
                              model:(CMTReplyViewModel)model;

/* input */

/// 评论数
@property (nonatomic, copy) NSString *badgeNumber;
/// 被回复的昵称
@property (nonatomic, copy) NSString *beRepliedNickName;

/* output */

/// 未登录时点击文本框
@property (nonatomic, strong, readonly) RACSignal *commentNotLoginButtonSignal;
/// 登录后点击文本框
@property (nonatomic, strong, readonly) RACSignal *commentTouchButtonSignal;
/// 点击查看评论列表按钮
@property (nonatomic, strong, readonly) RACSignal *commentSeeButtonSignal;
/// 点击查看文章详情按钮
@property (nonatomic, strong, readonly) RACSignal *postDetailSeeButtonSignal;
/// 点击发送评论按钮
@property (nonatomic, strong, readonly) RACSignal *commentSendButtonSignal;
/// 点击文章点赞按钮
@property (nonatomic, strong, readonly) RACSignal *praiseSignal;
/// 评论内容
@property (nonatomic, strong, readonly) RACSignal *commentTextSignal;
/// 回复框类型
@property (nonatomic, assign, readonly) CMTReplyViewModel replyViewModel;
/// 动画状态
@property (nonatomic, assign, readonly) BOOL animating;

/// 文章点赞按钮
@property (nonatomic, strong, readonly) UIButton *praiseSendButton;
/// 文本框
@property (nonatomic, strong, readonly) CMTTextField *textField;

/* control */

/// 回复框上部显示的区域
@property (nonatomic, assign) CGRect attachedRect;
/// 回复框作用域
@property (nonatomic, assign) CMTReplyViewDomain replyViewDomain;

/// 静默为YES时 输入框不跟随键盘弹出/隐藏 防止控制器间键盘干扰
@property (nonatomic, assign) BOOL silence;
/// 设置为YES时 弹出键盘 textField成为第一响应者
/// 设置为NO时  隐藏键盘 textField取消第一响应者
@property (nonatomic, assign) BOOL show;

@end
