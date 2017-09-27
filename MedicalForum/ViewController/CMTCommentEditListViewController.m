//
//  CMTCommentEditListViewController.m
//  MedicalForum
//
//  Created by fenglei on 14/12/28.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

// controller
#import "CMTCommentEditListViewController.h"            // header file
#import "CMTPostDetailCenter.h"                         // 文章详情

// view
#import "CMTCommentEditListCell.h"                      // 编辑评论cell

// viewModel
#import "CMTCommentEditListViewModel.h"                 // 编辑评论列表数据

@interface CMTCommentEditListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *sentTableView;                   // 我评论的列表

// viewModel
@property (nonatomic, strong) CMTCommentEditListViewModel *viewModel;       // 数据

@property(nonatomic,strong)UIView *ListEmptyBgView; //列表视图数据为空时的提示;
@property(nonatomic,assign)BOOL  ishiddenreciveTable;
@end

@implementation CMTCommentEditListViewController

#pragma mark Initializers

- (UITableView *)sentTableView {
    if (_sentTableView == nil) {
        _sentTableView = [[UITableView alloc] init];
        _sentTableView.backgroundColor = COLOR(c_ffffff);
        _sentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _sentTableView.dataSource = self;
        _sentTableView.delegate = self;
        [_sentTableView registerClass:[CMTCommentEditListCell class] forCellReuseIdentifier:CMTCommentEditListCellIdentifier];
        [_sentTableView fillinContainer:self.contentBaseView WithTop:64 Left:0 Bottom:0 Right:0];
    }
    
    return _sentTableView;
}

- (CMTCommentEditListViewModel *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [[CMTCommentEditListViewModel alloc] init];
    }
    
    return _viewModel;
}

-(UIView*)ListEmptyBgView{
    if (_ListEmptyBgView==nil) {
        _ListEmptyBgView=[[UIView alloc]init];
        [_ListEmptyBgView fillinContainer:self.contentBaseView WithTop:64 Left:0 Bottom:0 Right:0];
//        _ListEmptyBgView.hidden=NO;
        [_ListEmptyBgView setBackgroundColor:COLOR(c_ffffff)];
//        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake((self.ListEmptyBgView.frame.size.width-160)/2, (self.ListEmptyBgView.frame.size.height-35)/2, 40, 35)];
//        imageView.image=[UIImage imageNamed:@"comments_pic"];
//        [_ListEmptyBgView addSubview:imageView];
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(0,(SCREEN_WIDTH-35)/2, SCREEN_WIDTH, 35)];
        [lable setTextColor:[UIColor colorWithHexString:@"#c8c8c8"]];
        [lable setTextAlignment:NSTextAlignmentCenter];
        [lable setFont:[UIFont systemFontOfSize:20]];
        [lable setText:@"还没有评论"];
        [_ListEmptyBgView addSubview:lable];

    }
    return _ListEmptyBgView;
}
#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CommentEditList willDeallocSignal");
    }];
    self.ishiddenreciveTable=NO;
    // backItem
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    
    // title
    self.titleText = @"评论";
    
    [self setContentState:CMTContentStateLoading];
    // 评论列表
    [self.contentBaseView addSubview:self.ListEmptyBgView];
    [self.contentBaseView bringSubviewToFront:self.sentTableView];
    self.sentTableView.hidden = YES;
//    self.ListEmptyBgView.hidden = YES;
  
    
#pragma mark 发出的评论
    
    // 发出的评论 翻页
    [self.sentTableView addInfiniteScrollingWithActionHandler:nil];
    [self.sentTableView addPullToRefreshWithActionHandler:^{
        // 请求评论列表
        @strongify(self);
        self.viewModel.pullToRefreshState = SVPullToRefreshStateLoading;
    }];
    RAC(self.viewModel, sentCommentInfiniteScrollingState) = [RACObserve(self.sentTableView.infiniteScrollingView, state) distinctUntilChanged];
    RAC(self.sentTableView, showsInfiniteScrolling) = [[RACObserve(self.sentTableView, contentSize) distinctUntilChanged] map:^id(NSValue *contentSize) {
        @strongify(self);
        if (contentSize.CGSizeValue.height + self.sentTableView.contentInset.top <= self.sentTableView.height) return @NO; return @YES;
    }];
    
    // 发出的评论 停止翻页的加载中动画
    [[[RACSignal merge:@[
                         [RACObserve(self.viewModel, requestSentCommentFinish) ignore:@NO],
                         [RACObserve(self.viewModel, requestSentCommentEmpty) ignore:@NO],
                         [RACObserve(self.viewModel, requestSentCommentError) ignore:@NO],
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.sentTableView.infiniteScrollingView stopAnimating];
        [self.sentTableView.pullToRefreshView stopAnimating];
    }];
    
    // 发出的评论 刷新文章列表
    [[[RACObserve(self.viewModel, requestSentCommentFinish) ignore:@NO] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self.sentTableView reloadData];
        if(nil == self.viewModel.sentCommentList || 0 == [self.viewModel.sentCommentList count]){
            self.ListEmptyBgView.hidden = NO;
            self.sentTableView.hidden = YES;
        }else{
            self.ListEmptyBgView.hidden = YES;
            self.sentTableView.hidden = NO;
        }
       [self setContentState:CMTContentStateNormal];
    }];
    
    // 发出的评论 提示信息
    [[[RACObserve(self.viewModel, requestSentCommentMessage) ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *message) {
        // 显示信息
        CMTLog(@"%@", message);
        
        [self setContentState:CMTContentStateNormal];
    }];
    
    [[self rac_willDeallocSignal] subscribeCompleted:^{
        CMTLog(@"CommentEditList willDeallocSignal");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
    // 请求评论列表
    self.viewModel.pullToRefreshState = SVPullToRefreshStateLoading;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (tableView == self.sentTableView) {
        return [self.viewModel numberOfRowsInSectionForSentComment:section];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTObject *comment = nil;
    if (tableView == self.sentTableView) {
        comment = [self.viewModel commentForRowAtIndexPathForSentComment:indexPath];
    }
    
    return [CMTCommentEditListCell cellHeightFromComment:comment tableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTCommentEditListCell *cell = [tableView dequeueReusableCellWithIdentifier:CMTCommentEditListCellIdentifier forIndexPath:indexPath];
    CMTObject *comment = nil;
    if (tableView == self.sentTableView) {
        comment = [self.viewModel commentForRowAtIndexPathForSentComment:indexPath];
    }
    
    [cell reloadComment:comment tableView:tableView indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *postId = nil;
    NSString *isHTML = nil;
    NSString *postURL = nil;
    NSString *postModule = nil;
    CMTObject *comment = nil;
    @try {
       if (tableView == self.sentTableView) {
            comment = [self.viewModel commentForRowAtIndexPathForSentComment:indexPath];
            postId = [(CMTSendComment *)comment postId];
            isHTML = [(CMTSendComment *)comment isHTML];
            postURL = [(CMTSendComment *)comment url];
            postModule = [(CMTSendComment *)comment module];
        }
    }
    @catch (NSException *exception) {
        postId = nil;
        isHTML = nil;
        postURL = nil;
        comment = nil;
        CMTLogError(@"CommentEditList Get Comment Exception: %@", exception);
    }
    
    if (!BEMPTY(postId) && comment != nil) {
        CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:postId
                                                                                   isHTML:isHTML
                                                                                  postURL:postURL
                                                                               postModule:postModule
                                                                       toDisplayedComment:comment];
        
        [self.navigationController pushViewController:postDetailCenter animated:YES];
    }
    else {
        CMTLogError(@"CommentEditList Enter PostDetail Error");
    }
}

@end
