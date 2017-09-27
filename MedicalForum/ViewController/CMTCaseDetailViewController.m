//
//  CMTCaseDetailViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/7/30.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// controller
#import "CMTCaseDetailViewController.h"                     // header file
#import "CMTBindingViewController.h"                        // 登录页
#import "CMTUpgradeViewController.h"                        // 申请认证页
#import "CMTOtherPostListViewController.h"                  // 其他文章列表
#import "MWPhotoBrowser.h"                                  // 图片浏览器
#import "CMTPDFBrowserViewController.h"                     // PDF浏览器
#import "CMTWebBrowserViewController.h"                     // 网页浏览器
#import "CMTSendCaseViewController.h"                       // 发帖页面
#import "CMTCollectionViewController.h"                     // 收藏页

// view
#import "UIScrollView+CMTExtension_TableScrollView.h"       // TableScrollView
#import "CMTCommentListCell.h"                              // 评论cell
#import "CMTReplyListWrapCell.h"                            // 回复cell
#import "CMTReplyView.h"                                    // 评论回复框
#import "CMTReplyInputView.h"                               // 评论输入框
#import "CMTTapToRefresh.h"                                 // 点击刷新
#import "CMTCasefilterView.h"                               // 文章追加选择器
#import "CMTUserNotAuthenticView.h"                         // 用户未认证提示
#import "CMTPostProgressView.h"                             // 发帖进度条

// viewModel
#import "CMTPostDetailViewModel.h"                          // 文章详情数据
#import "CMTGroupInfoViewController.h"
#import "CMTLiveDetailViewController.h"
#import "CMTLiveViewController.h"
#import "LDZMoviePlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "CMTBaseViewController+CMTExtension.h"
@interface CMTCaseDetailViewController () <UIWebViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, CMTTableScrollViewDataSource, CMTTableScrollViewDelegate, CMTReplyListWrapCellDelegate, MWPhotoBrowserDelegate, CMTCommentListCellPraiseDelegate, CMTCasefilterViewDelegate,CMTPostProgressViewDelegate,UIActionSheetDelegate>

// view
@property (nonatomic, strong) UIBarButtonItem *shareItem;                           // 分享按钮
@property (nonatomic, strong) UIBarButtonItem *favoriteItem;                        // 收藏按钮
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) NSArray *rightItems;                                  // 导航右侧按钮
@property (nonatomic, strong) UIWebView *webView;                                   // 文章详情 + 点击刷新 + 评论列表
@property (nonatomic, strong) UIWebView *webViewModel;                              // 用于计算文章详情高度
@property (nonatomic, strong) CMTReplyView *replyView;                              // 评论回复框
@property (nonatomic, strong) CMTReplyInputView *replyInputView;                    // 直播评论输入框
@property (nonatomic, strong) CMTTapToRefresh *tapToRefresh;                        // 点击刷新
@property (nonatomic, strong) CMTCasefilterView *appendDetailFilter;                // 文章追加选择器
@property (nonatomic, strong) UIView *commentListHeader;                            // 评论列表顶部视图
@property (nonatomic, strong) CMTUserNotAuthenticView *userNotAuthenticView;        // 用户未认证提示
@property (nonatomic, strong) UIAlertView *loginAlert;                              // 登陆提示
@property (nonatomic, strong) UIAlertView *cancelStoreAlert;                        // 取消收藏提示
@property (nonatomic, strong) NSTimer *webViewHeightTimer;                          // 监听webview高度变化

// viewModel
@property (nonatomic, strong) CMTPostDetailViewModel *viewModel;                    // 数据
@property (nonatomic, assign) CMTPostDetailType postDetailType;                     // 详情类型
@property (assign) NSUInteger index;                                                // 用来记录删除收藏在数据中的下表

///分享title
@property (strong, nonatomic) NSString *shareTitle;
///分享brief
@property (strong, nonatomic) NSString *shareBrief;
///分享url
@property (strong, nonatomic) NSString *shareUrl;

//动态模板登陆事件登陆成功后刷新web view add by guoyuanchao
@property(nonatomic,assign)BOOL isreloadWebView;

@property(nonatomic,assign)NSInteger webViewLoadNumbers; // webView 加载的次数;
@property(nonatomic,assign)NSInteger webViewModelLoadNumbers; // modelwebView 加载的次数;
@property(nonatomic,strong)CMTPostProgressView *progressView;//进度条
@property(nonatomic,assign)BOOL greaterthanonescreen ;//滑动到的位置
@property(nonatomic,strong)NSURLRequest *lastRequest;//记录上一次加载的url;
@property(nonatomic,strong)NSURLRequest *lastmodelRequest;//记录上一次加载的url;
@property(nonatomic,strong)NSString *groupID;//文章小组ID
@property(nonatomic,strong)CMTGroup*mygroup;//文章小组对象
@property(nonatomic,assign)BOOL isdetailnomal;//文章详情是否正常
@property(nonatomic,assign)BOOL isHaveIframe;//是否页面包含IFrame对象
@property(nonatomic,strong)NSMutableArray *UrlArray;
@property(nonatomic,strong)UIBarButtonItem *moreBarItem;
@property(nonatomic,strong)NSString *videoUrlString;//链接地址
@property(nonatomic,assign)CMTime lastPalytime;//上次播放时间
@property(nonatomic,assign)BOOL isBeingUpdated;//是否正在更新
@property(nonatomic,assign)BOOL isHaveUpdated;//是否有更新
@property(nonatomic,strong)NSString*AudioName;
@property(nonatomic,strong)NSTimer *musicPlayedTime;

@end

@implementation CMTCaseDetailViewController

#pragma mark - Initializers

- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                    postModule:(NSString *)postModule
                postDetailType:(CMTPostDetailType)postDetailType {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    self.lastRequest=[[NSURLRequest alloc]init];
    self.lastmodelRequest=[[NSURLRequest alloc]init];
     self.UrlArray=[[NSMutableArray alloc]init];
    // 添加 文章详情
    self.webViewLoadNumbers = 1;
    self.webViewModelLoadNumbers=1;
    self.isdetailnomal=YES;
    self.postDetailType = postDetailType;
    self.viewModel = [[CMTPostDetailViewModel alloc] initWithPostId:postId
                                                             isHTML:isHTML
                                                            postURL:postURL
                                                         postModule:postModule
                                                 toDisplayedComment:nil];
    return self;
}
- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                       group:(CMTGroup *)group
                    postModule:(NSString *)postModule
                postDetailType:(CMTPostDetailType)postDetailType {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    self.lastRequest=[[NSURLRequest alloc]init];
    self.lastmodelRequest=[[NSURLRequest alloc]init];
    self.UrlArray=[[NSMutableArray alloc]init];
    // 添加 文章详情
    self.webViewLoadNumbers = 1;
    self.webViewModelLoadNumbers=1;
     self.isdetailnomal=YES;
    self.postDetailType = postDetailType;
    self.groupID=group.groupId;
    self.mygroup=group;
    self.viewModel = [[CMTPostDetailViewModel alloc] initWithPostId:postId
                                                             isHTML:isHTML
                                                            postURL:postURL
                                                            group:group
                                                         postModule:postModule
                                                 toDisplayedComment:nil];
    return self;
}


- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    self.lastRequest=[[NSURLRequest alloc]init];
    self.lastmodelRequest=[[NSURLRequest alloc]init];
     self.UrlArray=[[NSMutableArray alloc]init];
    // 添加 文章详情
    self.webViewLoadNumbers = 1;
    self.webViewModelLoadNumbers=1;
    self.postDetailType = CMTPostDetailTypeCommentEdit;
     self.isdetailnomal=YES;
    self.viewModel = [[CMTPostDetailViewModel alloc] initWithPostId:postId
                                                             isHTML:isHTML
                                                            postURL:postURL
                                                         postModule:postModule
                                                 toDisplayedComment:toDisplayedComment];
    return self;
}
- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                       group:(CMTGroup *)group
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    self.lastRequest=[[NSURLRequest alloc]init];
    self.lastmodelRequest=[[NSURLRequest alloc]init];
    self.webViewLoadNumbers = 1;
    self.webViewModelLoadNumbers=1;
     self.UrlArray=[[NSMutableArray alloc]init];
    self.postDetailType = CMTPostDetailTypeCommentEdit;
    self.groupID=group.groupId;
    self.mygroup=group;
    self.isdetailnomal=YES;
    self.viewModel = [[CMTPostDetailViewModel alloc] initWithPostId:postId
                                                             isHTML:isHTML
                                                            postURL:postURL
                                                              group:group
                                                         postModule:postModule
                                                 toDisplayedComment:toDisplayedComment];
    return self;
}
-(UIBarButtonItem*)moreBarItem{
    if (_moreBarItem==nil) {
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 30)];
        [button setTitle:@"更多" forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont boldSystemFontOfSize:18];
        [button setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(CmtMoreAction)  forControlEvents:UIControlEventTouchUpInside];
        _moreBarItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    }
    return _moreBarItem;
}


- (UIBarButtonItem *)shareItem {
    if (_shareItem == nil) {
        _shareItem = [[UIBarButtonItem alloc] initWithImage:IMAGE(@"naviBar_share")  style:UIBarButtonItemStylePlain target:nil action:nil];
        [_shareItem setBackgroundVerticalPositionAdjustment:-0.5 forBarMetrics:UIBarMetricsDefault];
    }
    
    return _shareItem;
}

- (UIButton *)favoriteButton{
    if (_favoriteButton == nil) {
        self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteButton.frame = CGRectMake(0, 0, 25, 25);
        [_favoriteButton setBackgroundImage:IMAGE(@"naviBar_favorit") forState:UIControlStateNormal];
    }
    return _favoriteButton;
}

- (UIBarButtonItem *)favoriteItem {
    if (_favoriteItem == nil) {
//        _favoriteItem = [[UIBarButtonItem alloc] initWithImage:IMAGE(@"naviBar_favorit") style:UIBarButtonItemStylePlain target:nil action:nil];
        self.favoriteButton.frame = CGRectMake(4, 4, 25, 25);
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 33, 33)];
        [view addSubview:self.favoriteButton];
        _favoriteItem = [[UIBarButtonItem alloc]initWithCustomView:view];
        [_favoriteItem setBackgroundVerticalPositionAdjustment:-0.5 forBarMetrics:UIBarMetricsDefault];
    }
    
    return _favoriteItem;
}

- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *rightFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        rightFixedSpace.width = -6 + (RATIO - 1)*(CGFloat)12;
        if(!isEmptyString(self.mygroup.memberGrade)&&(self.mygroup.memberGrade.integerValue<=1&& ![self.mygroup.memberGrade isEqualToString:@"-1"])){
            _rightItems = @[rightFixedSpace, self.moreBarItem];
        }else{
            if (self.mygroup.groupType.integerValue>=1||self.iscanShare) {
                _rightItems = @[rightFixedSpace, self.favoriteItem];
            }else{
              _rightItems = @[rightFixedSpace, self.favoriteItem, self.shareItem];
            }
        }
    }
    
    return _rightItems;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
        _webView.scrollView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTReplyViewDefaultHeight, 0.0);
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTReplyViewDefaultHeight, 0.0);
        _webView.scrollView.scrollsToTop = YES;
        _webView.backgroundColor = COLOR(c_fafafa);
        _webView.delegate = self;
        
        [_webView.scrollView initTableScrollView];
        _webView.scrollView.tableScrollViewDataSource = self;
        _webView.scrollView.tableScrollViewDelegate = self;
        _webView.scrollView.delegate = self;
        _webView.allowsInlineMediaPlayback = YES;
    }
    
    return _webView;
}

- (UIWebView *)webViewModel {
    if (_webViewModel == nil) {
        _webViewModel = [[UIWebView alloc] init];
        _webViewModel.scrollView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTReplyViewDefaultHeight, 0.0);
        _webViewModel.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTReplyViewDefaultHeight, 0.0);
        _webViewModel.scrollView.scrollsToTop = NO;
        _webViewModel.delegate = self;
    }
    
    return _webViewModel;
}

- (UIView *)replyPlaceholderView {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.webView.width, 100.0)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, placeholderView.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(15.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text = @"同行好友若相问，我在【壹生】写评论…";
    
    [placeholderView addSubview:placeholderLabel];
    
    return placeholderView;
}

- (CMTReplyView *)replyView {
    if (_replyView == nil) {
        _replyView = [[CMTReplyView alloc] initWithContentView:self.webView.scrollView contentmaxlength:500 model:CMTReplyViewModelPostDetail];
        [_replyView fillinContainer:self.contentBaseView WithTop:self.view.height - CMTReplyViewDefaultHeight Left:0 Bottom:0 Right:0];
    }
    
    return _replyView;
}

- (CMTReplyInputView *)replyInputView {
    if (_replyInputView == nil) {
        _replyInputView = [[CMTReplyInputView alloc] initWithInputViewModel:self.groupID!=nil?CMTReplyInputViewModelGroupPostDetail:CMTReplyInputViewModelPostDetail  contentMaxLength:500];
        _replyInputView.groupID=self.groupID;
    }
    
    return _replyInputView;
}

- (CMTTapToRefresh *)tapToRefresh {
    if (_tapToRefresh == nil) {
        _tapToRefresh = [[CMTTapToRefresh alloc] initWithFrame:CGRectMake(0.0, 0.0, self.webView.width, CMTTapToRefreshDefaultHeight)];
        _tapToRefresh.backgroundColor = COLOR(c_fafafa);
        _tapToRefresh.bottomLine.hidden = NO;
    }
    
    return _tapToRefresh;
}

- (CMTCasefilterView *)appendDetailFilter {
    if (_appendDetailFilter == nil) {
        _appendDetailFilter = [[CMTCasefilterView alloc] initWithFrame:CGRectMake(self.webView.width - 108.0*RATIO, 0.0, 94.0*RATIO, 90.0)
                                                                titles:@[@"追加描述",@"添加结论"]
                                                    casefilterViewType:CMTCasefilterViewTypeAppendDetailFilter];
        _appendDetailFilter.layer.cornerRadius = 5.0;
        _appendDetailFilter.delegate = self;
    }
    
    return _appendDetailFilter;
}

- (UIView *)commentListHeader {
    if (_commentListHeader == nil) {
        _commentListHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.webView.width, 25.0)];
        _commentListHeader.backgroundColor = COLOR(c_efeff4);
        
        UILabel *commentListTitle = [[UILabel alloc] init];
        [commentListTitle builtinContainer:_commentListHeader WithLeft:15.0 Top:0.0 Width:_commentListHeader.width - 15.0 Height:_commentListHeader.height];
        commentListTitle.tag = 100;
        commentListTitle.backgroundColor = COLOR(c_clear);
        commentListTitle.textColor = COLOR(c_9e9e9e);
        commentListTitle.font = FONT(12.0);
        commentListTitle.text = @"全部评论";
        
        UIView *topLine = [[UIView alloc] init];
        [topLine builtinContainer:_commentListHeader WithLeft:0.0 Top:0.0 Width:_commentListHeader.width Height:PIXEL];
        topLine.backgroundColor = COLOR(c_dedede);
        UIView *bottomLine = [[UIView alloc] init];
        [bottomLine builtinContainer:_commentListHeader WithLeft:0.0 Top:_commentListHeader.height - PIXEL Width:_commentListHeader.width Height:PIXEL];
        bottomLine.backgroundColor = COLOR(c_dedede);
        
        _commentListHeader.hidden = YES;
    }
    
    return _commentListHeader;
}

- (CMTUserNotAuthenticView *)userNotAuthenticView {
    if (_userNotAuthenticView == nil) {
        _userNotAuthenticView = [[CMTUserNotAuthenticView alloc] init];
        [_userNotAuthenticView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0 Bottom:0 Right:0];
        [_userNotAuthenticView setBackgroundColor:COLOR(c_clear)];
    }
    
    return _userNotAuthenticView;
}

- (UIAlertView *)loginAlert {
    if (_loginAlert == nil) {
        _loginAlert = [[UIAlertView alloc] initWithTitle:@"请登录之后发布评论"
                                                 message:nil
                                                delegate:nil
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定", nil];
    }
    
    return _loginAlert;
}

- (UIAlertView *)cancelStoreAlert {
    if (_cancelStoreAlert == nil) {
        _cancelStoreAlert = [[UIAlertView alloc]initWithTitle:@"确定不再收藏该文章吗？"
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:@"取消"
                                            otherButtonTitles:@"确定", nil];
    }
    
    return _cancelStoreAlert;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        @strongify(self);
        CMTLog(@"CaseDetail willDeallocSignal");
        if(self.webViewHeightTimer != nil){
            [self.webViewHeightTimer invalidate];
            self.webViewHeightTimer = nil;
        }
    }];
        self.AudioName=@"壹生";
     #pragma mark 导航栏按钮
    
    // 返回按钮
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    
    // 分享及收藏按钮
    self.navigationItem.rightBarButtonItems = self.rightItems;
    self.isHaveIframe=NO;
    self.isBeingUpdated=NO;
    
#pragma mark 分享
    
    // 点击分享
    self.shareItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        if ( ![self HandlingErrors]) {
            [RACSignal empty];
        }
        [self CMTShareAction];
        
        return [RACSignal empty];
    }];
    
#pragma mark 收藏
    
    // 收藏按钮状态
    [[[RACObserve(self.viewModel, isFavoritePost) distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.viewModel.isFavoritePost == YES) {
            [self.favoriteButton setBackgroundImage:IMAGE(@"naviBar_favorited") forState:UIControlStateNormal];
            
        }
        else {
            [UIView animateWithDuration:0.5 animations:^{
                [self.favoriteButton setBackgroundImage:IMAGE(@"naviBar_favorit") forState:UIControlStateNormal];
            }];
        }
    }
     error:^(NSError *error) {
         CMTLog(@"%@", error);
     }];
    
    // 取消收藏
    [[self.cancelStoreAlert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
        @strongify(self);
        [self.cancelStoreAlert changeScaleWithAnimate];
        if (index.integerValue == 1) {
            
            BOOL addFavoritePost =
            [CMTFOCUSMANAGER handleFavoritePostWithPostId:self.viewModel.postId
                                               postDetail:self.viewModel.postDetail
                                               cancelFlag:@"1"];
            // 取消收藏成功
            if (addFavoritePost == YES) {
                self.viewModel.isFavoritePost = NO;
                [self toastAnimation:@"取消收藏成功"];
            }
            // 取消收藏失败
            else {
                self.viewModel.isFavoritePost = YES;
                [self toastAnimation:@"取消收藏失败"];
            }
            
            // 删除收藏列表中对应文章
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[CMTCollectionViewController class]]) {
                    CMTCollectionViewController *collectionViewController = (CMTCollectionViewController *)viewController;
                    
                    [collectionViewController.mArrCollections removeObjectAtIndex:self.path.row];
                    [collectionViewController.mArrShowConllections removeObjectAtIndex:self.path.row];
                    [collectionViewController.mCollectTableView deleteRowsAtIndexPaths:@[self.path] withRowAnimation:UITableViewRowAnimationNone];
                    [collectionViewController.mCollectTableView reloadData];
                    
                    NSMutableArray *cachedCollectionPostList = [NSMutableArray arrayWithArray:
                                                                [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST]];
                    if (cachedCollectionPostList.count <= 0) {
                        [collectionViewController dataLoad];
                    }
                    break;
                }
            }
        }
    }];
    
    // 点击收藏
    self.viewModel.favoriteItemEnable = YES;
    self.favoriteButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        if (![self HandlingErrors ]) {
            return [RACSignal empty];
        } ;
        if (self.viewModel.favoriteItemEnable == NO || self.viewModel.postDetail == nil) {
            return [RACSignal empty];
        }
        [self.favoriteButton changeScaleWithAnimate];
        self.viewModel.favoriteItemEnable = NO;
        
        // 添加收藏
        if (self.viewModel.isFavoritePost == NO) {
            BOOL addFavoritePost =
            [CMTFOCUSMANAGER handleFavoritePostWithPostId:self.viewModel.postId
                                               postDetail:self.viewModel.postDetail
                                               cancelFlag:@"0"];
            // 添加收藏成功
            if (addFavoritePost == YES) {
                self.viewModel.isFavoritePost = YES;
                [self toastAnimation:@"收藏成功"];
            }
            // 添加收藏失败
            else {
                self.viewModel.isFavoritePost = NO;
                [self toastAnimation:@"收藏文章失败"];
            }
        }
        // 取消收藏
        else {
            // 弹窗警告
            [self.cancelStoreAlert show];
        }
        
        self.viewModel.favoriteItemEnable = YES;
        
        return [RACSignal empty];
    }];
    
#pragma mark 文章详情
    
    // 显示加载动画
    self.contentState = CMTContentStateLoading;
    
    [self.webView builtinContainer:self.contentBaseView WithLeft:0.0 Top:0.0 Width:self.contentBaseView.width Height:self.contentBaseView.height];
    self.webView.scrollView.placeholderView = [self replyPlaceholderView];
    self.viewModel.webView = self.webView;
    
    self.webViewModel.frame = CGRectMake(0.0, 0.0, self.contentBaseView.width, 0.0);
    self.viewModel.webViewModel = self.webViewModel;
    
    // 动态详情 直接加载webView 不在监听文章详情是否请求完成 add by guoyuanchao
    if(self.viewModel.isHTML.isTrue){
        
        [self CMT_ISHTML_LoadWebview];
    }
    // 静态详情 请求文章详情完成 刷新详情
    else {
        [[[RACObserve(self.viewModel, requestPostDetailFinish) ignore:@NO] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            
            [self CMT_ISHTML_LoadWebview];
        }];
        
        [[[[RACObserve(self.viewModel, requestPostDetailImageFinish) ignore:@NO] deliverOn:[RACScheduler mainThreadScheduler]] delay:0.25] subscribeNext:^(id x) {
            @strongify(self);
            
            [self webViewDidFinishLoad:self.webView];
        }];

    }
    
    // 请求文章详情网络错误 显示重新加载
    [[[RACObserve(self.viewModel, requestPostDetailNetError) ignore:@NO]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        self.contentState = CMTContentStateReload;
        CMTLog(@"requestCaseDetailNetError");
    }];
  
    // 请求文章详情服务器错误消息 空白页显示消息
    [[[RACObserve(self.viewModel, requestPostDetailServerErrorMessage) ignore:nil]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorMessage) {
        @strongify(self);
        self.contentEmptyView.contentEmptyPrompt = errorMessage;
        self.contentState = CMTContentStateEmpty;
         self.isdetailnomal=NO;
    }];
    // 请求文章详情系统错误信息 显示空白页并提示
    [[[RACObserve(self.viewModel, requestPostDetailSystemErrorString) ignore:nil]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorString) {
        @strongify(self);
        self.contentState = CMTContentStateBlank;
        [self toastAnimation:@"系统错误"];
         self.isdetailnomal=NO;
        self.navigationItem.rightBarButtonItems=nil;
        CMTLogError(@"CaseDetail 系统错误:\n%@", errorString);
    }];
    
#pragma mark 文章统计
    
    [[[RACSignal merge:@[
                         [[RACObserve(self.viewModel, postStatistics) ignore:nil] distinctUntilChanged],
                         [[[RACObserve(self.viewModel, postStatistics.commentCount) ignore:nil] skip:1] distinctUntilChanged],
                         [[[RACObserve(self.viewModel, postStatistics.praiseCount) ignore:nil] skip:1] distinctUntilChanged],
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 评论或点赞 未修改
        if ([x isKindOfClass:[CMTPostStatistics class]]) {
            self.viewModel.postStatistics.commentModified = @"0";
            if (self.viewModel.postStatistics.isPraise.boolValue) {
                ((UIImageView*)[self.replyView.praiseSendButton viewWithTag:1000]).image=IMAGE(@"praise");
                
            }else{
                ((UIImageView*)[self.replyView.praiseSendButton viewWithTag:1000]).image=IMAGE(@"unpraise");
            }

        }
        // 评论或点赞 已修改
        else {
            self.viewModel.postStatistics.commentModified = @"1";
        }
        
        // 刷新文章列表文章统计
        if (self.updatePostStatistics != nil) {
            self.updatePostStatistics(self.viewModel.postStatistics);
        }
    }];
#pragma mark 监听是否有音频存在
    [[[RACObserve(self.viewModel, postDetail) ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTPost *postDetail) {
            @strongify(self);
            if(postDetail.postAttr.isPostAttrAudio||postDetail.postAttr.isPostAttrVideo){
              self.musicPlayedTime=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(musicPlayed) userInfo:nil repeats:YES];
          
           }
        
    } error:^(NSError *error) {
        
    }];

    
#pragma mark 打开网页浏览器
    
    [[[RACObserve(self.viewModel, webLink) ignore:nil]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.navigationController pushViewController:
         [[CMTWebBrowserViewController alloc] initWithURL:self.viewModel.webLink]
                                             animated:YES];
    }];
    
#pragma mark 评论列表
    
    // 点击刷新 刷新评论
    [self.tapToRefresh.refreshButtonSignal subscribeNext:^(id x) {
        @strongify(self);
        self.tapToRefresh.active = YES;
        self.viewModel.tapToRefreshState = YES;
    }];
    
    // 隐藏点击刷新
    [[[[[RACObserve(self.viewModel, commentNotUpToDate) ignore:@YES] distinctUntilChanged] filter:^BOOL(id value) {
        @strongify(self);
        return (self.postDetailType == CMTPostDetailTypeCommentEdit);
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 刷新评论列表
        [self reloadTableScrollView];
    }];
    
    // 评论翻页
    [self.webView.scrollView addInfiniteScrollingWithoutAdjustBottomInset];
    RAC(self.viewModel, infiniteScrollingState) = [RACObserve(self.webView.scrollView.infiniteScrollingView, state) distinctUntilChanged];
    RAC(self.webView.scrollView, showsInfiniteScrolling) = [RACObserve(self.webView.scrollView, contentSize) map:^id(NSValue *contentSize) {
        @strongify(self);
        if (self.webView.scrollView.numberOfCells == 0) return @NO;
        if (self.webView.scrollView.lastCoveredHeight + self.webView.scrollView.contentInset.top < self.webView.scrollView.height) return @NO;
        return @YES;
    }];
    
    // 停止翻页的加载中动画
    [[[RACSignal merge:@[
                         [RACObserve(self.viewModel, requestCommentFinish) ignore:@NO],
                         [RACObserve(self.viewModel, requestCommentEmpty) ignore:@NO],
                         [RACObserve(self.viewModel, requestCommentError) ignore:@NO],
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        self.tapToRefresh.active = NO;
        [self.webView.scrollView.infiniteScrollingView stopAnimating];
    }];
    
    // 刷新评论列表
    [[[RACObserve(self.viewModel, requestCommentFinish) ignore:@NO]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
         // 文章详情已加载
         if (self.viewModel.postDetailLoadFinish == YES) {
             [self webViewDidFinishLoad:self.webView];
         }
    }];
    
    // 快速评论 滑动到要显示的评论
    [[[[RACSignal combineLatest:@[
                                 [[RACObserve(self.viewModel, requestCommentFinish) ignore:@NO] distinctUntilChanged],
                                 [[RACObserve(self.viewModel, replyListReloadFinish) ignore:@NO] distinctUntilChanged],
                                 ]] filter:^BOOL(id value) {
        @strongify(self);
        return self.postDetailType == CMTPostDetailTypeCaseListSeeReply;
    }]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        UIViewAnimationOptions keyboardAnimationCurve = 7;
        keyboardAnimationCurve |= keyboardAnimationCurve<<16;
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:keyboardAnimationCurve
                         animations:^{
                             @try {
                                 if (self.webView.scrollView.numberOfCells > 0) {
                                     CGFloat contentOffsetY = 0.0;
                                     CGFloat lastCoveredHeight = self.webView.scrollView.lastCoveredHeight;
                                     CGFloat displayHeight = self.webView.scrollView.frameHeight - (self.webView.scrollView.topInset + self.webView.scrollView.bottomInset);
                                     CGFloat cellY = CGRectGetMinY([self.webView.scrollView frameOfCellAtIndex:0]);
                                     
                                     // 该评论与最后一条评论之间高度大于一屏
                                     if (lastCoveredHeight - cellY > displayHeight) {
                                         // 滑动到该评论置顶
                                         contentOffsetY = cellY;
                                     }
                                     // 该评论与最后一条评论之间高度小于一屏
                                     else {
                                         // 滑动到最后一条评论置底
                                         contentOffsetY = lastCoveredHeight - displayHeight > 0.0 ? lastCoveredHeight - displayHeight : 0.0;
                                     }
                                     
                                     self.viewModel.toDisplayedCommentIndexPath = nil;
                                     self.viewModel.readingPostDetail = NO;
                                     [self.webView.scrollView setContentOffset:(CGPoint){0.0, -CMTNavigationBarBottomGuide + contentOffsetY} animated:YES];
                                 }
                             }
                             @catch (NSException *exception) {
                                 CMTLogError(@"CaseDetail Scroll To Displayed Comment Exception: %@", exception);
                             }
                         } completion:nil];
    }];
    
    // 我的评论/通知 滑动到要显示的评论
    [[[RACSignal combineLatest:@[
                                 [[RACObserve(self.viewModel, requestCommentFinish) ignore:@NO] distinctUntilChanged],
                                 [RACObserve(self.viewModel, toDisplayedCommentIndexPath) ignore:nil],
                                 [[RACObserve(self.viewModel, replyListReloadFinish) ignore:@NO] distinctUntilChanged],
                                 ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        UIViewAnimationOptions keyboardAnimationCurve = 7;
        keyboardAnimationCurve |= keyboardAnimationCurve<<16;
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:keyboardAnimationCurve
                         animations:^{
                             @try {
                                 NSIndexPath *indexPath = nil;
                                 if ([tuple.second isKindOfClass:[NSIndexPath class]]) {
                                     indexPath = tuple.second;
                                 }
                                 if (self.webView.scrollView.numberOfCells > 0) {
                                     CGFloat contentOffsetY = 0.0;
                                     CGFloat lastCoveredHeight = self.webView.scrollView.lastCoveredHeight;
                                     CGFloat displayHeight = self.webView.scrollView.frameHeight - (self.webView.scrollView.topInset + self.webView.scrollView.bottomInset);
                                     CGFloat cellY = CGRectGetMinY([self.webView.scrollView frameOfCellAtIndex:indexPath.row]);
                                     
                                     // 该评论与最后一条评论之间高度大于一屏
                                     if (lastCoveredHeight - cellY > displayHeight) {
                                         // 滑动到该评论置顶
                                         contentOffsetY = cellY;
                                     }
                                     // 该评论与最后一条评论之间高度小于一屏
                                     else {
                                         // 滑动到最后一条评论置底
                                         contentOffsetY = lastCoveredHeight - displayHeight > 0.0 ? lastCoveredHeight - displayHeight : 0.0;
                                     }
                                     
                                     self.viewModel.toDisplayedCommentIndexPath = nil;
                                     self.viewModel.readingPostDetail = NO;
                                     [self.webView.scrollView setContentOffset:(CGPoint){0.0, -CMTNavigationBarBottomGuide + contentOffsetY} animated:YES];
                                 }
                             }
                             @catch (NSException *exception) {
                                 CMTLogError(@"CaseDetail Scroll To Displayed Comment Exception: %@", exception);
                             }
                         } completion:nil];
    }];
    
#pragma mark 查看评论
    
    // 评论数
    RAC(self.replyView, badgeNumber) = [[RACObserve(self.viewModel, postStatistics.commentCount)
                                         distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
    RAC(self.replyInputView, badgeNumber) = [[RACObserve(self.viewModel, postStatistics.commentCount)
                                              distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
    
    // 阅读文章
    self.viewModel.readingPostDetail = YES;
    self.viewModel.lastContentOffsetY = -CMTNavigationBarBottomGuide;
    
    // 评论回复框 点击查看评论列表按钮
    [[[RACSignal merge:@[
                         self.replyView.commentSeeButtonSignal,
                         self.replyView.postDetailSeeButtonSignal,
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 当前阅读文章
        if (self.viewModel.readingPostDetail == YES) {
            // 滑动到评论列表
            CGFloat contentOffsetY = 0.0;
            CGFloat replyCellsHeight = self.webView.scrollView.lastCoveredHeight - self.webView.scrollView.headerHeight;
            CGFloat displayHeight = self.webView.scrollView.frameHeight - self.webView.scrollView.topInset - self.webView.scrollView.bottomInset;
            
            // 评论大于一屏
            if (replyCellsHeight > displayHeight) {
                // 滑动到第一条评论置顶
                contentOffsetY = CGRectGetMinY([self.webView.scrollView frameOfCellAtIndex:0]);
            }
            // 评论小于一屏
            else {
                // 滑动到最后一条评论置底
                CGFloat lastCellY = self.webView.scrollView.lastCoveredHeight;
                // 评论为空 滑动到评论为空提示
                if (self.webView.scrollView.numberOfCells == 0) {
                    lastCellY += self.webView.scrollView.placeholderView.height + self.commentListHeader.height;
                }
                
                contentOffsetY = lastCellY - displayHeight > 0.0 ? lastCellY - displayHeight : 0.0;
            }
            
            self.viewModel.readingPostDetail = NO;
            self.replyView.replyViewDomain = CMTReplyViewDomainCommentList;
            [self.webView.scrollView setContentOffset:(CGPoint){0.0, -CMTNavigationBarBottomGuide + contentOffsetY} animated:YES];
        }
        // 当前阅读评论列表
        else {
            // 滑动到上次阅读文章位置
            [self.webView.scrollView setContentOffset:(CGPoint){0.0, self.viewModel.lastContentOffsetY} animated:YES];
            self.viewModel.readingPostDetail = YES;
            self.replyView.replyViewDomain = CMTReplyViewDomainPostDetail;
        }
    }];
    
#pragma mark 发送评论
    
    // 提示登录
    [self.replyView.commentNotLoginButtonSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.loginAlert show];
    }];
    
    // 显示登录页
    [[self.loginAlert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
        @strongify(self);
        if ([index integerValue] == 1) {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [self.navigationController pushViewController:loginVC animated:YES];
        }
    }];
    [[[RACObserve(self.viewModel,postDetail)distinctUntilChanged]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPost *post) {
        @strongify(self);
        if (!([post.groupId isEqualToString:self.groupID]|| isEmptyString(post.groupId))) {
            self.groupID=self.viewModel.postDetail.groupId;
            self.replyInputView.groupID=self.viewModel.postDetail.groupId;
            [self.replyInputView loadViewGroupimageView:CMTReplyInputViewModelGroupPostDetail];
        }
    } error:^(NSError *error) {
        
    }];
    // 评论回复框 点击文本框
    [[self.replyView.commentTouchButtonSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (![self.viewModel.postDetail.groupId isEqualToString:self.groupID]) {
            self.groupID=self.viewModel.postDetail.groupId;
            self.replyInputView.groupID=self.viewModel.postDetail.groupId;
            [self.replyInputView loadViewGroupimageView:CMTReplyInputViewModelGroupPostDetail];
             [self.replyInputView showInputView];
            
        }else{
           [self.replyInputView showInputView];
        }
    }];
    
    // 评论回复框 被回复昵称提示
    [[[RACSignal merge:@[
                         RACObserve(self.viewModel, commentToReply),
                         RACObserve(self.viewModel, replyToReply),
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id comment) {
        @strongify(self);
        NSString *nickName = nil;
        if ([comment respondsToSelector:@selector(nickname)]) {
            nickName = [comment performSelector:@selector(nickname)];
        }
        
        self.replyView.beRepliedNickName = nickName;
        self.replyInputView.beRepliedNickName = nickName;
    }];
    
    // 评论回复框 发送评论
    self.viewModel.commentSendButtonSignal = self.replyInputView.commentSendButtonSignal;
    
    // 评论回复框 评论内容
    [[RACSignal merge:@[
                        self.replyInputView.commentTextSignal,
                        [[RACObserve(self.replyInputView, contentTextView.text) ignore:nil] distinctUntilChanged],
                        ]] subscribeNext:^(NSString *text) {
        @strongify(self);
        // 正文内容超出字数限制
        if (text.length > 500) {
            self.viewModel.commentText = [text substringToIndex:500];
        }
        else {
            self.viewModel.commentText = text;
        }
        
    }];
//监听提醒人员ID
  [[[RACObserve(self.replyInputView, remindString) ignore:nil] distinctUntilChanged]subscribeNext:^(NSString *text) {
      @strongify(self);
      self.viewModel.remindIDS=text;
  }];
    //更改图片路径
  [[[RACObserve(self.replyInputView, picFilepath) ignore:nil] distinctUntilChanged]subscribeNext:^(NSString*text) {
         @strongify(self);
         self.viewModel.CommentPicPath=text;

     }];
    // 评论/回复已经发送
    [[[RACObserve(self.viewModel, commentOrReplySend) ignore:@NO]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        // 关闭键盘
        [self.replyInputView hideInputView];
        // 清空回复内容
        self.replyView.textField.text = nil;
        self.replyInputView.contentTextView.text = nil;
        // 清空被回复对象
        self.viewModel.commentToReply = nil;
        self.viewModel.replyToReply = nil;
    }];
    
    // 关闭键盘
    [[self.replyInputView.commentCancelButtonSignal delay:0.2] subscribeNext:^(id x) {
        @strongify(self);
        // 设置评论回复框评论内容
        self.replyView.textField.text = self.replyInputView.contentTextView.text;
        // 清空被回复对象
        self.viewModel.commentToReply = nil;
        self.viewModel.replyToReply = nil;
    }];
    // 发送评论失败
    [[[RACObserve(self.viewModel, sendCommentError) ignore:@NO] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
         @strongify(self);
        CMTLogError(@"sendComment failed");
        [self toastAnimation:self.viewModel.sendCommentMessage];
    }];
    
#pragma 文章点赞
    [self.replyView.praiseSignal subscribeNext:^(id x) {
        @strongify(self);
        if (!CMTUSER.login ) {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [self.navigationController pushViewController:loginVC animated:YES];
        }else{
            NSDictionary *params=@{
                                   @"userId":CMTUSERINFO.userId ?:@"0",
                                   @"praiseType":@"4",
                                   @"postId":self.viewModel.postId,
                                   @"cancelFlag":!self.viewModel.postStatistics.isPraise.boolValue?@"0":@"1"
                                   };
            
            [[[CMTCLIENT Praise:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
                @strongify(self);
                if (!self.viewModel.postStatistics.isPraise.boolValue) {
                    self.viewModel.postStatistics.isPraise=@"1";
                    self.viewModel.postStatistics.praiseCount=[NSString stringWithFormat:@"%ld", (long)self.viewModel.postStatistics.praiseCount.integerValue+1];
                    [[self.replyView.praiseSendButton viewWithTag:1000] changeScaleWithAnimate];
                    ((UIImageView*)[self.replyView.praiseSendButton viewWithTag:1000]).image=IMAGE(@"praise");
                    
                }else{
                    self.viewModel.postStatistics.isPraise=@"0";
                    self.viewModel.postStatistics.praiseCount=[NSString stringWithFormat:@"%ld",(long)(self.viewModel.postStatistics.praiseCount.integerValue-1>0?:0)];
                    [[self.replyView.praiseSendButton viewWithTag:1000] changeScaleWithAnimate];
                    ((UIImageView*)[self.replyView.praiseSendButton viewWithTag:1000]).image=IMAGE(@"unpraise");
                }
                
            } error:^(NSError *error) {
                @strongify(self);
                if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                    [self toastAnimation:@"你的网络不给力"];
                }else{
                    [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
                }
                
            }completed:^{
                
            }];
            
            
        }
        
        
    }];

#pragma mark 删除评论
    
    // 删除评论成功
    [[[RACObserve(self.viewModel, deleteCommentFinish) ignore:@NO] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        // todo 提示删除成功
        CMTLog(@"deleteComment success");
    }];
    
    // 删除回复成功
    [[[RACObserve(self.viewModel, deleteReplyFinish) ignore:@NO] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        // todo 提示删除成功
        CMTLog(@"deleteReply success");
    }];
    
    // 删除评论失败
    [[[RACObserve(self.viewModel, deleteCommentError) ignore:@NO] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        CMTLogError(@"deleteComment failed");
    }];
    
#pragma mark 请求提示信息
    
    // 文章统计数 请求提示信息
    [[[RACObserve(self.viewModel, requestPostStatisticsMessage) ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *message) {
        CMTLog(@"requestPostStatisticsMessage: %@", message);
    }];
    
    // 评论列表 请求提示信息
    [[[RACObserve(self.viewModel, requestCommentMessage) ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *message) {
        @strongify(self);
        if ([message isEqual:@"最新"]) {
        }
        else if ([message isEqual:@"没有更多"]) {
            [self toastAnimation:@"没有更多评论"];
        }else if([message isEqual:@"你的网络不给力"]){
            [self toastAnimation:message];
        }
        else {
            [self toastAnimation:message];
        }

        
        CMTLog(@"requestCommentMessage: %@", message);
    }];
    
    // 发送评论 请求提示信息
    [[[RACObserve(self.viewModel, sendCommentMessage) ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *message) {
        @strongify(self);
        CMTLogError(@"sendCommentMessage :\n%@", message);
        [self toastAnimation:message];
    }];
    
    // 删除评论 请求提示信息
    [[[RACObserve(self.viewModel, deleteCommentMessage) ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *message) {
         @strongify(self);
        CMTLog(@"deleteCommentMessage: %@", message);
        [self toastAnimation:message];
    }];
    
#pragma mark 用户认证
    
    self.userNotAuthenticView.hidden = YES;
    
    // 显示用户未认证提示
    [[[RACSignal merge:@[[[RACObserve(self.viewModel, postDetail) ignore:nil] distinctUntilChanged],
                         // to do 认证信息改变signal待优化
                         [CMTUSER authStatusChangeSignal],
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        CMTPost *postDetail = self.viewModel.postDetail;
        NSString *authStatus = CMTUSERINFO.authStatus;
        
        // 文章需要认证可看 且用户未认证
        BOOL userNotAuthentic = [postDetail.authViewFlag isEqual:@"2"] && ![authStatus isEqual:@"1"] && ![authStatus isEqual:@"4"];
        self.userNotAuthenticView.hidden = !userNotAuthentic;
    }];
    
    // 点击申请认证按钮
    [self.userNotAuthenticView.requestAuthenticationSignal subscribeNext:^(id x) {
        @strongify(self);
        // 登陆用户 显示申请认证页
        if (CMTUSER.login == YES) {
            CMTUpgradeViewController *upgradeVC = [[CMTUpgradeViewController alloc] initWithNibName:nil bundle:nil];
            upgradeVC.nextVC = kDisVC;
            [self.navigationController pushViewController:upgradeVC animated:YES];
        }
        // 未登录用户 显示登录页
        else {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kDisVC;
            [self.navigationController pushViewController:loginVC animated:YES];
        }
    }];
#pragma 监听发送进度条
    [[RACObserve(CMTAPPCONFIG,addPostAdditionalData.addPostStatus) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        if (CMTAPPCONFIG.addPostAdditionalData.addPostStatus.integerValue==1) {
            if (self.progressView==nil) {
                self.progressView=[[CMTPostProgressView alloc]initWithFrame:CGRectMake(10,CMTNavigationBarBottomGuide,SCREEN_WIDTH-20,30) module:CMTSendCaseTypeAddPostDescribe];
                self.progressView.delegate=self;
                [self.contentBaseView addSubview:self.progressView];
            }
                [self.progressView start];
            
        }else if(CMTAPPCONFIG.addPostAdditionalData.addPostStatus.integerValue==3){
            if (self.progressView==nil) {
                self.progressView=[[CMTPostProgressView alloc]initWithFrame:CGRectMake(10,CMTNavigationBarBottomGuide+10,SCREEN_WIDTH-20,30) module:CMTSendCaseTypeAddPostDescribe];
                self.progressView.delegate=self;
                [self.contentBaseView addSubview:self.progressView];
            }
            [self.progressView SendFailure];
        }
        
    }];
    //下拉刷新
    [self DeteildropDownRefresh];
#pragma mark 网络判断
    [[[RACObserve([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus)
       deliverOn:[RACScheduler mainThreadScheduler]]distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self updateNetWorkingState];
        
        } error:^(NSError *error) {;
        
    }];

#pragma mark 手势滑动结束关闭音乐播放器
    [[[[[RACObserve(CMTAPPCONFIG, ISGesturesSlidingEnd)ignore:@"0" ]distinctUntilChanged]
       deliverOn:[RACScheduler mainThreadScheduler]]distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self);
        if (x.integerValue==1) {
            [self.webView stringByEvaluatingJavaScriptFromString:@"pauseAudio()"];
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            CMTAPPCONFIG.ISGesturesSlidingEnd=@"0";
            
        }
        
    } error:^(NSError *error) {;
        
    }];
    


    
}
#pragma mark 监听音乐播放器变化
-(void)musicPlayed{
    NSString *playstate=[self.webView stringByEvaluatingJavaScriptFromString:@"window.playStatus"];
    NSLog(@"jdjdjdjdjdjdj%@",playstate);
    if(playstate.integerValue==1){
        if([AVAudioSession sharedInstance].category==AVAudioSessionCategoryPlayback){
            [[AVAudioSession sharedInstance] setActive: YES error: nil];
        }else{
           [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
                        //   #pragma mark 控制声音是否后台播放
            [[AVAudioSession sharedInstance] setActive: YES error: nil];
        }
        [self.musicPlayedTime setFireDate:[NSDate distantFuture]];
    }
}
#pragma mark 更改页面网络状态
-(void)updateNetWorkingState{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"checkStatus(0)"];
        
    }else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWiFi) {
        
        [self.webView stringByEvaluatingJavaScriptFromString:@"checkStatus(2)"];
        
    }
    else if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWWAN){
        [self.webView stringByEvaluatingJavaScriptFromString:@"checkStatus(1)"];
    }
    
}
#pragma mark 下拉刷新
-(void)DeteildropDownRefresh{
    @weakify(self);
    [self.webView.scrollView addPullToRefreshWithActionHandler:^{
        @strongify(self)
        NSDictionary *param=@{@"postId":self.viewModel.postDetail.postId?:@"0",@"userId":CMTUSER.userInfo.userId?:@"0"};
        @weakify(self)
        [[[CMTCLIENT Details_update:param]deliverOn:[RACScheduler mainThreadScheduler ]]subscribeNext:^(CMTPost *x) {
            @strongify(self);
            BOOL htmlupdate=x.isNew.integerValue==0;
            if (htmlupdate) {
                //重新计算高度进行布局
                self.isHaveUpdated=YES;
                self.viewModel.appendDetailSend =NO;
                [self webViewDidFinishLoad:self.webView];
            }else{
                self.isBeingUpdated=YES;
                self.webViewLoadNumbers = 1;
                self.webViewModelLoadNumbers=1;
                [self.UrlArray removeAllObjects];
                //禁止滑动到追加的位置
                 self.viewModel.appendDetailSend =NO;
                if (((x.isNew.integerValue&1)==1)&&((x.isNew.integerValue&2)==2)) {
                    // 显示加载动画
                    self.viewModel.reloadPostDetailState =(x.isNew.integerValue&1)==1;
                    self.viewModel.commentFilterState=@"0";
                    [self setContentState:CMTContentStateLoading moldel:@"1"];
                    [self CMT_ISHTML_LoadWebview];
                }else if ((x.isNew.integerValue&2)==2) {
                     self.viewModel.commentFilterState=@"0";
                    [self.viewModel updatePoststatics];
                }else{
                     self.viewModel.reloadPostDetailState =(x.isNew.integerValue&1)==1;
                    [self setContentState:CMTContentStateLoading moldel:@"1"];
                    [self CMT_ISHTML_LoadWebview];

                }

                
                    

            }
            [self.webView.scrollView.pullToRefreshView stopAnimating];
            
        } error:^(NSError *error) {
            if (([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||CMTAPPCONFIG.reachability.integerValue==0) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            }
             [self.webView.scrollView.pullToRefreshView stopAnimating];
            
        }];
    }];
}

#pragma mark 更多操作
-(void)CmtMoreAction{
    UIActionSheet *sheet=[[UIActionSheet alloc]init];
    sheet.delegate=self;
    NSMutableArray *array=[[NSMutableArray alloc]init];
    if (self.mygroup.groupType.integerValue==0) {
        [sheet addButtonWithTitle:@"分享"];
        [array addObject:@"分享"];
    }
    [sheet addButtonWithTitle:self.viewModel.isFavoritePost == YES?@"取消收藏":@"收藏"];
    [array addObject:@"收藏"];
    [sheet addButtonWithTitle:self.viewModel.postDetail.topFlag.integerValue==1?@"取消置顶":@"置顶该帖"];
    [sheet addButtonWithTitle:@"屏蔽该帖"];
    [array addObject:@"屏蔽"];
    [sheet addButtonWithTitle:@"取消"];
     [array addObject:@"取消"];
    sheet.destructiveButtonIndex =array.count;

    sheet.cancelButtonIndex = array.count;
    [sheet showInView:self.contentBaseView];
     @weakify(self)
    [[sheet rac_buttonClickedSignal]subscribeNext:^(NSNumber *x) {
        @strongify(self)
        if(self.mygroup.groupType.integerValue==0){
            switch (x.integerValue) {
                case 0:
                    [self CMTShareAction];
                    break;
                case 1:
                    [self collectionAction];
                    break;
                case 2:
                    [self PlacedTheTopAction];
                    break;
                case 3:
                    [self ShieldingArticle];
                    break;
                default:
                    break;
            }
        }else{
        
            switch (x.integerValue) {
                case 0:
                    [self collectionAction];
                    break;
                case 1:
                    [self PlacedTheTopAction];
                    break;
                case 2:
                    [self ShieldingArticle];
                    break;
                default:
                    break;
            }

            
        }
            
        NSLog(@"jsjjsjsjssjsjsj%ld",(long)x.integerValue);
    } completed:^{
        
    }];
    
    

}
#pragma mark 收藏
-(void)collectionAction{
    if (! [self HandlingErrors]) {
        return;
    }
    if(self.viewModel.isFavoritePost==YES){
            BOOL addFavoritePost =
            [CMTFOCUSMANAGER handleFavoritePostWithPostId:self.viewModel.postId
                                               postDetail:self.viewModel.postDetail
                                               cancelFlag:@"1"];
            // 取消收藏成功
            if (addFavoritePost == YES) {
                self.viewModel.isFavoritePost = NO;
                [self toastAnimation:@"取消收藏成功"];
            }
            // 取消收藏失败
            else {
                self.viewModel.isFavoritePost = YES;
                [self toastAnimation:@"取消收藏失败"];
            }
            
            // 删除收藏列表中对应文章
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[CMTCollectionViewController class]]) {
                    CMTCollectionViewController *collectionViewController = (CMTCollectionViewController *)viewController;
                    
                    [collectionViewController.mArrCollections removeObjectAtIndex:self.path.row];
                    [collectionViewController.mArrShowConllections removeObjectAtIndex:self.path.row];
                    [collectionViewController.mCollectTableView deleteRowsAtIndexPaths:@[self.path] withRowAnimation:UITableViewRowAnimationNone];
                    [collectionViewController.mCollectTableView reloadData];
                    
                    NSMutableArray *cachedCollectionPostList = [NSMutableArray arrayWithArray:
                                                                [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST]];
                    if (cachedCollectionPostList.count <= 0) {
                        [collectionViewController dataLoad];
                    }
                    break;
                }
            }
    }else{
        // 添加收藏
        if (self.viewModel.isFavoritePost == NO) {
            BOOL addFavoritePost =
            [CMTFOCUSMANAGER handleFavoritePostWithPostId:self.viewModel.postId
                                               postDetail:self.viewModel.postDetail
                                               cancelFlag:@"0"];
            // 添加收藏成功
            if (addFavoritePost == YES) {
                self.viewModel.isFavoritePost = YES;
                [self toastAnimation:@"收藏成功"];
            }
            // 添加收藏失败
            else {
                self.viewModel.isFavoritePost = NO;
                [self toastAnimation:@"收藏文章失败"];
            }
        }
    }

}
#pragma  mark 置顶操作
-(void)PlacedTheTopAction{
    if (! [self HandlingErrors]) {
        return;
    }

    @weakify(self);
    [[[CMTCLIENT set_Post_top:@{@"postId":self.viewModel.postDetail.postId,@"flag":self.viewModel.postDetail.topFlag.integerValue==1?@"0":@"1"}]deliverOn:[RACScheduler mainThreadScheduler ]]subscribeNext:^(CMTPost *post) {
        @strongify(self);
        [self toastAnimation:post.topFlag.integerValue==1?@"置顶成功":@"取消成功"];
        self.viewModel.postDetail.topFlag=post.topFlag;
        if (self.PlacedTheTopSucess!=nil) {
            self.PlacedTheTopSucess(self.viewModel.postDetail);
        }
    } error:^(NSError *error) {
         @strongify(self);
        if (([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||CMTAPPCONFIG.reachability.integerValue==0){
                [self toastAnimation:@"你的网络不给力"];
        }else{
             [self toastAnimation:error.userInfo[@"errmsg"]];
        }
        
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
        
    }];
}
#pragma mark 屏蔽操作
-(void)ShieldingArticle{
    if (! [self HandlingErrors]) {
        return;
    }

    @weakify(self)
    NSDictionary *params = @{
                              @"userId":CMTUSERINFO.userId?:@"",
                              @"groupId":self.mygroup.groupId?:@"",
                              @"postId":self.viewModel.postDetail.postId,
                              };

    [[[CMTCLIENT deleteCase:params]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self)
        [self toastAnimation:@"屏蔽成功"];
        //更新收藏列表
        [CMTFOCUSMANAGER handleFavoritePostWithPostId:self.viewModel.postId
                                           postDetail:self.viewModel.postDetail
                                           cancelFlag:@"1"];

        if (self.ShieldingArticleSucess!=nil) {
            self.ShieldingArticleSucess(self.viewModel.postDetail);
        }
         @weakify(self)
        [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
              @strongify(self)
             [self.navigationController popViewControllerAnimated:YES];
        }];
        
    } error:^(NSError *error) {
           @strongify(self)
        if (([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||CMTAPPCONFIG.reachability.integerValue==0){
            [self toastAnimation:@"你的网络不给力"];
        }else{
            [self toastAnimation:error.userInfo[@"errmsg"]];
        }


       
    }];

}

#pragma  mark 进度条代理
-(void)DeletePosting{
    self.progressView=nil;
    
}
-(void)reloadCaselistData:(CMTAddPost*)newCase{
    [self.progressView SendSuccess];
    if(self.viewModel.isHTML.isTrue){
        self.webViewLoadNumbers=1;
        self.webViewModelLoadNumbers=1;
        [self CMT_ISHTML_LoadWebview];
        self.viewModel.appendDetailSend = YES;
    }else{
       [self.viewModel updatePostDetailWithAddPostAdditional:newCase];
    }

   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    CMTLogError(@"CaseDetail didReceiveMemoryWarning");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    // UMeng统计
    // 打开图片浏览器时不统计
    if (self.viewModel.photoBrowserOpening == YES) {
        self.viewModel.photoBrowserOpening = NO;
    }
    // 显示导航栏

#pragma mark 显示评论回复框

    [self.contentBaseView insertSubview:self.replyView aboveSubview:self.webView];
    
#pragma mark 用户认证
    
    // to do 认证信息改变signal优化后 取消此处判断
    CMTPost *postDetail = self.viewModel.postDetail;
    NSString *authStatus = CMTUSERINFO.authStatus;
    
    // 文章需要认证可看 且用户未认证
    BOOL userNotAuthentic = [postDetail.authViewFlag isEqual:@"2"] && ![authStatus isEqual:@"1"] && ![authStatus isEqual:@"4"];
    self.userNotAuthenticView.hidden = !userNotAuthentic;
    
#pragma mark 收藏按钮状态
    
    BOOL contained = NO;
    NSMutableArray *cachedCollectionPostList = [NSMutableArray arrayWithArray:
                                                [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST]];
    for (int index = 0; index < cachedCollectionPostList.count; index++) {
        if ([[cachedCollectionPostList objectAtIndex:index] isKindOfClass:[CMTStore class]]) {
            CMTStore *store = [cachedCollectionPostList objectAtIndex:index];
            if ([store.postId isEqual:self.viewModel.postId]) {
                self.index = index;
                contained = YES;
                break;
            }
        }
    }
    if (contained == YES) {
        self.viewModel.isFavoritePost = YES;
    }
    else {
        self.viewModel.isFavoritePost = NO;
    }
    
#pragma mark 开启监听webview高度变化
    
    // 如果计时器对象不为空则重新开启计时器
    if (self.webViewHeightTimer != nil){
        [self.webViewHeightTimer setFireDate:[NSDate distantPast]];
    }
    if(self.musicPlayedTime !=nil){
         [self.musicPlayedTime setFireDate:[NSDate distantPast]];
    }
    if (CMTAPPCONFIG.IsWWANplaybackVideo.integerValue==1&&self.videoUrlString.length>0) {
        if (CMTAPPCONFIG.IsWWANplaybackVideo.integerValue==1) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看" message:nil delegate:nil
                                               cancelButtonTitle:@"取消" otherButtonTitles:@"继续播放", nil];
            [alert show];
            @weakify(self)
            [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                // 确定 跳转App Store
                @strongify(self);
                if ([index integerValue] == 1) {
                    LDZMoviePlayerController *moviewPlayerVC = [[LDZMoviePlayerController alloc] initWithUrl:[NSURL URLWithString: self.videoUrlString]];
                    //  播放网络
                    moviewPlayerVC.networkReachabilityStatus =@"1";
                    moviewPlayerVC.postId = self.viewModel.postId;
                    [self.navigationController pushViewController:moviewPlayerVC animated:YES];
                    
                }
            }];
            
        }
        
    }
   #pragma mark 监听进入前台记录系统音频播放器状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];



}

- (void)setLockScreenNowPlayingInfo
{
    //更新锁屏时的歌曲信息
    self.AudioName=[[[self.webView stringByEvaluatingJavaScriptFromString:@"getAudioName()"] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    CMTAPPCONFIG.AudioName=self.AudioName;
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    NSMutableDictionary *songInfo = [ [NSMutableDictionary alloc] init];
    [ songInfo setObject:CMTAPPCONFIG.AudioName forKey:MPMediaItemPropertyTitle ];
     songInfo[MPMediaItemPropertyAlbumTitle]=self.viewModel.postDetail.title;
    center.nowPlayingInfo=songInfo;
    APPDELEGATE.songInfo=songInfo;
    [self becomeFirstResponder];
    // 开始监控
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
}

-(void)appWillResignActive:(NSNotification *)aNotification{
    [self setLockScreenNowPlayingInfo];
}
//接受远程事件控制
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//响应远程音乐播放控制消息
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
                [self.webView stringByEvaluatingJavaScriptFromString:@"pauseAudio()"];
                NSLog(@"hdhdhdjdjdj%@", [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo[MPMediaItemPropertyAlbumTitle]);
                NSLog(@"aaaaaaaaaa%@", [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo[MPMediaItemPropertyTitle]);
                NSLog(@"RemoteControlEvents: pause");
                break;
            case UIEventSubtypeRemoteControlPlay:
                [self.webView stringByEvaluatingJavaScriptFromString:@"playAudio()"];
                break;
            case UIEventSubtypeRemoteControlStop:
                [self.webView stringByEvaluatingJavaScriptFromString:@"stopAudio()"];
                NSLog(@"RemoteControlEvents: Stop");
                break;
            default:
                break;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    self.viewModel.viewDidAppearState = YES;
    CMTAPPCONFIG.IsInterruptAudioPlayback=NO;
    // 登陆成功后刷新动态模板
    if (self.isreloadWebView) {
        self.webViewLoadNumbers=1;
        self.webViewModelLoadNumbers=1;
        [self CMT_ISHTML_LoadWebview];
        self.isreloadWebView=NO;
    }
    
    // 快速评论显示键盘
    if (self.viewModel.postDetailLoadFinish == YES &&
        self.viewModel.quickReplyFinish == NO &&
        self.postDetailType == CMTPostDetailTypeCaseListWithReply) {
        self.viewModel.quickReplyFinish = YES;
        
        // 显示键盘
        [self.replyInputView showInputView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
#pragma mark 关闭监听webview高度变化
    [self setLockScreenNowPlayingInfo];
    // 如果计时器对象不为空则关闭计时器
    if (self.webViewHeightTimer != nil){
        [self.webViewHeightTimer setFireDate:[NSDate distantFuture]];
    }
    if(self.musicPlayedTime!=nil){
        [self.musicPlayedTime setFireDate:[NSDate distantFuture]];

    }
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
  #pragma mark 页面消失关闭声音后台播放
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
  
    if(!CMTAPPCONFIG.IsInterruptAudioPlayback){
         [self.webView stringByEvaluatingJavaScriptFromString:@"pauseAudio()"];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];

    }else{
        CMTAPPCONFIG.IsInterruptAudioPlayback=NO;
    }
   
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
}
//释放对象
-(void)dealloc{
    if(self.musicPlayedTime!=nil){
        [self.musicPlayedTime setFireDate:[NSDate distantFuture]];
    }
    [self.musicPlayedTime invalidate];
}

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    // 请求文章详情
    self.viewModel.reloadPostDetailState = YES;
    self.viewModel.commentFilterState=@"0";
    self.navigationItem.rightBarButtonItems=self.rightItems;
    // 显示加载动画
    self.contentState = CMTContentStateLoading;
    [self CMT_ISHTML_LoadWebview];
}

#pragma mark 点击返回按钮

- (void)popViewController {
    CMTAPPCONFIG.IsInterruptAudioPlayback=NO;
    [super popViewController];
}

#pragma mark - WebView

// 增加动态模板控制页面字体, 答题模式的属性
- (NSString*)getExpose_param_String {
    NSString *paramString=[@"{\"is_night_mode\":" stringByAppendingFormat:@"\"%@\"",@"true"];
    paramString=[paramString stringByAppendingFormat:@",\"font-size\":\"%@\"",CMTAPPCONFIG.customFontSize];
    paramString=[paramString stringByAppendingFormat:@",\"scr-size\":\"%ld_%ld\"}",(long)SCREEN_WIDTH,(long)SCREEN_HEIGHT];
    
    return paramString;
}

// 加载动态模板url add by guoyuanchao
- (void)CMT_ISHTML_LoadWebview {
    
    // 动态文章详情
    if (self.viewModel.isHTML.isTrue) {
        
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[[NSURL alloc]initWithString:self.viewModel.postURL relativeToURL:[CMTClient defaultClient].baseURL]];
        
        if (CMTUSER.login) {
            [request addValue: USER_AGENT forHTTPHeaderField:@"User-Agent"];
            NSString *userId = CMTUSER.userInfo.userId;
            [request setValue:userId forHTTPHeaderField:@"userId"];
            [request setValue:CMTUSERINFO.userUuid forHTTPHeaderField:@"userUuid"];
            [request setValue:USER_AGENT forHTTPHeaderField:@"cmUserAgent"];
        }
        else {
            [request addValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
            [request setValue:@"0" forHTTPHeaderField:@"userId"];
            [request setValue:@"0" forHTTPHeaderField:@"userUuid"];
            [request setValue:USER_AGENT forHTTPHeaderField:@"cmUserAgent"];

        }
        
        [request setValue:[self getExpose_param_String]forHTTPHeaderField:@"expose-param"];
        CMTLog(@"head头%@",request.allHTTPHeaderFields);
        [self.webViewModel loadRequest:request];
        [self.webView loadRequest:request];
    }
    // 静态文章详情
    else {
        
        // 刷新文章详情
        [self.webViewModel loadHTMLString:self.viewModel.postDetailHTMLString
                                  baseURL:[[NSBundle mainBundle] URLForResource:CMTNSStringHTMLTemplate_caseDetail_fileName
                                                                  withExtension:CMTNSStringHTMLTemplate_fileType]];
        [self.webView loadHTMLString:self.viewModel.postDetailHTMLString
                             baseURL:[[NSBundle mainBundle] URLForResource:CMTNSStringHTMLTemplate_caseDetail_fileName
                                                             withExtension:CMTNSStringHTMLTemplate_fileType]];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    @try {
        NSString *URLString = request.URL.absoluteString;
        NSString *URLScheme = request.URL.scheme;
        //处理空白页和系统标签
        if ([URLString hasPrefix:@"about"]||[URLString hasPrefix:@"chrome"]) {
            return YES;
        }

        // scheme: file
        if ([URLScheme rangeOfString:CMTNSStringHTMLScheme_FILE
                             options:NSCaseInsensitiveSearch].length > 0) {
            
#pragma mark 静态文章详情
            
            if ([URLString rangeOfString:[NSString stringWithFormat:@"%@.%@", CMTNSStringHTMLTemplate_caseDetail_fileName, CMTNSStringHTMLTemplate_fileType]
                                 options:NSCaseInsensitiveSearch].length > 0) {
                
                return YES;
            }
        }
        
#pragma mark HTML动作标签
        
        // scheme: cmtopdr
        else if ([URLScheme rangeOfString:CMTNSStringHTMLTagScheme_CMTOPDR
                                  options:NSCaseInsensitiveSearch].length > 0) {
            
            [self handleHTMLTag:URLString];
        }
        
        // other scheme
        else {
            
#pragma mark 动态文章详情
                if (webView==self.webView) {
                    if (self.webViewLoadNumbers == 1) {
                        self.lastRequest=request;
                       return YES;
                    }else if (![self.UrlArray containsObject:self.lastRequest]&&self.viewModel.webViewModelLoadFinish) {
                        // 动态文章详情 其他链接
                        BOOL flag=[URLString handleWithinArticle:URLString viewController:self ];
                                if(!flag){
                                    return flag;
                                }
                         if (self.viewModel.isHTML.isTrue&&!CMTUSER.login) {
                             self.isreloadWebView = YES;
                         }
                        self.viewModel.webLink = request.URL.absoluteString;
                        return NO;
                    }else{
                          self.lastRequest=request;
                        return YES;
                    }
                }else if(webView==self.webViewModel){
                    self.lastmodelRequest=request;
                   return YES;
                }
        }
        
    }
    @catch (NSException *exception) {
        CMTLogError(@"CaseDetail Analyze WebView Request Exception: %@", exception);
    }
    
    return NO;
}

/**
 *  判断是否带有webView
 *
 *  @param webView
 */
-(void)ishaveFrame:(UIWebView*)webView request:(NSURLRequest*)request{
    [webView stringByEvaluatingJavaScriptFromString:
     @"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function ResizeImages() { "
     " return document.getElementsByTagName('iframe').length;"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    
    NSString *frameNumbers=[webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    NSLog(@"hdhdhdhdhdhdhdh%@",frameNumbers);
     [self.UrlArray removeObject:request];
    if (frameNumbers.integerValue>0) {
        [self.UrlArray addObject:request];
    }

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    

    if (webView == self.webView) {
                self.webViewLoadNumbers++;
        self.viewModel.webViewLoadFinish = YES;
        [self ishaveFrame:webView request: webView.request];
       
    }
    else if (webView == self.webViewModel) {
        self.viewModel.webViewModelLoadFinish = YES;
          self.webViewModelLoadNumbers++;
         [self ishaveFrame:webView request:webView.request];
    }

            if (self.viewModel.webViewLoadFinish == YES &&
        self.viewModel.webViewModelLoadFinish == YES) {
        // 用户为该文章作者
        if ([self.viewModel.postDetail.authorId isEqual:CMTUSERINFO.userId]) {
            // 添加文章追加按钮
            [[self.webView stringByEvaluatingJavaScriptFromString:@"showComment()"] floatValue];
        }
                
        //获取详情高度
        [[self.webView stringByEvaluatingJavaScriptFromString:@"getHeight()"] floatValue];
        
        // 添加评论筛选按钮
        [[self.webView stringByEvaluatingJavaScriptFromString:@"showFilter()"] floatValue];
        
        float filtebuttonbuttom= [[self.webView stringByEvaluatingJavaScriptFromString:@"getfilteButtonbottom()"]floatValue];
        
        float filteButtonTop= [[self.webView stringByEvaluatingJavaScriptFromString:@"getfilteButtonTop()"]floatValue];
        float displayheight=self.webView.height - (CMTNavigationBarBottomGuide +CMTReplyViewDefaultHeight);
        // 获取文章详情高度
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0||[[[UIDevice currentDevice] systemVersion] floatValue]< 8.0) {
             self.greaterthanonescreen=filtebuttonbuttom>=displayheight;
          if (!self.greaterthanonescreen) {
            [self.webView stringByEvaluatingJavaScriptFromString:[@"setfilteButtonTop(" stringByAppendingFormat:@"%f)",displayheight-(filtebuttonbuttom-filteButtonTop)] ];
            
          }
          self.viewModel.postDetailContentHeight =self.webView.scrollView.contentSize.height;
        }else{
            self.viewModel.postDetailContentHeight =!self.viewModel.isHTML.boolValue?filtebuttonbuttom:[[self.webView stringByEvaluatingJavaScriptFromString:@"getfilteDivbottom()"]floatValue];
                
        }
        if (self.viewModel.postDetailContentHeight == 0) {
            self.viewModel.postDetailContentHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
        }
        // 刷新评论列表
        [self reloadTableScrollView];
        
        // 快速评论显示键盘
        if (self.viewModel.viewDidAppearState == YES &&
            self.viewModel.quickReplyFinish == NO &&
            self.postDetailType == CMTPostDetailTypeCaseListWithReply) {
            self.viewModel.quickReplyFinish = YES;
            
            // 显示键盘
            [self.replyInputView showInputView];
        }
        
        // 文章追加已发送 滑动到文章详情底部
        if (self.viewModel.appendDetailSend == YES) {
            //处理内容过少时IOS8滑动距离出现问题
            CGFloat contentOffsetY = self.viewModel.postDetailContentHeight - (self.webView.height - CMTReplyViewDefaultHeight);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0||[[[UIDevice currentDevice] systemVersion] floatValue]< 9.0){
                if(self.viewModel.postDetailContentHeight<self.webView.height){
                    [self.webView.scrollView setContentOffset:(CGPoint){0.0, 0.0} animated:YES];
                }else{
                     [self.webView.scrollView setContentOffset:(CGPoint){0.0,contentOffsetY} animated:YES];
                }
            }else{
                 [self.webView.scrollView setContentOffset:(CGPoint){0.0, contentOffsetY} animated:YES];
            }
            
        }
        
        // 显示详情
        if (self.isdetailnomal) {
             self.contentState = CMTContentStateNormal;
            if (self.isBeingUpdated) {
                [self toastAnimation:@"内容更新完成"];
                self.isBeingUpdated=NO;
            }
            if (self.isHaveUpdated) {
                [self toastAnimation:@"没有最新内容"];
                self.isHaveUpdated=NO;

            }
        }
       
        // 静态文章详情 刷新PDF文件状态
        NSArray *pdfFiles = self.viewModel.postDetail.pdfFiles;
        for (int index = 0; index < pdfFiles.count; index++) {
            CMTPdf *pdfInfo = pdfFiles[index];
            [self refreshPDFFileStatus:[CMTPDFBrowserViewController checkPDFFileStatusWithPDFURL:pdfInfo.fileUrl] WithPDFID:[NSString stringWithFormat:@"%d", index]];
        }
        
        if (self.viewModel.isHTML.isTrue && self.webViewHeightTimer == nil) {
            self.webViewHeightTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changewebViewHeight) userInfo:nil repeats:YES];
        }
        if (!self.viewModel.postDetailLoadFinish) {
            self.viewModel.postDetailLoadFinish = YES;
        }
        //隐藏文章类型
        [self.webView stringByEvaluatingJavaScriptFromString:@"hidePostType()"];
        //更新网络状态
        [self updateNetWorkingState];

    }
}

//处理疾病标签阅读时间 add by guoyuanchao
-(void)CMTEditDiseaseTagReadtime:(NSString*)diseaseID{
    NSMutableArray *Disarray=[[NSMutableArray alloc]init];
    Disarray=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]mutableCopy];
    for(CMTDisease *dis in Disarray){
        if ([dis.diseaseId isEqualToString:diseaseID]) {
            if ([self.viewModel.postDetail.module integerValue]==0) {
                CMTAPPCONFIG.UnreadPostNumber_Slide=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.UnreadPostNumber_Slide integerValue]-[dis.postCount integerValue]];
                dis.postCount=@"0";
                dis.postReadtime=TIMESTAMP;
            }else if([self.viewModel.postDetail.module integerValue]==1){
                CMTAPPCONFIG.UnreadCaseNumber_Slide=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.UnreadCaseNumber_Slide integerValue]-[dis.caseCout integerValue]];
                dis.caseCout=@"0";
                dis.caseReadtime=TIMESTAMP;
            }else if([self.viewModel.postDetail.module integerValue]==3){
                CMTAPPCONFIG.GuideUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.GuideUnreadNumber integerValue]-[dis.count integerValue]];
                dis.count=@"0";
                dis.readTime=TIMESTAMP;
            }
            break;
        }
    }
    [NSKeyedArchiver archiveRootObject:Disarray toFile:PATH_FOUSTAG];
    
}

//监听高度事件 add by guoyuanchao
- (void)changewebViewHeight {
    float filtebuttonbuttom= [[self.webView stringByEvaluatingJavaScriptFromString:@"getfilteDivbottom()"]floatValue];
    CGFloat webViewHeight =filtebuttonbuttom;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0||[[[UIDevice currentDevice] systemVersion] floatValue]< 8.0){
          webViewHeight=self.webView.scrollView.contentSize.height;
    }
    if (webViewHeight == 0) {
        webViewHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
    }
    
    if (webViewHeight > self.viewModel.postDetailContentHeight) {
        [self webViewDidFinishLoad:self.webView];
        [self.webViewHeightTimer invalidate];
        self.webViewHeightTimer=nil;
    }
  }

- (void)handleHTMLTag:(NSString *)HTMLTag {
    if (![HTMLTag isKindOfClass:[NSString class]]) {
        CMTLogError(@"CaseDetail handle HTMLTag Error: HTMLTag is not Kind Of NSString Class");
        return;
    }
    
    NSDictionary *parseDictionary = HTMLTag.CMT_HTMLTag_parseDictionary;
    NSDictionary *parameters = parseDictionary[CMTNSStringHTMLTagParseKey_parameters];
    NSString *action = parameters[CMTNSStringHTMLTagParameterKey_action];
    
#pragma mark 点击作者
    
    if ([action isEqual:CMTNSStringHTMLTagAction_author]) {
        
        [self.navigationController pushViewController:
         [[CMTOtherPostListViewController alloc] initWithAuthor:[parameters[CMTNSStringHTMLTagParameterKey_nickname] URLDecodeString]
                                                       authorId:parameters[CMTNSStringHTMLTagParameterKey_authorid]]
                                             animated:YES];
    }
    
#pragma mark 点击类型
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_type]) {
        
        [self.navigationController pushViewController:
         [[CMTOtherPostListViewController alloc] initWithPostType:[parameters[CMTNSStringHTMLTagParameterKey_posttype] URLDecodeString]
                                                       postTypeId:parameters[CMTNSStringHTMLTagParameterKey_posttypeid]]
                                             animated:YES];
    }
    
#pragma mark 点击专题标签
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_themeTag]) {
        
        [self.navigationController pushViewController:
         [[CMTOtherPostListViewController alloc] initWithThemeId:parameters[CMTNSStringHTMLTagParameterKey_themeId]
                                                          postId:parameters[CMTNSStringHTMLTagParameterKey_postId]
                                                          isHTML:self.viewModel.isHTML
                                                         postURL:self.viewModel.postURL]
                                             animated:YES];
    }
    
#pragma mark 点击疾病标签
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_diseaseTag]) {
        [self CMTEditDiseaseTagReadtime:parameters[CMTNSStringHTMLTagParameterKey_diseaseId]];
        
        [self.navigationController pushViewController:
         [[CMTOtherPostListViewController alloc] initWithDisease:[parameters[CMTNSStringHTMLTagParameterKey_disease] URLDecodeString]
                                                      diseaseIds:parameters[CMTNSStringHTMLTagParameterKey_diseaseId]
                                                          module:parameters[CMTNSStringHTMLTagParameterKey_module]]
                                             animated:YES];
    }
    
#pragma mark 点击二级标签
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_searchKeyword]) {
        
        [self.navigationController pushViewController:
         [[CMTOtherPostListViewController alloc] initWithKeyword:parameters[CMTNSStringHTMLTagParameterKey_keyword]
                                                          module:parameters[CMTNSStringHTMLTagParameterKey_module]]
                                             animated:YES];
    }
    
#pragma mark 点击图片
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_showPicture]) {
        
        // 动态详情页 点击图片
        NSString *imageURLArrayString = [parameters[CMTNSStringHTMLTagParameterKey_picList] URLDecodeString];
        if ([imageURLArrayString isKindOfClass:[NSString class]] && !BEMPTY(imageURLArrayString)) {
            NSArray *imageURLArray = [imageURLArrayString componentsSeparatedByString:@","];
            NSString *curImageURL = [parameters[CMTNSStringHTMLTagParameterKey_curPic] URLDecodeString];
            
            [self openPhotoBrowserWithCurrentImageURL:curImageURL
                                       totalImageURLs:imageURLArray];
        }
        // 静态详情页 点击图片
        else {
            NSString *picIndex = parameters[CMTNSStringHTMLTagParameterKey_picIndex];
            NSArray *imageURLArray = [self.viewModel.postDetail.imageList componentsOfValueForKey:@"picFilepath"];
            
            [self openPhotoBrowserWithCurrentImageIndex:picIndex
                                         totalImageURLs:imageURLArray];
        }
    }
    
#pragma mark 点击PDF
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_openPDF]) {
        NSString *PDFURL = parameters[CMTNSStringHTMLTagParameterKey_pdfUrl];
        NSString *PDFSize = parameters[CMTNSStringHTMLTagParameterKey_size];
        NSString *PDFID = parameters[CMTNSStringHTMLTagParameterKey_id];
        if (!BEMPTY(PDFURL) && !BEMPTY(PDFSize)) {
            
            [self openPDFBrowserWithPDFURL:PDFURL PDFSize:PDFSize PDFID:PDFID];
        }
        else {
            
            CMTLogError(@"CaseDetail Open PDFBrowser Error:  Empty PDFURL or Empty PDFSize");
        }
    }
    
#pragma mark 点击追加按钮
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_additionalDetails]) {
        [MobClick event:@"B_lunBa_AddDiscription"];
        [self filterData:0];

    }else if ([action isEqual:CMTNSStringHTMLTagAction_additionalConclusions]) {
        [MobClick event:@"B_lunBa_AddConclusion"];
        [self filterData:1];

        
        
    }
    
#pragma mark 点击评论过滤按钮
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_zan]) {
        NSString *isFirstClikcommentFilter=[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstClikcommentFilter"];

        // 未登录
        if (CMTUSER.login == NO) {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [self.navigationController pushViewController:loginVC animated:YES];
        }
        // 第一次点击评论过滤按钮
        else if (isEmptyString(isFirstClikcommentFilter)&&!isFirstClikcommentFilter.boolValue) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"该按钮用于快速筛选你赞过的精彩评论" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"isFirstClikcommentFilter"];
        }
        else {
            UILabel *commentListTitle = (UILabel *)[self.commentListHeader viewWithTag:100];
            if ([self.viewModel.commentFilterState isEqual:@"1"]) {
                self.viewModel.commentFilterState = @"0";
                commentListTitle.text = @"全部评论";
                [self.webView stringByEvaluatingJavaScriptFromString:@"filter()"];
            }
            else {
                self.viewModel.commentFilterState = @"1";
                commentListTitle.text = @"我赞过的";
                [self.webView stringByEvaluatingJavaScriptFromString:@"filter('1')"];
            }
        }
    }
    
#pragma mark 点击登陆
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_login]) {
        self.isreloadWebView=YES;
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    
#pragma mark 点击分享
    
    else if ([action isEqual:CMTNSStringHTMLTagAction_share]) {
        
        [self CMTShareAction];
    }else if ([action isEqualToString:@"originalVideo"]){
        self.videoUrlString=[parameters[@"url"]decodeFromPercentEscapeString];
        
        if([self getCaseNetworkReachabilityStatus].integerValue==0){
            
            [self toastAnimation:@"你的网络不给力"];
            return;
        }else if ([self getCaseNetworkReachabilityStatus].integerValue==1) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看视频" message:nil delegate:nil
                                               cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
            @weakify(self)
            [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                @strongify(self);
                if ([index integerValue] == 1) {
                    LDZMoviePlayerController *moviewPlayerVC = [[LDZMoviePlayerController alloc] initWithUrl:[NSURL URLWithString: self.videoUrlString]];
                    //  播放网络
                    moviewPlayerVC.postId = self.viewModel.postId;
                    [self.navigationController pushViewController:moviewPlayerVC animated:YES];
                    
                }
            }];
            [alert show];
            
        }else{
            LDZMoviePlayerController *moviewPlayerVC = [[LDZMoviePlayerController alloc] initWithUrl:[NSURL URLWithString: self.videoUrlString]];
            //  播放网络
            moviewPlayerVC.postId = self.viewModel.postId;
            [self.navigationController pushViewController:moviewPlayerVC animated:YES];
            return;
        }
    }

    
#pragma mark 其他
    
    else {
        
        CMTLog(@"HTMLTag: %@\nparseDictionary: %@", HTMLTag, parseDictionary);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请升级新版本"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
            // 确定 跳转App Store
            if ([index integerValue] == 1) {
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/yi-sheng/id548271766?l=zh&ls=1&mt=8"]];
            }
        }];
        [alert show];
    }
}
-(NSString*)getCaseNetworkReachabilityStatus{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable) {
        return @"0";
    }else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWWAN){
        return @"1";
    }
    else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWiFi){
        return @"2";
    }
    return @"2";
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // tableScrollView
    if (scrollView == self.webView.scrollView) {
        [self.webView.scrollView tableScrollViewDidScroll:scrollView];
        
        // 当前阅读文章
        if (self.viewModel.readingPostDetail == YES) {
            // 记录上次阅读文章位置
            if (scrollView.contentOffset.y < (-CMTNavigationBarBottomGuide + self.webView.scrollView.headerHeight - 20.0)) {
                self.viewModel.lastContentOffsetY = scrollView.contentOffset.y;
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    // 文章追加选择器
    [self.appendDetailFilter hideFilter];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // tableScrollView
    if (scrollView == self.webView.scrollView) {
        [self.webView.scrollView tableScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // tableScrollView
    if (scrollView == self.webView.scrollView) {
        [self.webView.scrollView tableScrollViewDidEndDecelerating:scrollView];
        
        // 当前阅读文章
        if (self.viewModel.readingPostDetail == YES) {
            // 记录上次阅读文章位置
            if (scrollView.contentOffset.y < (-CMTNavigationBarBottomGuide + self.webView.scrollView.headerHeight - 20.0)) {
                self.viewModel.lastContentOffsetY = scrollView.contentOffset.y;
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    // tableScrollView
    if (scrollView == self.webView.scrollView) {
        [self.webView.scrollView tableScrollViewDidEndScrollingAnimation:scrollView];
    }
}

#pragma mark - TableScrollView

// 刷新评论列表
- (void)reloadTableScrollView {
    // 判断是否需要显示点击刷新
    BOOL showTapToRefresh = (self.postDetailType == CMTPostDetailTypeCommentEdit && self.viewModel.commentNotUpToDate == YES);
    // 刷新评论列表
    [self.webView.scrollView reloadDataWithHeaderHeight:self.viewModel.postDetailContentHeight
                                        fixedViewHeight:self.commentListHeader.height
                                        accessoryHeight:showTapToRefresh ? CMTTapToRefreshDefaultHeight : 0.0
                                            frameHeight:self.webView.height
                                               topInset:CMTNavigationBarBottomGuide
                                            bottomInset:CMTReplyViewDefaultHeight];
    // 刷新评论列表顶部视图
    self.commentListHeader.visible = YES;
    [self.commentListHeader builtinContainer:self.webView.scrollView
                                    WithLeft:self.commentListHeader.left
                                         Top:self.viewModel.postDetailContentHeight
                                       Width:self.commentListHeader.width
                                      Height:self.commentListHeader.height];
    // 刷新点击刷新
    self.tapToRefresh.visible = showTapToRefresh;
    [self.tapToRefresh builtinContainer:self.webView.scrollView
                               WithLeft:0.0
                                    Top:self.commentListHeader.bottom
                                  Width:self.webView.width
                                 Height:CMTTapToRefreshDefaultHeight];
    // 刷新翻页控件
    [self.webView.scrollView refreshInfiniteScrollingOriginY:self.webView.scrollView.lastCoveredHeight];
    // 评论列表刷新完成
    if (self.viewModel.commentReplyList.count > 0) {
        self.viewModel.replyListReloadFinish = YES;
    }
}

- (NSUInteger)numberOfCellsInTableScrollView:(UIScrollView *)tableScrollView {
    return [self.viewModel numberOfRowsInSection:0];
}

- (CGFloat)tableScrollView:(UIScrollView *)tableScrollView heightForCellAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    RACTuple *tuple = [self.viewModel commentReplyForRowAtIndexPath:indexPath];
    if ([tuple.first isKindOfClass:[CMTComment class]]) {
        
        return [CMTCommentListCell cellHeightFromComment:tuple.first cellWidth:self.webView.scrollView.width];
    }
    else if ([tuple.first isKindOfClass:[CMTReply class]]) {
        CMTComment *comment = nil;
        BOOL last = NO;
        
        if ([tuple.third isKindOfClass:[CMTComment class]]) {
            comment = tuple.third;
        }
        if ([tuple.second respondsToSelector:@selector(boolValue)]) {
            last = [tuple.second boolValue];
        }
        
        return [CMTReplyListWrapCell cellHeightFromReply:tuple.first comment:comment cellWidth:self.webView.scrollView.width last:last];
    }
    else {
        
        return 0;
    }
}

- (UITableViewCell *)tableScrollView:(UIScrollView *)tableScrollView cellAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    static NSString *cellIdentifier = @"defaultCell";
    UITableViewCell *cell = nil;
    RACTuple *tuple = [self.viewModel commentReplyForRowAtIndexPath:indexPath];
    
    if ([tuple.first isKindOfClass:[CMTComment class]]) {
        
        cell = [self.webView.scrollView dequeueReusableCellWithIdentifier:CMTPostDetailCommentListCommentCellIdentifier];
        if (cell == nil) {
            cell = [[CMTCommentListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CMTPostDetailCommentListCommentCellIdentifier];
          
        }
        ((CMTCommentListCell *)cell).delegate=self;
        [(CMTCommentListCell *)cell reloadComment:tuple.first cellWidth:self.webView.scrollView.width indexPath:indexPath];
    }
    else if ([tuple.first isKindOfClass:[CMTReply class]]) {
        CMTComment *comment = nil;
        BOOL last = NO;
        
        if ([tuple.third isKindOfClass:[CMTComment class]]) {
            comment = tuple.third;
        }
        if ([tuple.second respondsToSelector:@selector(boolValue)]) {
            last = [tuple.second boolValue];
        }
        
        cell = [self.webView.scrollView dequeueReusableCellWithIdentifier:CMTPostDetailCommentListReplyCellIdentifier];
        if (cell == nil) {
            cell = [[CMTReplyListWrapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CMTPostDetailCommentListReplyCellIdentifier];
        }
        [(CMTReplyListWrapCell *)cell setDelegate:self];
        [(CMTReplyListWrapCell *)cell reloadReply:tuple.first comment:comment cellWidth:self.webView.scrollView.width indexPath:indexPath last:last];
    }
    else {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)tableScrollView:(UIScrollView *)tableScrollView didSelectCellAtIndex:(NSInteger)index {
    CMTLog(@"didSelectCellAtIndex: %ld", (long)index);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    // 未登陆状态
    if (CMTUSER.login == NO) {
        // 提示登录
        [self.loginAlert show];
        return;
    }
    
    // 获取选中的评论
    CMTComment *comment = nil;
    RACTuple *commentReply = [self.viewModel commentReplyForRowAtIndexPath:indexPath];
    if ([commentReply.first isKindOfClass:[CMTComment class]]) {
        
        comment = commentReply.first;
    }
    if (comment == nil) {
        CMTLogError(@"CaseDetail Get Selected Comment Error");
        return;
    }
    
    // 删除评论
    if ([comment.userId isEqual:CMTUSERINFO.userId]) {
        // 删除提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否删除该评论" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        @weakify(self);
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            // 确定删除
            if ([index integerValue] == 1) {
                self.viewModel.commentToDelete = comment;
            }
        }];
        [alert show];
        return;
    }
    
    // 回复评论
    // 显示键盘
    [self.replyInputView showInputView];
    // 设置tableView 当前选中的indexPath
    self.viewModel.selectedIndexPath = indexPath;
    // 设置被回复的评论
    self.viewModel.commentToReply = comment;
}

- (void)replyListWrapCell:(CMTReplyListWrapCell *)cell didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 未登陆状态
    if (CMTUSER.login == NO) {
        // 提示登录
        [self.loginAlert show];
        return;
    }
    
    // 获取选中的回复
    CMTReply *reply = nil;
    RACTuple *commentReply = [self.viewModel commentReplyForRowAtIndexPath:indexPath];
    if ([commentReply.first isKindOfClass:[CMTReply class]]) {
        
        reply = commentReply.first;
    }
    if (reply == nil) {
        CMTLogError(@"CaseDetail Get Selected Reply Error");
        return;
    }
    
    // 删除回复
    if ([reply.userId isEqual:CMTUSERINFO.userId]) {
        // 删除提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否删除该回复" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        @weakify(self);
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            // 确定删除
            if ([index integerValue] == 1) {
                self.viewModel.replyToDelete = reply;
            }
        }];
        [alert show];
        return;
    }
    
    // 回复回复
    // 显示键盘
    [self.replyInputView showInputView];
    // 设置tableView 当前选中的indexPath
    self.viewModel.selectedIndexPath = indexPath;
    // 设置被回复的回复
    self.viewModel.replyToReply = reply;
}

//子评论点赞
-(void)replyListPraise:(CMTReply*)reply index:(NSIndexPath*)indexpath{
    
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        @weakify(self)
        NSDictionary *params=@{
                               @"userId":CMTUSERINFO.userId ?:@"0",
                               @"praiseType":@"6",
                               @"replyId":reply.replyId,
                               @"postId":self.viewModel.postId,
                               @"cancelFlag":!reply.isPraise.boolValue?@"0":@"1"
                               };
        
        [[[CMTCLIENT Praise:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            @strongify(self)
            RACTuple *tuple = [self.viewModel commentReplyForRowAtIndexPath:indexpath];
            
            if ([tuple.first isKindOfClass:[CMTReply class]]) {
                if (!((CMTReply*)tuple.first).isPraise.boolValue) {
                    ((CMTReply*)tuple.first).isPraise=@"1";
                    ((CMTReply*)tuple.first).praiseCount=[@"" stringByAppendingFormat:@"%ld",(long)(((CMTReply*)tuple.first).praiseCount.integerValue+1)];
                }else{
                    ((CMTReply*)tuple.first).isPraise=@"0";
                    ((CMTReply*)tuple.first).praiseCount=[@"" stringByAppendingFormat:@"%ld",(long)(((CMTReply*)tuple.first).praiseCount.integerValue-1>0?((CMTReply*)tuple.first).praiseCount.integerValue-1:0)];
                    
                }
                
            }
            
            [self reloadTableScrollView];
        } error:^(NSError *error) {
            @strongify(self);
            if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                [self toastAnimation:error.userInfo[@"errmsg"]];
            }
            
        }completed:^{
            
        }];
        
        
    }
    
}
//评论点赞
-(void)CommentListCellPraise:(CMTComment*)Comment index:(NSIndexPath*)indexpath{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        @weakify(self)
        NSDictionary *params=@{
                               @"userId":CMTUSERINFO.userId ?:@"0",
                               @"praiseType":@"5",
                               @"commentId":Comment.commentId,
                               @"postId":self.viewModel.postId,
                               @"cancelFlag":!Comment.isPraise.boolValue?@"0":@"1"
                               };
        
        [[[CMTCLIENT Praise:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            @strongify(self)
            RACTuple *tuple = [self.viewModel commentReplyForRowAtIndexPath:indexpath];
            
            if ([tuple.first isKindOfClass:[CMTComment class]]) {
                if (!((CMTComment*)tuple.first).isPraise.boolValue) {
                    ((CMTComment*)tuple.first).isPraise=@"1";
                    ((CMTComment*)tuple.first).praiseCount=[@"" stringByAppendingFormat:@"%ld",(long)(((CMTComment*)tuple.first).praiseCount.integerValue+1)];
                }else{
                    ((CMTComment*)tuple.first).isPraise=@"0";
                    ((CMTComment*)tuple.first).praiseCount=[@"" stringByAppendingFormat:@"%ld",(long)(((CMTComment*)tuple.first).praiseCount.integerValue-1>0?((CMTComment*)tuple.first).praiseCount.integerValue-1:0)];
                    
                }
                
            }
            
            
            
            [self reloadTableScrollView];
        } error:^(NSError *error) {
            @strongify(self);
            if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                 [self toastAnimation:error.userInfo[@"errmsg"]];
            }
            
        }completed:^{
            
        }];
        
        
    }
    
    
}


#pragma mark - MWPhotoBrowser

- (void)openPhotoBrowserWithCurrentImageURL:(NSString *)imageURL
                             totalImageURLs:(NSArray *)totalImageURLs {
    // Photos
    NSMutableArray *photos = [NSMutableArray array];
    for (NSInteger index = 0; index < totalImageURLs.count; index++) {
        // 原始图片URL
        NSString *imageURLString = [UIImage fullQualityImageURLWithURL:totalImageURLs[index]];
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
        photo.caption = [NSString stringWithFormat:@"%ld/%ld", (long)(index + 1), (long)totalImageURLs.count];
        [photos addObject:photo];
    }
    self.viewModel.photoBrowserPhotos = photos;
    
    // PhotoBrowser
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableSwipeToDismiss = NO;
    [photoBrowser setCurrentPhotoIndex:[totalImageURLs indexOfObject:imageURL]];
    
    // Show
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.viewModel.photoBrowserOpening = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)openPhotoBrowserWithCurrentImageIndex:(NSString *)imageIndex
                               totalImageURLs:(NSArray *)totalImageURLs {
    // Photos
    NSMutableArray *photos = [NSMutableArray array];
    for (NSInteger index = 0; index < totalImageURLs.count; index++) {
        // 原始图片URL
        NSString *imageURLString = [UIImage fullQualityImageURLWithURL:totalImageURLs[index]];
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
        photo.caption = [NSString stringWithFormat:@"%ld/%ld", (long)(index + 1), (long)totalImageURLs.count];
        [photos addObject:photo];
    }
    self.viewModel.photoBrowserPhotos = photos;
    
    // PhotoBrowser
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableSwipeToDismiss = NO;
    [photoBrowser setCurrentPhotoIndex:imageIndex.integerValue];
    
    // Show
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.viewModel.photoBrowserOpening = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.viewModel.photoBrowserPhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.viewModel.photoBrowserPhotos.count) {
        return self.viewModel.photoBrowserPhotos[index];
    }
    return nil;
}

#pragma mark - PDF

- (void)refreshPDFFileStatus:(CMTPDFFileStatus)PDFFileStatus WithPDFID:(NSString *)PDFID {
    
    NSString *javascriptString = [NSString stringWithFormat:@"javascript:setStatus('%@', %ld)", PDFID, (long)PDFFileStatus];
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
}

- (void)openPDFBrowserWithPDFURL:(NSString *)PDFURL PDFSize:(NSString *)PDFSize PDFID:(NSString *)PDFID {
    @weakify(self);
    CMTPDFBrowserViewController *PDFBrowserViewController = [[CMTPDFBrowserViewController alloc] initWithPDFURL:PDFURL PDFSize:PDFSize PDFID:PDFID
                                                                                                updatePDFStatus:^(CMTPDFFileStatus PDFFileStatus) {
                                                                                                    @strongify(self);
                                                                                                    [self refreshPDFFileStatus:PDFFileStatus WithPDFID:PDFID];
                                                                                                }];
    [self.navigationController pushViewController:PDFBrowserViewController animated:YES];
}

#pragma mark - 文章追加

- (void)filterData:(NSInteger)index {
    @weakify(self);
    
    // 文章追加类型
    CMTSendCaseType sendCaseType = CMTSendCaseTypeUnDefined;
    NSString *sendCaseTypeString = nil;
    if (index == 0) {
        sendCaseType = CMTSendCaseTypeAddPostDescribe;
        sendCaseTypeString = @"请登录之后追加描述";
    }
    else if (index == 1) {
        sendCaseType = CMTSendCaseTypeAddPostConclusion;
        sendCaseTypeString = @"请登录之后添加结论";
    }
    
    // 未登陆
    if (CMTUSER.login == NO) {
        // 提示登录
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:sendCaseTypeString
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        // 显示登录页
        [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if ([index integerValue] == 1) {
                CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
                loginVC.nextvc = kComment;
                [self.navigationController pushViewController:loginVC animated:YES];
            }
        }];
        [alertView show];
    }else if(CMTAPPCONFIG.addPostAdditionalData.addPostStatus.integerValue!=0){
        [self toastAnimation:@"还有描述或者结论未上传完成"];
    }else if ([self.viewModel.postDetail.postDiseaseExtList count]==21) {
        [self toastAnimation:@"不能再追加描述或结论啦"];
    }else if([self.viewModel.postDetail.postDiseaseExtList count]==20&&index==0){
        [self toastAnimation:@"不能再追加描述"];
    }else{
        
    // 显示发帖页面
    CMTSendCaseViewController *sendCaseViewController = [[CMTSendCaseViewController alloc] initWithSendCaseType:sendCaseType
                                                                                                         postId:self.viewModel.postId
                                                                                                     postTypeId:nil
                                                                                                        groupId:nil
                                                                                                 groupSubjectId:nil];
    sendCaseViewController.updateCaseList = ^(CMTAddPost *addPostAdditional) {
        @strongify(self);
        // 刷新文章详情及图片数组
        [self.progressView SendSuccess];
        if(self.viewModel.isHTML.isTrue){
            self.webViewLoadNumbers=1;
            self.webViewModelLoadNumbers=1;
            [self CMT_ISHTML_LoadWebview];
             self.viewModel.appendDetailSend = YES;
        }else{
          [self.viewModel updatePostDetailWithAddPostAdditional:addPostAdditional];
        }
    };
    
    CMTNavigationController *navi = [[CMTNavigationController alloc] initWithRootViewController:sendCaseViewController];
    [self presentViewController:navi animated:YES completion:nil];
  }
}

#pragma mark - ShareMethod

// 分享处理方法 add byguoyuanchao
- (void)CMTShareAction {
    if ( ![self HandlingErrors]) {
        return;
    }
    if (self.viewModel.postDetail != nil) {
        
        NSString *shareBrief = self.viewModel.postDetail.brief;
        if (BEMPTY(shareBrief)) {
            shareBrief = self.viewModel.postDetail.title.HTMLUnEscapedString;
        }
        [self.mShareView.mBtnFriend addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.mShareView.mBtnSina addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.mShareView.mBtnWeix addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.mShareView.mBtnMail addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.mShareView.cancelBtn addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
        //自定义分享
        [self shareViewshow:self.mShareView bgView:self.tempView currentViewController:self.navigationController];
        self.shareTitle = self.viewModel.postDetail.title.HTMLUnEscapedString;
        self.shareBrief = shareBrief;
        self.shareUrl = self.viewModel.postDetail.shareUrl;
    }
}

- (void)showShare:(UIButton *)btn {
    [self methodShare:btn];
}
//处理分享错误
-(BOOL)HandlingErrors{
    if ( self.viewModel.requestPostDetailNetError) {
        [self toastAnimation:@"你的网络不给力"];
        return NO;
    }else if(!isEmptyObject(self.viewModel.requestPostDetailServerErrorMessage)){
        [self toastAnimation:self.viewModel.requestPostDetailServerErrorMessage];
         return NO;
    }else if(!isEmptyObject(self.viewModel.requestPostDetailSystemErrorString)){
        [self toastAnimation:self.viewModel.requestPostDetailSystemErrorString];
          return NO;
    }else if (self.viewModel.postDetail.status.integerValue==11){
         [self toastAnimation:@"该贴已移除小组"];
          return NO;
    }
    return YES;
}
/// 平台按钮关联的分享方法
- (void)methodShare:(UIButton *)btn {
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
            NSMutableString *pdfUrl = [NSMutableString string];
            for (CMTPdf *pdf in self.viewModel.postDetail.pdfFiles) {
                NSString *shareName = pdf.originalFilename;
                NSString *sharePdfUrl = pdf.fileUrl;
                NSString *pTempStr = [NSString stringWithFormat:@"%@ %@",shareName,sharePdfUrl];
                [pdfUrl appendString:[NSString stringWithFormat:@"%@<br>",pTempStr]];
            }
             NSString *shareURL = self.viewModel.postDetail.shareUrl;
            NSString *pContent = [NSString stringWithFormat:@"#壹生#《%@》%@ 来自@壹生 <br>%@", self.viewModel.postDetail.title.HTMLUnEscapedString, self.viewModel.postDetail.shareUrl,pdfUrl];
           [self shareImageAndTextToPlatformType:UMSocialPlatformType_Email shareTitle:[NSString stringWithFormat:@"%@", self.viewModel.postDetail.title.HTMLUnEscapedString] sharetext:pContent sharetype:shareType sharepic:self.viewModel.postDetail.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"sharePost" shareData: self.viewModel.postDetail];        }
            break;
         case 5555:
        {
            
            [self shareViewDisapper];
        }
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
    [self.mShareView.cancelBtn removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
}

/// 朋友圈分享
- (void)friendCircleShare {
    NSString *shareType = @"1";
    NSString *shareURL = self.viewModel.postDetail.shareUrl;
    CMTLog(@"朋友圈");
    NSString *shareText = self.viewModel.postDetail.title.HTMLUnEscapedString;
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.viewModel.postDetail.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"sharePost" shareData: self.viewModel.postDetail];
}

/// 微信好友分享
- (void)weixinShare {
    NSString *shareType = @"2";
    NSString *shareTitle = self.viewModel.postDetail.title.HTMLUnEscapedString;
    NSString *shareText = self.viewModel.postDetail.brief;
    NSString *shareURL = self.viewModel.postDetail.shareUrl;
    if (BEMPTY(shareText)) {
        shareText = self.viewModel.postDetail.title.HTMLUnEscapedString;
    }
     [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.viewModel.postDetail.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"sharePost" shareData: self.viewModel.postDetail];
    }

- (void)weiboShare {
     NSString *shareType = @"3";
     NSString *shareURL = self.viewModel.postDetail.shareUrl;
     NSString *shareTitle = self.viewModel.postDetail.title.HTMLUnEscapedString;
    NSString *shareText = [NSString stringWithFormat:@"#%@# %@。%@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY, self.viewModel.postDetail.title.HTMLUnEscapedString, self.viewModel.postDetail.shareUrl];
    
    CMTLog(@"新浪文博\nshareText:%@", shareText);
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.viewModel.postDetail.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"sharePost" shareData: self.viewModel.postDetail];
}



@end
