//
//  CMTReplyInputView.h
//  MedicalForum
//
//  Created by fenglei on 15/9/18.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 输入框类型
typedef NS_ENUM(NSInteger, CMTReplyInputViewModel) {
    CMTReplyInputViewModelPostDetail = 0,        // 文章详情类型
    CMTReplyInputViewModelLiveDetail,            // 直播详情类型
    CMTReplyInputViewModelGroupPostDetail,
};

/// 评论输入框
@interface CMTReplyInputView : UIViewController

/* init */

- (instancetype)initWithInputViewModel:(CMTReplyInputViewModel)inputViewModel
                      contentMaxLength:(NSInteger)contentMaxLength;

/* input */

/// 评论数
@property (nonatomic, copy) NSString *badgeNumber;
/// 被回复的昵称
@property (nonatomic, copy) NSString *beRepliedNickName;

/* output */

/// 点击取消按钮
@property (nonatomic, strong, readonly) RACSignal *commentCancelButtonSignal;
/// 点击发送评论按钮
@property (nonatomic, strong, readonly) RACSignal *commentSendButtonSignal;
/// 评论内容
@property (nonatomic, strong, readonly) RACSignal *commentTextSignal;
/// 文本区
@property (nonatomic, strong, readonly) UITextView *contentTextView;
//图片地址
@property(nonatomic,strong) NSString *picFilepath;
//提醒人员数组
@property(nonatomic,strong)NSArray *remindArray;
//小组ID
@property(nonatomic,strong)NSString *groupID;
//提醒人员ID
@property(nonatomic,strong)NSString *remindString;
//更改界面
-(void)loadViewGroupimageView:(CMTReplyInputViewModel)InputViewModel;

/* control */

- (void)showInputView;
- (void)hideInputView;

@end
