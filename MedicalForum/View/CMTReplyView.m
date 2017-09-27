//
//  CMTReplyView.m
//  MedicalForum
//
//  Created by fenglei on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

// view
#import "CMTReplyView.h"                // header file
#import "CMTBadge.h"                    // 数字标记

const CGFloat CMTReplyViewDefaultHeight = 60.0;

@interface CMTReplyView ()

// output
@property (nonatomic, strong, readwrite) RACSignal *commentNotLoginButtonSignal;    // 未登录时点击文本框
@property (nonatomic, strong, readwrite) RACSignal *commentTouchButtonSignal;       // 登录后点击文本框
@property (nonatomic, strong, readwrite) RACSignal *commentSeeButtonSignal;         // 点击查看评论列表按钮
@property (nonatomic, strong, readwrite) RACSignal *postDetailSeeButtonSignal;      // 点击查看文章详情按钮
@property (nonatomic, strong, readwrite) RACSignal *commentSendButtonSignal;        // 点击发送评论按钮
@property (nonatomic, strong, readwrite) RACSignal *praiseSignal;                   // 点赞按钮
@property (nonatomic, strong, readwrite) RACSignal *commentTextSignal;              // 评论内容
@property (nonatomic, assign, readwrite) CMTReplyViewModel replyViewModel;          // 回复框类型
@property (nonatomic, assign, readwrite) BOOL animating;                            // 动画状态

// view
@property (nonatomic, strong) UIScrollView *contentView;                            // 回复信息视图
@property (nonatomic, strong) UIView *topLine;                                      // 分隔线
@property (nonatomic, strong, readwrite) CMTTextField *textField;                   // 文本框
@property (nonatomic, strong) UIButton *commentNotLoginButton;                      // 文本框未登录提示按钮
@property (nonatomic, strong) UIButton *commentTouchButton;                         // 文本框登录后点击按钮
@property (nonatomic, strong) UIButton *commentSeeButton;                           // 查看评论列表按钮
@property (nonatomic, strong) UIButton *postDetailSeeButton;                        // 查看文章详情按钮
@property (nonatomic, strong) UIButton *commentSendButton;                          // 发送评论按钮
@property (nonatomic, strong) UIButton *praiseSendButton;                           // 发送评论按钮
@property (nonatomic, strong) CMTBadge *badge;                                      // 评论数

// data
@property (nonatomic, assign) BOOL initialization;                                  // 是否初始化frame
@property (nonatomic, assign) NSInteger contentmaxlength;
@property (nonatomic, assign) CGFloat additionalContentOffset;                      // scrollView contentOffset的额外偏移

@end

@implementation CMTReplyView

#pragma mark Initializers

- (UIView *)topLine {
    if (_topLine == nil) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = COLOR(c_dadada);
    }
    
    return _topLine;
}

- (CMTTextField *)textField {
    if (_textField == nil) {
        _textField = [[CMTTextField alloc] init];
        _textField.backgroundColor = COLOR(c_ffffff);
        _textField.textColor = COLOR(c_151515);
        _textField.font = FONT(15.0);
        _textField.placeholder = @"我想说...";
        _textField.delegate = self;
    }
    
    return _textField;
}

- (UIButton *)commentNotLoginButton {
    if (_commentNotLoginButton == nil) {
        _commentNotLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentNotLoginButton setBackgroundColor:COLOR(c_clear)];
    }
    
    return _commentNotLoginButton;
}

- (UIButton *)commentTouchButton {
    if (_commentTouchButton == nil) {
        _commentTouchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentTouchButton setBackgroundColor:COLOR(c_clear)];
    }
    
    return _commentTouchButton;
}

- (UIButton *)commentSeeButton {
    if (_commentSeeButton == nil) {
        _commentSeeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentSeeButton setBackgroundColor:[UIColor colorWithHexString:@"F8F8F8"]];
        _commentSeeButton.layer.borderWidth=1;
        _commentSeeButton.layer.borderColor=[UIColor colorWithHexString:@"#ECECEC"].CGColor;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(11.0, 11.0, 18.0, 18.0)];
        imageView.tag = 1000;
        imageView.image=IMAGE(@"comments");
        [_commentSeeButton addSubview:imageView];

    }
    
    return _commentSeeButton;
}

- (UIButton *)postDetailSeeButton {
    if (_postDetailSeeButton == nil) {
        _postDetailSeeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_postDetailSeeButton setBackgroundColor:[UIColor colorWithHexString:@"F8F8F8"]];
        _postDetailSeeButton.layer.borderWidth=1;
        _postDetailSeeButton.layer.borderColor=[UIColor colorWithHexString:@"#ECECEC"].CGColor;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(11.0, 11.0, 18.0, 18.0)];
        imageView.tag = 1000;
        imageView.image=IMAGE(@"comment_post");
        [_postDetailSeeButton addSubview:imageView];

    }
    
    return _postDetailSeeButton;
}

- (UIButton *)commentSendButton {
    if (_commentSendButton == nil) {
        _commentSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentSendButton setBackgroundColor:COLOR(c_clear)];
        [_commentSendButton setImage:IMAGE(@"comment_Send_H") forState:UIControlStateNormal];
        [_commentSendButton setImage:IMAGE(@"comment_Send_D") forState:UIControlStateDisabled];

        [_commentSendButton setBackgroundColor:[UIColor colorWithHexString:@"F8F8F8"]];
        _commentSendButton.layer.borderWidth=1;
        _commentSendButton.layer.borderColor=[UIColor colorWithHexString:@"#ECECEC"].CGColor;

    }
    
    return _commentSendButton;
}

- (UIButton *)praiseSendButton {
    if (_praiseSendButton == nil) {
        _praiseSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_praiseSendButton setBackgroundColor:[UIColor colorWithHexString:@"F8F8F8"]];
        _praiseSendButton.layer.borderWidth=1;
        _praiseSendButton.layer.borderColor=[UIColor colorWithHexString:@"#ECECEC"].CGColor;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0, 11.5, 20.0, 17.0)];
        imageView.tag = 1000;
        imageView.image=IMAGE(@"unpraise");
        [_praiseSendButton addSubview:imageView];
    }
    
    return _praiseSendButton;
}

- (CMTBadge *)badge {
    if (_badge == nil) {
        _badge = [[CMTBadge alloc] init];
    }
    return _badge;
}

- (instancetype)initWithContentView:(UIScrollView *)contentView
                   contentmaxlength:(NSInteger)contentmaxlength
                              model:(CMTReplyViewModel)model {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"ReplyView willDeallocSignal");
    }];
    
    self.contentView = contentView;
    self.contentmaxlength = contentmaxlength;
    self.replyViewModel = model;
    
    self.backgroundColor = COLOR(c_F7F7F7);
    self.silence = YES;
    
    // 初始化frame
    [[RACObserve(self, frame)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.frame.size.height > 0.0 && !self.initialization) {
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];
    
    // 编辑状态 按钮变换
    [self.rac_deallocDisposable addDisposable:
     [[[RACSignal merge:@[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidEndEditingNotification object:nil],
                          [self.textField rac_textSignal],
                          ]]
       deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        self.commentSeeButton.hidden = self.textField.isEditing;
        self.commentSendButton.hidden = !self.textField.isEditing;
        self.postDetailSeeButton.hidden = self.textField.isEditing;
        
        if ([x isKindOfClass:[NSString class]]) {
            self.commentSendButton.enabled = (self.textField.text.length > 0);
        }
    }]];
    
    // 评论数
    [[RACObserve(self, badgeNumber)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString * badgeNumber) {
        @strongify(self);
        
        // 评论数标记
        self.badge.text = badgeNumber;
        
        // placeholder
        if ([badgeNumber integerValue] > 0) {
            self.textField.placeholder = @"我想说...";
        }
        else {
            self.textField.placeholder = @"争做第一发言人";
        }
    }];
    
    // 点击查看评论列表按钮
    self.commentSeeButtonSignal = [self.commentSeeButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    // 点击点赞按钮
    self.praiseSignal = [self.praiseSendButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    // 点击查看文章详情按钮
    self.postDetailSeeButtonSignal = [self.postDetailSeeButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    // 切换查看评论列表按钮/查看文章详情按钮
    [[[RACObserve(self, replyViewDomain) distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *replyViewDomainNumber) {
        @strongify(self);
        switch (replyViewDomainNumber.integerValue) {
                
                // 文章详细 显示查看评论列表按钮
            case CMTReplyViewDomainPostDetail: {
                [self insertSubview:self.commentSeeButton aboveSubview:self.postDetailSeeButton];
            }
                break;
                
                // 评论列表 显示查看文章详情按钮
            case CMTReplyViewDomainCommentList: {
                [self insertSubview:self.postDetailSeeButton aboveSubview:self.commentSeeButton];
            }
                break;
                
            default:
                break;
        }
    }];
    
    // 文本框未登录提示按钮
    RAC(self.commentNotLoginButton, hidden) = [RACObserve(CMTUSER, login) deliverOn:[RACScheduler mainThreadScheduler]];
    
    // 未登录时点击文本框
    self.commentNotLoginButtonSignal = [self.commentNotLoginButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    // 登录后点击文本框
    self.commentTouchButtonSignal = [self.commentTouchButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    // 被回复的昵称提示
    [[[RACObserve(self, beRepliedNickName) distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *beRepliedNickName) {
        @strongify(self);
        if (beRepliedNickName == nil) {
            self.textField.placeholder = [self.badgeNumber integerValue] == 0 ? @"争做第一发言人" : @"我想说...";
        }
        else {
            self.textField.placeholder = [NSString stringWithFormat:@"回复%@:", beRepliedNickName];
        }
    }];
    
    // 点击发送评论按钮
    self.commentSendButtonSignal = [self.commentSendButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    [[self.commentSendButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        // to do 优化发送及清空 self.textField.text = nil; 目前会导致连续点击发送多条
        // 显示重复
        
        @strongify(self);
        self.commentSendButton.enabled = NO;
    }];
       // 评论内容
    self.commentTextSignal = [self.textField rac_textSignal];
    
    // 弹出/隐藏 动画
    [self.rac_deallocDisposable addDisposable:
     [[RACSignal merge:@[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil],
                         [[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidShowNotification object:nil],
                         [[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
                         ]]
      subscribeNext:^(NSNotification *notification) {
          // 此处不用重复转到主线程 否则会崩溃
          @strongify(self);
          if (self.silence == YES) {
              return;
          }
          
          // keyboard userInfo
          NSTimeInterval keyboardAnimationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
          UIViewAnimationOptions keyboardAnimationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
          keyboardAnimationCurve |= keyboardAnimationCurve<<16;
          __block CGRect keyboardFrameBegin = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
          __block CGRect keyboardFrameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
          
          // 回复框移动动画
          [UIView animateWithDuration:keyboardAnimationDuration
                                delay:0.0
                              options:keyboardAnimationCurve
                           animations:^{
                               self.animating = YES;
                               if (keyboardFrameEnd.size.height == 216.0
                                   && keyboardFrameBegin.size.height == keyboardFrameEnd.size.height
                                   && ![notification.name isEqual:UIKeyboardWillHideNotification]
                                   && [self.textField.textInputMode.primaryLanguage isEqual:@"zh-Hans"]) {
                                   keyboardFrameEnd.origin.y -= (252.0 - 216.0);
                               }
                               if (self.replyViewModel == CMTReplyViewModelLiveDetail &&
                                   [notification.name isEqual:UIKeyboardWillHideNotification]) {
                                   self.bottom = keyboardFrameEnd.origin.y + CMTReplyViewDefaultHeight;
                               }
                               else {
                                   self.bottom = keyboardFrameEnd.origin.y;
                               }
                           } completion:^(BOOL finished) {
                               self.animating = NO;
                           }];
          
          // 键盘弹出/切换输入法
          if ([notification.name isEqual:UIKeyboardWillShowNotification] || [notification.name isEqual:UIKeyboardDidShowNotification]) {
              // 滚动回复信息视图
              if (!CGRectEqualToRect(self.attachedRect, CGRectZero)) {
                  [self scrollContentViewWithKeyboardAnimationDuration:keyboardAnimationDuration
                                                keyboardAnimationCurve:keyboardAnimationCurve
                                                    keyboardFrameBegin:keyboardFrameBegin
                                                      keyboardFrameEnd:keyboardFrameEnd];
              }
              
              // 点击textField弹出键盘时 同步show标记值
              if (self.show == NO) {
                  self.show = YES;
              }
          }
          
          // 键盘隐藏
          if ([notification.name isEqual:UIKeyboardWillHideNotification]) {
              // 滚动tableView 撤销contentOffset的额外偏移
              self.contentView.contentOffset =  CGPointMake(0.0, self.contentView.contentOffset.y - self.additionalContentOffset);
              // 清空tableView contentOffset的额外偏移记录
              self.additionalContentOffset = 0.0;
              // 清空tableView attachedRect记录
              self.attachedRect = CGRectZero;
              
              // 点击WebView隐藏键盘时 同步show标记值
              if (self.show == YES) {
                  self.show = NO;
              }
          }
      }]];
    
    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    if (self.replyViewModel == CMTReplyViewModelPostDetail) {
        [self.textField fillinContainer:self WithTop:10.0 Left:10.0*RATIO Bottom:10.0 Right:110.0];
        [self.commentTouchButton fillinContainer:self.textField WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        [self.commentNotLoginButton fillinContainer:self.textField WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        [self.praiseSendButton fillinContainer:self WithTop:10.0 Left:self.textField.right + 10.0 Bottom:10.0 Right:60.0];
        [self.commentSendButton fillinContainer:self WithTop:10.0 Left:self.praiseSendButton.right + 10.0 Bottom:10.0 Right:10.0];
        [self.postDetailSeeButton fillinContainer:self WithTop:10.0 Left:self.praiseSendButton.right + 10.0 Bottom:10.0 Right:10.0];
        [self.commentSeeButton fillinContainer:self WithTop:10.0 Left:self.praiseSendButton.right + 10.0 Bottom:10.0 Right:10.0];
        [self.badge builtinContainer:self.commentSeeButton WithLeft:self.commentSeeButton.width - 23.5 Top:6.0 Width:kCMTBadgeWidth Height:12.0];
        self.badge.layer.masksToBounds = NO;
        self.badge.layer.cornerRadius = 0.0;
        [self.topLine builtinContainer:self WithLeft:0.0 Top:0.0 Width:size.width Height:PIXEL];
    }
    else if (self.replyViewModel == CMTReplyViewModelLiveDetail) {
        [self.textField fillinContainer:self WithTop:10.0 Left:10.0*RATIO Bottom:10.0 Right:60.0];
        [self.commentSendButton fillinContainer:self WithTop:10.0 Left:self.textField.right + 10.0 Bottom:10.0 Right:10.0];
        [self.topLine builtinContainer:self WithLeft:0.0 Top:0.0 Width:size.width Height:PIXEL];
    }
    
    return YES;
}

- (void)setShow:(BOOL)show {
    if (self.silence == YES) {
        return;
    }
    
    _show = show;
    
    if (show == YES) {
        [self.textField becomeFirstResponder];
    } else {
        [self.textField endEditing:YES];
    }
}

- (void)scrollContentViewWithKeyboardAnimationDuration:(NSTimeInterval)keyboardAnimationDuration
                                keyboardAnimationCurve:(UIViewAnimationOptions)keyboardAnimationCurve
                                    keyboardFrameBegin:(CGRect)keyboardFrameBegin
                                      keyboardFrameEnd:(CGRect)keyboardFrameEnd {
    
    // todo 当键盘处于出现状态时  contentOffset会有问题
    // todo 当contentOffset已经处于补充状态下 再设置contentOffset会使键盘收起?
    
    // tableView contentOffset滚动距离(当前选中cell底部与replyView顶部之间的位差)
    CGFloat gapFromCellBottomToReplyViewTop = 0.0;
    // tableView contentOffset的额外偏移
    CGFloat additionalContentOffset = 0.0;
    
    // 获取当前选中cell的位置
    CGRect cellRect = [self.superview convertRect:self.attachedRect fromView:self.contentView];
    CGFloat cellBottom = cellRect.origin.y + cellRect.size.height;
    
    // 计算tableView contentOffset滚动距离
    gapFromCellBottomToReplyViewTop = cellBottom - self.top;
    
    // 位差为正(cellBottomY > replyViewTopY), tableView需要向上滚动, 如果contentSize不足 contentOffset会正值补充 键盘消失时 要去掉补充
    if (gapFromCellBottomToReplyViewTop > 0.0) {
        // 计算contentSize剩余量
        CGFloat consentSizeRemain = self.contentView.contentSize.height - self.contentView.contentOffset.y - self.contentView.bounds.size.height;
        // to do contentSize剩余量为负 是否可以当作consentSizeRemain = 0处理?
        if (consentSizeRemain < 0.0) {
            consentSizeRemain = 0.0;
        }
        // contentSize不足 contentOffset会正值补充 计算补充值 键盘消失时 去掉该补充
        if (consentSizeRemain < gapFromCellBottomToReplyViewTop) {
            additionalContentOffset = gapFromCellBottomToReplyViewTop - consentSizeRemain;
        }
    }
    // 位差为负(cellBottomY < replyViewTopY), tableView需要向下滚动, 如果contentOffset不足 contentOffset会负值补充 键盘消失时 要去掉补充
    else if (gapFromCellBottomToReplyViewTop < 0.0) {
//        // 计算contentSize下滑剩余量
//        // to do contentSize下滑剩余量 是否为contentOffset.y?
//        CGFloat consentSizeTopRemain = self.contentView.contentOffset.y;
//        // to do contentSize下滑剩余量为负 是否可以当作consentSizeTopRemain = 0处理?
//        if (consentSizeTopRemain < 0.0) {
//            consentSizeTopRemain = 0.0;
//        }
//        // contentSize下滑剩余量不足 contentOffset会负值补充 计算补充值 键盘消失时 去掉该补充
//        if (consentSizeTopRemain < fabs((double)gapFromCellBottomToReplyViewTop)) {
//            additionalContentOffset = -(fabs((double)gapFromCellBottomToReplyViewTop) - consentSizeTopRemain);
//        }
        
        // 2.0.0开始 位差为负 不再向下滚动tableView
        additionalContentOffset = 0.0;
        gapFromCellBottomToReplyViewTop = 0.0;
    }
    
    // 计算tableView contentOffset的额外偏移
    // to do additionalContentOffset每次累加是否存在bug? 也就是切换键盘时additionalContentOffset这样处理是否合理?
    self.additionalContentOffset += additionalContentOffset;
    
    // 滚动tableView
    self.contentView.contentOffset = CGPointMake(0.0,  self.contentView.contentOffset.y + gapFromCellBottomToReplyViewTop);
}

#pragma mark TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [self.textField.text stringByAppendingString:string];
    if (str.length > self.contentmaxlength) {
        str = [str substringToIndex:self.contentmaxlength];
        textField.text = str;
        self.commentSendButton.enabled = YES;
        return NO;
    }
    
    return YES;
}

@end
