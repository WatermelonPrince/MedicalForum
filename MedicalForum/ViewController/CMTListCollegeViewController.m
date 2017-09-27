
//  CMTListCollegeViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTListCollegeViewController.h"
#import "CMTCourseCell.h"
#import "CMTCollegeFocusView.h"
#import "UIButton+WebCache.h"
#import "CMTSeriesDetailsViewController.h"
#import "CmtMoreVideoViewController.h"
#import "CMTMoreseriesListViewController.h"
#import "CMTLightVideoViewController.h"
#import "CMTRecordedViewController.h"
#import "CMTAdvertCell.h"
#import "CMTListCollegeGuideView.h"
#import "CMTWebBrowserViewController.h"



@interface CMTListCollegeViewController ()<UITableViewDataSource,UITableViewDelegate,CMTCollegeFocusViewDelegate,CMTVedioCellDelegate,SDWebImageManagerDelegate,CMTAdvertCellDelegate>
@property (nonatomic, strong)NSMutableArray *focusArr;//焦点图数组；
@property (nonatomic, strong)NSMutableArray *listCollegeArr;//学院数组；
@property (nonatomic, strong)NSMutableArray *videosArr;//系列课程;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)CMTCollegeFocusView *collegeFocusView;//焦点视图;
@property (nonatomic, strong)UIView *tableHeaderView;
@property (nonatomic, strong)UIView *collegeGuideBgView;
@property (nonatomic, strong)UIImageView *bannerplaceImageView;
@property (nonatomic, strong)NSString *queryType;//查询类型
@property (nonatomic, assign)BOOL advertRequstHaveResponse;//广告请求有回应
@property (nonatomic, assign)BOOL collegeDataRequstHaveResponse;//壹生大学数据请求有回应
@property (nonatomic, strong)NSMutableArray *advertArr;//广告数组
@property (nonatomic, assign)BOOL isReloadDate;//是否刷新数据


@end

@implementation CMTListCollegeViewController

- (NSMutableArray *)advertArr{
    if (!_advertArr) {
        _advertArr = [NSMutableArray array];
    }
    return _advertArr;
}
- (UIImageView *)bannerplaceImageView{
    if (!_bannerplaceImageView) {
        _bannerplaceImageView = [[UIImageView alloc]init];
        _bannerplaceImageView.userInteractionEnabled = YES;
    }
    return _bannerplaceImageView;
}

- (UIView *)collegeGuideBgView{
    if (!_collegeGuideBgView) {
        _collegeGuideBgView = [[UIView alloc]init];
        _collegeGuideBgView.backgroundColor = ColorWithHexStringIndex(c_ffffff);
    }
    return _collegeGuideBgView;
}

- (UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc]init];
        _tableHeaderView.backgroundColor = ColorWithHexStringIndex(c_f5f5f5);
    }
    return _tableHeaderView;
}

- (CMTCollegeFocusView *)collegeFocusView{
    if (!_collegeFocusView) {
        _collegeFocusView = [[CMTCollegeFocusView alloc]init];
        _collegeFocusView.backgroundColor = COLOR(c_clear);
        _collegeFocusView.delegate = self;
    }
    return _collegeFocusView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT - CMTNavigationBarBottomGuide - CMTTabBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[CMTCourseCell class] forCellReuseIdentifier:@"CMTCourseCell"];
        [_tableView registerClass:[CMTAdvertCell class] forCellReuseIdentifier:@"CMTAdvertCell"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.placeholderView=[self tableViewPlaceholderView:_tableView text:@"一大波课程即将来袭,敬请期待"];
        
        _tableView.backgroundColor=COLOR(c_ffffff);



    }
    return _tableView;
}

- (NSMutableArray *)focusArr{
    if (!_focusArr) {
        _focusArr = [NSMutableArray array];
    }
    return _focusArr;
}
- (NSMutableArray *)listCollegeArr{
    if (!_listCollegeArr) {
        _listCollegeArr = [NSMutableArray array];
    }
    return _listCollegeArr;
}



- (NSMutableArray *)videosArr{
    if (!_videosArr) {
        _videosArr = [NSMutableArray array];
    }
    return _videosArr;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.contentBaseView addSubview:self.tableView];
    [self setContentState:CMTContentStateLoading];
    [self getDataFromNet];
    [self getAdvertData];
    [self pullToRefreshList];
    [self CMTmoreVideoInfIniteRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AppDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    RAC(self,isReloadDate) = [[RACSignal combineLatest:@[[RACObserve(self, advertRequstHaveResponse)distinctUntilChanged],
                                                                   [RACObserve(self, collegeDataRequstHaveResponse)distinctUntilChanged]]reduce:^(NSNumber *a,NSNumber *b){
                                                                       BOOL lighted = a.integerValue == 1 && b.integerValue == 1;
                                                                       return @(lighted);
                                                                       
                                                                   }] deliverOn:[RACScheduler mainThreadScheduler]];
    [[RACObserve(self, isReloadDate)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber * x) {
        if (x.integerValue == 1) {
            if (self.videosArr.count > 0) {
                for (int i = 0; i < self.advertArr.count; i ++ ) {
                    CMTAdvert *advert = self.advertArr[i];
                    //位置须为偶数且插入位置包含在数组中
                    if (self.videosArr.count - 1 > advert.position.integerValue && advert.position.integerValue%2 == 0) {
                        [self.videosArr insertObject:advert atIndex:(advert.position.integerValue + i * 2)];
                        [self.videosArr insertObject:advert atIndex:(advert.position.integerValue + i * 2 + 1)];
                    }
                }
            }
            [self.tableView reloadData];
            [self setContentState:CMTContentStateNormal];
            
        }
    }];
}


- (void)AppDidBecomeActive{
    if (CMTAPPCONFIG.isrefreshCollegedata) {
        [self setContentState:CMTContentStateLoading];
        self.collegeDataRequstHaveResponse = NO;
        self.advertRequstHaveResponse = NO;
        [self getDataFromNet];
        [self getAdvertData];
        CMTAPPCONFIG.isrefreshCollegedata=NO;
    }
}
//下拉刷新
- (void)pullToRefreshList{
    @weakify(self);
    [self.tableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        NSDictionary *dic = @{
                              @"userId":CMTUSERINFO.userId?:@"0",
                              @"actionType":@"2",
                              };
        @weakify(self);
        [[[CMTCLIENT getCMTPlayParamIsNew:dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord * x) {
            @strongify(self);
            if (x.flag.integerValue == 0 &&self.videosArr.count>0) {
                [self toastAnimation:@"没有最新视频"];
                [self.tableView.pullToRefreshView stopAnimating];
            }else{
                NSDictionary *parameters = @{
                                             @"userId":CMTUSER.userInfo.userId?:@"0",
                                             };
                @weakify(self);
                [[[CMTCLIENT CMTGetUniverVediolist:parameters]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList * playParam) {
                    @strongify(self);
                    self.queryType = @"1";
                    [self.focusArr removeAllObjects];
                    [self.listCollegeArr removeAllObjects];
                    [self.videosArr removeAllObjects];
                    //焦点图数据
                    self.focusArr = [playParam.focuslist mutableCopy];
                    //学科导航数据
                    NSMutableArray *collArr = [playParam.colleges mutableCopy];
                    
                    self.listCollegeArr  = [collArr mutableCopy];
                    //课程数据
                    self.videosArr = [playParam.videos mutableCopy];
                   

                    if (self.videosArr.count > 0) {
                        for (int i = 0; i < self.advertArr.count; i ++ ) {
                            CMTAdvert *advert = self.advertArr[i];
                            //位置须为偶数且插入位置包含在数组中
                            if (self.videosArr.count - 1 > advert.position.integerValue && advert.position.integerValue%2 == 0) {
                                [self.videosArr insertObject:advert atIndex:(advert.position.integerValue + i * 2)];
                                [self.videosArr insertObject:advert atIndex:(advert.position.integerValue + i * 2 + 1)];
                            }
                        }
                    }
                    [self creatFocusView];
                    [self creatCollegeGuideView:self.listCollegeArr];
                   [self.tableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-(self.tableView.height - self.tableHeaderView.height)/2 + 20)]];
                    [self.tableView reloadData];
                    [self toastAnimation:@"视频更新完毕"];
                    [self.tableView.pullToRefreshView stopAnimating];
                    
                } error:^(NSError *error) {
                    @strongify(self);
                    if (([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||CMTAPPCONFIG.reachability.integerValue==0) {
                        [self toastAnimation:@"你的网络不给力"];
                    }else{
                        [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
                    }
                    [self.tableView.pullToRefreshView stopAnimating];
                    
                }];
            }
            
            
        } error:^(NSError *error) {
            @strongify(self);
            if (([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||CMTAPPCONFIG.reachability.integerValue==0) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            }
            [self.tableView.pullToRefreshView stopAnimating];
        }];
    }];
}

#pragma mark 上拉翻页
-(void)CMTmoreVideoInfIniteRefresh{
    @weakify(self);
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        if (self.videosArr.count<30) {
            [self.parentVC toastAnimation:@"没有更多课程"];
            [self.tableView.infiniteScrollingView stopAnimating];
            return ;
        }
        CMTLivesRecord *Record=[[CMTLivesRecord alloc]init];
        Record.pageOffset=@"0";
        if(self.videosArr.count>0){
            Record=self.videosArr.lastObject;
        }
        NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                              @"pageOffset":Record.pageOffset,
                              @"pageSize":@"30",
                              @"incrIdFlag":@"1",
                              @"queryType":self.queryType,
                              };
        @weakify(self);
        [[[CMTCLIENT CMTQueryTypeVideos:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray* searchList) {
            @strongify(self);
            NSArray *arr = [searchList mutableCopy];
            if (arr.count==0) {
                [self.parentVC toastAnimation:@"没有更多课程"];
            }else{
                [self.videosArr addObjectsFromArray:arr];
                [self.tableView reloadData];
            }
            [self.tableView.infiniteScrollingView stopAnimating];
            
        } error:^(NSError *error) {
            @strongify(self);
            if (error.code>=-1009&&error.code<=-1001) {
                @strongify(self);
                [self.parentVC toastAnimation:@"你的网络不给力"];
                
            }else{
                @strongify(self);
                [self.parentVC toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
            [self.tableView.infiniteScrollingView stopAnimating];
            
        } completed:^{
            NSLog(@"完成");
        }];
    }];
}


- (void)getDataFromNet{
    NSDictionary *paramas = @{
                              @"userId": CMTUSERINFO.userId ?:@"0",
                              };
    @weakify(self);
    [[[CMTCLIENT CMTGetUniverVediolist:paramas]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList *playParam) {
        @strongify(self);
        self.queryType = @"1";
        [self.focusArr removeAllObjects];
        [self.listCollegeArr removeAllObjects];
        [self.videosArr removeAllObjects];
        //焦点图数据
        self.focusArr = [playParam.focuslist mutableCopy];
        [self creatFocusView];
        //学科导航数据
        NSMutableArray *collArr = [playParam.colleges mutableCopy];
       
        self.listCollegeArr  = [collArr mutableCopy];
        [self creatCollegeGuideView:self.listCollegeArr];
        //推荐视频最多4个
        self.videosArr = [playParam.videos mutableCopy];
        if (self.collegeDataRequstHaveResponse) {
            [self.tableView reloadData];
            [self setContentState:CMTContentStateNormal];
        }else{
            self.collegeDataRequstHaveResponse = YES;
        }
       


       
        
        [_tableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-(self.tableView.height - self.tableHeaderView.height)/2 + 20)]];
        
    }error:^(NSError *error) {
        @strongify(self);
        self.collegeDataRequstHaveResponse = YES;
        [self setContentState:CMTContentStateReload];
        if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
            @strongify(self);
            [self toastAnimation:@"你的网络不给力"];
         }else{
             [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
    }];
    
}

- (void)getAdvertData{
    NSDictionary *paramas = @{
                              @"type":@"college",
                              };
    @weakify(self);
    [[[CMTCLIENT CMTGetAdvert:paramas]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList * list) {
        @strongify(self);
        if (list.advers.count > 0) {
            self.advertArr = [list.advers mutableCopy];

           
        }
        self.advertRequstHaveResponse = YES;
        
    } error:^(NSError *error) {
        self.advertRequstHaveResponse = YES;

        if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
            CMTLog(@"你的网络不给力");
        }else{
            CMTLog(@"%@",[error.userInfo objectForKey:@"errmsg"]);
            
        }
    }];
}

- (void)animationFlash{
    [super animationFlash];
    [self setContentState:CMTContentStateLoading];
    [self getDataFromNet];
}


//创建焦点图
- (void)creatFocusView{
    if (self.focusArr.count == 0) {
        self.collegeFocusView.hidden = YES;
        self.bannerplaceImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9/16);
        self.bannerplaceImageView.image = IMAGE(@"recordedDefaultimage");
        [self.tableHeaderView addSubview:self.bannerplaceImageView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollToLive)];
        [self.bannerplaceImageView addGestureRecognizer:tapGesture];
        self.tableHeaderView.size = CGSizeMake(SCREEN_WIDTH,SCREEN_WIDTH *9/16);
        self.tableView.tableHeaderView = self.tableHeaderView;
        return;
    }
    if (self.focusArr.count > 0) {
        self.collegeFocusView.hidden = NO;
        self.bannerplaceImageView.frame = CGRectZero;
        self.collegeFocusView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9/16);
        self.tableHeaderView.size = CGSizeMake(SCREEN_WIDTH,SCREEN_WIDTH *9/16);
        [self.tableHeaderView addSubview:self.collegeFocusView];
        self.tableView.tableHeaderView = self.tableHeaderView;
    }
    [[[RACObserve(self.collegeFocusView, initialization)ignore:@NO]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber * x) {
        if (x.integerValue == 1) {
            [self.collegeFocusView reloadData];
            if (self.focusPageShuffling == nil) {
                self.focusPageShuffling = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(foucePage_shuffling) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.focusPageShuffling forMode:NSRunLoopCommonModes];
            }
            self.collegeFocusView.initialization = NO;

        }
    }];
}

//创建学院导航图

- (void)creatCollegeGuideView:(NSMutableArray *)data{
    if ( data.count >= 10 || data.count == 5 || data.count == 9 ) {
        while ([self.collegeGuideBgView.subviews lastObject]) {
            [self.collegeGuideBgView.subviews.lastObject removeFromSuperview];
        }
        
        NSInteger time = floor(data.count/5);  NSInteger retain = data.count % 5 > 0;
        NSInteger heightCount = time + retain;
        self.collegeGuideBgView.frame = CGRectMake(0, self.tableHeaderView.height, SCREEN_WIDTH, 248/3 * XXXRATIO * heightCount);
        for (int i  = 0; i < data.count; i ++ ) {
            NSInteger a = i%5;
            NSInteger b = floor(i / 5);
            CMTListCollegeGuideView *guideView = [[CMTListCollegeGuideView alloc]initWithFrame:CGRectMake(a * SCREEN_WIDTH/5, b * 248/3 * XXXRATIO, SCREEN_WIDTH/5, 248/3 * XXXRATIO)];
            
            [self.collegeGuideBgView addSubview:guideView];
            
            CMTCollegeDetail *collegeDetail = data[i];
            guideView.guideButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            guideView.guideButton.clipsToBounds = YES;
            [guideView.guideButton sd_setBackgroundImageWithURL:[NSURL URLWithString:collegeDetail.picUrl] forState:UIControlStateNormal placeholderImage:IMAGE(@"placeholder_college_default")];
            guideView.guideButton.tag = 1000 + i;
            guideView.touchView.tag = 10000 + i;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(collegeDidSelectedGesture:)];
            [guideView.touchView addGestureRecognizer:tapGesture];
            guideView.guideLabel.textAlignment = NSTextAlignmentCenter;
            guideView.guideLabel.text = collegeDetail.collegeName;
            if ((i + 1)%5 == 0) {
                guideView.lineView.hidden = YES;
            }
            
        }
        [self.tableHeaderView addSubview:self.collegeGuideBgView];
        self.tableHeaderView.size = CGSizeMake(SCREEN_WIDTH, self.collegeGuideBgView.height + SCREEN_WIDTH * 9/16);
        self.tableView.tableHeaderView = self.tableHeaderView;
        return;
    }
    if (data.count ==4 || data.count == 7 || data.count == 8) {
        while ([self.collegeGuideBgView.subviews lastObject]) {
            [self.collegeGuideBgView.subviews.lastObject removeFromSuperview];
        }
        NSInteger time = floor(data.count/4);  NSInteger retain = data.count % 4 > 0;
        NSInteger heightCount = time + retain;
        self.collegeGuideBgView.frame = CGRectMake(0, self.tableHeaderView.height, SCREEN_WIDTH, 248/3 * XXXRATIO * heightCount);
        for (int i  = 0; i < data.count; i ++ ) {
            NSInteger a = i%4;

            NSInteger b = floor(i / 4);
            CMTListCollegeGuideView *guideView = [[CMTListCollegeGuideView alloc]initWithFrame:CGRectMake(a * SCREEN_WIDTH/4, b * 248/3 * XXXRATIO, SCREEN_WIDTH/4, 248/3 * XXXRATIO)];
           
            [self.collegeGuideBgView addSubview:guideView];
            
            CMTCollegeDetail *collegeDetail = data[i];
            guideView.guideButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            guideView.guideButton.clipsToBounds = YES;

            //
            [guideView.guideButton sd_setBackgroundImageWithURL:[NSURL URLWithString:collegeDetail.picUrl] forState:UIControlStateNormal placeholderImage:IMAGE(@"placeholder_college_default")];
            guideView.guideButton.tag = 1000 + i;
            guideView.touchView.tag = 10000 + i;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(collegeDidSelectedGesture:)];
            [guideView.touchView addGestureRecognizer:tapGesture];
            guideView.guideLabel.textAlignment = NSTextAlignmentCenter;
            guideView.guideLabel.text = collegeDetail.collegeName;
            if ((i + 1)%4 == 0) {
                guideView.lineView.hidden = YES;
            }
            
            
        }
        [self.tableHeaderView addSubview:self.collegeGuideBgView];
        self.tableHeaderView.size = CGSizeMake(SCREEN_WIDTH, self.collegeGuideBgView.height + SCREEN_WIDTH * 9/16);
        self.tableView.tableHeaderView = self.tableHeaderView;
        return;
        
        
    }
    
    if (data.count == 1 || data.count == 2 || data.count == 3 || data.count == 6) {
        while ([self.collegeGuideBgView.subviews lastObject]) {
            [self.collegeGuideBgView.subviews.lastObject removeFromSuperview];
        }
        NSInteger time = floor(data.count/3);  NSInteger retain = data.count % 3 > 0;
        NSInteger heightCount = time + retain;
        self.collegeGuideBgView.frame = CGRectMake(0, self.tableHeaderView.height, SCREEN_WIDTH, 248/3 * XXXRATIO * heightCount);
        for (int i  = 0; i < data.count; i ++ ) {
            NSInteger a = i%3;
            NSInteger b = floor(i / 3);
            CMTListCollegeGuideView *guideView = [[CMTListCollegeGuideView alloc]initWithFrame:CGRectMake(a * SCREEN_WIDTH/3, b * 248/3 * XXXRATIO, SCREEN_WIDTH/3, 248/3 * XXXRATIO)];
            [self.collegeGuideBgView addSubview:guideView];
            CMTCollegeDetail *collegeDetail = data[i];
            guideView.guideButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            guideView.guideButton.clipsToBounds = YES;
            //
            [guideView.guideButton sd_setBackgroundImageWithURL:[NSURL URLWithString:collegeDetail.picUrl] forState:UIControlStateNormal placeholderImage:IMAGE(@"placeholder_college_default")];
            guideView.guideButton.tag = 1000 + i;
            guideView.touchView.tag = 10000 + i;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(collegeDidSelectedGesture:)];
            [guideView.touchView addGestureRecognizer:tapGesture];
            guideView.guideLabel.textAlignment = NSTextAlignmentCenter;
            guideView.guideLabel.text = collegeDetail.collegeName;
            if ((i + 1)%3 == 0) {
                guideView.lineView.hidden = YES;
            }
            
        }
        [self.tableHeaderView addSubview:self.collegeGuideBgView];
        self.tableHeaderView.size = CGSizeMake(SCREEN_WIDTH, self.collegeGuideBgView.height + SCREEN_WIDTH * 9/16);
        self.tableView.tableHeaderView = self.tableHeaderView;
        return;
        
        
    }
    
    
}

#pragma 点击学院进入视频列表

- (void)collegeDidSelectedGesture:(UITapGestureRecognizer *)gesture{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if([self getNetworkReachabilityStatus].integerValue==0){
        
        [self.parentVC toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }
    NSDictionary *states=@{@"31":@"B_College_Surgery",
                           @"32":@"B_College_Intervention",
                           @"33":@"B_College_Humanities",
                           @"37":@"B_College_Oncology",
                           @"36":@"B_College_Circulation",
                           };
    
    CMTCollegeDetail *collegeDetail = self.listCollegeArr[gesture.view.tag - 10000];
    [MobClick event:[states objectForKey:collegeDetail.collegeId]];
    CmtMoreVideoViewController *collegeDetailVC = [[CmtMoreVideoViewController alloc]initWithCollege:collegeDetail type:CMTCollCollegeVideo];
    [self.parentVC.navigationController pushViewController:collegeDetailVC animated:YES];
}




//轮播图自动滚动计时器方法
- (void)foucePage_shuffling{
    [self.collegeFocusView CMT_shuffling_pic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return  cell.frame.size.height;

    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger z = floor(self.videosArr.count/2);
    NSInteger a = self.videosArr.count%2;
    return z + a;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
        if (self.videosArr.count == 0) {
            return 0;
        }else{
            return 160/3;
        }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160/3)];
    view.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = ColorWithHexStringIndex(c_f5f5f5);
    __block UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10 * XXXRATIO, 10, 250/3, 112/3 )];
    label.centerY = view.height/2;
    label.font = FONT(16);
    __block UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(SCREEN_WIDTH - 310/3, 10, 280/3, 90/3);
    button.centerY = view.height/2;
    button.titleLabel.font = FONT(14);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
  
    [view addSubview:lineView];
    [view addSubview:button];
    [view addSubview:label];
    
        if (self.videosArr.count == 0) {
            return nil;
        }
        label.textColor = ColorWithHexStringIndex(c_3CC6C1);
    

        [button addTarget:self action:@selector(switchNewOrHeat:) forControlEvents:UIControlEventTouchUpInside];
    [[RACObserve(self, queryType)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString * x) {
        if (x.integerValue == 1) {
            label.text = @"最新课程";
            button.layer.borderColor = [UIColor colorWithHexString:@"#e9ebee"].CGColor;
            button.backgroundColor = [UIColor colorWithHexString:@"#e9ebee"];
            [button setTitleColor:[UIColor colorWithHexString:@"#545659"] forState:UIControlStateNormal];
            [button setTitle:@"按热度排序" forState:UIControlStateNormal];
        }else{
            label.text = @"最热课程";
            
            button.layer.borderColor = ColorWithHexStringIndex(c_3CC6C1).CGColor;
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:ColorWithHexStringIndex(c_3CC6C1) forState:UIControlStateNormal];
            [button setTitle:@"√按热度排序" forState:UIControlStateNormal];
        }
        
    }];

    
    return view;
    
}

#pragma 全部视频事件
- (void)allVideosAction:(UIButton *)action{
    if([self getNetworkReachabilityStatus].integerValue==0){
        [self.parentVC toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }
    [MobClick event:@"B_College_All"];
    CmtMoreVideoViewController *moreVideoList = [[CmtMoreVideoViewController alloc]initWithType:CMTTAllRecommendedVideo];
    [self.parentVC.navigationController pushViewController:moreVideoList animated:YES];
}



- (void)getVediosDataSource{
    NSDictionary *paramas = @{
                              @"userId": CMTUSERINFO.userId ?:@"0",
                              @"queryType":self.queryType,
                              @"incrIdFlag":@"0"
                              };
    
    @weakify(self);
    [[[CMTCLIENT CMTQueryTypeVideos:paramas]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *VideoArray) {
        @strongify(self);
        [self.videosArr removeAllObjects];
        self.videosArr=[VideoArray mutableCopy];
        [self.tableView reloadData];
        [self setContentState:CMTContentStateNormal];
        
    } error:^(NSError *error) {
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001){
            @strongify(self);
            [self setContentState:CMTContentStateReload];
            [self toastAnimation:@"你的网络不给力"];
            
            
        }else{
            @strongify(self);
            [self setContentState:CMTContentStateReload];
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
        
        
    } completed:^{
        NSLog(@"完成");
    }];
}

#pragma --热度/最新排序
- (void)switchNewOrHeat:(UIButton *)action{
    if (self.queryType.integerValue == 1) {
        self.queryType = @"2";
    }else{
        self.queryType = @"1";
    }
    action.enabled = NO;
    NSDictionary *paramas = @{
                              @"userId": CMTUSERINFO.userId ?:@"0",
                              @"queryType":self.queryType,
                              @"incrIdFlag":@"0"
                              };
    
    @weakify(self);
    [[[CMTCLIENT CMTQueryTypeVideos:paramas]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *VideoArray) {
        @strongify(self);
        action.enabled = YES;
        [self.videosArr removeAllObjects];
        self.videosArr=[VideoArray mutableCopy];
        if (self.videosArr.count > 0) {
            for (int i = 0; i < self.advertArr.count; i ++ ) {
                CMTAdvert *advert = self.advertArr[i];
                //位置须为偶数且插入位置包含在数组中
                if (self.videosArr.count - 1 > advert.position.integerValue && advert.position.integerValue%2 == 0) {
                    [self.videosArr insertObject:advert atIndex:(advert.position.integerValue + i * 2)];
                    [self.videosArr insertObject:advert atIndex:(advert.position.integerValue + i * 2 + 1)];
                }
            }
        }
        [self.tableView reloadData];
        [self setContentState:CMTContentStateNormal];
        
    } error:^(NSError *error) {
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001){
            @strongify(self);
            [self setContentState:CMTContentStateReload];
            [self toastAnimation:@"你的网络不给力"];
            
            
        }else{
            @strongify(self);
            [self setContentState:CMTContentStateReload];
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
        
        
    } completed:^{
        NSLog(@"完成");
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTLivesRecord *model;
    CMTLivesRecord *model1;
    CMTAdvert *amodel;
    CMTAdvert *amodel1;
    if (indexPath.row * 2 + 1 <= self.videosArr.count) {
        if ([self.videosArr[indexPath.row * 2] isKindOfClass:[CMTLivesRecord  class]]){
            model = self.videosArr[indexPath.row * 2];
        }else{
            amodel = self.videosArr[indexPath.row * 2];
        }
    }
    if (indexPath.row * 2 + 2 <= self.videosArr.count) {
        if ([self.videosArr[indexPath.row * 2] isKindOfClass:[CMTLivesRecord  class]]){
            model1 = self.videosArr[indexPath.row * 2 + 1];
        }else{
            amodel1 = self.videosArr[indexPath.row * 2 + 1];
        }
    }
    NSMutableArray *modelarr = [NSMutableArray array];
    if (model!=nil) {
        [modelarr addObject:model];
    }
    if (model1!=nil) {
        [modelarr addObject:model1];
    }
    if (amodel!=nil) {
        [modelarr addObject:amodel];
    }
    if (amodel!=nil) {
        [modelarr addObject:amodel1];
    }
    if ([modelarr[0] isKindOfClass:[CMTLivesRecord class]]) {
        CMTCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMTCourseCell"];
        if(cell==nil){
            cell=[[CMTCourseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CMTCourseCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell reloadCellWithData:modelarr];
        return cell;
    }else{
        CMTAdvertCell*cell = [tableView dequeueReusableCellWithIdentifier:@"CMTAdvertCell"];
        if(cell==nil){
            cell=[[CMTAdvertCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CMTAdvertCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell reloadCellWithModel:modelarr[0]];
        return cell;
    }
}

#pragma mark__广告点击代理
- (void)didSelectAdvert:(CMTAdvert *)advert{
    if (advert.jumpLinks.length > 0) {
        BOOL flag=[advert.jumpLinks handleWithinArticle:advert.jumpLinks viewController:self.parentVC];
        if(flag){
            CMTWebBrowserViewController *web=[[CMTWebBrowserViewController alloc]initWithURL:advert.jumpLinks];
            [self.parentVC.navigationController pushViewController:web animated:YES];
        }
    }
    
    NSDictionary *params = @{
                             @"adverId":advert.adverId
                             };
    [[[CMTCLIENT GetAdClickStatistics:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        CMTLog(@"统计失败");
    }];
   
}


#pragma seriousCellDelegate 系列课程cell点击事件回调
- (void)didSelecteVideo:(CMTLivesRecord*)Record{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if([self getNetworkReachabilityStatus].integerValue==0){
        
        [self.parentVC toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }else{
        if(Record.themeInfo.themeUuid.length>0){
            CMTSeriesDetails *seriesDetails=[[CMTSeriesDetails alloc]init];
            seriesDetails.themeUuid=Record.themeInfo.themeUuid;
            CMTSeriesDetailsViewController *series=[[CMTSeriesDetailsViewController alloc]initWithParam:seriesDetails];
            @weakify(self);
            [series setUpdatevideoList:^(NSString *themUuid) {
                @strongify(self);
                Record.themeInfo.themeUuid = @"";
                [self.tableView reloadData];
            }];
            [self.parentVC.navigationController pushViewController:series animated:YES];
            return;
        }
        if (Record.type.integerValue==1) {
            CMTLightVideoViewController *lightVideoViewController = [[CMTLightVideoViewController alloc]init];
            //  播放网络
            lightVideoViewController.myliveParam = Record;
            @weakify(self);
            lightVideoViewController.updateReadNumber=^(CMTLivesRecord *record){
                @strongify(self);
                if (record==nil) {
                    [self setContentState:CMTContentStateLoading];
                    self.collegeDataRequstHaveResponse = NO;
                    [self getDataFromNet];
                }else{
                    Record.users=record.users;
                    [self.tableView reloadData];
                }
                
            };
            [self.parentVC.navigationController pushViewController:lightVideoViewController animated:YES];
            
        }else{
            CMTRecordedViewController *recordView=[[CMTRecordedViewController alloc]initWithRecordedParam:[Record copy]];
            @weakify(self)
            recordView.updateReadNumber=^(CMTLivesRecord *record){
                @strongify(self);
                if (record==nil) {
                    [self setContentState:CMTContentStateLoading];
                    self.collegeDataRequstHaveResponse = NO;
                    [self getDataFromNet];
                }else{
                    Record.users=record.users;
                    [self.tableView reloadData];
                }
                
            };
            [self.parentVC.navigationController pushViewController:recordView animated:YES];
            
        }
    }


}

#pragma CMTCollegeFocusViewDelegate
- (NSUInteger)numberOfFocusInFocusPageView:(CMTCollegeFocusView *)focusPageView{
    return self.focusArr.count;
}
- (CMTSeriesDetails *)focusPageView:(CMTCollegeFocusView *)focusPageView focusAtIndex:(NSUInteger)index{
    CMTSeriesDetails *focus = self.focusArr[index];
    return focus;
}

#pragma 焦点图系列课程点击事件
- (void)focusPageView:(CMTCollegeFocusView *)focusPageView didSelectFocusAtIndex:(NSInteger)index{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    if([self getNetworkReachabilityStatus].integerValue==0){
        [self.parentVC toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }
    CMTSeriesDetails *focus = self.focusArr[index];
    CMTSeriesDetailsViewController *det=[[CMTSeriesDetailsViewController alloc]initWithParam:[self.focusArr[index] copy]];
    if (focus.type.integerValue == 2) {
        [MobClick event:@"B_LiveList_Notice"];
        [[RACScheduler mainThreadScheduler] afterDelay:0.3 schedule:^{
            [self.parentVC.switchCustomScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
        }];
        return;
    }else{
        [self.parentVC.navigationController pushViewController:det animated:YES];
    }
}

-(void)scrollToLive{
    [MobClick event:@"B_LiveList_Notice"];
    [[RACScheduler mainThreadScheduler] afterDelay:0.3 schedule:^{
        [self.parentVC.switchCustomScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
    }];

}
@end
