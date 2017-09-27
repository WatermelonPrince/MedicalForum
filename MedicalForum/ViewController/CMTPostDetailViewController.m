//
//  CMTPostDetailViewController.m
//  MedicalForum
//
//  Created by fenglei on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

// controller
#import "CMTPostDetailViewController.h"                     // header file
#import "CMTBindingViewController.h"                        // 登录页
#import "CMTUpgradeViewController.h"                        // 申请认证页
#import "CMTOtherPostListViewController.h"                  // 其他文章列表
#import "MWPhotoBrowser.h"                                  // 图片浏览器
#import "CMTPDFBrowserViewController.h"                     // PDF浏览器
#import "CMTWebBrowserViewController.h"                     // 网页浏览器
#import "CMTCollectionViewController.h"                     // 收藏页

// view
#import "CMTPostDetailCommentHeader.h"                      // 文章详情评论列表表头 (简单文章详情 + 点击刷新)
#import "CMTCommentListCell.h"                              // 评论cell
#import "CMTReplyListWrapCell.h"                            // 回复cell
#import "UITableView+CMTExtension_PlaceholderView.h"        // 评论列表空数据提示
#import "CMTReplyView.h"                                    // 评论回复框
#import "CMTReplyInputView.h"                               // 评论输入框
#import "CMTUserNotAuthenticView.h"                         // 用户未认证提示
#import "CMTCustomScrollView.h"

// viewModel
#import "CMTPostDetailViewModel.h"                          // 文章详情数据
#import "SDWebImageManager.h"                       // 图片缓存
#import "SDWebImageOperation.h"                     // 图片缓存Operation
#import "CMTGroupInfoViewController.h"
#import "CMTLiveDetailViewController.h"
#import "CMTLiveViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CMTUpgradeViewController.h"
#import "LDZMoviePlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "CMTDigitalWebViewController.h"
#import "CMTDigitalNewspaperViewController.h"
#import "MBProgressHUD.h"
#import "CMTBaseViewController+CMTExtension.h"
@interface CMTPostDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, CMTReplyListWrapCellDelegate, MWPhotoBrowserDelegate,CMTCommentListCellPraiseDelegate>

// view
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIBarButtonItem *shareItem;                           // 分享按钮
@property (nonatomic, strong) UIBarButtonItem *favoriteItem;                        // 收藏按钮
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) NSArray *rightItems;                                  // 导航右侧按钮
@property (nonatomic, strong) CMTCustomScrollView *contentScrollView;                      // 文章详情 + (评论列表 + (简单文章详情 + 点击刷新))
@property (nonatomic, strong) UIWebView *webView;                                   // 文章详情
@property (nonatomic, strong) UITableView *tableView;                               // 评论列表 + (简单文章详情 + 点击刷新)
@property (nonatomic, strong) CMTPostDetailCommentHeader *postDetailCommentHeader;  // 简单文章详情 + 点击刷新
@property (nonatomic, strong) CMTReplyView *replyView;                              // 评论回复框
@property (nonatomic, strong) CMTReplyInputView *replyInputView;                    // 直播评论输入框
@property (nonatomic, strong) CMTUserNotAuthenticView *userNotAuthenticView;        // 用户未认证提示
@property (nonatomic, strong) UIAlertView *loginAlert;                              // 登陆提示
@property (nonatomic, strong) UIAlertView *cancelStoreAlert;                        // 取消收藏提示
@property (nonatomic, strong) UIView *hiddenView;//文章下线时的遮挡视图;
@property (nonatomic, strong) UILabel *offlineLabel;//下线提示;

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
@property(nonatomic,strong)NSMutableArray *requestArray;//记录加载了多少url
@property(nonatomic,strong)NSURLRequest *lastRequest;//记录上一次加载的url;
@property(nonatomic,strong)NSString *videoUrlString;
@property(nonatomic,assign)CMTime lastPalytime;
@property(nonatomic,strong)NSString*AudioName;
@property(nonatomic,strong)NSTimer *musicPlayedTime;


@end

@implementation CMTPostDetailViewController

#pragma mark - Initializers

- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                    postModule:(NSString *)postModule
                postDetailType:(CMTPostDetailType)postDetailType {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    CMTAPPCONFIG.IsWWANplaybackVideo=@"0";
    self.postDetailType = postDetailType;
    self.requestArray=[NSMutableArray array];
    self.lastRequest=[[NSURLRequest alloc]init];
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
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
     CMTAPPCONFIG.IsWWANplaybackVideo=@"0";
    self.requestArray=[NSMutableArray array];
    self.lastRequest=[[NSURLRequest alloc]init];
    self.postDetailType = CMTPostDetailTypeCommentEdit;
    self.viewModel = [[CMTPostDetailViewModel alloc] initWithPostId:postId
                                                             isHTML:isHTML
                                                            postURL:postURL
                                                         postModule:postModule
                                                 toDisplayedComment:toDisplayedComment];
    return self;
}

- (UIView *)hiddenView{
    if (_hiddenView == nil) {
        self.hiddenView = [[UIView alloc]init];
        _hiddenView.backgroundColor = [UIColor whiteColor];
        
        self.hiddenView.hidden = YES;
        
    }
    return _hiddenView;
}

- (UILabel *)offlineLabel{
    if (_offlineLabel == nil) {
        self.offlineLabel = [[UILabel alloc]init];
        _offlineLabel.center = self.hiddenView.center;
        _offlineLabel.textAlignment = NSTextAlignmentCenter;
        _offlineLabel.text = @"该文章已下线";
        _offlineLabel.font = FONT(21);
        _offlineLabel.textColor = [UIColor blackColor];
    }
    return _offlineLabel;
}

- (UIBarButtonItem *)shareItem {
    if (_shareItem == nil) {
        _shareItem = [[UIBarButtonItem alloc] initWithImage:IMAGE(@"naviBar_share")  style:UIBarButtonItemStylePlain target:nil action:nil];
        [_shareItem setBackgroundVerticalPositionAdjustment:-0.5 forBarMetrics:UIBarMetricsDefault];
    }
    
    return _shareItem;
}

- (UIBarButtonItem *)favoriteItem {
    if (_favoriteItem == nil) {
        self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteButton.frame = CGRectMake(4, 4, 25, 25);
        [_favoriteButton setBackgroundImage:IMAGE(@"naviBar_favorit") forState:UIControlStateNormal];
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
        _rightItems = @[rightFixedSpace, self.favoriteItem, self.shareItem];
    }
    
    return _rightItems;
}

- (UIScrollView *)contentScrollView {
    if (_contentScrollView == nil) {
        _contentScrollView = [[CMTCustomScrollView alloc] init];
        [_contentScrollView fillinContainer:self.contentBaseView WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        _contentScrollView.contentSize = CGSizeMake(_contentScrollView.width * 2.0, _contentScrollView.height);
        _contentScrollView.backgroundColor = COLOR(c_fafafa);
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.bounces = NO;
        _contentScrollView.scrollsToTop = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.delegate = self;
    }
    
    return _contentScrollView;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
        _webView.scrollView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTReplyViewDefaultHeight, 0.0);
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTReplyViewDefaultHeight, 0.0);
        _webView.scrollView.scrollsToTop = YES;
        _webView.backgroundColor = COLOR(c_fafafa);
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        _webView.allowsInlineMediaPlayback = YES;
    }
    
    return _webView;
}

- (UIView *)tableViewPlaceholderView {
    UIView *placeholderView = [[UIView alloc] init];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,(SCREEN_HEIGHT-100-CMTNavigationBarBottomGuide*2)/2, self.contentBaseView.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(15.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text = @"同行好友若相问，我在【壹生】写评论…";
    
    [placeholderView addSubview:placeholderLabel];
    
    return placeholderView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, (CMTReplyViewDefaultHeight - PIXEL) - SVInfiniteScrollingViewHeight, 0.0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTReplyViewDefaultHeight, 0.0);
        _tableView.backgroundColor = COLOR(c_fafafa);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollsToTop = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CMTCommentListCell class] forCellReuseIdentifier:CMTPostDetailCommentListCommentCellIdentifier];
        [_tableView registerClass:[CMTReplyListWrapCell class] forCellReuseIdentifier:CMTPostDetailCommentListReplyCellIdentifier];
        
        // 评论列表空数据提示
        _tableView.placeholderView = [self tableViewPlaceholderView];
    }
    
    return _tableView;
}

- (CMTPostDetailCommentHeader *)postDetailCommentHeader {
    if (_postDetailCommentHeader == nil) {
        BOOL showTapToRefresh = self.postDetailType == CMTPostDetailTypeCommentEdit;
        _postDetailCommentHeader = [[CMTPostDetailCommentHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.width, 0.0) showTapToRefresh:showTapToRefresh];
    }
    
    return _postDetailCommentHeader;
}

- (CMTReplyView *)replyView {
    if (_replyView == nil) {
        _replyView = [[CMTReplyView alloc] initWithContentView:self.tableView contentmaxlength:500 model:CMTReplyViewModelPostDetail];
        [_replyView fillinContainer:self.contentBaseView WithTop:self.view.height - CMTReplyViewDefaultHeight Left:0.0 Bottom:0.0 Right:0.0];
        [self.contentBaseView addSubview:_replyView];
    }
    
    return _replyView;
}

- (CMTReplyInputView *)replyInputView {
    if (_replyInputView == nil) {
        _replyInputView = [[CMTReplyInputView alloc] initWithInputViewModel:CMTReplyInputViewModelPostDetail
                                                           contentMaxLength:500];
    }
    
    return _replyInputView;
}

- (CMTUserNotAuthenticView *)userNotAuthenticView {
    if (_userNotAuthenticView == nil) {
        _userNotAuthenticView = [[CMTUserNotAuthenticView alloc] init];
        [_userNotAuthenticView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0.0 Bottom:0.0 Right:0.0];
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

- (void)loadView {
    [super loadView];
    CMTLog(@"%s", __FUNCTION__);
    
    if (self.contentScrollView.height == 0.0) {
        self.contentScrollView.frame = self.contentBaseView.frame;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);

    // Do any additional setup after loading the view, typically from a nib.
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
                CMTLog(@"PostDetail willDeallocSignal");
    }];
#pragma mark 导航栏按钮
    self.AudioName=@"壹生";
    // 返回按钮
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    
    // 分享及收藏按钮
    self.navigationItem.rightBarButtonItems = self.rightItems;
    
#pragma mark 分享
    
    // 点击分享
    self.shareItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
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
            [self.favoriteButton setBackgroundImage:IMAGE(@"naviBar_favorit") forState:UIControlStateNormal];
            
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
    
    // 添加 文章详情
    self.webViewLoadNumbers = 1;
    [self.webView builtinContainer:self.contentScrollView WithLeft:0.0 Top:0.0 Width:self.contentScrollView.width Height:self.contentScrollView.height];
    self.viewModel.webView = self.webView;
    
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
    }
    
    // 请求文章详情网络错误 显示重新加载
    [[[RACObserve(self.viewModel, requestPostDetailNetError) ignore:@NO]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        self.contentState = CMTContentStateReload;
        CMTLog(@"requestPostDetailNetError");
    }];
    
    // 请求文章详情服务器错误消息 空白页显示消息
    [[[RACObserve(self.viewModel, requestPostDetailServerErrorMessage) ignore:nil]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorMessage) {
        @strongify(self);
        self.contentEmptyView.contentEmptyPrompt = errorMessage;
        self.contentState = CMTContentStateEmpty;
    }];
    
    // 请求文章详情系统错误信息 显示空白页并提示
    [[[RACObserve(self.viewModel, requestPostDetailSystemErrorString) ignore:nil]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorString) {
        @strongify(self);
        self.contentState = CMTContentStateBlank;
        [self toastAnimation:@"系统错误"];
        CMTLogError(@"PostDetail 系统错误:\n%@", errorString);
    }];
   #pragma mark 监听是否有音频存在
    [[[RACObserve(self.viewModel,postDetail) ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTPost *postDetail) {
            @strongify(self);
            if(postDetail.postAttr.isPostAttrAudio||postDetail.postAttr.isPostAttrVideo){
                self.musicPlayedTime=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(PostMusicPlayed) userInfo:nil repeats:YES];
                
            }
        
    } error:^(NSError *error) {
        
    }];
    //文章下线时
    
    [[RACObserve(self.viewModel, postStatisticsErrorCode)deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.viewModel.postStatisticsErrorCode.integerValue == 102) {
            self.hiddenView.hidden = NO;
            self.viewModel.postStatistics.commentCount = 0;
            self.viewModel.postStatistics.praiseCount = 0;
        }else{
            self.hiddenView.hidden = YES;
        }
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
    
#pragma mark 打开网页浏览器
    
    [[[RACObserve(self.viewModel, webLink) ignore:nil]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.navigationController pushViewController:
         [[CMTWebBrowserViewController alloc] initWithURL:self.viewModel.webLink]
                                             animated:YES];
    }];
    
#pragma mark 评论列表
    
    // 添加评论列表
    [self.tableView builtinContainer:self.contentScrollView WithLeft:self.contentScrollView.width Top:0.0 Width:self.contentScrollView.width Height:self.contentScrollView.height];
    [self.hiddenView builtinContainer:self.contentScrollView WithLeft:self.contentScrollView.width Top:0 Width:self.contentScrollView.width Height:self.contentScrollView.height];
    [self.offlineLabel builtinContainer:self.hiddenView WithLeft:0 Top:self.hiddenView.height/2 - 30 Width:SCREEN_WIDTH Height:100];
    
    // 添加简单文章详情
    [self.tableView setTableHeaderView:self.postDetailCommentHeader];
    
    // 使用简单文章详情数据刷新简单文章详情
    [[[[[RACObserve(self.viewModel, postStatistics) ignore:nil] distinctUntilChanged] filter:^BOOL(id value) {
        @strongify(self);
        return self.viewModel.isHTML.isTrue;
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTPostStatistics *postStatistics) {
        @strongify(self);
        [self.postDetailCommentHeader reloadHeaderWithSimplePostDetail:postStatistics];
    }];
    
    // 简单文章详情 刷新高度
    self.postDetailCommentHeader.updateHeaderHeight = ^(CGFloat headerHeight) {
        @strongify(self);
        self.viewModel.postDetailHeaderHeight = headerHeight;
        [self.tableView setTableHeaderView:self.postDetailCommentHeader];
    };
    
    // 简单文章详情 点击链接
    self.postDetailCommentHeader.shouldStartLoadWithRequest = ^(NSURLRequest * request) {
        @strongify(self);
        [self webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked];
    };
    
    // 点击刷新 刷新评论
    [self.postDetailCommentHeader.tapToRefresh.refreshButtonSignal subscribeNext:^(id x) {
        @strongify(self);
        self.postDetailCommentHeader.tapToRefresh.active = YES;
        self.viewModel.tapToRefreshState = YES;
    }];
    
    // 隐藏点击刷新
    [[[[[RACObserve(self.viewModel, commentNotUpToDate) ignore:@YES] distinctUntilChanged] filter:^BOOL(id value) {
        @strongify(self);
        return (self.postDetailType == CMTPostDetailTypeCommentEdit);
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.postDetailCommentHeader hideTapToRefresh];
    }];
    
    // 评论翻页
    [self.tableView addInfiniteScrollingWithActionHandler:nil];
    RAC(self.viewModel, infiniteScrollingState) = [RACObserve(self.tableView.infiniteScrollingView, state) distinctUntilChanged];
    RAC(self.tableView, showsInfiniteScrolling) = [[RACObserve(self.tableView, contentSize) distinctUntilChanged] map:^id(NSValue *contentSize) {
        @strongify(self);
        if ([self.viewModel numberOfRowsInSection:0] == 0) return @NO;
        if ((self.tableView.contentInset.top + contentSize.CGSizeValue.height + CMTReplyViewDefaultHeight) <= self.tableView.height) return @NO;
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
        self.postDetailCommentHeader.tapToRefresh.active = NO;
        [self.tableView.infiniteScrollingView stopAnimating];
    }];
    
    // 刷新评论列表
    [[[RACObserve(self.viewModel, requestCommentFinish) ignore:@NO]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        // 如果当前文章详情未加载 则不刷新评论列表
        if (self.viewModel.postDetailContentHeight > 0) {
            
            // 刷新评论列表
            [self.tableView reloadData];
            // 评论列表刷新完成
            self.viewModel.replyListReloadFinish = YES;
        }
    }];
    
    // 滑动到要显示的评论
    [[[RACSignal combineLatest:@[
                                 [[RACObserve(self.viewModel, requestCommentFinish) ignore:@NO] distinctUntilChanged],
                                 [RACObserve(self.viewModel, toDisplayedCommentIndexPath) distinctUntilChanged],
                                 [[RACObserve(self.viewModel, replyListReloadFinish) ignore:@NO] distinctUntilChanged],
                                 [[RACObserve(self.viewModel, postDetailHeaderHeight) ignore:@0] distinctUntilChanged],
                                 ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        @try {
            NSIndexPath *indexPath = nil;
            if ([tuple.second isKindOfClass:[NSIndexPath class]]) {
                indexPath = tuple.second;
            }
            // 每次刷新简单文章详情后 postDetailHeaderHeight浮点值都会有变化
            // 导致该滑动被触发
            // 所以第一次滑动后toDisplayedCommentIndexPath设置为nil
            // 以此来判断是否需要滑动
            if (indexPath == nil) {
                return;
            }
            CGFloat numberOfCells = [self.viewModel numberOfRowsInSection:0];
            if (numberOfCells > 0) {
                CGFloat contentOffsetY = 0.0;
                CGFloat lastCoveredHeight = CGRectGetMaxY([self.tableView rectForRowAtIndexPath:
                                                           [NSIndexPath indexPathForRow:(numberOfCells - 1) inSection:0]]);
                CGFloat displayHeight = self.tableView.height - (self.tableView.contentInset.top + CMTReplyViewDefaultHeight);
                CGFloat cellY = CGRectGetMinY([self.tableView rectForRowAtIndexPath:indexPath]);
                
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
                [self.tableView setContentOffset:(CGPoint){0.0, -CMTNavigationBarBottomGuide + contentOffsetY} animated:NO];
                
                // 滑动到评论列表
                [self.contentScrollView setContentOffset:(CGPoint){self.contentScrollView.width, 0.0} animated:NO];
                self.viewModel.readingPostDetail = NO;
                self.replyView.replyViewDomain = CMTReplyViewDomainCommentList;
            }
        }
        @catch (NSException *exception) {
            CMTLogError(@"PostDetail Scroll To Displayed Comment Exception: %@", exception);
        }
    }];
    
#pragma mark 查看评论
    
    // 评论数
    RAC(self.replyView, badgeNumber) = [[RACObserve(self.viewModel, postStatistics.commentCount)
                                         distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
    RAC(self.replyInputView, badgeNumber) = [[RACObserve(self.viewModel, postStatistics.commentCount)
                                         distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
    
    // 阅读文章
    self.viewModel.readingPostDetail = YES;
    
    // 评论回复框 点击查看评论列表按钮
    [[[self.replyView.commentSeeButtonSignal filter:^BOOL(id value) {
        @strongify(self);
        // 当前显示文章详情
        return self.viewModel.readingPostDetail == YES;
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 滑动到评论列表
        [self.contentScrollView setContentOffset:(CGPoint){self.contentScrollView.width, 0.0} animated:YES];
        self.viewModel.readingPostDetail = NO;
    }];
    
    // 评论回复框 点击查看文章详情按钮
    [[[self.replyView.postDetailSeeButtonSignal filter:^BOOL(id value) {
        @strongify(self);
        // 当前显示评论列表
        return self.viewModel.readingPostDetail == NO;
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        // 滑动到文章详情
        [self.contentScrollView setContentOffset:(CGPoint){0.0, 0.0} animated:YES];
        self.viewModel.readingPostDetail = YES;
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
    
    // 评论回复框 点击文本框
    [[self.replyView.commentTouchButtonSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.replyInputView showInputView];
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
        CMTLogError(@"sendComment failed");
         @strongify(self);
        [self toastAnimation:self.viewModel.sendCommentMessage];
    }];
    
    //文章点赞
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
            @weakify(self);
            [[[CMTCLIENT Praise:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
                @strongify(self);
                if (!self.viewModel.postStatistics.isPraise.boolValue) {
                    self.viewModel.postStatistics.isPraise=@"1";
                    [[self.replyView.praiseSendButton viewWithTag:1000] changeScaleWithAnimate];
                  ((UIImageView*)[self.replyView.praiseSendButton viewWithTag:1000]).image=IMAGE(@"praise");
                    
                }else{
                    self.viewModel.postStatistics.isPraise=@"0";
                    [[self.replyView.praiseSendButton viewWithTag:1000] changeScaleWithAnimate];
               ((UIImageView*)[self.replyView.praiseSendButton viewWithTag:1000]).image=IMAGE(@"unpraise");
                }
                if (self.updatePostStatistics!=nil) {
                    self.updatePostStatistics(self.viewModel.postStatistics);
                }
                
                
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
        CMTLog(@"deleteCommentMessage: %@", message);
    }];
    
#pragma mark 用户认证
    
    self.userNotAuthenticView.hidden = NO;
    
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
-(void)PostMusicPlayed{
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    CMTLogError(@"PostDetail didReceiveMemoryWarning");
}

- (void)viewWillAppear:(BOOL)animated {
    [CMTPostDetailViewController attemptRotationToDeviceOrientation];
    [super viewWillAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    // 显示评论回复框
    [self.contentBaseView insertSubview:self.replyView aboveSubview:self.contentScrollView];
    if(self.musicPlayedTime!=nil){
        [self.musicPlayedTime setFireDate:[NSDate distantPast]];
    }
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
                        moviewPlayerVC.postId = self.viewModel.postId;
                        [self.navigationController pushViewController:moviewPlayerVC animated:YES];

                            
                        }
                }];
                
            }
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    CMTAPPCONFIG.AudioName=@"壹生";

    
}
//监听页面是否将要进入后台
-(void)appWillResignActive:(NSNotification *)aNotification{
        [self setLockScreenNowPlayingInfo];
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
    
    // 登陆成功后刷新动态模板
    if (self.isreloadWebView) {
        self.webViewLoadNumbers=1;
        [self CMT_ISHTML_LoadWebview];
        self.isreloadWebView=NO;
    }
    CMTAPPCONFIG.IsInterruptAudioPlayback=NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
    [self setLockScreenNowPlayingInfo];
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
#pragma mark 页面消失关闭声音后台播放
    if (!(self.contentScrollView.isDragging||self.contentScrollView.tracking||self.contentScrollView.decelerating)) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"pauseAudio()"];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    if(self.musicPlayedTime!=nil){
        [self.musicPlayedTime setFireDate:[NSDate distantFuture]];
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
    self.webViewLoadNumbers=1;
    [self.requestArray removeAllObjects];
    self.lastRequest=nil;
    self.viewModel.reloadPostDetailState = YES;
    self.viewModel.commentFilterState=@"0";
    // 显示加载动画
    self.contentState = CMTContentStateLoading;
    [self CMT_ISHTML_LoadWebview];
}

#pragma mark 点击返回按钮

- (void)popViewController {
    if (self.viewModel.readingPostDetail == YES) {
        [super popViewController];
    }
    else {
        // 滑动到文章详情
        [self.contentScrollView setContentOffset:(CGPoint){0.0, 0.0} animated:YES];
        self.viewModel.readingPostDetail = YES;
    }
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
        [self.webView loadRequest:request];
    }
    // 静态文章详情
    else {
        
        // 刷新文章详情
        [self.webView loadHTMLString:self.viewModel.postDetailHTMLString
                             baseURL:[[NSBundle mainBundle] URLForResource:CMTNSStringHTMLTemplate_fileName
                                                             withExtension:CMTNSStringHTMLTemplate_fileType]];
        // 使用文章详情数据刷新简单文章详情
        [self.postDetailCommentHeader reloadHeaderWithPostDetail:self.viewModel.postDetail];
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
            
            if ([URLString rangeOfString:[NSString stringWithFormat:@"%@.%@", CMTNSStringHTMLTemplate_fileName, CMTNSStringHTMLTemplate_fileType]
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
          //其他链接
                if (self.webViewLoadNumbers == 1&&[self.requestArray count]==0) {
                    self.lastRequest=request;
                    [self.requestArray addObject: self.lastRequest];

                    return YES;
                }else if ([self.requestArray count]==0) {
                    
                    //pragma mark 处理内部文章链接
                    BOOL flag=[self urlLinkToDealWith:URLString];
                    if (!flag) {
                        return flag;
                    }
                     if (self.viewModel.isHTML.isTrue&&!CMTUSER.login) {
                       self.isreloadWebView = YES;
                     }
                      // 动态文章详情 其他链接
                      self.viewModel.webLink = request.URL.absoluteString;
                }else{
                    //pragma mark 处理内部文章链接
                    BOOL flag=[self urlLinkToDealWith:URLString];
                    if (!flag) {
                        return flag;
                    }
                    self.lastRequest=request;
                    [self.requestArray addObject: self.lastRequest];
                    return YES;
                }
            }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Analyze WebView Request Exception: %@", exception);
    }
    
    return NO;
}
#pragma mark 处理内部文章链接
-(BOOL)urlLinkToDealWith:(NSString*)URLString{
       BOOL flag=YES;
       flag=[URLString handleWithinArticle:URLString viewController:self];
        return flag;

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.requestArray removeObject: self.lastRequest];
    if (self.requestArray.count==0) {
        self.webViewLoadNumbers++;
    }

    //动态拉伸等待图的大小
    SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
   
    for (CMTPicture *pic in self.viewModel.postDetail.imageList) {
        NSString *cacheKey_90Q = [webImageManager cacheKeyForURL:[NSURL URLWithString:[UIImage fullQualityImageURLWithURL:pic.picFilepath]]];
        NSString *cachePath1 = [webImageManager.imageCache defaultCachePathForKey:cacheKey_90Q];
       NSString *cacheKey = [webImageManager cacheKeyForURL:[NSURL URLWithString:[UIImage lowQualityImageURLWithURL:pic.picFilepath]]];
     NSString * cachePath = [webImageManager.imageCache defaultCachePathForKey:cacheKey];
        if (!([[NSFileManager defaultManager] fileExistsAtPath:cachePath]||[[NSFileManager defaultManager] fileExistsAtPath:cachePath1])) {
            NSArray *attr=[pic.picAttr componentsSeparatedByString:@"_"];
            float base= [attr[0] floatValue]>(SCREEN_WIDTH-20)?[attr[0] floatValue]/(SCREEN_WIDTH-20):1.0;
            [webView stringByEvaluatingJavaScriptFromString:[@"setImagesHeihgt(" stringByAppendingFormat:@"%lu,%f,%f)",(unsigned long)[self.viewModel.postDetail.imageList indexOfObject:pic],[attr[0] floatValue],[attr[1] floatValue]/base ]];
            
        }
    
    }
// 文章详情高度
    self.viewModel.postDetailContentHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
    
    // 显示详情
    self.contentState = CMTContentStateNormal;
    
    // 刷新评论列表
    [self.tableView reloadData];
    // 评论列表刷新完成
    self.viewModel.replyListReloadFinish = YES;
    
    // 静态文章详情 刷新PDF文件状态
    NSArray *pdfFiles = self.viewModel.postDetail.pdfFiles;
    for (int index = 0; index < pdfFiles.count; index++) {
        CMTPdf *pdfInfo = pdfFiles[index];
        [self refreshPDFFileStatus:[CMTPDFBrowserViewController checkPDFFileStatusWithPDFURL:pdfInfo.fileUrl] WithPDFID:[NSString stringWithFormat:@"%d", index]];
    }
    [self updateNetWorkingState];
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
#pragma mark 处理动作标签
- (void)handleHTMLTag:(NSString *)HTMLTag {
    if (![HTMLTag isKindOfClass:[NSString class]]) {
        CMTLogError(@"PostDetail handle HTMLTag Error: HTMLTag is not Kind Of NSString Class");
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
            
            CMTLogError(@"PostDetail Open PDFBrowser Error:  Empty PDFURL or Empty PDFSize");
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

               if([self getNetworkReachabilityStatus].integerValue==0){

            [self toastAnimation:@"你的网络不给力"];
             return;
        }else if ([self getNetworkReachabilityStatus].integerValue==1) {
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
    }else if([action isEqual:CMTNSStringHTMLTagAction_epaper]){
        if([parameters[CMTNSStringHTMLTagAction_flag] isEqualToString:@"0"]){
            CMTDigitalNewspaperViewController *digit=[[CMTDigitalNewspaperViewController alloc]init];
            [self.navigationController pushViewController:digit animated:YES];
        }else{
          NSString *url=parameters[CMTNSStringHTMLTagParameterKey_url];
          [self GetDigitalSubject:url];
        }
        
    }else {
        #pragma mark 其他
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
-(void)GetDigitalSubject:(NSString*)url{
     [MBProgressHUD showHUDAddedTo:self.contentBaseView animated:YES];
     @weakify(self)
    NSDictionary *param=@{@"onlyDecryptKey":@"0",
                          @"userId":CMTUSERINFO.userId?:@"0",
                          @"flag":@"1",
                          };
    [[[CMTCLIENT GetDigitalSubject:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTDigitalObject *Digital) {
        @strongify(self);
            CMTAPPCONFIG.epaperStoreUrl = Digital.epaperStoreUrl;
            CMTUSERINFO.decryptKey=Digital.decryptKey;
            CMTUSERINFO.canRead=Digital.canRead;
        CMTDigitalWebViewController *dig=[[CMTDigitalWebViewController alloc]initWithURl:url model:@"0"];
        [self.navigationController pushViewController:dig animated:YES];
        [MBProgressHUD hideHUDForView:self.contentBaseView animated:YES];
    } error:^(NSError *error) {
        @strongify(self);
        [MBProgressHUD hideHUDForView:self.contentBaseView animated:YES];
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
            
            [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            
        } else {
            [self toastAnimation:@"你的网络不给力"];
            CMTLogError(@"Request verification code System Error: %@", error);
        }
        

    } completed:^{
        CMTLog(@"加载完成");
    }];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - ScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // contentScrollView
    if (scrollView == self.contentScrollView) {
        
        // 阅读文章详情
        if (self.contentScrollView.contentOffset.x <= 0) {
            self.viewModel.readingPostDetail = YES;
            self.replyView.replyViewDomain = CMTReplyViewDomainPostDetail;
        }
        // 阅读评论列表
        else {
            self.viewModel.readingPostDetail = NO;
            self.replyView.replyViewDomain = CMTReplyViewDomainCommentList;
        }
        
        return;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    // contentScrollView
    if (scrollView == self.contentScrollView) {
        
        // 阅读文章详情
        if (self.contentScrollView.contentOffset.x <= 0) {
            self.viewModel.readingPostDetail = YES;
            self.replyView.replyViewDomain = CMTReplyViewDomainPostDetail;
        }
        // 阅读评论列表
        else {
            self.viewModel.readingPostDetail = NO;
            self.replyView.replyViewDomain = CMTReplyViewDomainCommentList;
        }
        
        return;
    }
}

#pragma mark - TableView

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
    RACTuple *tuple = [self.viewModel commentReplyForRowAtIndexPath:indexPath];
    if ([tuple.first isKindOfClass:[CMTComment class]]) {
        
        return [CMTCommentListCell cellHeightFromComment:tuple.first cellWidth:tableView.width];
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
        
        return [CMTReplyListWrapCell cellHeightFromReply:tuple.first comment:comment cellWidth:tableView.width last:last];
    }
    else {
        
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *separatorLine = [[UIView alloc] init];
    [separatorLine sizeToBuiltinContainer:tableView WithLeft:0.0 Top:0.0 Width:tableView.width Height:PIXEL];
    separatorLine.backgroundColor = COLOR(c_9e9e9e);
    
    return separatorLine;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"defaultCell";
    UITableViewCell *cell = nil;
    RACTuple *tuple = [self.viewModel commentReplyForRowAtIndexPath:indexPath];
    
    if ([tuple.first isKindOfClass:[CMTComment class]]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CMTPostDetailCommentListCommentCellIdentifier forIndexPath:indexPath];
        ((CMTCommentListCell *)cell).delegate=self;
        [(CMTCommentListCell *)cell reloadComment:tuple.first cellWidth:tableView.width indexPath:indexPath];
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
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:CMTPostDetailCommentListReplyCellIdentifier forIndexPath:indexPath];
        [(CMTReplyListWrapCell *)cell setDelegate:self];
        [(CMTReplyListWrapCell *)cell reloadReply:tuple.first comment:comment cellWidth:tableView.width indexPath:indexPath last:last];
    }
    else {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
        CMTLogError(@"PostDetail Get Selected Comment Error");
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
        CMTLogError(@"PostDetail Get Selected Reply Error");
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

            [ self.tableView reloadData];
        } error:^(NSError *error) {
            @strongify(self)
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

            
         
            [self.tableView reloadData];
        } error:^(NSError *error) {
            @strongify(self)
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
    if (self.viewModel.photoBrowserPhotos.count == 0) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSInteger index = 0; index < totalImageURLs.count; index++) {
            // 原始图片URL
            NSString *imageURLString = [UIImage fullQualityImageURLWithURL:totalImageURLs[index]];
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
            photo.caption = [NSString stringWithFormat:@"%ld/%ld", (long)(index + 1), (long)totalImageURLs.count];
            [photos addObject:photo];
        }
        self.viewModel.photoBrowserPhotos = photos;
    }
    
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
    if (self.viewModel.photoBrowserPhotos.count == 0) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSInteger index = 0; index < totalImageURLs.count; index++) {
            // 原始图片URL
            NSString *imageURLString = [UIImage fullQualityImageURLWithURL:totalImageURLs[index]];
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
            photo.caption = [NSString stringWithFormat:@"%ld/%ld", (long)(index + 1), (long)totalImageURLs.count];
            [photos addObject:photo];
        }
        self.viewModel.photoBrowserPhotos = photos;
    }
    
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

#pragma mark - ShareMethod

// 分享处理方法 add byguoyuanchao
- (void)CMTShareAction {
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
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_Email shareTitle:[NSString stringWithFormat:@"%@", self.viewModel.postDetail.title.HTMLUnEscapedString] sharetext:pContent sharetype:shareType sharepic:self.viewModel.postDetail.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"sharePost" shareData: self.viewModel.postDetail];      }
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
    [self.mShareView.cancelBtn removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
}

//// 朋友圈分享
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
//微博分享
- (void)weiboShare {
    NSString *shareType = @"3";
    NSString *shareURL = self.viewModel.postDetail.shareUrl;
    NSString *shareTitle = self.viewModel.postDetail.title.HTMLUnEscapedString;
    NSString *shareText = [NSString stringWithFormat:@"#%@# %@。%@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY, self.viewModel.postDetail.title.HTMLUnEscapedString, self.viewModel.postDetail.shareUrl];
    
    CMTLog(@"新浪文博\nshareText:%@", shareText);
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.viewModel.postDetail.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"sharePost" shareData: self.viewModel.postDetail];
}

@end
