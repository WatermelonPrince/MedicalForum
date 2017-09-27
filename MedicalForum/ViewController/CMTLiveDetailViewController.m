//
//  CMTLiveDetailViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// controller
#import "CMTLiveDetailViewController.h"                     // header file
#import "CMTBindingViewController.h"                        // 登录页
#import "CMTLiveTagFilterViewController.h"                  // 直播标签筛选列表                               

// view
#import "CMTCaseListCell.h"                                 // 直播详情视图
#import "UITableView+CMTExtension_PlaceholderView.h"        // 评论列表空数据提示
#import "CMTCommentListCell.h"                              // 评论cell
#import "CMTReplyToolBar.h"                                 // 回复工具条
#import "CMTReplyInputView.h"                               // 评论输入框

// viewModel
#import "CMTLiveDetailViewModel.h"                          // 直播详情数据
#import "SDWebImageManager.h"                               // 图片缓存

@interface CMTLiveDetailViewController () <UITableViewDataSource, UITableViewDelegate, CMTLiveListCellDelegate>

// view
@property (nonatomic, strong) CMTCaseListCell *liveDetailView;                      // 直播详情视图
@property (nonatomic, strong) UITableView *tableView;                               // 直播详情 + 直播评论列表
@property (nonatomic, strong) CMTReplyToolBar *replyToolBar;                        // 直播回复工具条
@property (nonatomic, strong) CMTReplyInputView *replyInputView;                    // 直播评论输入框

// viewModel
@property (nonatomic, strong) CMTLiveDetailViewModel *viewModel;                    // 直播详情数据
@property (nonatomic, assign) CMTLiveDetailType liveDetailType;                     // 直播详情类型

@end

@implementation CMTLiveDetailViewController

#pragma mark - Initializers

- (instancetype)initWithLiveDetail:(CMTLive *)liveDetail
                    liveDetailType:(CMTLiveDetailType)liveDetailType {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.liveDetailType = liveDetailType;
    self.viewModel = [[CMTLiveDetailViewModel alloc] initWithLiveDetail:liveDetail];
    
    return self;
}

- (instancetype)initWithLiveBroadcastMessageId:(NSString *)liveBroadcastMessageId
                                liveDetailType:(CMTLiveDetailType)liveDetailType {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.liveDetailType = liveDetailType;
    self.viewModel = [[CMTLiveDetailViewModel alloc] initWithLiveBroadcastMessageId:liveBroadcastMessageId];
    
    return self;
}
- (instancetype)initWithLiveMessageUuid:(NSString *)MessageUuid
                                liveDetailType:(CMTLiveDetailType)liveDetailType {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.liveDetailType = liveDetailType;
    self.viewModel = [[CMTLiveDetailViewModel alloc] initWithLiveMessageUuid:MessageUuid];
    
    return self;
}

- (CMTCaseListCell *)liveDetailView {
    if (_liveDetailView == nil) {
        _liveDetailView = [[CMTCaseListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _liveDetailView.isShowinteractive = NO;
        _liveDetailView.isLivedetails = YES;
        _liveDetailView.liveDelegate = self;
        _liveDetailView.lastController=self;
    }
    
    return _liveDetailView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentBaseView.width, self.contentBaseView.height)];
        _tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, (CMTReplyToolBarDefaultHeight - PIXEL) + 100.0, 0.0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTReplyToolBarDefaultHeight, 0.0);
        _tableView.backgroundColor = COLOR(c_fafafa);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollsToTop = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CMTCommentListCell class] forCellReuseIdentifier:CMTLiveDetailCommentListCommentCellIdentifier];
        _tableView.placeholderView = [self tableViewPlaceholderView];
    }
    
    return _tableView;
}

- (UIView *)tableViewPlaceholderView {
    UIView *placeholderView = [[UIView alloc] init];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(15.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text = @"同行好友若相问，我在【壹生】写评论…";
    
    [placeholderView addSubview:placeholderLabel];
    
    return placeholderView;
}

- (CMTReplyToolBar *)replyToolBar {
    if (_replyToolBar == nil) {
        _replyToolBar = [[CMTReplyToolBar alloc] initWithFrame:CGRectMake(0.0,
                                                                          self.contentBaseView.height - CMTReplyToolBarDefaultHeight,
                                                                          self.contentBaseView.width,
                                                                          CMTReplyToolBarDefaultHeight)
                                                         items:@[
                                                                 [CMTReplyToolBarItem itemWithItemTitle:@"分享" itemIcon:@"replyToolBarShare"],
                                                                 [CMTReplyToolBarItem itemWithItemTitle:@"评论" itemIcon:@"comments"],
                                                                 [CMTReplyToolBarItem itemWithItemTitle:@"赞" itemIcon:@"unpraise"],
                                                                 ]];
    }
    
    return _replyToolBar;
}

- (CMTReplyInputView *)replyInputView {
    if (_replyInputView == nil) {
        _replyInputView = [[CMTReplyInputView alloc] initWithInputViewModel:CMTReplyInputViewModelLiveDetail
                                                           contentMaxLength:200];
    }
    
    return _replyInputView;
}

#pragma mark - LifeCycle

- (void)loadView {
    [super loadView];
    
    // 直播详情 + 直播评论列表
    [self.contentBaseView addSubview:self.tableView];
    // 直播回复工具条
    [self.contentBaseView addSubview:self.replyToolBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"LiveDetail willDeallocSignal");
    }];
    
#pragma mark 导航栏按钮
    
    // 返回按钮
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    
#pragma mark 直播详情
    
    // 显示加载动画
    self.contentState = CMTContentStateLoading;
    
    // 加载直播详情
    [[[RACObserve(self.viewModel, liveDetail) ignore:nil]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        // 刷新直播详情视图
        [self reloadLiveDetailView];
        self.contentState = CMTContentStateNormal;
        // 直播快速评论 显示键盘
        if (self.viewModel.viewDidAppearState == YES &&
            self.viewModel.quickReplyFinish == NO &&
            self.liveDetailType == CMTLiveDetailTypeLiveListWithReply) {
            self.viewModel.quickReplyFinish = YES;
            
            // 显示键盘
            [self.replyInputView showInputView];
        }
        
        // 刷新直播回复工具条分享按钮/评论数/点赞数
        [self updateReplyToolBarShareItem];
        [self updateReplyToolBarCommentItem];
        [self updateReplyToolBarPraiseItem];
        // 刷新直播分享数据
        self.viewModel.shareTitle = [NSString stringWithFormat:@"%@在%@说:",
                                     self.viewModel.liveDetail.createUserName ?: @"",
                                     self.viewModel.liveDetail.liveBroadcastName ?: @""];
        self.viewModel.shareDescription = self.viewModel.liveDetail.content;
        self.viewModel.shareURL = self.viewModel.liveDetail.liveBroadcastMessageShareUrl;
    }];
    
    // 刷新直播详情参与成员
    [[[[RACObserve(self.viewModel, liveDetailRequestStatusInfo) ignore:nil] filter:^BOOL(id value) {
        return [value isEqual:CMTClientRequestStatusInfoFinish];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        // 刷新直播详情视图
        [self reloadLiveDetailView];
    }];
    
    // 刷新直播详情
    self.liveDetailView.updateheadView = ^(){
        @strongify(self);
        self.tableView.tableHeaderView = self.liveDetailView;
        self.tableView.placeholderView.top = self.liveDetailView.bottom;
    };
    
    // 请求直播详情网络错误 显示重新加载
    [[[[RACObserve(self.viewModel, liveDetailRequestStatusInfo) ignore:nil] filter:^BOOL(id value) {
        return [value isEqual:CMTClientRequestStatusInfoNetError];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        self.contentState = CMTContentStateReload;
    }];
    
    // 请求直播详情服务器错误消息 空白页显示消息
    [[[[[RACObserve(self.viewModel, liveDetailRequestStatusInfo) ignore:nil] map:^id(NSString *info) {
        return [info serverErrorMessage];
    }] ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorMessage) {
        @strongify(self);
        self.contentEmptyView.contentEmptyPrompt = errorMessage;
        self.contentState = CMTContentStateEmpty;
    }];
    
    // 请求直播详情系统错误信息 显示空白页并提示
    [[[[[RACObserve(self.viewModel, liveDetailRequestStatusInfo) ignore:nil] map:^id(NSString *info) {
        return [info systemErrorMessage];
    }] ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorString) {
        @strongify(self);
        self.contentState = CMTContentStateBlank;
        [self toastAnimation:@"系统错误"];
        CMTLogError(@"LiveDetail 系统错误:\n%@", errorString);
    }];
   
#pragma mark 直播评论列表
    
    // 直播评论数
    RAC(self.replyInputView, badgeNumber) = [[RACObserve(self.viewModel, liveDetail.commentCount)
                                         distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
    
    // 直播评论列表
    [[[[RACObserve(self.viewModel, liveCommentRequestStatusInfo) ignore:nil] filter:^BOOL(id value) {
        return [value isEqual:CMTClientRequestStatusInfoFinish];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        // 刷新直播评论列表
        [self.tableView reloadData];
        self.tableView.placeholderView.top = self.liveDetailView.bottom;
        // 直播快速评论 滑动到第一条直播评论
        [self scrollToFirstLiveComment];
    }];
    
    // 直播评论翻页
    [self.tableView addInfiniteScrollingWithActionHandler:nil];
    RAC(self.viewModel, infiniteScrollingState) = [RACObserve(self.tableView.infiniteScrollingView, state) distinctUntilChanged];
    [[RACObserve(self.tableView, contentSize) distinctUntilChanged] subscribeNext:^(NSValue *contentSize) {
        @strongify(self);
        if ([self.viewModel numberOfRowsInSection:0] == 0) {
            self.tableView.showsInfiniteScrolling = NO;
            self.tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, (CMTReplyToolBarDefaultHeight - PIXEL) + 100.0, 0.0);
        }
        else if ((self.tableView.contentInset.top + contentSize.CGSizeValue.height + CMTReplyToolBarDefaultHeight) <= self.tableView.height) {
            self.tableView.showsInfiniteScrolling = NO;
            self.tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, (CMTReplyToolBarDefaultHeight - PIXEL), 0.0);
        }
        else {
            self.tableView.showsInfiniteScrolling = YES;
            self.tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, (CMTReplyToolBarDefaultHeight - PIXEL), 0.0);
        }
    }];
    
    // 停止翻页的加载中动画
    [[[RACObserve(self.viewModel, liveCommentRequestStatusInfo) filter:^BOOL(id value) {
        return ![value isEqual:CMTClientRequestStatusInfoSent];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.infiniteScrollingView stopAnimating];
    }];

#pragma mark 发送直播评论
    
    // 点击回复直播评论按钮
    [[[self.replyToolBar itemAtIndex:1] itemTouchSignal] subscribeNext:^(id x) {
        @strongify(self);
        // 未登陆
        if (CMTUSER.login == NO) {
            // 提示登录
            UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"请登录之后发布评论"
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
            [[loginAlert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                @strongify(self);
                if ([index integerValue] == 1) {
                    CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
                    loginVC.nextvc = kComment;
                    [self.navigationController pushViewController:loginVC animated:YES];
                }
            }];
            [loginAlert show];
        }
        // 已登录
        else {
            // 显示直播评论回复框
            [self.replyInputView showInputView];
        }
    }];
    
    // 被回复直播评论昵称
    [[RACObserve(self.viewModel, liveCommentToReply)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTLiveComment * liveComment) {
        @strongify(self);
        NSString *nickName = nil;
        if ([liveComment respondsToSelector:@selector(userNickname)]) {
            nickName = [liveComment performSelector:@selector(userNickname)];
        }
        
        self.replyInputView.beRepliedNickName = nickName;
    }];
    
    // 直播评论内容
    [[RACSignal merge:@[
                        self.replyInputView.commentTextSignal,
                        [[RACObserve(self.replyInputView, contentTextView.text) ignore:nil] distinctUntilChanged],
                        ]] subscribeNext:^(NSString *text) {
        @strongify(self);
        // 正文内容超出字数限制
        if (text.length > 200) {
            self.viewModel.liveCommentText = [text substringToIndex:200];
        }
        else {
            self.viewModel.liveCommentText = text;
        }
    }];
    
    // 点击发送直播评论按钮
    self.viewModel.liveCommentSendButtonSignal = self.replyInputView.commentSendButtonSignal;
    
    // 直播评论/回复已经发送
    [[[[RACObserve(self.viewModel, sendLiveCommentRequestStatusInfo) ignore:nil] filter:^BOOL(id value) {
        return [value isEqual:CMTClientRequestStatusInfoSent];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        // 关闭键盘
        [self.replyInputView hideInputView];
        // 清空回复内容
        self.replyInputView.contentTextView.text = nil;
        // 清空被回复的直播评论/回复
        self.viewModel.liveCommentToReply = nil;
    }];
    
    // 关闭键盘
    [[self.replyInputView.commentCancelButtonSignal delay:0.2] subscribeNext:^(id x) {
        @strongify(self);
        // 清空被回复对象
        self.viewModel.liveCommentToReply = nil;
    }];

    // 发送直播评论失败
    [[[[[RACObserve(self.viewModel, sendLiveCommentRequestStatusInfo) ignore:nil] map:^id(NSString *info) {
        return [info serverErrorMessage];
    }] ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorMessage) {
        @strongify(self);
        [self toastAnimation:errorMessage];
    }];
    
#pragma mark 直播点赞
    
    // 点击直播点赞按钮
    [[[self.replyToolBar itemAtIndex:2] itemTouchSignal] subscribeNext:^(id x) {
        @strongify(self);
        // 未登陆
        if (CMTUSER.login == NO) {
            // 跳转登陆页
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [self.navigationController pushViewController:loginVC animated:YES];
        }
        // 已登录
        else {
            // 已点赞 无操作
            if ([self.viewModel.liveDetail.isPraise isEqual:@"1"]) {
                return;
            }
            // 未点赞
            // 调用直播点赞接口
            [[[CMTCLIENT live_message_praise:@{
                                               @"userId": CMTUSERINFO.userId ?: @"0",
                                               @"liveBroadcastMessageId": self.viewModel.liveBroadcastMessageId ?: @"",
                                               }]
              deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                @strongify(self)
                // 创建新的参与者
                CMTParticiPators *particiPator = [[CMTParticiPators alloc] initWithDictionary:@{
                                                                                                @"userId": CMTUSERINFO.userId ?: @"",
                                                                                                @"nickname": self.viewModel.liveDetail.userName ?: @"",
                                                                                                @"picture": self.viewModel.liveDetail.userPic ?: @"",
                                                                                                @"opTime": TIMESTAMP ?: @"",
                                                                                                } error:nil];
                // 去重
                NSMutableArray *praiseUserList = [NSMutableArray arrayWithArray:self.viewModel.liveDetail.praiseUserList];
                for (NSInteger index = 0; index < praiseUserList.count; index++) {
                    CMTParticiPators *tempParticiPator = [praiseUserList objectAtIndex:index];
                    if ([tempParticiPator.userId isEqual:particiPator.userId] && [tempParticiPator.userType isEqual:@"0"]) {
                        [praiseUserList removeObject:tempParticiPator];
                        break;
                    }
                }
                // 新的参与者放到列表第一个
                [praiseUserList insertObject:particiPator atIndex:0];
                self.viewModel.liveDetail.praiseUserList = praiseUserList;
                // 刷新直播详情
                [self reloadLiveDetailView];
                // 更新点赞状态及点赞数
                self.viewModel.liveDetail.isPraise = @"1";
                self.viewModel.liveDetail.praiseCount = [NSString stringWithFormat:@"%ld", (long)(self.viewModel.liveDetail.praiseCount.integerValue + 1)];
            }];
        }
    }];

#pragma mark 直播评论数/点赞数
    
    [[[RACSignal merge:@[
                         [[[RACObserve(self.viewModel, liveDetail.commentCount) ignore:nil] skip:1] distinctUntilChanged],
                         [[[RACObserve(self.viewModel, liveDetail.praiseCount) ignore:nil] skip:1] distinctUntilChanged],
                         [[[RACObserve(self.viewModel, liveDetail.isPraise) ignore:nil] skip:1] distinctUntilChanged],
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        // 刷新直播回复工具条评论数/点赞数
        [self updateReplyToolBarCommentItem];
        [self updateReplyToolBarPraiseItem];
        // 刷新直播列表统计数
        if (self.updateLiveStatistics != nil) {
            self.updateLiveStatistics(self.viewModel.liveDetail);
        }
    }];
    
#pragma mark 直播编辑/分享
    
    [[[self.replyToolBar itemAtIndex:0] itemTouchSignal] subscribeNext:^(id x) {
        @strongify(self);
        // 点击直播编辑按钮
        if ([self.viewModel.liveDetail.createUserId isEqual:CMTUSERINFO.userId]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:nil
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"分享", @"删除", nil];
            [actionSheet.rac_buttonClickedSignal subscribeNext:^(NSNumber *indexNumber) {
                @strongify(self);
                // 点击直播分享按钮
                if (indexNumber.integerValue == 0) {
                    [self CMTShareAction];
                }
                // 点击直播删除按钮
                else if (indexNumber.integerValue == 1) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                        message:@"确定删除该篇帖子"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    [alertView.rac_buttonClickedSignal subscribeNext:^(NSNumber *indexNumber) {
                        @strongify(self);
                        if (indexNumber.integerValue == 1) {
                            // 调用删除直播详情接口
                            [[[CMTCLIENT deleteLive_message:@{
                                                              @"userId": CMTUSERINFO.userId ?: @"0",
                                                              @"liveBroadcastMessageId": self.viewModel.liveBroadcastMessageId ?: @"",
                                                              }]
                              deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                                @strongify(self);
                                if (self.deleteLiveBroadcastMessage != nil) {
                                    self.deleteLiveBroadcastMessage(self.viewModel.liveDetail);
                                }
                                [self popViewController];
                            }];
                        }
                    }];
                    [alertView show];
                }
            }];
            [actionSheet showInView:self.view];
        }
        // 点击直播分享按钮
        else {
            [self CMTShareAction];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
    if (self.updateLiveNoticeStatus != nil) {
        self.updateLiveNoticeStatus();
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
    self.viewModel.viewDidAppearState = YES;
    
    // 直播快速评论 显示键盘
    if (self.viewModel.liveDetail != nil &&
        self.viewModel.quickReplyFinish == NO &&
        self.liveDetailType == CMTLiveDetailTypeLiveListWithReply) {
        self.viewModel.quickReplyFinish = YES;
        
        // 显示键盘
        [self.replyInputView showInputView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    // 请求直播详情
    self.viewModel.reloadLiveDetailState = YES;
    // 显示加载动画
    self.contentState = CMTContentStateLoading;
}

#pragma mark - TableView

- (void)reloadLiveDetailView {
    [self.liveDetailView reloadLiveCell:self.viewModel.liveDetail index:nil];
    [self reloadTableHeaderView];
}

- (void)reloadTableHeaderView {
    self.tableView.tableHeaderView = self.liveDetailView;
    self.tableView.placeholderView.top = self.liveDetailView.bottom;
}

- (void)scrollToFirstLiveComment {
    if (self.liveDetailType != CMTLiveDetailTypeLiveListSeeReply ||
        self.viewModel.quickReplyFinish == YES) {
        return;
    }
    self.viewModel.quickReplyFinish = YES;
    UIViewAnimationOptions keyboardAnimationCurve = 7;
    keyboardAnimationCurve |= keyboardAnimationCurve<<16;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:keyboardAnimationCurve
                     animations:^{
                         @try {
                             if ([self.viewModel numberOfRowsInSection:0] > 0) {
                                 CGFloat contentOffsetY = 0.0;
                                 CGFloat lastCoveredHeight = self.tableView.contentSize.height;
                                 CGFloat displayHeight = self.tableView.height - (self.tableView.contentInset.top + self.tableView.contentInset.bottom);
                                 CGFloat firstCellY = self.liveDetailView.height;
                                 
                                 // 第一条直播评论与最后一条直播评论之间高度大于一屏
                                 if (lastCoveredHeight - firstCellY > displayHeight) {
                                     // 滑动到第一条直播评论置顶
                                     contentOffsetY = firstCellY;
                                 }
                                 // 第一条直播评论与最后一条直播评论之间高度小于一屏
                                 else {
                                     // 滑动到最后一条直播评论置底
                                     contentOffsetY = lastCoveredHeight - displayHeight > 0.0 ? lastCoveredHeight - displayHeight : 0.0;
                                 }
                                 
                                 [self.tableView setContentOffset:(CGPoint){0.0, -self.tableView.contentInset.top + contentOffsetY} animated:YES];
                             }
                         }
                         @catch (NSException *exception) {
                             CMTLogError(@"LiveDetail Scroll To First LiveComment Exception: %@", exception);
                         }
                     } completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return PIXEL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTLiveComment *liveComment = [self.viewModel liveCommentForRowAtIndexPath:indexPath];
    return [CMTCommentListCell cellHeightFromLiveComment:liveComment cellWidth:tableView.width];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *separatorLine = [[UIView alloc] init];
    [separatorLine sizeToBuiltinContainer:tableView WithLeft:0.0 Top:0.0 Width:tableView.width Height:PIXEL];
    separatorLine.backgroundColor = COLOR(c_9e9e9e);
    
    return separatorLine;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTLiveComment *liveComment = [self.viewModel liveCommentForRowAtIndexPath:indexPath];
    CMTCommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CMTLiveDetailCommentListCommentCellIdentifier forIndexPath:indexPath];
    [cell reloadLiveComment:liveComment cellWidth:tableView.width indexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 未登陆
    if (CMTUSER.login == NO) {
        // 提示登录
        UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"请登录之后发布评论"
                                                             message:nil
                                                            delegate:nil
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:@"确定", nil];
        @weakify(self);
        [[loginAlert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if ([index integerValue] == 1) {
                CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
                loginVC.nextvc = kComment;
                [self.navigationController pushViewController:loginVC animated:YES];
            }
        }];
        [loginAlert show];
        return;
    }
    
    // 获取选中的直播评论
    CMTLiveComment *liveComment = [self.viewModel liveCommentForRowAtIndexPath:indexPath];
    
    // 删除直播评论
    if ([liveComment.userId isEqual:CMTUSERINFO.userId]) {
        // 删除提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否删除该评论"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        @weakify(self);
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            // 确定删除
            if ([index integerValue] == 1) {
                self.viewModel.liveCommentToDelete = liveComment;
            }
        }];
        [alert show];
        return;
    }
    
    // 回复直播评论
    // 显示键盘
    [self.replyInputView showInputView];
    // 设置被回复的直播评论
    self.viewModel.liveCommentToReply = liveComment;
}

#pragma mark - CMTReplyToolBar

- (void)updateReplyToolBarShareItem {
    CMTReplyToolBarItem *shareItem = [self.replyToolBar itemAtIndex:0];
    // 直播编辑按钮
    if ([self.viewModel.liveDetail.createUserId isEqual:CMTUSERINFO.userId]) {
        shareItem.itemIconImageView.image = IMAGE(@"live_item_more");
        shareItem.itemIconImageView.left = (shareItem.width - shareItem.itemIconImageView.width)/2.0;
        shareItem.itemTitleLabel.text = @"";
    }
    // 直播分享按钮
    else {
        shareItem.itemIconImageView.image = IMAGE(@"replyToolBarShare");
        shareItem.itemTitleLabel.text = @"分享";
    }
}

- (void)updateReplyToolBarCommentItem {
    CMTReplyToolBarItem *commentItem = [self.replyToolBar itemAtIndex:1];
    // 直播评论数
    NSString *commentCount = self.viewModel.liveDetail.commentCount;
    if (commentCount.integerValue <= 0) {
        commentCount = @"评论";
    }
    commentItem.itemTitleLabel.text = commentCount;
}

- (void)updateReplyToolBarPraiseItem {
    CMTReplyToolBarItem *praiseItem = [self.replyToolBar itemAtIndex:2];
    // 直播点赞数
    NSString *praiseCount = self.viewModel.liveDetail.praiseCount;
    if (praiseCount.integerValue <= 0) {
        praiseCount = @"赞";
    }
    praiseItem.itemTitleLabel.text = praiseCount;
    // 直播点赞图标
    if ([self.viewModel.liveDetail.isPraise isEqual:@"0"]) {
        praiseItem.itemIconImageView.image = IMAGE(@"unpraise");
        praiseItem.itemTitleLabel.textColor = COLOR(c_9e9e9e);
    }
    else if ([self.viewModel.liveDetail.isPraise isEqual:@"1"]) {
        praiseItem.itemIconImageView.image = IMAGE(@"praise");
        praiseItem.itemTitleLabel.textColor = COLOR(c_32c7c2);
    }
}

#pragma mark - 直播标签筛选

- (void)CMTGoLiveTagList:(CMTLiveTag *)LiveTag {
    CMTLiveTagFilterViewController *liveTagFilterViewController = [[CMTLiveTagFilterViewController alloc] initWithlive:self.viewModel.liveDetail
                                                                                                    liveBroadcastTagId:LiveTag.liveBroadcastTagId
                                                                                                  liveBroadcastTagName:LiveTag.name];
    [self.navigationController pushViewController:liveTagFilterViewController animated:YES];
}
#pragma mark - ShareMethod

// 分享处理方法 add byguoyuanchao
- (void)CMTShareAction {
    if (BEMPTY(self.viewModel.shareTitle) ||
        BEMPTY(self.viewModel.shareDescription) ||
        BEMPTY(self.viewModel.shareURL)) {
        return;
    }
    [self.mShareView.mBtnFriend addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.cancelBtn addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    // 自定义分享
    [self shareViewshow:self.mShareView bgView:self.tempView currentViewController:self.navigationController];
}

- (void)showShare:(UIButton *)btn {
    [self methodShare:btn];
}

///平台按钮关联的分享方法
- (void)methodShare:(UIButton *)btn {
    self.viewModel.liveDetail.shareModel=@"1";
    self.viewModel.liveDetail.shareServiceId=self.viewModel.liveDetail.liveBroadcastMessageId;
    // 没有网络连接
    if (!NET_WIFI && !NET_CELL && btn.tag != 5555) {
        [self toastAnimation:@"你的网络不给力"];
        [self shareViewDisapper];
        return;
    }
    
    NSString *shareType = nil;
    switch (btn.tag)
    {
        case 1111:
        {
            if ([self respondsToSelector:@selector(friendCircleShare)]) {
                [self performSelector:@selector(friendCircleShare) withObject:nil afterDelay:0.20];
            }
            
        }
            break;
        case 2222:
        {
            if ([self respondsToSelector:@selector(weixinShare)]) {
                [self performSelector:@selector(weixinShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 3333:
        {
            shareType = @"3";
            if ([self respondsToSelector:@selector(weiboShare)]) {
                [self performSelector:@selector(weiboShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 4444:
        {
            CMTLog(@"邮件");
            shareType = @"4";
            NSInteger toIndex = self.viewModel.liveDetail.content.length;
            NSString *pointString = @"";
            if (toIndex > 15) {
                toIndex = 15;
                pointString = @"...";
            }
            NSString *shareText = [NSString stringWithFormat:@"%@在现场说了什么？<br>%@%@",
                                   self.viewModel.liveDetail.createUserName ?: @"",
                                   [self.viewModel.liveDetail.content substringToIndex:toIndex] ?: @"",
                                   pointString];
            NSString *pContent = [NSString stringWithFormat:@"#壹生# %@<br>%@<br>来自@壹生<br>", shareText, self.viewModel.shareURL];
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_Email shareTitle:self.viewModel.liveDetail.liveBroadcastName sharetext:pContent sharetype:shareType sharepic:self.viewModel.liveDetail.sharePic.picFilepath shareUrl:self.viewModel.shareURL StatisticalType:@"getShareLive" shareData:self.viewModel.liveDetail];
        }
            break;
        case 5555:
            [self shareViewDisapper];
            break;
        default:
            CMTLog(@"其他分享");
            break;
    }
    if ([self respondsToSelector:@selector(removeTargets)]) {
        [self performSelector:@selector(removeTargets) withObject:nil afterDelay:0.2];
    }
    
    [self shareViewDisapper];
}

- (void)removeTargets {
    [self.mShareView.mBtnFriend removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
}

/// 朋友圈分享
- (void)friendCircleShare {
    NSString *shareType = @"1";
    CMTLog(@"朋友圈");
    NSString *shareText = [NSString stringWithFormat:@"%@在现场说了什么？", self.viewModel.liveDetail.createUserName ?: @""];
   [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.viewModel.liveDetail.sharePic.picFilepath shareUrl:self.viewModel.shareURL StatisticalType:@"getShareLive" shareData:self.viewModel.liveDetail];
}
/// 微信好友分享
- (void)weixinShare {
    NSString *shareType = @"2";
    NSInteger toIndex = self.viewModel.liveDetail.content.length;
    NSString *pointString = @"";
    if (toIndex > 15) {
        toIndex = 15;
        pointString = @"...";
    }
    NSString *shareTitle = [NSString stringWithFormat:@"%@在现场说了什么？", self.viewModel.liveDetail.createUserName ?: @""];
    NSString *shareText = [NSString stringWithFormat:@"%@%@", [self.viewModel.liveDetail.content substringToIndex:toIndex] ?: @"", pointString];
    NSString *shareURL = self.viewModel.shareURL;
    if (BEMPTY(shareText)) {
        //        shareText = self.viewModel.postDetail.title;
        shareText =@"壹生文章分享";
    }
     [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.viewModel.liveDetail.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"getShareLive" shareData:self.viewModel.liveDetail];
}

- (void)weiboShare {
    NSInteger toIndex = self.viewModel.liveDetail.content.length;
    NSString *pointString = @"";
    if (toIndex > 15) {
        toIndex = 15;
        pointString = @"...";
    }
    NSString *title = [NSString stringWithFormat:@"%@在现场说了什么？", self.viewModel.liveDetail.createUserName ?: @""];
    NSString *text = [NSString stringWithFormat:@"%@%@", [self.viewModel.liveDetail.content substringToIndex:toIndex] ?: @"", pointString];
    NSString *shareText = [NSString stringWithFormat:@"#%@# %@%@ %@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY, title, text, self.viewModel.shareURL];
    
    CMTLog(@"新浪文博\nshareText:%@", shareText);
    NSString *shareType=@"3";
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.viewModel.liveDetail.sharePic.picFilepath shareUrl:self.viewModel.shareURL StatisticalType:@"getShareLive" shareData:self.viewModel.liveDetail];
}



@end
