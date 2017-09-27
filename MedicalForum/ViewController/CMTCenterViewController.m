//
//  CMTCenterViewController.m
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

// controller
#import "CMTCenterViewController.h"             // header file
#import "CMTPostDetailCenter.h"                 // 文章详情
#import "CMTOtherPostListViewController.h"      // 其他文章列表
#import "CMTBindingViewController.h"            // 登录
#import "CMTNoticeViewController.h"             // 通知
#import "CMTWebBrowserViewController.h"         //活动
#import "CMTOtherPostListViewController.h"      //专题
#import "CMTGroupInfoViewController.h"          //小组
#import "CMTPostDetailCenter.h"                 //病例
#import "CMTPostDetailViewController.h"         //文章




// view
#import "CMTBarButtonItem.h"                    // 导航按钮
#import "CMTBadgePoint.h"                       // 标记红点
#import "CMTFocusPageView.h"                    // 焦点图
#import "CMTTableSectionHeader.h"               // 分组header
#import "CMTPostListCell.h"                     // 文章列表cell
#import "CMTHomePageSideBar.h"                  // 侧边栏
#import "CMTFloatView.h"                        // 浮动视图
#import "CMTSearchView.h"                       // 搜索框
#import "CMTBadge.h"

// viewModel
#import "CMTPostListViewModel.h"                // 文章列表数据
#import "CMTLiveListCell.h"
#import "CMTLiveViewController.h"
#import "CMTColledgeVedioViewController.h"
#import "CMTNavigationController.h"

@interface CMTCenterViewController () <UITableViewDataSource, UITableViewDelegate, CMTFocusPageViewDelegate, CMTHomePageSideBarDelegte>

// controller
@property (nonatomic, strong) CMTBindingViewController *loginViewController;    // 登陆页

// view
@property (nonatomic, strong) UIImageView *titleView;                           // 标题
@property (nonatomic, strong) CMTBarButtonItem *personalItem;                   // 个人按钮
@property (nonatomic, strong) NSArray *leftItems;                               // 导航左侧按钮
@property (nonatomic, strong) UITableView *tableView;                           // 文章列表 + 焦点图框架
@property (nonatomic, strong) CMTFocusPageView *focusPageView;                  // 焦点图
@property (nonatomic, strong) CMTHomePageSideBar *sideBar;                      // 侧边栏

// viewModel
@property (nonatomic, strong) CMTPostListViewModel *viewModel;                  // 数据

@property(nonatomic,strong) NSTimer *focusPageShuffling;//焦点图计时器
@property(nonatomic,strong)UIView *tableViewHeaderView;//列表头部视图
@property(nonatomic,strong)CMTSearchView *searchView; //搜索框
@property (nonatomic, strong) CMTBarButtonItem *NavRightItem;//打开通知按钮
//右侧工具按钮
@property (nonatomic, strong) NSArray *rightItems;
@property(nonatomic,assign)NSInteger livenotice;
//摇晃让数据请求延时1秒，使音乐文件不重合
@property(nonatomic,strong)NSTimer *timer;

//摇晃请求标志，当为1时再次摇晃不请求数据，无声音
@property(assign)BOOL isShaken;
@end

@implementation CMTCenterViewController

#pragma mark Initializers

- (CMTBindingViewController *)loginViewController {
    if (_loginViewController == nil) {
        _loginViewController = [[CMTBindingViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    return _loginViewController;
}

- (UIImageView *)titleView {
    if (_titleView  == nil) {
        _titleView = [[UIImageView alloc] initWithImage:IMAGE(@"naviBar_title")];
    }
    
    return _titleView;
}

- (CMTBarButtonItem *)personalItem {
    if (_personalItem == nil) {
        CMTBadge *badge = [[CMTBadge alloc] init];
        badge.frame = CGRectMake(31.0,-7.5, kCMTBadgeWidth, kCMTBadgeWidth);
        badge.hidden = YES;
        CMTBadgePoint *badgePoint = [[CMTBadgePoint alloc] init];
        badgePoint.frame = CGRectMake(35.0, -2.0, CMTBadgePointWidth, CMTBadgePointWidth);
        badgePoint.hidden = YES;
       
        _personalItem = [CMTBarButtonItem itemWithImage:IMAGE(@"naviBar_list")badge:badgePoint badgeValue:badge imageEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
    }
    
    return _personalItem;
}

- (NSArray *)leftItems {
    if (_leftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _leftItems = @[leftFixedSpace, self.personalItem];
    }
    
    return _leftItems;
}
- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        FixedSpace.width =(RATIO - 1.0)*(CGFloat)12;
        if(CMTAPPCONFIG.HomeNoticeNumber.integerValue!=0){
           _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.NavRightItem, nil];
            self.NavRightItem.badgeValue.text=CMTAPPCONFIG.HomeNoticeNumber;
        }else{
            _rightItems=[[NSArray alloc]init];

        }
        
    }
    
    return _rightItems;
}

-(CMTBarButtonItem*)NavRightItem{
    if (_NavRightItem==nil) {
        CMTBadge *badge = [[CMTBadge alloc] init];
        badge.frame = CGRectMake(18,-7.5, kCMTBadgeWidth,kCMTBadgeWidth);
        badge.hidden = NO;
        _NavRightItem = [CMTBarButtonItem itemWithImage:IMAGE(@"bell")  badgeValue:badge imageEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];    }
    
    return _NavRightItem;
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        [_tableView fillinContainer:self.contentBaseView WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        _tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTTabBarHeight, 0.0);
        _tableView.backgroundColor = COLOR(c_efeff4);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CMTPostListCell class] forCellReuseIdentifier:CMTPostListCellIdentifier];
        [_tableView registerClass:[CMTLiveListCell class] forCellReuseIdentifier:CMTLiveListCellIdentifier];
    }
    
    return _tableView;
}

- (CMTFocusPageView *)focusPageView {
    if (_focusPageView == nil) {
        _focusPageView = [[CMTFocusPageView alloc] init];
        _focusPageView.backgroundColor = COLOR(c_clear);
        _focusPageView.delegate = self;
    }
    
    return _focusPageView;
}

- (CMTTabBar *)bottomTabBar {
    if (_bottomTabBar == nil) {
        _bottomTabBar = [[CMTTabBar alloc] init];
        [_bottomTabBar fillinContainer:self.tabBarContainer WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        _bottomTabBar.backgroundColor = COLOR(c_clear);
        self.tabBarContainer.hidden = NO;
    }
    
    return _bottomTabBar;
}

- (CMTHomePageSideBar *)sideBar {
    if (_sideBar == nil) {
        _sideBar = [[CMTHomePageSideBar alloc] initWithModel:@"0"];
        _sideBar.delegete=self;
    }
    
    return _sideBar;
}

- (CMTPostListViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [[CMTPostListViewModel alloc] init];
    }
    
    return _viewModel;
}

- (UIView *)tableViewHeaderView{
    if (_tableViewHeaderView == nil) {
        _tableViewHeaderView = [[UIView alloc] init];
        [_tableViewHeaderView addSubview:self.searchView];
        [_tableViewHeaderView addSubview:self.focusPageView];
    }
    
    return _tableViewHeaderView;
}

- (CMTSearchView*)searchView {
    if (_searchView==nil) {
        _searchView=[[CMTSearchView alloc]initWithFrame:CGRectMake(10,10, SCREEN_WIDTH-20, 30)];
        _searchView.lastController=self;
        _searchView.titlefontSize=13;
        _searchView.module=@"0";
        [_searchView setBackgroundColor:ColorWithHexStringIndex(c_ffffff)];
        [_searchView drawSearchButton:@"搜索文章"];

    }
    return _searchView;
}

//轮播图片
-(void)foucePage_shuffling{
    [self.focusPageView CMT_shuffling_pic];
}

//侧边栏代理刷新数据
- (void)refreshListdata{
    self.viewModel.resetState = YES;
}

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
        // Do any additional setup after loading the view, typically from a nib.
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal");
    }];
#pragma mark bindingSignals
    //第一次安装 获取服务器历史数据
    if(CMTAPPCONFIG.subscriptionCached == NO && CMTAPPCONFIG.currentVersionSubscribed == NO){
        [CMTAPPCONFIG MandatoryUpdateNotificationAndSubscription];
    }
    self.livenotice=0;
    // 未读专题文章数
    RACSignal *themeUnreadNumberSignal = [RACObserve(CMTAPPCONFIG, themeUnreadNumber) ignore:nil];
   //未读通知数目
    RACSignal *NoticeUnreadNumberSignal = [RACObserve(CMTAPPCONFIG, HomeNoticeNumber) ignore:nil];

    //未读指南文章数
    RACSignal *postUnreadNumberSignal=[RACObserve(CMTAPPCONFIG,UnreadPostNumber_Slide)ignore:nil];
    // 焦点图列表 请求为空
    RACSignal *focusListRequestEmptySignal = [RACObserve(self.viewModel, focusListRequestEmpty) ignore:@NO];
    // 焦点图列表 请求完成
    RACSignal *focusListRequestFinishSignal = [RACObserve(self.viewModel, focusListRequestFinish) ignore:@NO];
    
    // 文章列表 启动读取缓存完成
    RACSignal *launchLoadCacheFinishSignal = [RACObserve(self.viewModel, launchLoadCacheFinish) ignore:@NO];
    // 文章列表 请求完成
    RACSignal *postListRequestFinishSignal = [RACObserve(self.viewModel, postListRequestFinish) ignore:@NO];
    // 文章列表 请求为空提示
    RACSignal *postListRequestEmptyMessageSignal = [RACObserve(self.viewModel, postListRequestEmptyMessage) ignore:nil];
    // 文章列表 请求网络错误
    RACSignal *postListRequestNetErrorSignal = [RACObserve(self.viewModel, postListRequestNetError) ignore:nil];
    // 文章列表 请求服务器错误提示
    RACSignal *postListRequestServerErrorMessageSignal = [RACObserve(self.viewModel, postListRequestServerErrorMessage) ignore:nil];
    // 文章列表 请求系统错误提示
    RACSignal *postListRequestSystemErrorMessageSignal = [RACObserve(self.viewModel, postListRequestSystemErrorMessage) ignore:nil];
    
#pragma mark subsequentSignals
    
    // 文章列表 请求网络错误 无缓存文章
    RACSignal *postListRequestNetErrorEmptyCacheSignal = [postListRequestNetErrorSignal filter:^BOOL(id value) {
        @strongify(self);
        return [self.viewModel numberOfSections] == 0;
    }];
    
    // 文章列表 请求网络错误 有缓存文章
    RACSignal *postListRequestNetErrorButCachedSignal = [postListRequestNetErrorSignal filter:^BOOL(id value) {
        @strongify(self);
        return [self.viewModel numberOfSections] != 0;
    }];
    
#pragma mark 导航栏
    
    // 导航栏标题
    self.navigationItem.titleView = self.titleView;
    
    // 导航栏标记红点
    [[[RACSignal merge:@[themeUnreadNumberSignal,postUnreadNumberSignal]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if ((CMTAPPCONFIG.themeUnreadNumber.integerValue+CMTAPPCONFIG.UnreadPostNumber_Slide.integerValue)==0) {
            self.personalItem.badge.hidden=YES;
            self.personalItem.badgeValue.hidden=YES;

        }else if(CMTAPPCONFIG.UnreadPostNumber_Slide.integerValue>0){
            self.personalItem.badge.hidden=YES;
            self.personalItem.badgeValue.hidden=NO;
            self.personalItem.badgeValue.text=CMTAPPCONFIG.UnreadPostNumber_Slide;
        }else{
            self.personalItem.badge.hidden=NO;
            self.personalItem.badgeValue.hidden=YES;
                   }
        }];
    
    [[NoticeUnreadNumberSignal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        FixedSpace.width =(RATIO - 1.0)*(CGFloat)12;
        if(CMTAPPCONFIG.HomeNoticeNumber.integerValue!=0){
           self.rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.NavRightItem, nil];
            self.navigationItem.rightBarButtonItems=self.rightItems;
        }else{
            _rightItems=[[NSArray alloc]init];
            self.navigationItem.rightBarButtonItems=self.rightItems;

        }
        self.NavRightItem.badgeValue.text=CMTAPPCONFIG.HomeNoticeNumber;
    }];
    
    // 左侧栏按钮
    self.navigationItem.leftBarButtonItems = self.leftItems;
    
    self.navigationItem.rightBarButtonItems=self.rightItems;
    
    // 点击左侧栏按钮
    [self.personalItem.touchSignal subscribeNext:^(id x) {
         CMTAPPCONFIG.isALLowShowSlide=YES;
        @strongify(self);
        if (self.sideBar.view.superview == nil) {
            [MobClick event:@"B_Navi_Home"];
            [self.sideBar showAnimated:YES];
        }
        else {
            [self.sideBar dismissAnimated:YES completion:nil];
        }
    }];
    
    //点击消息通知按钮
    [self.NavRightItem.touchSignal subscribeNext:^(id x) {
        @strongify(self);
        if (!CMTUSER.login ) {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [self.navigationController pushViewController:loginVC animated:YES];
        }else{
            CMTNoticeViewController *noticViewController=[[CMTNoticeViewController alloc]initWithModel:@"0"];
            noticViewController.updatenoticeNumber=^(){
                 #pragma 计算未读通知数目
                [self countHomeunReadNotice];
                CMTAPPCONFIG.HomeNoticeUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)(self.livenotice+CMTAPPCONFIG.HomeNoticeNumber.integerValue)];
                
            };
            [self.navigationController pushViewController:noticViewController animated:YES];
        }
        
    }];

    
#pragma mark 底部导航栏
    
    // 设置底部导航栏当前选中的条目
    self.bottomTabBar.selectedIndex = 0;
    
#pragma mark contentState
    
    // 初始显示加载动画
    self.contentState = CMTContentStateLoading;
    
    // 显示重新加载
    [[postListRequestNetErrorEmptyCacheSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        self.contentState = CMTContentStateReload;
    }];
    
    // 显示内容页
    [[[RACSignal merge:@[
                         launchLoadCacheFinishSignal,
                         postListRequestFinishSignal,
                         postListRequestEmptyMessageSignal,
                         postListRequestNetErrorButCachedSignal,
                         postListRequestServerErrorMessageSignal,
                         postListRequestSystemErrorMessageSignal,
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        self.contentState = CMTContentStateNormal;
    }];
    
#pragma mark 强制刷新 刷新 翻页
    
    // 刷新控件
    [self.tableView addPullToRefreshWithActionHandler:nil];
    RAC(self.viewModel, pullToRefreshState) = [RACObserve(self.tableView.pullToRefreshView, state) distinctUntilChanged];
    // 翻页控件
    [self.tableView addInfiniteScrollingWithActionHandler:nil];
    RAC(self.viewModel, infiniteScrollingState) = [RACObserve(self.tableView.infiniteScrollingView, state) distinctUntilChanged];
    RAC(self.tableView, showsInfiniteScrolling) = [[RACObserve(self.tableView, contentSize) distinctUntilChanged] map:^id(NSValue *contentSize) {
        @strongify(self);
        if (contentSize.CGSizeValue.height + self.tableView.contentInset.top <= self.tableView.height) return @NO; return @YES;
    }];

    
    // 停止 强制刷新 刷新/翻页动画
    [[[RACSignal merge:@[
                         postListRequestEmptyMessageSignal,
                         postListRequestFinishSignal,
                         postListRequestNetErrorSignal,
                         postListRequestServerErrorMessageSignal,
                         postListRequestSystemErrorMessageSignal,
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 强制刷新
        self.viewModel.resetState = NO;
        
        // 刷新/翻页动画
        [self.tableView.pullToRefreshView stopAnimating];
        [self.tableView.infiniteScrollingView stopAnimating];
    }];
    
#pragma mark 焦点图列表
    
    // 初始化焦点图
    self.focusPageView.frame = CGRectMake(0.0,
                                          self.searchView.bottom + 10.0,
                                          self.tableView.width,
                                          [CMTFocusPageView heightForWidth:self.tableView.width]);
    
    // 隐藏焦点图
    [[focusListRequestEmptySignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 隐藏焦点图
        self.focusPageView.hidden = YES;
        
        // 设置tableHeaderView
        self.tableViewHeaderView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, 50.0);

        BOOL needHideSearchBar = NO;
        if (self.tableView.tableHeaderView == nil) {
            needHideSearchBar = YES;
        }
        
        self.tableView.tableHeaderView = self.tableViewHeaderView;
        
        if (needHideSearchBar == YES) {
            [self.tableView setContentOffset:CGPointMake(0.0, 50.0 + self.tableView.contentOffset.y)];
        }
        
        // 显示第一个section的sectionHeader
        [self countHomeunReadNotice];
        CMTAPPCONFIG.HomeNoticeUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)(self.livenotice+CMTAPPCONFIG.HomeNoticeNumber.integerValue)];
        [self.tableView reloadData];
    }];
    
    // 显示焦点图
    [[focusListRequestFinishSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 刷新焦点图
        [self.focusPageView reloadData];
        self.focusPageView.hidden = NO;
        if (self.focusPageShuffling == nil) {
            self.focusPageShuffling = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(foucePage_shuffling) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.focusPageShuffling forMode:NSRunLoopCommonModes];
        }
        
        // 设置tableHeaderView
        self.tableViewHeaderView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, self.focusPageView.bottom);
        
        BOOL needHideSearchBar = NO;
        if (self.tableView.tableHeaderView == nil) {
            needHideSearchBar = YES;
        }
        
        self.tableView.tableHeaderView = self.tableViewHeaderView;
        
        if (needHideSearchBar == YES) {
            [self.tableView setContentOffset:CGPointMake(0.0, 50.0 + self.tableView.contentOffset.y)];
        }

        // 隐藏第一个section的sectionHeader
        [self countHomeunReadNotice];
        CMTAPPCONFIG.HomeNoticeUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)(self.livenotice+CMTAPPCONFIG.HomeNoticeNumber.integerValue)];
        [self.tableView reloadData];
    }];
    
#pragma mark 文章列表
    
    // 文章列表 请求为空提示
    [[postListRequestEmptyMessageSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *emptyMessage) {
        @strongify(self);
        [self toastAnimation:emptyMessage];
    }];
    
    // 刷新文章列表
    [[[RACSignal merge:@[
                         launchLoadCacheFinishSignal,
                         postListRequestFinishSignal,
                         focusListRequestFinishSignal,
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        #pragma 计算未读通知数目
        [self countHomeunReadNotice];
        CMTAPPCONFIG.HomeNoticeUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)(self.livenotice+CMTAPPCONFIG.HomeNoticeNumber.integerValue)];
        
        [self.tableView reloadData];
    }];
    
    // 文章列表 请求网络错误
    [[postListRequestNetErrorButCachedSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSError *netError) {
        CMTLogError(@"PostList 网络错误:\n%@", netError);		
    }];
    
    // 文章列表 请求服务器错误提示
    [[postListRequestServerErrorMessageSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorMessage) {
        @strongify(self);
        [self toastAnimation:errorMessage];
        CMTLogError(@"PostList 服务器返回错误:\n%@", errorMessage);
    }];
    
    // 文章列表 请求系统错误提示
    [[postListRequestSystemErrorMessageSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorMessage) {
        CMTLogError(@"PostList 系统错误:\n%@", errorMessage);
    }];
    
#pragma mark 网络判断
    
    [[RACObserve(CMTAPPCONFIG, reachability)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
            [self.view addSubview:self.offlineToast];
            self.mToastView.hidden = YES;
            // pullToRefreshView stopAnimating 会使tableView contentOffset回复到初始值 所以次处不能使用contentInset做位移
            [self.tableView sizeToFillinContainer:self.contentBaseView WithTop:self.offlineToast.height Left:0.0 Bottom:0.0 Right:0.0];
            self.isShaken = YES;
        }
        else if ([CMTAPPCONFIG.reachability isEqual:@"1"]||[CMTAPPCONFIG.reachability isEqual:@"2"]) {
            [self.offlineToast removeFromSuperview];
            self.mToastView.hidden = NO;
            [self.tableView sizeToFillinContainer:self.contentBaseView WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
            self.isShaken = NO;
        }
        else {
            CMTLogError(@"APPCONFIG Reachability Error Value: %@", CMTAPPCONFIG.reachability);
            self.isShaken = NO;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    CMTLogError(@"PostList didReceiveMemoryWarning");
}
#pragma 计算直播未读通知数目
-(void)countHomeunReadNotice{
    self.livenotice=0;
    if ([self.viewModel.caseLivelist count]>0) {
        for (CMTLive *live in self.viewModel.caseLivelist ) {
            self.livenotice+=live.noticeCount.integerValue;
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    //页面出现时将摇晃请求标志置为NO；
    if ([CMTAPPCONFIG.reachability isEqual:@"1"]) {
        self.isShaken = NO;
    }
        [super viewWillAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
//    [MobClick beginLogPageView:@"P_List_Home"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
#pragma mark 侧边栏恢复打开状态
    
    if (self.sideBar.needReOpen == YES&& CMTAPPCONFIG.isALLowShowSlide) {
        self.sideBar.needReOpen = NO;
        [self.sideBar showAnimated:animated];
    }
    
   // 开启轮播计数器
    if (self.focusPageShuffling!=nil) {
        [self.focusPageShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    if ([CMTAPPCONFIG.refreshmodel isEqualToString:@"2"]) {
        self.viewModel.resetState = YES;
        CMTAPPCONFIG.refreshmodel=@"0";
    }
      [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    if (self.sideBar.needReOpen == YES&& CMTAPPCONFIG.isALLowShowSlide) {
        self.sideBar.needReOpen = NO;
        [self.sideBar showAnimated:animated];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //关闭定时器
        [self.timer invalidate];
        _timer = nil;
   
    
    
    //关闭轮播计数器
    if (self.focusPageShuffling!=nil) {
        [self.focusPageShuffling setFireDate:[NSDate distantFuture]];
    }

    CMTLog(@"%s", __FUNCTION__);
//    [MobClick endLogPageView:@"P_List_Home"];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
}

// 启动时刷新文章列表
- (void)refreshPostListFromLaunch {
    CMTLog(@"%s", __FUNCTION__);
    
    // 显示加载动画
    self.contentState = CMTContentStateLoading;
    
    // 刷新文章列表
    [self refreshListdata];
}

#pragma mark 刷新侧边栏

// 刷新侧边栏
- (void)refreshSideBar {
    
    // 通过缓存数据刷新左侧栏
    [self.sideBar refreshFormCache];
}

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    CMTLog(@"%s", __FUNCTION__);
    
    // 显示加载动画
    self.contentState = CMTContentStateLoading;
    // 刷新操作
    self.viewModel.pullToRefreshState = SVPullToRefreshStateLoading;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.viewModel.caseLivelist count]>0) {
        if (section==1) {
            if (self.viewModel.topArticles.postId!=nil) {
                return [self.viewModel numberOfRowsInSection:section]+1;
            }
          }
    }else{
        if (section==0) {
            if (self.viewModel.topArticles.postId!=nil) {
                return [self.viewModel numberOfRowsInSection:section]+1;
            }

        }
    }
    return [self.viewModel numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((section == 0||section == 1)) {
        if (section==0) {
            return 0;
        }else if([self.viewModel.caseLivelist count]>0){
            return 5;
        }else {
            return [self.viewModel heightForHeaderInSection:section];
        }
        
    }
    
    return [self.viewModel heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.caseLivelist.count!=0&&indexPath.section==0) {
     
        return 60;
    }else{
        return [self.viewModel heightForRowAtIndexPath:indexPath];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CMTTableSectionHeader *header = [CMTTableSectionHeader headerWithHeaderWidth:tableView.width
                                                                    headerHeight:[self.viewModel heightForHeaderInSection:section]];
    header.title = [self.viewModel titleForHeaderInSection:section];

    if (section == 0||section == 1) {
        
        if (section==0) {
             return nil;
        }else if([self.viewModel.caseLivelist count]>0){
           return nil;
        }else {
            return header;
        }

       
    }else{
        return header;
    }
    
 }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.viewModel.caseLivelist.count!=0&&indexPath.section==0) {
        
         CMTLiveListCell *listCell=[self.tableView dequeueReusableCellWithIdentifier:CMTLiveListCellIdentifier forIndexPath:indexPath];
        if(listCell==nil){
            listCell=[[CMTLiveListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CMTLiveListCellIdentifier];
        }
        CMTLive *live=[self.viewModel liveForRowAtIndexPath:indexPath];
        [listCell reloadCell:live index:indexPath];
        return listCell;
       
    }else{
    CMTPostListCell *cell =nil;
      cell=[self.tableView dequeueReusableCellWithIdentifier:CMTPostListCellIdentifier forIndexPath:indexPath];
        CMTPost *post=nil;
        if (self.viewModel.topArticles.postId!=nil) {
            if ((self.viewModel.caseLivelist.count!=0&&indexPath.section==1)||(self.viewModel.caseLivelist.count==0&&indexPath.section==0)) {
                if (indexPath.row==0) {
                    post=self.viewModel.topArticles;
                }else{
                    post=[self.viewModel postForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section] ];
                }
            }else{
                post=[self.viewModel postForRowAtIndexPath:indexPath];
            }
        }else{
            post=[self.viewModel postForRowAtIndexPath:indexPath];
        }
           [cell reloadPost:post tableView:tableView indexPath:indexPath];
        return cell;
    }
        
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.viewModel.caseLivelist count]>0&&indexPath.section==0) {
        CMTLiveListCell *cell=(CMTLiveListCell*)[tableView cellForRowAtIndexPath:indexPath];
        CMTLive *live1=[self.viewModel.caseLivelist objectAtIndex:indexPath.row];
        CMTLiveViewController *ViewController=[[CMTLiveViewController alloc]initWithlive:live1];
        ViewController.shareimage=cell.livePic.image;
        ViewController.updatelivedata=^void(CMTLive * live){
             live1.noticeCount=live.noticeCount;
            [self countHomeunReadNotice];
            CMTAPPCONFIG.HomeNoticeUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)(self.livenotice+CMTAPPCONFIG.HomeNoticeNumber.integerValue)];
            [self.tableView reloadData];
            [NSKeyedArchiver archiveRootObject:self.viewModel.caseLivelist toFile:PATH_CACHE_LIVELIST];

        };
        [self.navigationController pushViewController:ViewController animated:YES];

    }else{
        
        CMTPost *post =nil;
        if (self.viewModel.topArticles.postId!=nil) {
            if ((self.viewModel.caseLivelist.count!=0&&indexPath.section==1)||(self.viewModel.caseLivelist.count==0&&indexPath.section==0)) {
                if (indexPath.row==0) {

                    post=self.viewModel.topArticles;
                }else{
                   post=[self.viewModel postForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section] ];
                }
         }else{
             post=[self.viewModel postForRowAtIndexPath:indexPath];
         }
        }else{
            post=[self.viewModel postForRowAtIndexPath:indexPath];
        }
        
        // 专题
        if ([post.themeStatus isEqual:@"2"]) {
            CMTOtherPostListViewController *otherPostListViewController = [[CMTOtherPostListViewController alloc] initWithThemeId:post.themeId
                                                                                                                           postId:post.postId
                                                                                                                           isHTML:post.isHTML
                                                                                                                          postURL:post.url];
            otherPostListViewController.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
                @strongify(self);
                [self updatePost:post withPostStatistics:postStatistics];
            };
            otherPostListViewController.updateLive=^(CMTLive* live){
                  @strongify(self);
                for (CMTLive *lives in self.viewModel.caseLivelist) {
                    if ([lives.liveBroadcastId isEqualToString:live.liveBroadcastId]) {
                        lives.noticeCount=live.noticeCount;
                    }
                }
                [self countHomeunReadNotice];
                CMTAPPCONFIG.HomeNoticeUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)(self.livenotice+CMTAPPCONFIG.HomeNoticeNumber.integerValue)];
                [self.tableView reloadData];
                [NSKeyedArchiver archiveRootObject:self.viewModel.caseLivelist toFile:PATH_CACHE_LIVELIST];
            };
            
            [self.navigationController pushViewController:otherPostListViewController animated:YES];
        }
        // 文章详情
        else {
            CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                       isHTML:post.isHTML
                                                                                      postURL:post.url
                                                                                   postModule:post.module
                                                                               postDetailType:CMTPostDetailTypeHomePostList];
            
            postDetailCenter.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
                @strongify(self);
                [self updatePost:post withPostStatistics:postStatistics];
            };
            
            [self.navigationController pushViewController:postDetailCenter animated:YES];
        }
    }
}

- (void)updatePost:(CMTPost *)post withPostStatistics:(CMTPostStatistics *)postStatistics {
    
    // 刷新文章
    post.heat = postStatistics.heat;
    post.postAttr = postStatistics.postAttr;
    post.themeStatus = postStatistics.themeStatus;
    post.themeId = postStatistics.themeId;
    post.isPraise=postStatistics.isPraise;
    
    // 刷新文章列表
    [self countHomeunReadNotice];
    CMTAPPCONFIG.HomeNoticeUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)(self.livenotice+CMTAPPCONFIG.HomeNoticeNumber.integerValue)];
    [self.tableView reloadData];
    // 保存文章列表
    [self.viewModel saveCachePostList];
}

#pragma mark FocusPageView

- (NSUInteger)numberOfFocusInFocusPageView:(CMTFocusPageView *)focusPageView {
    return self.viewModel.cacheFocusList.count;
}

- (CMTFocus *)focusPageView:(CMTFocusPageView *)focusPageView focusAtIndex:(NSUInteger)index {
    if (index < self.viewModel.cacheFocusList.count) {
        
        return self.viewModel.cacheFocusList[index];
    }
    else {
        
        return nil;
    }
}

- (void)focusPageView:(CMTFocusPageView *)focusPageView didSelectFocusAtIndex:(NSInteger)index {
    @weakify(self);

    if (index < self.viewModel.cacheFocusList.count) {
        CMTFocus *focus = self.viewModel.cacheFocusList[index];
        switch (focus.subjectId.integerValue) {
            case -1:
                [MobClick event:@"B_Total_FocusPic"];
                break;
            case 1:
                [MobClick event:@"B_Tumour_FocusPic"];
                break;
            case 2:
                [MobClick event:@"B_Cardio_FocusPic"];
                break;
            case 3:
                [MobClick event:@"B_Endocrine_FocusPic"];
                break;
            case 4:
                [MobClick event:@"B_Digestion_FocusPic"];
                break;
            case 5:
                [MobClick event:@"B_Nerve_FocusPic"];
                break;
            case 6:
                [MobClick event:@"B_General_FocusPic"];
                break;
            case 7:
                [MobClick event:@"B_Dental_FocusPic"];
                break;
            case 8:
                [MobClick event:@"B_JAMA_FocusPic"];
                break;
            case 9:
                [MobClick event:@"B_Culture_FocusPic"];
                break;
            default:
                break;
        }
        // 专题
        if ([focus.themeStatus isEqual:@"2"]) {
            CMTOtherPostListViewController *otherPostListViewController = [[CMTOtherPostListViewController alloc] initWithThemeId:focus.themeId
                                                                                                                           postId:focus.postId
                                                                                                                           isHTML:focus.isHTML
                                                                                                                          postURL:focus.url];
            otherPostListViewController.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
                @strongify(self);
                [self updateFocus:focus withPostStatistics:postStatistics];
            };
            
            [self.navigationController pushViewController:otherPostListViewController animated:YES];
        }
        // 文章详情
        else {
            CMTGroup *group=[[CMTGroup alloc]init];
            group.groupId=focus.groupId;
            group.groupName=focus.groupName;
            group.groupType=focus.groupType;
            group.memberGrade=focus.memberGrade;
            CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:focus.postId
                                                                                       isHTML:focus.isHTML
                                                                                      postURL:focus.url
                                                                                   postModule:focus.module
                                                                                   group:group
                                                                                   iscanShare:NO
                                                                               postDetailType:CMTPostDetailTypeHomePostList
                                                                             ];
            
            postDetailCenter.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
                @strongify(self);
                [self updateFocus:focus withPostStatistics:postStatistics];
            };
            
            [self.navigationController pushViewController:postDetailCenter animated:YES];
        }
    }
}

- (void)updateFocus:(CMTFocus *)focus withPostStatistics:(CMTPostStatistics *)postStatistics {
    
    // 刷新焦点图
    focus.postAttr = postStatistics.postAttr;
    focus.themeStatus = postStatistics.themeStatus;
    focus.themeId = postStatistics.themeId;
    
    // 刷新焦点图说明
    [self.focusPageView refreshCaption];
    // 保存焦点图列表
    [self.viewModel saveCacheFocusList];
}

#pragma 摇晃动作触发事件
/**
 *
 *
 *  @param motion 摇晃类型
 *  @param event  摇晃事件
 */
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        /**
         *  摇晃声音
         */
        if(self.isShaken == NO){
            if (CMTAPPCONFIG.shakeobject!= nil) {
                 [self startAudioVoice];
            }
        }
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        /**
         *  摇晃之后请求数据
         */
        if (self.isShaken == NO) {
            //将摇晃标志置为YES
            self.isShaken = YES;
            
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getDataFromNet) userInfo:nil repeats:NO];
            
         }
    }
}
#pragma 摇晃声音
- (void)startAudioVoice{
    NSString *voicePath = [[NSBundle mainBundle] pathForResource:@"shaking" ofType:@"wav"];
    if (voicePath) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([NSURL fileURLWithPath:voicePath]), &soundID);
        AudioServicesPlaySystemSound (soundID);
    }
    
}

- (void)shakeHaveFoundVoice{
    NSString *voicePath = [[NSBundle mainBundle] pathForResource:@"shakend" ofType:@"mp3"];
    if (voicePath) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([NSURL fileURLWithPath:voicePath]), &soundID);
        AudioServicesPlaySystemSound (soundID);
    }

}

/**
 *  摇晃手机请求事件
 */;
- (void)getDataFromNet{
      CMTshakeobject *shakeObject=CMTAPPCONFIG.shakeobject;
           if (shakeObject != nil && ![shakeObject.status isEqualToString:@"2"]) {

            NSLog(@"kfdhjdifdifni%@",shakeObject.param.themeId);
            CMTshakeobject *paramaDic =shakeObject.param;
            /**
             *  如果返回来的是专题接口
             */
            if (paramaDic.themeId!=nil) {
                
                
                CMTOtherPostListViewController *otherVC = [[CMTOtherPostListViewController alloc]initWithThemeId:paramaDic.themeId postId:@"" isHTML:@"" postURL:@""];
                [self.navigationController pushViewController:otherVC animated:YES];
                [CMTAPPCONFIG.shakeDictionary setObject:shakeObject.resultId forKey:shakeObject.resultId];
                

                
            }//如果返回的是活动接口
            else if (paramaDic.url!=nil&&paramaDic.diseaseId ==nil && paramaDic.postId == nil){
                CMTWebBrowserViewController *webVC = [[CMTWebBrowserViewController alloc]initWithURL:paramaDic.url];
                
                [self.navigationController pushViewController:webVC animated:YES];
                [CMTAPPCONFIG.shakeDictionary setObject:shakeObject.resultId forKey:shakeObject.resultId];
                
            }//如果返回的是小组接口
            else if (paramaDic.groupId != nil){
                                CMTGroup *group = [[CMTGroup alloc]init];
                                group.groupName = paramaDic.groupName;
                                group.groupId = paramaDic.groupId;
                                group.noticeCount = paramaDic.noticeCount;
                                group.jumpFrom=@"center";
                                CMTGroupInfoViewController *groupVC = [[CMTGroupInfoViewController alloc]initWithGroup:group];
                                [self.navigationController pushViewController:groupVC animated:YES];
                [CMTAPPCONFIG.shakeDictionary setObject:shakeObject.resultId forKey:shakeObject.resultId];
            }//如果返回的是病例接口
            else if (paramaDic.diseaseId != nil){
                CMTPostDetailCenter *postDVC = [CMTPostDetailCenter postDetailWithPostId:paramaDic.diseaseId isHTML:paramaDic.isHTML postURL:paramaDic.url postModule:@"1" postDetailType:CMTPostDetailTypeCaseGroup];
                               [self.navigationController pushViewController:postDVC animated:YES];

                [CMTAPPCONFIG.shakeDictionary setObject:shakeObject.resultId forKey:shakeObject.resultId];

                
            }//如果返回的是文章接口
            else if (paramaDic.postId != nil){
                CMTPostDetailViewController *postVC = [[CMTPostDetailViewController alloc]initWithPostId:paramaDic.postId isHTML:paramaDic.isHTML postURL:paramaDic.url postModule:@"0" postDetailType:CMTPostDetailTypeUnDefind];
                                [self.navigationController pushViewController:postVC animated:YES];
                [CMTAPPCONFIG.shakeDictionary setObject:shakeObject.resultId forKey:shakeObject.resultId];

            }
            //摇晃请求到数据的声音
            [self shakeHaveFoundVoice];
        }
      
       
        self.isShaken=NO;
}

//根据网络状态 改变摇晃标志




@end
