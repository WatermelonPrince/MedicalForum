//
//  UniversityViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/5/31.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTUniversityViewController.h"
#import "TimeCell.h"
#import "BaseTableViewCell.h"
#import "CMTTabBar.h"
#import "LightVideolistCell.h"
#import "CMTClient+getCMTPlayParam.h"
#import "LiveVideoPlayViewController.h"
#import "CMTLightVideoViewController.h"
#import "UITableView+CMTExtension_PlaceholderView.h"
@interface CMTUniversityViewController ()<UITableViewDataSource,UITableViewDelegate,VodDownLoadDelegate>
@property (nonatomic, strong) CMTTabBar *bottomTabBar; //底部导航条按钮
@property (nonatomic, strong) UITableView    *m_tableView;
@property (nonatomic, strong) NSMutableArray  *livesArray;
@property (nonatomic, strong) NSTimer        *m_timer;
@property (nonatomic, copy)NSString *currentDate;
@property (nonatomic, copy)NSString *classRoomId;
@property (nonatomic, strong) CMTLivesRecord *record;
@property(nonatomic,strong)NSIndexPath *registrationRecord;//记录报名的cell位置 防止由于登陆导致报名数据丢失
@end

@implementation CMTUniversityViewController



- (CMTTabBar *)bottomTabBar {
    if (_bottomTabBar == nil) {
        _bottomTabBar = [[CMTTabBar alloc] init];
        [_bottomTabBar fillinContainer:self.tabBarContainer WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        _bottomTabBar.backgroundColor = COLOR(c_clear);
        self.tabBarContainer.hidden = NO;
    }
    return _bottomTabBar;
}

- (NSMutableArray *)livesArray{
    if (!_livesArray) {
        _livesArray = [NSMutableArray array];
    }
    return _livesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.registrationRecord=nil;
    [self initTableView];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"University willDeallocSignal");
    }];
    //跳立方
    [self setContentState:CMTContentStateLoading];
    [self getUniverCityList];
    [self CMTnfIniteRefresh];
    [self CMTPullToRefresh];
    
    @weakify(self);
    [[RACSignal merge:@[[CMTUSER loginSignal] ?: [RACSignal empty],
                        [CMTUSER logoutSignal] ?: [RACSignal empty]
                        ]]
     subscribeNext:^(id x) {
         @strongify(self);
         [self setContentState:CMTContentStateLoading];
         if (!CMTUSER.login) {
              self.registrationRecord=nil;
         }
         [self getUniverCityList];
     }];
    [[[[RACObserve(CMTAPPCONFIG, isrefreshLivelist) distinctUntilChanged]ignore:@"0"] deliverOn:[RACScheduler  mainThreadScheduler]]subscribeNext:^(id x) {
        [self setContentState:CMTContentStateLoading];
        if(self.livesArray.count>0){
           [self getUniverCityList];
        }
        CMTAPPCONFIG.isrefreshLivelist=@"0";
    } error:^(NSError *error) {
        NSLog(@"刷新失败") ;
        
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AppDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)AppDidBecomeActive{
    if (CMTAPPCONFIG.isrefreshPlayAndRecord) {
            [self setContentState:CMTContentStateLoading];
            [self getUniverCityList];
            CMTAPPCONFIG.isrefreshPlayAndRecord=NO;
    }
}

- (void)animationFlash {
    [super animationFlash];
    [self getUniverCityList];
}
- (UIView *)tableViewPlaceholderView {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,self.m_tableView.width, 100.0)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, placeholderView.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(17.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text =@"一大波课程即将来袭，敬请期待";
    
    [placeholderView addSubview:placeholderLabel];
    
    
    return placeholderView;
}


//初次加载
- (void)getUniverCityList{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           
                           };
    @weakify(self);
    [[[CMTCLIENT getCMTPlayParam:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList *playParam) {
        @strongify(self);
        self.registrationRecord=nil;
        [self.livesArray removeAllObjects];
        CMTPlayAndRecordList *receivePlayParam = playParam;
        self.currentDate = playParam.sysDate;
        if (receivePlayParam.lives.count > 0) {
            self.livesArray = [receivePlayParam.lives mutableCopy];
        }
        [self.m_tableView reloadData];
        [self setContentState:CMTContentStateNormal];
    }error:^(NSError *error) {
         [self setContentState:CMTContentStateReload];
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"无法连接到网络，请检查网络设置"];
        }else{
            [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
        }
        
        [self stopAnimation];
    }];
}


//下拉刷新
-(void)CMTPullToRefresh{
    @weakify(self);
    [self.m_tableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        NSDictionary *param = @{
                                @"userId":CMTUSER.userInfo.userId?:@"0",
                                };
        @weakify(self);
        [[[CMTCLIENT getCMTPlayParamIsNew:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord* x) {
            @strongify(self);
            if (x.flag.integerValue == 0) {
                self.currentDate = x.sysDate;
                [self.m_tableView reloadData];
                [self toastAnimation:@"没有最新视频"];
                 [self.m_tableView.pullToRefreshView stopAnimating];
            }else{
                NSDictionary *parameters = @{
                                             @"userId":CMTUSER.userInfo.userId?:@"0",
                                             @"pageSize":@"30",
                                             };
                @weakify(self);
                [[[CMTCLIENT getCMTPlayParam:parameters]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList * playParam) {
                    @strongify(self);
                    self.registrationRecord=nil;
                    CMTPlayAndRecordList *receivePlayParam = playParam;
                    self.currentDate = playParam.sysDate;
                    [self.livesArray removeAllObjects];
                    if (receivePlayParam.lives.count > 0) {
                        self.livesArray = [receivePlayParam.lives mutableCopy];
                    }
                    [self.m_tableView reloadData];
                    [self toastAnimation:@"视频更新完毕"];
                    [self.m_tableView.pullToRefreshView stopAnimating];
                    
                } error:^(NSError *error) {
                    @strongify(self);
                    if (error.code>=-1009&&error.code<=-1001) {
                        [self toastAnimation:@"无法连接到网络，请检查网络设置"];
                    }else{
                        [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
                    }
                    [self.m_tableView.pullToRefreshView stopAnimating];
                    
                }];
            }
            
            
        } error:^(NSError *error) {
            @strongify(self);
            if (error.code>=-1009&&error.code<=-1001) {
                [self toastAnimation:@"无法连接到网络，请检查网络设置"];
            }else{
                [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            }
            [self.m_tableView.pullToRefreshView stopAnimating];
            
        }];
        
    }];
}

//上拉加载
-(void)CMTnfIniteRefresh{
    @weakify(self);
    [self.m_tableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        NSString *pageoffset;
        if (self.livesArray.count == 0) {
            pageoffset = @"0";
        }else{
            CMTLivesRecord *record = [self.livesArray lastObject];
            pageoffset = record.pageOffset;
        }
        NSDictionary *params = @{
                                 @"userId": CMTUSERINFO.userId ?: @"0",
                                 @"pageSize": @"30",
                                 @"pageOffset":pageoffset,
                                 @"incrIdFlag":@"1",
                                 
                                 };
        [[[CMTCLIENT getCMTPlayParam:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList * playParam) {
               @strongify(self);
              CMTPlayAndRecordList *receivePlayParam = playParam;
            if (receivePlayParam.lives.count > 0) {
                self.currentDate = receivePlayParam.sysDate;
                NSMutableArray *refreshRecordArray = [receivePlayParam.lives mutableCopy];
                [self.livesArray addObjectsFromArray:refreshRecordArray];
            }
            if (receivePlayParam.lives.count == 0) {
                [self toastAnimation:@"没有更多视频"];
            }
            [self.m_tableView reloadData];
            [self.m_tableView.infiniteScrollingView stopAnimating];
            
        } error:^(NSError *error) {
            @strongify(self);
            if (error.code>=-1009&&error.code<=-1001) {
                [self toastAnimation:@"无法连接到网络，请检查网络设置"];
            }else{
                [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            }
            [self.m_tableView.infiniteScrollingView stopAnimating];
            
        }];
        
    }];
}

#pragma mark - TableView

- (void)initTableView {
    
    self.m_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64,SCREEN_WIDTH, SCREEN_HEIGHT - 64 - CMTTabBarHeight) style:UITableViewStylePlain];
    _m_tableView.delegate       = self;
    _m_tableView.dataSource     = self;
    _m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_m_tableView registerClass:[TimeCell class] forCellReuseIdentifier:TIME_CELL];
    [_m_tableView registerClass:[LightVideolistCell class] forCellReuseIdentifier:LIGHTVIDEOLISTCELL];
    _m_tableView.placeholderView=[self tableViewPlaceholderView];
    [_m_tableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-self.m_tableView.height/2+50)]];
    [self.contentBaseView addSubview:_m_tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

        return self.livesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
       CMTLivesRecord * model = self.livesArray[indexPath.row];
       if (self.registrationRecord!=nil) {
          if ([indexPath isEqual:self.registrationRecord]) {
               model.isJoin=@"0";
           }
        }
    
       TimeCell *cell = [tableView dequeueReusableCellWithIdentifier:TIME_CELL];
        [cell loadData:model indexPath:indexPath currentDate:self.currentDate];
        [cell.m_registrationButton addTarget:self action:@selector(registrationOrCancle:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        return SCREEN_WIDTH * 9/16 + 200/3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
      [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if([self getNetworkReachabilityStatus].integerValue==0){
        
        [self.parentVC toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }else if ([self getNetworkReachabilityStatus].integerValue==1) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看课程" message:nil delegate:nil
                                           cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
        @weakify(self)
        [[[alert rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if ([index integerValue] == 1) {
                    CMTLivesRecord *liveLivesRecord=self.livesArray[indexPath.row];
                    LiveVideoPlayViewController *live=[[LiveVideoPlayViewController alloc]initWithParam:[liveLivesRecord copy]];
                    live.networkReachabilityStatus =[self.parentVC getNetworkReachabilityStatus];

                    @weakify(self);
                    live.updateLiveList=^(CMTLivesRecord* liveRec){
                        @strongify(self);
                        if (liveRec==nil||![liveLivesRecord.startDate isEqualToString:liveRec.startDate]) {
                            [self setContentState:CMTContentStateLoading];
                            [self getUniverCityList];
                        }else{
                            self.registrationRecord=indexPath;
                            liveLivesRecord.isJoin=liveRec.isJoin;
                            liveLivesRecord.sysDate=liveRec.sysDate;
                            liveLivesRecord.startDate=liveRec.startDate;
                            liveLivesRecord.endDate=liveRec.endDate;
                            self.currentDate=liveRec.sysDate;
                            [tableView reloadData];
                        }
                    };
                    [self.parentVC.navigationController pushViewController:live animated:YES];
                    
                }
        }];
        [alert show];
        
    }else{
            CMTLivesRecord *liveLivesRecord=self.livesArray[indexPath.row];
            LiveVideoPlayViewController *live=[[LiveVideoPlayViewController alloc]initWithParam:[liveLivesRecord copy]];
             live.networkReachabilityStatus =[self.parentVC getNetworkReachabilityStatus];
            @weakify(self);
            live.updateLiveList=^(CMTLivesRecord* liveRec){
                @strongify(self);
                if (liveRec==nil||![liveLivesRecord.startDate isEqualToString:liveRec.startDate]) {
                    [self setContentState:CMTContentStateLoading];
                    [self getUniverCityList];
                }else{
                    if(![liveLivesRecord.isJoin isEqualToString:liveRec.isJoin]){
                        self.registrationRecord=indexPath;
                        liveLivesRecord.isJoin=liveRec.isJoin;
                    }else{
                        self.registrationRecord=nil;
                    }
                    liveLivesRecord.sysDate=liveRec.sysDate;
                    self.currentDate=liveRec.sysDate;
                    liveLivesRecord.startDate=liveRec.startDate;
                    liveLivesRecord.endDate=liveRec.endDate;
                    [tableView reloadData];
                }
            };
            [self.parentVC.navigationController pushViewController:live animated:YES];
        
    }
    
}


//报名或者取消报名
- (void)registrationOrCancle:(UIButton *)button{
       @weakify(self);
    if (!CMTUSER.login) {
        CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
        [self.parentVC.navigationController pushViewController:bing animated:YES];
        return;
    }
    NSInteger index = button.tag - 1000;
    self.registrationRecord= [NSIndexPath indexPathForRow:index inSection:0];
    CMTLivesRecord *record = self.livesArray[index];
    self.classRoomId = record.classRoomId;
    if ([button.currentTitle isEqualToString:@"点击报名"]) {
        
        NSDictionary *params = @{
                                 @"userId" : CMTUSERINFO.userId?:@"0",
                                 @"classRoomId": self.classRoomId?:@"0",
                                 @"flag":@"0",
                                 };
        [[[CMTCLIENT getCMTPlayRegistStatus:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *x) {
            [button setTitle:@"" forState:UIControlStateNormal];
            [button setBackgroundImage:IMAGE(@"registedImage") forState:UIControlStateNormal];
            record.isJoin =x.isJoin;
            record.sysDate=x.sysDate;
            self.currentDate=x.sysDate;
            [button setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
            button.layer.borderWidth = 1;
            button.layer.borderColor = COLOR(c_32c7c2).CGColor;
            button.backgroundColor = [UIColor clearColor];
            [self.m_tableView reloadData];
            [self toastAnimation:@"报名成功"];

        } error:^(NSError *error) {
            @strongify(self);
            if (error.code>=-1009&&error.code<=-1001) {
                [self toastAnimation:@"无法连接到网络，请检查网络设置"];
            }else{
                [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            }

        }];
    }else{

        
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
