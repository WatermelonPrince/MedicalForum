//
//  CMTMoreseriesListViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/7/29.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTMoreseriesListViewController.h"
#import "CMTSeriousListViewCell.h"
#import "CMTSeriesDetailsViewController.h"

@interface CMTMoreseriesListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *seriousListArr;
@property (nonatomic, strong)UITableView *listTableView;//系列课程列表视图

@end

@implementation CMTMoreseriesListViewController

- (UITableView *)listTableView{
    if (!_listTableView) {
        _listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.backgroundColor=COLOR(c_ffffff);
        [_listTableView registerClass:[CMTSeriousListViewCell class] forCellReuseIdentifier:@"cell"];
        _listTableView.placeholderView=[self tableViewPlaceholderView:_listTableView text:@"一大波课程即将来袭"];
        
        _listTableView.backgroundColor=COLOR(c_ffffff);
        [_listTableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,_listTableView.height/2+50)]];
        [self.contentBaseView addSubview:_listTableView];
    }
    return _listTableView;
}


- (NSMutableArray *)seriousListArr{
    if (!_seriousListArr) {
        _seriousListArr = [NSMutableArray array];
    }
    return _seriousListArr;
}

- (instancetype)initWithHeHe{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setContentState:CMTContentStateLoading];
    [self getDataFromNet];
    self.titleText = @"系列课程";
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTRecordListViewController willDeallocSignal");
    }];
    
    //下拉刷新
    [self pullToRefresh];
    //上啦加载
    [self pullToGetMore];
}

//下拉刷新
- (void)pullToRefresh{
    @weakify(self);
    [self.listTableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTSeriesDetails *seriesDetail = [[CMTSeriesDetails alloc]init];
        seriesDetail.pageOffset = @"0";
        if(self.seriousListArr.count>0){
            seriesDetail=self.seriousListArr.firstObject;
        }
        NSDictionary *param = @{
                                @"userId":CMTUSERINFO.userId?:@"0",
                                @"pageOffset":seriesDetail.pageOffset,
                                @"pageSize":@"30",
                                @"actionType":@"3",
                                @"incrIdFlag":@"0",
                                
                                };
        @weakify(self);
        [[[CMTCLIENT CMTGetmoreSerious:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *data) {
            @strongify(self);
            if (data.count == 0) {
                [self toastAnimation:@"没有最新课程"];
            }else{
                NSMutableArray *arr = [NSMutableArray arrayWithArray:data];
                [arr addObjectsFromArray:[self.seriousListArr copy]];
                self.seriousListArr = [arr mutableCopy];
                [self.listTableView reloadData];
                [self toastAnimation:@"课程更新完毕"];

            }
            
            [self.listTableView.pullToRefreshView stopAnimating];
            
        } error:^(NSError *error) {
            @strongify(self);
            if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
                @strongify(self);
                [self toastAnimation:@"你的网络不给力"];
                
            }else{
                @strongify(self);
                [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
            [self.listTableView.pullToRefreshView stopAnimating];

            
            
        }];

        
        
        
    }];
}

//上拉加载
- (void)pullToGetMore{
    @weakify(self);
    [self.listTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        if (self.seriousListArr.count *(SCREEN_WIDTH *9/16 + 7 * XXXRATIO) < SCREEN_HEIGHT - 64 ) {
            [self.listTableView.infiniteScrollingView stopAnimating];
            return ;
        }
        CMTSeriesDetails *seriesDetail = [[CMTSeriesDetails alloc]init];
        seriesDetail.pageOffset = @"0";
        if (self.seriousListArr.count > 0) {
            seriesDetail = [self.seriousListArr lastObject];
        }
        NSDictionary *param = @{
                                @"userId":CMTUSERINFO.userId?:@"0",
                                @"pageOffset":seriesDetail.pageOffset,
                                @"pageSize":@"30",
                                @"actionType":@"3",
                                @"incrIdFlag":@"1",
                                };
        @weakify(self);
        [[[CMTCLIENT CMTGetmoreSerious:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *data) {
            @strongify(self);
            NSMutableArray *arr = [data mutableCopy];
            if (arr.count == 0) {
                [self toastAnimation:@"没有更多课程"];
            }else{
                [self.seriousListArr addObjectsFromArray:arr];
                [self.listTableView reloadData];
            }
            [self.listTableView.infiniteScrollingView stopAnimating];
            
        } error:^(NSError *error) {
            @strongify(self);
            if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
                @strongify(self);
                [self toastAnimation:@"你的网络不给力"];
                
            }else{
                @strongify(self);
                [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
            [self.listTableView.infiniteScrollingView stopAnimating];
            
            
            
        }];
        
    }];
}

#pragma mark 重新加载
-(void)animationFlash{
    [super animationFlash];
    [self setContentState:CMTContentStateLoading];
    [self getDataFromNet];
}

//第一次请求网络数据
- (void)getDataFromNet{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId ? :@"0",
                             //                             @"pageOffset":
                             @"pageSize":@"30",
                             @"actionType":@"3",
                             @"incrIdFlag":@"0"
                             };
    @weakify(self);
    [[[CMTCLIENT CMTGetmoreSerious:params] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *data) {
        @strongify(self);
        self.seriousListArr = [data mutableCopy];
        [self.listTableView reloadData];
        [self setContentState:CMTContentStateNormal];
        
    } error:^(NSError *error) {
        @strongify(self);
        if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
            @strongify(self);
            [self setContentState:CMTContentStateReload];

            [self toastAnimation:@"你的网络不给力"];
            
        }else{
            @strongify(self);
            [self setContentState:CMTContentStateReload];

            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
        [self.listTableView.infiniteScrollingView stopAnimating];
    }];
    
}
#pragma tableViewDelegate,dateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.seriousListArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTSeriousListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell reloadCellWithModel:self.seriousListArr[indexPath.row]];
    //设置选中颜色区域
    if (cell.selectedBackgroundView.tag==1000) {
        cell.selectedBackgroundView.frame=cell.frame;
        [cell.selectedBackgroundView viewWithTag:10001].frame=CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height-7*XXXRATIO);
    }else{
        UIView *view=[[UIView alloc]initWithFrame:cell.frame];
        view.tag=1000;
        UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height-7*XXXRATIO)];
        backView.tag=10001;
        backView.backgroundColor=[UIColor colorWithHexString:@"#d9d9d9"];
        [view addSubview:backView];
        cell.selectedBackgroundView=view;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SCREEN_WIDTH *9/16 + 7 * XXXRATIO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CMTSeriesDetailsViewController *det=[[CMTSeriesDetailsViewController alloc]initWithParam:[self.seriousListArr[indexPath.row] copy]];
    
    [self.navigationController pushViewController:det animated:YES];
}


@end
