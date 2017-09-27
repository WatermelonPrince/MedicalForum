//
//  CMTOtherPostListViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/1/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// controller
#import "CMTOtherPostListViewController.h"                  // header file
#import "CMTPostDetailCenter.h"                             // 文章详情
#import "CMTEnterSubjectionViewController.h"                // 订阅的全部专题列表
#import "CMTSubjectListViewController.h"
#import "CMTNeedMoreGuideViewController.h"

// view
#import "CMTThemeHeader.h"                                  // 专题/'单个疾病标签'顶部视图
#import "CMTTableSectionHeader.h"                           // 分组header
#import "CMTPostListCell.h"                                 // 首页文章列表cell
#import "CMTGuidePostListCell.h"                            // 指南文章列表cell
#import "UITableView+CMTExtension_PlaceholderView.h"        // 评论列表空数据提示
#import "CMTTagMarker.h"

// viewModel
#import "CMTOtherPostListViewModel.h"                       // 文章列表数据
#import "CMTLiveListCell.h"
#import "CMTLiveViewController.h"
/// 其他文章列表类型

@interface CMTOtherPostListViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, CMTThemeHeaderDelegate, CMTTagMarkerDelegte>

// view
@property (nonatomic, strong) UITableView *tableView;                               // 文章列表
@property (nonatomic, strong) UIAlertView *alertView;                               // 弹窗警告
@property (nonatomic, strong) CMTThemeHeader *themeHeader;                          // 专题/'单个疾病标签'顶部视图
@property (nonatomic, strong) CMTTagMarker *TagMarkerView;                          // 标签管理视图

// viewModel
@property (nonatomic, strong) CMTOtherPostListViewModel *viewModel;                 // 数据
@property (nonatomic, assign) CMTOtherPostListType otherPostListType;               // 其他文章列表类型
@property (nonatomic, strong) NSMutableArray *FocusTagArrays;                       // 订阅tag标签
@property (nonatomic, strong) UIBarButtonItem *leftButtonItem;                      // 打开左侧栏按钮
@property (nonatomic, strong) NSArray *leftItems;                                   // 导航左侧按钮

@end

@implementation CMTOtherPostListViewController

#pragma mark - Initializers

- (instancetype)initWithAuthor:(NSString *)author
                      authorId:(NSString *)authorId {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.otherPostListType = CMTOtherPostListTypeAuthor;
    self.titleText = author;
    self.viewModel = [[CMTOtherPostListViewModel alloc] initWithAuthorId:authorId];
    
    return self;
}

- (instancetype)initWithPostType:(NSString *)postType
                      postTypeId:(NSString *)postTypeId {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.otherPostListType = CMTOtherPostListTypePostType;
    self.titleText = postType;
    self.viewModel = [[CMTOtherPostListViewModel alloc] initWithPostTypeId:postTypeId];
    
    return self;
}

- (instancetype)initWithDisease:(NSString *)disease
                     diseaseIds:(NSString *)diseaseIds
                         module:(NSString *)module {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.otherPostListType = CMTOtherPostListTypeDisease;
    self.viewModel = [[CMTOtherPostListViewModel alloc] initWithDisease:disease
                                                             diseaseIds:diseaseIds
                                                                 module:module];
    
    return self;
}

- (instancetype)initWithKeyword:(NSString *)keyWord
                         module:(NSString *)module {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.otherPostListType = CMTOtherPostListTypeKeyword;
    self.titleText = [keyWord URLDecodeString];
    self.viewModel = [[CMTOtherPostListViewModel alloc] initWithKeyword:keyWord.URLDecodeString
                                                                 module:module];
    
    return self;
}

- (instancetype)initWithSubject:(NSString *)subject
                      subjectId:(NSString *)subjectId
                         module:(NSString *)module {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.otherPostListType = CMTOtherPostListTypeSubject;
    self.titleText = subject;
    self.viewModel = [[CMTOtherPostListViewModel alloc] initWithSubjectId:subjectId
                                                                   module:module];
    
    return self;
}

- (instancetype)initWithThemeId:(NSString *)themeId
                         postId:(NSString *)postId
                         isHTML:(NSString *)isHTML
                        postURL:(NSString *)postURL {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.otherPostListType = CMTOtherPostListTypeTheme;
    self.viewModel = [[CMTOtherPostListViewModel alloc] initWithThemeId:themeId
                                                                 postId:postId
                                                                 isHTML:isHTML
                                                                postURL:postURL];
    
    return self;
}
- (instancetype)initWithThemeUIid:(NSString *)UIid{
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    self.otherPostListType=CMTOtherPostListTypeTheme;
    self.viewModel = [[CMTOtherPostListViewModel alloc] initWithThemeUIid:UIid];
    return self;
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        [_tableView fillinContainer:self.contentBaseView WithTop:0.0 Left:0 Bottom:0 Right:0];
        _tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _tableView.backgroundColor = COLOR(c_efeff4);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CMTPostListCell class] forCellReuseIdentifier:CMTOtherPostListCellIdentifier];
        [_tableView registerClass:[CMTGuidePostListCell class] forCellReuseIdentifier:CMTGuidePostListCellIdentifier];
         [_tableView registerClass:[CMTLiveListCell class] forCellReuseIdentifier:CMTOtherLiveListCellIdentifier];
    }
    
    return _tableView;
}

- (UIAlertView *)alertView
{
    if (!_alertView)
    {
        _alertView = [[UIAlertView alloc] initWithTitle:@"确定不再订阅该专题吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
    return _alertView;
}

- (UIBarButtonItem *)leftButtonItem {
    if (_leftButtonItem == nil) {
        _leftButtonItem = [[UIBarButtonItem alloc]initWithImage:IMAGE(@"naviBar_back") style:UIBarButtonItemStyleDone target:self action:@selector(GobackAction)];
        [_leftButtonItem setBackgroundVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsDefault];
    }
    return _leftButtonItem;
}

- (NSArray *)leftItems {
    if (_leftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _leftItems = @[leftFixedSpace, self.leftButtonItem];
    }
    
    return _leftItems;
}

//订阅的标签管理视图
-(CMTTagMarker*)TagMarkerView{
    if (_TagMarkerView==nil) {
        _TagMarkerView=[[CMTTagMarker alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        _TagMarkerView.delegate=self;
        _TagMarkerView.model=self.viewModel.module;
    }
    return _TagMarkerView;
}
//获取标签列表 绘制标签视图
-(void)CMTGetTagArray{
    if (self.TagMarkerView !=nil) {
        for (UIView *view in [self.TagMarkerView subviews]) {
            [view removeFromSuperview];
        }
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:PATH_FOUSTAG]) {
        self.FocusTagArrays=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]mutableCopy];
        
        [self.TagMarkerView DrawTagMakerMangeView:[self.FocusTagArrays mutableCopy]];
        self.TagMarkerView.frame=CGRectMake(0, 0, self.TagMarkerView.width, self.TagMarkerView.height);
        
        self.tableView.tableHeaderView=self.TagMarkerView;
        
        
    }
    else {
        [self.FocusTagArrays removeAllObjects];
        [self.TagMarkerView DrawTagMakerMangeView:[self.FocusTagArrays mutableCopy]];
        self.TagMarkerView.frame=CGRectMake(0, 0, self.TagMarkerView.width, self.TagMarkerView.height);
        
        self.tableView.tableHeaderView=self.TagMarkerView;
    }
    
    // 获取所有疾病标签的diseaseId
    NSString *diseaseIds = [[[self.FocusTagArrays.rac_sequence map:^id(CMTDisease *disease) {
        if ([disease respondsToSelector:@selector(diseaseId)])
            return [disease diseaseId];
        else
            return @"";
    }] array] componentsJoinedByString:@","];
    
    // 如果标签改变了
    // 强制刷新
    [self.viewModel updateDiseaseIds:diseaseIds ?: @""];
}

//TAgMArker视图代理 展示疾病指南文章列表
-(void)CMTGotoGuidePostListView:(CMTDisease*)Disease{
    for (CMTDisease *dis in self.FocusTagArrays) {
        if ([dis.diseaseId isEqualToString:Disease.diseaseId]) {
            if ([self.viewModel.module integerValue]==0) {
                CMTAPPCONFIG.UnreadPostNumber_Slide=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.UnreadPostNumber_Slide integerValue]-[dis.postCount integerValue]];
                dis.postCount=@"0";
                dis.postReadtime=TIMESTAMP;
            }else if([self.viewModel.module integerValue]==1){
                CMTAPPCONFIG.UnreadCaseNumber_Slide=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.UnreadCaseNumber_Slide integerValue]-[dis.caseCout integerValue]];
                dis.caseCout=@"0";
                dis.caseReadtime=TIMESTAMP;
            }else if([self.viewModel.module integerValue]==3){
                CMTAPPCONFIG.GuideUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.GuideUnreadNumber integerValue]-[dis.count integerValue]];
                  dis.count=@"0";
               dis.readTime=TIMESTAMP;
            }
                break;
        }
  }
    [NSKeyedArchiver archiveRootObject:self.FocusTagArrays toFile:PATH_FOUSTAG];
    CMTOtherPostListViewController *need=[[CMTOtherPostListViewController alloc] initWithDisease:Disease.disease diseaseIds:Disease.diseaseId
                                                                                          module:self.viewModel.module];
    
    [self.navigationController pushViewController:need animated:YES];
}

//添加疾病标签
-(void)CmtAddTagAction{
    CMTSubjectListViewController *suject=[[CMTSubjectListViewController alloc]init];
    [self.navigationController pushViewController:suject animated:YES];
}

//返回
-(void)GobackAction{
    [self.navigationController popViewControllerAnimated:YES];
    // 如果是指南列表 点击返回清空指南数值标记
    if(self.tableView.tableHeaderView!=nil&&[self.tableView.tableHeaderView isKindOfClass:[CMTTagMarker class]]&&isEmptyString(self.viewModel.disease)){
        if ([self.viewModel.module isEqualToString:@"0"]) {
            CMTAPPCONFIG.UnreadPostNumber_Slide=@"0";
        }else if([self.viewModel.module isEqualToString:@"1"]){
            CMTAPPCONFIG.UnreadCaseNumber_Slide=@"0";
        }
       self.FocusTagArrays=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]mutableCopy];
        for (CMTDisease *disease in self.FocusTagArrays) {
            if ([self.viewModel.module isEqualToString:@"0"]) {
               disease.postCount=@"0";
                disease.postReadtime=TIMESTAMP;
            }else if([self.viewModel.module isEqualToString:@"1"]){
                disease.caseCout=@"0";
                disease.caseReadtime=TIMESTAMP;
            }

        }
       [NSKeyedArchiver archiveRootObject:[self.FocusTagArrays mutableCopy] toFile:PATH_FOUSTAG];
    }

    
}


#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"OtherPostList willDeallocSignal");
    }];
     self.navigationItem.leftBarButtonItems=self.leftItems;

#pragma mark bindingSignals
    
    // 文章列表 请求完成
    RACSignal *requestPostFinishSignal = [RACObserve(self.viewModel, requestPostFinish) ignore:@NO];
    // 文章列表 强制刷新为空
    RACSignal *resetPostEmptyStringSignal = [RACObserve(self.viewModel, resetPostEmptyString) ignore:nil];
    // 文章列表 请求刷新为空
    RACSignal *requestNewPostEmptyStringSignal = [RACObserve(self.viewModel, requestNewPostEmptyString) ignore:nil];
    // 文章列表 请求翻页为空
    RACSignal *requestMorePostEmptyStringSignal = [RACObserve(self.viewModel, requestMorePostEmptyString) ignore:nil];
    // 文章列表 请求网络错误
    RACSignal *requestPostNetErrorSignal = [RACObserve(self.viewModel, requestPostNetError) ignore:@NO];
    // 文章列表 请求服务器错误消息
    RACSignal *requestPostServerErrorMessageSignal = [RACObserve(self.viewModel, requestPostServerErrorMessage) ignore:nil];
    // 文章列表 请求系统错误信息
    RACSignal *requestPostSystemErrorStringSignal = [RACObserve(self.viewModel, requestPostSystemErrorString) ignore:nil];
    
    // 专题 专题信息请求完成
    RACSignal *themeFinishSignal = [RACObserve(self.viewModel, theme) ignore:nil];

#pragma mark 刷新 翻页
    
    // 刷新控件 作者文章列表显示
    if (self.otherPostListType == CMTOtherPostListTypeAuthor) {
        [self.tableView addPullToRefreshWithActionHandler:nil];
        RAC(self.viewModel, pullToRefreshState) = [RACObserve(self.tableView.pullToRefreshView, state) distinctUntilChanged];
    }
    // 翻页控件
    [self.tableView addInfiniteScrollingWithActionHandler:nil];
    RAC(self.viewModel, infiniteScrollingState) = [RACObserve(self.tableView.infiniteScrollingView, state) distinctUntilChanged];
    RAC(self.tableView, showsInfiniteScrolling) = [[RACObserve(self.tableView, contentSize) distinctUntilChanged] map:^id(NSValue *contentSize) {
        @strongify(self);
        if (contentSize.CGSizeValue.height + self.tableView.contentInset.top <= self.tableView.height) return @NO; return @YES;
    }];
    
    // 停止刷新/翻页动画
    [[[RACSignal merge:@[
                         requestPostFinishSignal,
                         requestNewPostEmptyStringSignal,
                         requestMorePostEmptyStringSignal,
                         requestPostNetErrorSignal,
                         requestPostServerErrorMessageSignal,
                         requestPostSystemErrorStringSignal,
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.pullToRefreshView stopAnimating];
        [self.tableView.infiniteScrollingView stopAnimating];
    }];
    
#pragma mark 加载动画
    
    self.contentState = CMTContentStateLoading;
    
#pragma mark 疾病标签顶部
    
    if (self.otherPostListType == CMTOtherPostListTypeDisease) {
        UIView *tableHeaderView = nil;
        
        // '单个疾病标签'顶部
        if (!BEMPTY(self.viewModel.disease)) {
            self.themeHeader = [[CMTThemeHeader alloc] initWithDisease:self.viewModel.disease
                                                                module:self.viewModel.module
                                                       andLimitedWidth:self.tableView.width];
            self.themeHeader.delegate = self;
            tableHeaderView = self.themeHeader;
        }
        // '所有疾病标签'顶部
        else {
            // 刷新标题
            self.titleText = @"订阅的疾病";
            tableHeaderView = self.TagMarkerView;
        }
        
        // 设置tableHeaderView
        self.tableView.tableHeaderView = tableHeaderView;
    }
    
#pragma mark 专题顶部
    
    if (self.otherPostListType == CMTOtherPostListTypeTheme) {
        // 专题 专题信息请求完成
        [[themeFinishSignal
          deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            
            // 刷新标题
            self.titleText = self.viewModel.theme.title;
            
            // 专题顶部
            self.themeHeader = [[CMTThemeHeader alloc] initWithTheme:self.viewModel.theme
                                                     andLimitedWidth:self.tableView.width];
            self.themeHeader.delegate = self;
            
            // 设置tableHeaderView
            if (self.tableView.tableHeaderView == nil) {
                self.tableView.tableHeaderView = self.themeHeader;
            }
        }];
    }

#pragma mark 文章列表
    
    // 文章列表 请求完成
    [[requestPostFinishSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 刷新列表
        [self.tableView reloadData];
        self.contentState = CMTContentStateNormal;
    }];
    
    // 文章列表 强制刷新为空
    [[resetPostEmptyStringSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *emptyString) {
        @strongify(self);
        
        // 作者文章列表
        if (self.otherPostListType == CMTOtherPostListTypeAuthor) {
            NSString *contentEmptyPrompt = [CMTUSERINFO.userId isEqualToString:
                                            self.viewModel.authorId]?
            @"你还没有发表过文章":
            @"该作者还没有发表文章";
            self.contentEmptyView.contentEmptyPrompt = contentEmptyPrompt;
            self.contentState = CMTContentStateEmpty;
        }
        
        // 类型文章列表
        else if (self.otherPostListType == CMTOtherPostListTypePostType) {
            self.contentEmptyView.contentEmptyPrompt = @"没有该类型文章";
            self.contentState = CMTContentStateEmpty;
        }
        
        // '单个'/'所有'疾病标签文章列表
        else if (self.otherPostListType == CMTOtherPostListTypeDisease) {
//            self.contentEmptyView.contentEmptyPrompt = [NSString stringWithFormat:@"该疾病下还没有发表过%@",
//                                                        self.viewModel.module.moduleString];
            self.tableView.placeholderView = BEMPTY(self.viewModel.disease) ? nil : [self tableViewPlaceholderView] ;
            self.tableView.placeholderViewOffset = [NSValue valueWithCGPoint:
                                                    CGPointMake(0.0,0-self.tableView.tableHeaderView.height/2)];
            
            NSLog(@"djfdjfbjdbfjdbfjdfbjdb%@",self.tableView.subviews);
            // 刷新列表
            [self.tableView reloadData];
            self.contentState = CMTContentStateNormal;
        }
        
        // 二级标签文章列表
        else if (self.otherPostListType == CMTOtherPostListTypeKeyword) {
            self.contentEmptyView.contentEmptyPrompt = @"该标签下还没有发表过文章";
            self.contentState = CMTContentStateEmpty;
        }
        
        // 学科文章列表
        else if (self.otherPostListType == CMTOtherPostListTypeSubject) {
            self.contentEmptyView.contentEmptyPrompt = @"该学科下没有文章";
            self.contentState = CMTContentStateEmpty;
        }
        
        // 专题文章列表
        else if (self.otherPostListType == CMTOtherPostListTypeTheme) {
            self.contentEmptyView.contentEmptyPrompt = @"该专题下没有文章";
            self.tableView.placeholderView = self.contentEmptyView;
            self.tableView.placeholderViewOffset = [NSValue valueWithCGPoint:
                                                    CGPointMake(0.0, self.tableView.tableHeaderView.height/2.0)];
            // 刷新列表
            [self.tableView reloadData];
            self.contentState = CMTContentStateNormal;
        }
        
        // 其他文章列表
        else {
            self.contentEmptyView.contentEmptyPrompt = @"没有文章";
            self.contentState = CMTContentStateEmpty;
        }
    }];
    
    // 文章列表 请求刷新为空
    [[requestNewPostEmptyStringSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *emptyString) {
        @strongify(self);
        
        // 提示没有最新
        [self toastAnimation:emptyString];
        self.contentState = CMTContentStateNormal;
    }];
    
    // 文章列表 请求翻页为空
    [[requestMorePostEmptyStringSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *emptyString) {
        @strongify(self);
        
        // 提示没有更多
        [self toastAnimation:emptyString];
        self.contentState = CMTContentStateNormal;
    }];
    
    // 文章列表 请求网络错误
    [[requestPostNetErrorSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        
        // 当前列表无数据 显示重新加载
        if ([self.viewModel countOfCachePostList] == 0) {
            
            // '单个','所有'疾病标签文章列表
            // 带有顶部视图 且数据不需网络请求
            if (self.otherPostListType == CMTOtherPostListTypeDisease) {
                self.tableView.placeholderView = self.mReloadBaseView;
                self.tableView.placeholderViewOffset = [NSValue valueWithCGPoint:
                                                        CGPointMake(0.0, self.tableView.tableHeaderView.height/2.0)];
                // 刷新列表
                [self.tableView reloadData];
                self.contentState = CMTContentStateNormal;
            }
            
            // 没有顶部视图 或顶部视图数据需要网络请求
            else {
                
                self.contentState = CMTContentStateReload;
            }
        }
        
        // 当前列表有数据 提示网络不给力
        else {
            
            [self toastAnimation:@"你的网络不给力"];
        }
    }];
    
    // 文章列表 请求服务器错误消息
    [[requestPostServerErrorMessageSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorMessage) {
        @strongify(self);
        
        // 显示空白页 并消息提示
        self.contentState = CMTContentStateBlank;
        [self toastAnimation:errorMessage];
        CMTLogError(@"OtherPostList 服务器返回错误:\n%@", errorMessage);
        
        // 删除我的专题中的已删除专题
        @try {
            NSArray *pArr = [self.navigationController childViewControllers];
            NSUInteger count = pArr.count;
            if (count >= 2) {
                if ([[pArr objectAtIndex:count-2]isKindOfClass:[CMTEnterSubjectionViewController class]]) {
                    CMTEnterSubjectionViewController *themeVC = (CMTEnterSubjectionViewController *)[pArr objectAtIndex:count-2];
                    [self.viewModel.arrayTheme removeObjectAtIndex:self.indexPath.row];
                    [themeVC.mTableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    if (CMTUSER.login == YES) {
                        //服务器端删除
                        /*调用删除接口*/
                    }
                    
                    // 重新存储
                    BOOL suc = [NSKeyedArchiver archiveRootObject:self.viewModel.arrayTheme toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
                    if (suc) {
                        CMTLog(@"已删除专题在我的专题中删除成功");
                    }
                    else{
                        CMTLog(@"已删除专题在我的专题中删除失败");
                    }
                }
            }
        }
        @catch (NSException *exception) {
            CMTLog(@"更新订阅专题失败");
        }
    }];
    
    // 文章列表 请求系统错误信息
    [[requestPostSystemErrorStringSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *errorString) {
        @strongify(self);
        
        // 显示空白页 并消息提示
        self.contentState = CMTContentStateBlank;
        [self toastAnimation:@"系统错误"];
        CMTLogError(@"OtherPostList 系统错误:\n%@", errorString);
    }];
    
}
- (UIView *)tableViewPlaceholderView {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.tableView.tableHeaderView.height, self.tableView.width, 100.0)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, placeholderView.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(15.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text =[NSString stringWithFormat:@"该疾病下还没有发表过%@",
                            self.viewModel.module.moduleString];
    
    [placeholderView addSubview:placeholderLabel];
    
    return placeholderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
//    // 作者文章列表
//    if (self.otherPostListType == CMTOtherPostListTypeAuthor) {
//        [MobClick beginLogPageView:@"P_List_Authors"];
//    }
    
    // 如果是疾病标签列表呈现时更新tag标签视图
    if (self.tableView.tableHeaderView != nil && [self.tableView.tableHeaderView isKindOfClass:[CMTTagMarker class]]) {
        [self CMTGetTagArray];
    }
    
    // 专题文章列表
    if (self.otherPostListType == CMTOtherPostListTypeTheme) {
        self.viewModel.arrayTheme = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    
#pragma mark 专题指定文章不存在
    
    if (self.otherPostListType == CMTOtherPostListTypeTheme) {
        [[[RACObserve(self.viewModel, requestThemeSpecifiedPostNotExist) ignore:@NO]
          deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            CMTLog(@"专题指定文章不存在");
            
            CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:self.viewModel.postId
                                                                        isHTML:self.viewModel.isHTML
                                                                        postURL:self.viewModel.postURL
                                                                        postModule:nil
                                                                        postDetailType:CMTPostDetailTypeUnDefind];
            
            postDetailCenter.updatePostStatistics = self.updatePostStatistics;
            [self.navigationController popThenPushViewController:postDetailCenter animated:NO];
        }];
        
        //如果是从我的专题进入的当前专题，则删除我的专题中缓存的数据(待实现)
        
        
        //如果存在，且当前专题在我的专题中存在，更新缓存信息(刷新指定行)
        @try {
            NSArray *pArr = [self.navigationController childViewControllers];
            NSUInteger count = pArr.count;
            if (count >= 2) {
                if ([[pArr objectAtIndex:count-2]isKindOfClass:[CMTEnterSubjectionViewController class]]) {
                    CMTEnterSubjectionViewController *themeVC = (CMTEnterSubjectionViewController *)[pArr objectAtIndex:count-2];
                    CMTTheme *theme = [self.viewModel.arrayTheme objectAtIndex:self.indexPath.row];
                    self.viewModel.theme.opTime = theme.opTime;
                    if (self.viewModel.theme.themeId != nil) {
                        [self.viewModel.arrayTheme replaceObjectAtIndex:self.indexPath.row withObject:self.viewModel.theme];
                    }
                    [themeVC.mTableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    // 重新存储
                    BOOL suc = [NSKeyedArchiver archiveRootObject:self.viewModel.arrayTheme toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
                    if (suc) {
                        CMTLog(@"订阅专题更新成功");
                    }
                    else{
                        CMTLog(@"订阅专题更新失败");
                    }
                }
            }
        }
        @catch (NSException *exception) {
            CMTLog(@"更新订阅专题失败");
        }
        
        // 更新浏览时间
        [self updateCacheThemeViewTime];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
//    if (self.otherPostListType == CMTOtherPostListTypeAuthor) {
//        [MobClick endLogPageView:@"P_List_Authors"];
//    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
}

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    
    // 请求文章列表
    self.viewModel.pullToRefreshState = SVPullToRefreshStateLoading;
    // 显示加载动画
    self.contentState = CMTContentStateLoading;
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.viewModel heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.liveinfo.liveBroadcastId!=nil&&indexPath.section==0) {
        return 60;
    }
    return [self.viewModel heightForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.viewModel.liveinfo.liveBroadcastId!=nil&&(section==0||section==1)){
        return nil;
    }else{
        CMTTableSectionHeader *header = [CMTTableSectionHeader headerWithHeaderWidth:tableView.width
                                                                        headerHeight:[self.viewModel heightForHeaderInSection:section]];
        header.title = [self.viewModel titleForHeaderInSection:section];
        
        return header;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = CMTOtherPostListCellIdentifier;
    
    // '单个疾病标签'指南列表
    if (self.otherPostListType == CMTOtherPostListTypeDisease && self.viewModel.disease != nil && self.viewModel.module.isPostModuleGuide) {
        cellIdentifier = CMTGuidePostListCellIdentifier;
    }
     #pragma 直播
    if (self.viewModel.liveinfo.liveBroadcastId!=nil&&indexPath.section==0) {
        
        CMTLiveListCell *listCell=[self.tableView dequeueReusableCellWithIdentifier:CMTOtherLiveListCellIdentifier forIndexPath:indexPath];
        if(listCell==nil){
            listCell=[[CMTLiveListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CMTOtherLiveListCellIdentifier];
        }
        [listCell reloadCell:self.viewModel.liveinfo index:indexPath];
        return listCell;

    }else{
        CMTPostListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        CMTPost *post = [self.viewModel postForRowAtIndexPath:indexPath];
        post.themeStatus = @"0";
        [cell reloadPost:post tableView:tableView indexPath:indexPath];
        return cell;

     }
    
   }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.viewModel.liveinfo.liveBroadcastId !=nil&&indexPath.section==0) {
        CMTLiveListCell *cell=(CMTLiveListCell*)[tableView cellForRowAtIndexPath:indexPath];
        CMTLive *live=self.viewModel.liveinfo;
        CMTLiveViewController *ViewController=[[CMTLiveViewController alloc]initWithlive:live];
        ViewController.shareimage=cell.livePic.image;
        ViewController.updatelivedata=^(CMTLive *live){
            @strongify(self);
            self.viewModel.liveinfo.noticeCount=live.noticeCount;
            if (self.updateLive!=nil) {
                 self.updateLive(live);
            }
            [tableView reloadData];
        };
//        CMTNavigationController *nav=[[CMTNavigationController alloc]initWithRootViewController:ViewController];
//        [self presentViewController:nav animated:YES completion:nil];
        [self.navigationController pushViewController:ViewController animated:YES];
    }else{

        // 文章详情
        CMTPost *post = [self.viewModel postForRowAtIndexPath:indexPath];
        CMTPostDetailType postDetailType = CMTPostDetailTypeUnDefind;
        if (self.otherPostListType == CMTOtherPostListTypeAuthor) {
            postDetailType = CMTPostDetailTypeAuthorPostList;
        }
        //当groupId不为空时
        if (!isEmptyString(post.groupId) && post.groupId.integerValue != 0) {
            CMTGroup *group = [[CMTGroup alloc]init];
            group.groupId = post.groupId;
            group.memberGrade=post.memberGrade;
            group.groupType=post.groupType;
            group.groupName=post.groupName;
            CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId isHTML:post.isHTML postURL:post.url group:group postModule:post.module postDetailType:postDetailType];
            postDetailCenter.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
                @strongify(self);
                [self updatePost:post withPostStatistics:postStatistics];
            };
            [self.navigationController pushViewController:postDetailCenter animated:YES];
        }else{
            CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                       isHTML:post.isHTML
                                                                                      postURL:post.url
                                                                                   postModule:post.module
                                                                               postDetailType:postDetailType];
            
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
    
    // 刷新文章列表
    [self.tableView reloadData];
}

#pragma mark - ThemeHeader

// 点击全文
- (void)themeHeaderShowContentButtonTouched:(CMTThemeHeader *)themeHeader {
    CMTLog(@"点击全文: %@", self.viewModel.theme);
    
    self.tableView.tableHeaderView = themeHeader;
}

// 点击分享
- (void)themeHeaderShareButtonTouched:(CMTThemeHeader *)themeHeader {
    CMTLog(@"点击分享: %@", self.viewModel.theme);
    [self.mShareView.mBtnFriend addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.cancelBtn addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    //自定义分享
    [self shareViewshow:self.mShareView bgView:self.tempView currentViewController:self.navigationController];
//    self.shareTitle = self.viewModel.postDetail.title;
//    self.shareBrief = self.viewModel.postDetail.brief;
//    self.shareUrl = self.viewModel.postDetail.shareUrl;
    
}

// 点击求助
- (void)themeHeaderHelpButtonTouched:(CMTThemeHeader *)themeHeader {
    
    // '单个疾病标签'
    if (self.otherPostListType == CMTOtherPostListTypeDisease && self.viewModel.disease != nil) {
        CMTLog(@"点击求助: %@:%@", self.viewModel.diseaseIds, self.viewModel.disease);
        CMTDisease *dis=[[CMTDisease alloc]init];
        dis.disease=self.viewModel.disease;
        dis.diseaseId=self.viewModel.diseaseIds;
        CMTNeedMoreGuideViewController *needMore=[[CMTNeedMoreGuideViewController alloc]initDisease:dis];
        [self.navigationController pushViewController:needMore animated:YES];
    }
}

// 点击订阅
- (void)themeHeaderFocusButtonTouched:(CMTThemeHeader *)themeHeader {
    
    // 专题
    if (self.otherPostListType == CMTOtherPostListTypeTheme) {
        
        CMTLog(@"点击订阅专题: %@", self.viewModel.theme);
        
        if ([themeHeader.focusButton.titleLabel.text isEqualToString:@"订阅"]) {
            // 首次点击订阅
            if (CMTAPPCONFIG.currentVersionThemeFocused == NO) {
                // 显示提示
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"你可以在左侧导航的“专题”中，查看已订阅的全部专题。" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] show];
                // 记录强制订阅版本
                CMTAPPCONFIG.themeFocusedRecordedVersion = APP_VERSION;
            }
            [self focus:themeHeader];
        }
        else {
            self.alertView.title = @"确定不再订阅该专题吗？";
            [self.alertView show];
        }
    }
    
    // '单个疾病标签'
    else if (self.otherPostListType == CMTOtherPostListTypeDisease && self.viewModel.disease != nil) {
        CMTLog(@"点击订阅疾病标签: %@:%@", self.viewModel.diseaseIds, self.viewModel.disease);
        
        if ([themeHeader.focusButton.titleLabel.text isEqualToString:@"订阅"]) {
            [self focusDisease];
        }
        else {
            self.alertView.title = @"确定不再订阅该疾病吗？";
            [self.alertView show];
        }
    }

}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // 专题
    if (self.otherPostListType == CMTOtherPostListTypeTheme) {
        switch (buttonIndex) {
            case 0: {
                CMTLog(@"%@",[alertView buttonTitleAtIndex:buttonIndex]);
            }
                break;
            case 1: {
                CMTLog(@"%@",[alertView buttonTitleAtIndex:buttonIndex]);
                [self focused:self.themeHeader];
                [self.themeHeader.focusButton setTitle:@"订阅" forState:UIControlStateNormal];
                self.themeHeader.focusImage.image = IMAGE(@"theme_focus");
            }
                break;
            
            default:
                break;
        }
    }
    
    // '单个疾病标签'
    else if (self.otherPostListType == CMTOtherPostListTypeDisease && self.viewModel.disease != nil) {
        switch (buttonIndex) {
            case 0: {
                CMTLog(@"%@", [alertView buttonTitleAtIndex:buttonIndex]);
            }
                break;
            case 1: {
                CMTLog(@"%@", [alertView buttonTitleAtIndex:buttonIndex]);
                [self cancelFocusedDisease];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Disease

- (void)focusDisease {
    
    NSMutableArray *focusedDiseaseArray = [[NSMutableArray alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_FOUSTAG]) {
        focusedDiseaseArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]];
    }
    
    CMTDisease *disease = [[CMTDisease alloc] init];
    disease.diseaseId = [[self.viewModel.diseaseIds componentsSeparatedByString:@","] firstObject];
    disease.disease = self.viewModel.disease;
    disease.opTime = TIMESTAMP;
    disease.count = @"0";
    [focusedDiseaseArray addObject:disease];
    [NSKeyedArchiver archiveRootObject:focusedDiseaseArray toFile:PATH_FOUSTAG];
    
    NSDictionary *dic = @{
                          @"userId": CMTUSER.userInfo.userId ?: @"0",
                          @"diseaseId": disease.diseaseId ?: @"",
                          @"cancelFlag": @"0",
                          };
    CMTLog(@"订阅疾病标签参数: %@", dic);
    [[[CMTCLIENT FollowDisease:dic]
      deliverOn:[RACScheduler scheduler]] subscribeNext:^(CMTDisease *dis) {
        CMTLog(@"订阅疾病标签返回值: %@", dis);
        for (CMTDisease *focusedDisease in focusedDiseaseArray) {
            if ([focusedDisease.diseaseId isEqual:dis.diseaseId]) {
                disease.opTime = dis.opTime;
                disease.readTime = TIMESTAMP;
                disease.count = @"0";
                disease.readTime=TIMESTAMP;
                disease.caseCout=@"0";
                disease.caseReadtime=TIMESTAMP;
                disease.postCount=@"0";
                disease.postReadtime=TIMESTAMP;
                break;
            }
        }
        [NSKeyedArchiver archiveRootObject:focusedDiseaseArray toFile:PATH_FOUSTAG];
    } error:^(NSError *error) {
        CMTLog(@"订阅疾病标签失败: %@", error);
    }];
    
    [self.themeHeader.focusButton setTitle:@"已订阅" forState:UIControlStateNormal];
    self.themeHeader.focusImage.image = IMAGE(@"theme_focused");
}

- (void)cancelFocusedDisease {
    NSString *diseaseId = [[self.viewModel.diseaseIds componentsSeparatedByString:@","] firstObject];
    CMTDisease *disease = nil;

    NSMutableArray *focusedDiseaseArray = [[NSMutableArray alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_FOUSTAG]) {
        focusedDiseaseArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]];
    }
    
    for (CMTDisease *focusedDisease in focusedDiseaseArray) {
        if ([focusedDisease.diseaseId isEqual:diseaseId]) {
            disease = focusedDisease;
            break;
        }
    }
    
    [focusedDiseaseArray removeObject:disease];
    [NSKeyedArchiver archiveRootObject:focusedDiseaseArray toFile:PATH_FOUSTAG];
    
    NSDictionary *dic = @{
                          @"userId": CMTUSER.userInfo.userId ?: @"0",
                          @"diseaseId": disease.diseaseId ?: @"",
                          @"cancelFlag": @"1",
                          };
    [[[CMTCLIENT FollowDisease:dic]
      deliverOn:[RACScheduler scheduler]] subscribeNext:^(id x) {
        CMTLog(@"取消订阅疾病标签成功");
        
    } error:^(NSError *error) {
        CMTLog(@"取消订阅疾病标签失败: %@", error);
    }];
    
    [self.themeHeader.focusButton setTitle:@"订阅" forState:UIControlStateNormal];
    self.themeHeader.focusImage.image = IMAGE(@"theme_focus");
}

#pragma mark - Theme

- (void)focused:(CMTThemeHeader *)themeHeader {
    if (self.updateFocusState!=nil) {
        self.updateFocusState();
    }
   int index = 0;
    @try {
        CMTTheme *theme;
        
        for (int i = 0; i < self.viewModel.arrayTheme.count; i++)
        {
            if ([[self.viewModel.arrayTheme objectAtIndex:i]isKindOfClass:[CMTTheme class]])
            {
                theme = [self.viewModel.arrayTheme objectAtIndex:i];
                if ([themeHeader.theme.themeId isEqualToString:theme.themeId])
                {
                    index = i;
                    break;
                }
            }
            
        }
        CMTLog(@"提示标题");
        if(CMTUSER.login == YES)
        {
            /*有无网络*/
            BOOL netState = [AFNetworkReachabilityManager sharedManager].isReachable;
            if (netState)
            {
                CMTLog(@"有网络,服务端可以删除");
                /*获取该对象*/
               
                NSDictionary *pDic = @{
                                       @"userId":CMTUSER.userInfo.userId?:@"0",
                                       @"themeId":theme.themeId,
                                       @"cancelFlag":[NSNumber numberWithInt:1],
                                       };
                //调用全局的删除接口
                [CMTFOCUSMANAGER asyneTheme:pDic];
                
            }
        }
        else
        {
        }
        if (index <= self.viewModel.arrayTheme.count && self.viewModel.arrayTheme.count > 0)
        {
            [self.viewModel.arrayTheme removeObjectAtIndex:index];
            //[self.viewModel.arrayThemeShow removeObjectAtIndex:index];
            BOOL sucess = [NSKeyedArchiver archiveRootObject:self.viewModel.arrayTheme toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
            if (sucess)
            {
                CMTLog(@"本地删除成功");
                NSArray *pArr = [self.navigationController childViewControllers];
                NSUInteger viewControllers = pArr.count;
                if ([[pArr objectAtIndex:viewControllers-2]isKindOfClass:[CMTEnterSubjectionViewController class]])
                {
                    CMTEnterSubjectionViewController *enterVC = (CMTEnterSubjectionViewController *)[pArr objectAtIndex:viewControllers-2];
                    
                   // dispatch_async(dispatch_get_main_queue(), ^{
                    [enterVC.mArrSubjects removeObjectAtIndex:index];
                    [enterVC.mArrShowSubjects removeObjectAtIndex:index];
                    [enterVC.mTableView beginUpdates];
                        [enterVC.mTableView deleteRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [enterVC.mTableView endUpdates];
                        //[enterVC.mTableView reloadData];
                    //});
                }

            }
            else
            {
                CMTLog(@"本地删除失败");
            }
        }
    }
    @catch (NSException *exception) {
        CMTLog(@"exception.userInfo:%@",exception.userInfo);
    }
}

- (void)focus:(CMTThemeHeader *)themeHeader
{
    if (self.updateFocusState!=nil) {
        self.updateFocusState();
    }
    if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"focusList"]])
    {
        self.viewModel.arrayTheme = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
    }
    //CMTUSER.userInfo;
    //self.viewModel.postDetail;
    CMTLog(@"订阅");
    CMTLog(@"themeHeader.theme.themeId = %@",themeHeader.theme.themeId);
    
    NSDictionary *pDic = @{
                           @"userId":[NSNumber numberWithInteger:CMTUSER.userInfo.userId.integerValue?:0],
                           @"themeId": [NSNumber numberWithInteger:themeHeader.theme.themeId.integerValue],
                           @"cancelFlag":[NSNumber numberWithInt:0],
                           };
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        if (CMTUSER.login == YES)
        {
            @weakify(self);
            [[CMTCLIENT fetchTheme:pDic]subscribeNext:^(CMTTheme *theme) {
                @strongify(self);
                CMTLog(@"后返回对象的操作时间为%@",theme.opTime);
                CMTLog(@"订阅成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    /*弹出收藏成功视图*/
                    if (themeHeader.theme.descriptionString == nil)
                    {
                        [self toastAnimation:@"没有专题内容，请点击刷新"];
                    }
                    else
                    {
                        
                        [themeHeader.focusButton setTitle:@"已订阅" forState:UIControlStateNormal];
                        themeHeader.focusImage.image = IMAGE(@"theme_focused");
                        
                        theme.themeId = themeHeader.theme.themeId;
                        theme.title = themeHeader.theme.title;
                        theme.descriptionString = themeHeader.theme.descriptionString;
                        theme.picture = themeHeader.theme.picture;
                        theme.shareUrl = themeHeader.theme.shareUrl;
                        theme.opTime = theme.opTime;
                        theme.viewTime = theme.opTime;
                        NSUInteger themeCount = self.viewModel.arrayTheme.count;
                        BOOL isContained = NO;
                        NSUInteger index = 0;
                        if (themeCount > 0)
                        {
                            /*去重,缓存本地*/
                            for (NSUInteger i = 0; i < themeCount; i++)
                            {
                                if ([[self.viewModel.arrayTheme objectAtIndex:i]isKindOfClass:[CMTTheme class]])
                                {
                                    CMTTheme *pTempTheme = [self.viewModel.arrayTheme objectAtIndex:i];
                                    if ([pTempTheme.themeId isEqualToString: themeHeader.theme.themeId])
                                    {
                                        isContained = YES;
                                        index = i;
                                        break;
                                    }
                                }
                            }
                            if (isContained)
                            {
                                [self.viewModel.arrayTheme removeObjectAtIndex:index];
                                CMTLog(@"已经有这条订阅专题信息,订阅时间将更新");
                            }
                        }
                        [self.viewModel.arrayTheme addObject:theme];
                        
                        BOOL suc = [NSKeyedArchiver archiveRootObject:self.viewModel.arrayTheme toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
                        if (suc)
                        {
                            CMTLog(@"缓存到本地成功");
                        }
                        else
                        {
                            CMTLog(@"缓存本地失败");
                        }
                    }
                    
                });
            } error:^(NSError *error) {
                @strongify(self);
                CMTLog(@"error:%@",error);
                NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                if ([errorCode integerValue] > 100) {
                    NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                    CMTLog(@"errMes = %@",errMes);
                } else {
                    CMTLogError(@"Request subscriptionList System Error: %@", error);
                }
                
                // 添加缓存专题
                [self addCacheThemeForThemeHeader:themeHeader];
            }];
        }
        else
        {
            // 添加缓存专题
            [self addCacheThemeForThemeHeader:themeHeader];
        }
    }
    else
    {
        // 添加缓存专题
        [self addCacheThemeForThemeHeader:themeHeader];
    }
}

- (void)addCacheThemeForThemeHeader:(CMTThemeHeader *)themeHeader {
    if (themeHeader.theme.descriptionString == nil)
    {
        [self toastAnimation:@"没有文章内容，请点击刷新"];
    }
    else
    {
        CMTTheme *theme = [[CMTTheme alloc]init];
        theme.opTime = [NSDate UNIXTimeStampFromNow];
        theme.viewTime = theme.opTime;
        theme.themeId = themeHeader.theme.themeId;
        theme.title = themeHeader.theme.title;
        theme.descriptionString = themeHeader.theme.descriptionString;
        theme.picture = themeHeader.theme.picture;
        theme.shareUrl = themeHeader.theme.shareUrl;
        
        NSUInteger index = self.viewModel.arrayTheme.count;
        BOOL isContained = NO;
        if (index > 0)
        {
            /*去重,缓存本地*/
            for (NSUInteger i = 0; i < index; i++)
            {
                if ([[self.viewModel.arrayTheme objectAtIndex:i]isKindOfClass:[CMTTheme class]])
                {
                    CMTTheme *pTempTheme = [self.viewModel.arrayTheme objectAtIndex:i];
                    if ([pTempTheme.themeId isEqualToString: themeHeader.theme.themeId])
                    {
                        index = i;
                        isContained = YES;
                        break;
                    }
                }
            }
            if (isContained)
            {
                [self.viewModel.arrayTheme removeObjectAtIndex:index];
                CMTLog(@"已经有这条订阅专题信息,订阅时间将更新");
            }
        }
        [self.viewModel.arrayTheme addObject:theme];
        BOOL sucess = [NSKeyedArchiver archiveRootObject:self.viewModel.arrayTheme toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
        if (sucess)
        {
            CMTLog(@"匿名订阅专题成功");
        }
        else
        {
            CMTLog(@"匿名订阅专题失败");
        }
        
        [themeHeader.focusButton setTitle:@"已订阅" forState:UIControlStateNormal];
        themeHeader.focusImage.image = IMAGE(@"theme_focused");
    }
}

- (void)updateCacheThemeViewTime {
    CMTLog(@"更新订阅专题浏览时间 themeId: %@", self.viewModel.themeId);
    
    CMTTheme *cacheTheme = nil;
    for (CMTTheme *tempTheme in self.viewModel.arrayTheme) {
        if ([tempTheme.themeId isEqualToString:self.viewModel.themeId]) {
            cacheTheme = tempTheme;
            break;
        }
    }
    
    if (cacheTheme != nil) {
        cacheTheme.viewTime = TIMESTAMP;
        
        BOOL sucess = [NSKeyedArchiver archiveRootObject:self.viewModel.arrayTheme toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
        if (sucess)
        {
            CMTLog(@"更新订阅专题浏览时间成功\nTheme: %@\nThemeList: %@", cacheTheme, self.viewModel.arrayTheme);
        }
        else
        {
            CMTLogError(@"更新订阅专题浏览时间失败\nTheme: %@\nThemeList: %@", cacheTheme, self.viewModel.arrayTheme);
        }
    }
}


#pragma mark - ShareMethod

- (void)showShare:(UIButton *)btn
{
    [self methodShare:btn];
}

///平台按钮关联的分享方法
- (void)methodShare:(UIButton *)btn
{
    NSString *shareType = nil;
    switch (btn.tag)
    {
        case 1111:
        {
            if ([self respondsToSelector:@selector(weixinFriendShare)]) {
                [self performSelector:@selector(weixinFriendShare) withObject:nil afterDelay:0.2];
            }
        }
            break;
        case 2222:
        {
            if ([self respondsToSelector:@selector(weixinShare)]) {
                [self performSelector:@selector(weixinShare) withObject:nil afterDelay:0.2];
            }
        }
            break;
        case 3333:
        {
            shareType = @"3";
            CMTLog(@"新浪微博");
            if ([self respondsToSelector:@selector(weiboShare)]) {
                [self performSelector:@selector(weiboShare) withObject:nil afterDelay:0.2];
            }
            
        }
            break;
        case 4444:
        {
            CMTLog(@"邮件");
            shareType = @"4";
            NSString *shareText=[NSString stringWithFormat:@"#壹生#壹生专题：%@\n%@ 来自@壹生", self.viewModel.theme.title, self.viewModel.theme.shareUrl];
             [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:[NSString stringWithFormat:@"壹生专题：%@",self.viewModel.theme.title] sharetext:shareText sharetype:shareType sharepic:self.viewModel.theme.sharePic.picFilepath shareUrl:self.viewModel.theme.shareUrl StatisticalType:@"shareTheme" shareData: self.viewModel.theme];        }
            break;
        case 5555:
            [self shareViewDisapper];
            break;
        default:
            CMTLog(@"其他分享");
            break;
    }
    if ([self respondsToSelector:@selector(removeTaget)]) {
        [self performSelector:@selector(removeTaget) withObject:nil afterDelay:0.2];
    }
    [self shareViewDisapper];
}
- (void)removeTaget
{
    [self.mShareView.mBtnFriend removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.cancelBtn removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)weixinShare
{
    NSString * shareType = @"2";
    CMTLog(@"微信好友");
    NSString *shareText = self.viewModel.theme.descriptionString;
    if (shareText.length>50) {
        shareText=[shareText substringToIndex:49];
    }
    CMTLog(@"brief:%@",shareText);
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:[NSString stringWithFormat:@"壹生专题：%@",self.viewModel.theme.title] sharetext:shareText sharetype:shareType sharepic:self.viewModel.theme.sharePic.picFilepath shareUrl:self.viewModel.theme.shareUrl StatisticalType:@"shareTheme" shareData: self.viewModel.theme];
    
}
- (void)weixinFriendShare
{
    NSString * shareType = @"1";
    CMTLog(@"朋友圈");
    NSString *shareText =[NSString stringWithFormat:@"壹生专题：%@",self.viewModel.theme.title];
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.viewModel.theme.sharePic.picFilepath shareUrl:self.viewModel.theme.shareUrl StatisticalType:@"shareTheme" shareData: self.viewModel.theme];
}
- (void)weiboShare{
    NSString *shareType=@"3";
    NSString *shareText = [NSString stringWithFormat:@"#%@# 壹生专题：%@。%@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY, self.viewModel.theme.title,self.viewModel.theme.shareUrl];
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.viewModel.theme.sharePic.picFilepath shareUrl:self.viewModel.theme.shareUrl StatisticalType:@"shareTheme" shareData: self.viewModel.theme];

}



@end
