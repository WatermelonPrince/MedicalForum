//
//  CmtMoreSeriesVideoViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/27.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CmtMoreVideoViewController.h"
#import "CMTLightVideoViewController.h"
#import "CMTRecordedViewController.h"
#import "CMTLiveShareView.h"
#import "CMTCourseCell.h"
#import "CMTScreeningButton.h"
#import "CMTScreeningControlView.h"
#import "CMTSeriesDetailsViewController.h"
#import "CMTSeriousListViewCell.h"
#import "CMTAdvertCell.h"
#import "CMTWebBrowserViewController.h"
@interface CmtMoreVideoViewController ()<UITableViewDelegate,UITableViewDataSource,CMTVedioCellDelegate,CMTAdvertCellDelegate>{
    BOOL isfristload;
    NSString *oldqueryType;
    NSString *oldclassType;
}
@property(nonatomic,assign)CMTOptionType optiomType;//操作类型
@property(nonatomic,strong)CMTSeriesNavigation *mynavigation;//系列名称
@property(nonatomic,strong)UITableView *dataTableView;
@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)CMTCollegeDetail *myCollege;
@property (nonatomic, strong)UIButton *shareItem;  // 分享按钮
@property(nonatomic,strong)CMTLiveShareView *LiveShareView;//分享视图
@property(nonatomic,strong)UIView *CollegeHeadView;
@property(nonatomic,strong)NSString *queryType;//排序类型
@property(nonatomic,strong)NSString *assortmentId;//分类ID
@property(nonatomic,strong)UIView *bgView;//弹出筛选的背景遮罩
@property(nonatomic,strong)CMTScreeningControlView *ScreeningControl;
@property(nonatomic,strong)UILabel *tipsLable;//提示语
@property(nonatomic,strong)UIImageView *headimageView;
@property(nonatomic,strong)NSString *classType;
@property (nonatomic, assign)BOOL advertRequstHaveResponse;//广告请求有回应
@property (nonatomic, assign)BOOL dataRequstHaveResponse;//数据请求有回应
@property (nonatomic, assign)BOOL isReloadDate;//是否刷新数据
@property (nonatomic, strong)NSMutableArray *advertArr;//广告数组
@property (nonatomic, assign)BOOL advertShow;




@end

@implementation CmtMoreVideoViewController

- (NSMutableArray *)advertArr{
    if (!_advertArr) {
        _advertArr = [NSMutableArray array];
    }
    return _advertArr;
}
-(UIView*)CollegeHeadView{
    if(_CollegeHeadView==nil){
        _CollegeHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 130*XXXRATIO+1)];
        _CollegeHeadView.tag=1000000;
        self.headimageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 130*XXXRATIO)];
        self.headimageView.contentMode=UIViewContentModeScaleAspectFill;
        self.headimageView.clipsToBounds=YES;
        self.headimageView.tag=1000;
        [self.headimageView setImageURL:self.myCollege.collgeNewHeadPicUrl placeholderImage:IMAGE(@"Placeholderdefault")contentSize:self.headimageView.size];
        [_CollegeHeadView addSubview:self.headimageView];
        UIButton *backbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 20, 40, 30)];
        [backbutton setImage:IMAGE(@"collegeBackimage") forState:UIControlStateNormal];
        [backbutton addTarget:self action:@selector(gotolastContoller) forControlEvents:UIControlEventTouchUpInside];
        [_CollegeHeadView addSubview:backbutton];
        self.shareItem=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-40, 20, 40, 30)];
        [self.shareItem setImage:IMAGE(@"collegeShareimage") forState:UIControlStateNormal];
        [_CollegeHeadView addSubview:self.shareItem];
        [self.contentBaseView addSubview:_CollegeHeadView];
    }
    return _CollegeHeadView;
}
-(UILabel*)tipsLable{
    if (_tipsLable==nil) {
        _tipsLable=[[UILabel alloc]initWithFrame:CGRectMake(0,130+(SCREEN_HEIGHT-60-130)/2, SCREEN_WIDTH, 60)];
        _tipsLable.text=[self PlaceholderText];
        _tipsLable.textAlignment=NSTextAlignmentCenter;
        _tipsLable.textColor=COLOR(c_d2d2d2);
        _tipsLable.font=[UIFont systemFontOfSize:16*XXXRATIO];
        _tipsLable.hidden=YES;
    }
    return _tipsLable;
    
}
#pragma  设置是否显示提示语句
-(void)settipsContent{
    self.tipsLable.hidden=self.dataSource.count>0;
    if(self.optiomType==CMTCollCollegeVideo){
         self.tipsLable.frame=CGRectMake(0,(self.dataTableView.height-50*XXXRATIO)/2, self.tipsLable.width, self.tipsLable.height);
    }else{
        self.tipsLable.frame=CGRectMake(0,self.dataTableView.height/2, self.tipsLable.width, self.tipsLable.height);
    }
   
    
}

-(void)gotolastContoller{
    [self cancelFilterdView];
    [self.navigationController popViewControllerAnimated:YES];
}
-(instancetype)initWithType:(CMTOptionType)option{
    self=[super init];
    if (self) {
        self.optiomType=option;
    }
    return self;
}

-(instancetype)initWithSeresParam:(CMTSeriesNavigation*)navgation type:(CMTOptionType)option{
    self=[super init];
    if (self) {
        self.optiomType=option;
        self.mynavigation=navgation;
        isfristload=YES;
    }
    return self;
}
-(instancetype)initWithCollege:(CMTCollegeDetail*)College type:(CMTOptionType)option{
    self=[super init];
    if (self) {
        self.optiomType=option;
        self.myCollege=College;
        isfristload=YES;
    }
    return self;
}

-(UITableView*)dataTableView{
    if (_dataTableView==nil) {
        _dataTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide) style:UITableViewStylePlain];
        _dataTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _dataTableView.dataSource=self;
        _dataTableView.delegate=self;
        _dataTableView.allowsSelection=NO;
        _dataTableView.backgroundColor=COLOR(c_ffffff);
        [_dataTableView addSubview:self.tipsLable];
        if(self.optiomType==CMTCollCollegeVideo){
         [_dataTableView.panGestureRecognizer addTarget:self action:@selector(dataTableViewPan:)];
        }
        [self.contentBaseView addSubview:_dataTableView];
    }
    return _dataTableView;
}
-(void)dataTableViewPan:(UIPanGestureRecognizer*)pan{
    CGPoint point=[pan translationInView:self.dataTableView];
    if(point.y==0.000000){
        return;
    }
    if(point.y>0.000000){
        if(self.dataTableView.top==20){
         [UIView animateWithDuration:0.1 animations:^{
             self.dataTableView.top=self.CollegeHeadView.height;
             self.dataTableView.height=SCREEN_HEIGHT-self.CollegeHeadView.height;
         } completion:^(BOOL finished) {
          }];
        }
    }else{
        if(self.dataTableView.top!=20){
          [UIView animateWithDuration:0.1 animations:^{
            self.dataTableView.top=20;
            self.dataTableView.height=SCREEN_HEIGHT-20;
            [self.contentBaseView bringSubviewToFront:self.dataTableView];
          }completion:^(BOOL finished) {
              
          }];
        }
    }
}
-(NSString*)PlaceholderText{
    if (self.optiomType==CMTCollCollegeVideo) {
        return @"一大波课程即将来袭，敬请期待";
    }
    return @"没有课程存在";
}
#pragma mark 获取学院详情
-(void)getCollegeDeteil{
    NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                          @"collegeId":self.myCollege.collegeId?:@"0",
                        };
    @weakify(self);
    [[[CMTCLIENT CMTGetCollegeDetails:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTCollegeDetail *College) {
        @strongify(self);
        self.myCollege=College;
        [((UIImageView*)[self.CollegeHeadView viewWithTag:1000]) setImageURL:self.myCollege.collgeNewHeadPicUrl placeholderImage:IMAGE(@"Placeholderdefault")  contentSize:[self.CollegeHeadView viewWithTag:1000].size];
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        
    } completed:^{
        NSLog(@"完成");
    }];

    
}
#pragma mark 获取列表数据
-(void)getDataSource{
    NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                          @"pageOffset":@"0",
                          @"pageSize":@"30",
                          @"themeUuid":self.mynavigation.themeUuid?:@"0",
                          @"navigationId":self.mynavigation.navigationId?:@"0",
                          @"collegeId":self.myCollege.collegeId?:@"0",
                          @"incrIdFlag":@"0",
                          @"queryType":self.queryType,
                          @"assortmentId":self.assortmentId,
                          };
    @weakify(self);
    [[(self.classType.integerValue==0?[CMTCLIENT CMTGetmoreVideo:param]:[CMTCLIENT CMTColledgeSeriesSelectList:param])deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *VideoArray) {
        @strongify(self);
        
                oldqueryType=self.queryType;
        oldclassType=self.classType;
        [self.dataSource removeAllObjects];
        self.dataSource=[VideoArray mutableCopy];
        self.dataTableView.allowsSelection=self.classType.integerValue==1;
        [self settipsContent];
        [self.dataTableView.infiniteScrollingView stopAnimating];
        if (self.advertShow) {
            for (int i = 0; i < self.advertArr.count; i ++ ) {
                CMTAdvert *advert = self.advertArr[i];
                //位置须为偶数且插入位置包含在数组中
                if (self.dataSource.count - 1 > advert.position.integerValue && advert.position.integerValue%2 == 0 ) {
                    [self.dataSource insertObject:advert atIndex:(advert.position.integerValue + i * 2)];
                    [self.dataSource insertObject:advert atIndex:(advert.position.integerValue + i * 2 + 1)];
                }
            }
            self.advertShow = NO;
        }
        if (self.dataRequstHaveResponse) {
            [self.dataTableView reloadData];
            [self setContentState:CMTContentStateNormal];
        }else{
            self.dataRequstHaveResponse = YES;
        }

        isfristload=NO;
        if(self.optiomType==CMTCollCollegeVideo){
          if([self.contentBaseView viewWithTag:1000000]==nil){
            [self.CollegeHeadView removeFromSuperview];
            [self.contentBaseView addSubview:self.CollegeHeadView];
            }
        }

    } error:^(NSError *error) {
          @strongify(self);
        self.dataRequstHaveResponse = YES;
        NSString *errorString=[error.userInfo objectForKey:@"errmsg"];
        if (error.code>=-1009&&error.code<=-1001){
           errorString=@"你的网络不给力";
        }
        [self toastAnimation:errorString];
        if(isfristload){
             [self setContentState:CMTContentStateReload];
            if(self.optiomType==CMTCollCollegeVideo){
                [self.CollegeHeadView removeFromSuperview];
                [self.view addSubview:self.CollegeHeadView];
                self.mReloadImgView.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT-self.CollegeHeadView.height)/2);
                self.mLbupload.centerX = self.view.centerX;
                self.mLbupload.centerY = self.mReloadImgView.centerY + self.mReloadImgView.frame.size.height/2+13+self.mLbupload.frame.size.height/2;

            }
           
        }else{
            [self setContentState:CMTContentStateNormal];
            self.queryType=oldqueryType;
            self.classType=oldclassType;
            [self.dataTableView reloadData];
        }

        
    } completed:^{
        NSLog(@"完成");
    }];
}

#pragma mark__广告请求
- (void)getAdvertData{
    NSDictionary *paramas = @{
                              @"type":@"academy",
                              @"pageId":self.myCollege.collegeId?:@"",
                              @"pageName":self.myCollege.collegeName?:@"",
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
#pragma mark 改变列表坐标
-(void)ChangeListOfCoordinates{
    if (self.optiomType==CMTCollCollegeVideo) {
        [self.dataTableView setContentOffset:CGPointMake(0, 0)];
        if (self.dataTableView.top==20) {
            self.dataTableView.top=self.CollegeHeadView.height;
            self.dataTableView.height=SCREEN_HEIGHT-self.CollegeHeadView.height;
        }
    }

}
#pragma mark 下拉刷新
-(void)CMTmoreVideoPullIniteRefresh{
    @weakify(self);
    [self.dataTableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTLivesRecord *Record=[[CMTLivesRecord alloc]init];
        Record.pageOffset=@"0";
        if(self.dataSource.count>0){
            Record=self.dataSource.firstObject;
        }
        CMTSeriesDetails *SeriesRecord=nil;
        if(self.classType.integerValue==1){
           SeriesRecord=[[CMTSeriesDetails alloc]init];
            SeriesRecord.pageOffset=@"0";
            if(self.dataSource.count>0){
                SeriesRecord=self.dataSource.firstObject;
            }

        }
        NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                              @"pageOffset":self.classType.integerValue==0?Record.pageOffset:SeriesRecord.pageOffset,
                              @"pageSize":@"30",
                              @"themeUuid":self.mynavigation.themeUuid?:@"0",
                              @"navigationId":self.mynavigation.navigationId?:@"0",
                              @"collegeId":self.myCollege.collegeId?:@"0",
                              @"incrIdFlag":@"0",
                              @"queryType":self.queryType,
                              @"assortmentId":self.assortmentId,
                              };
        @weakify(self);
        [[(self.classType.integerValue==0?[CMTCLIENT CMTGetmoreVideo:param]:[CMTCLIENT CMTColledgeSeriesSelectList:param]) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *VideoArray) {
            @strongify(self);
            if (VideoArray.count==0) {
                [self toastAnimation:@"没有最新课程"];
            }else{
                if(self.updateseriesContent!=nil){
                    self.updateseriesContent(self.mynavigation);
                }
                NSMutableArray *array=[NSMutableArray arrayWithArray:VideoArray];
                [array addObjectsFromArray:[self.dataSource copy]];
                self.dataSource=array;
                //去掉数组中已存广告
                for (NSInteger i = self.dataSource.count; i > 0; i--) {
                    
                    if ([self.dataSource[i - 1] isKindOfClass:[CMTAdvert class]]) {
                        [self.dataSource removeObject:self.dataSource[i - 1]];
                    }
                }
                //重新添加广告
                for (int i = 0; i < self.advertArr.count; i ++ ) {
                    CMTAdvert *advert = self.advertArr[i];
                    //位置须为偶数且插入位置包含在数组中
                    if (self.dataSource.count - 1 > advert.position.integerValue && advert.position.integerValue%2 == 0 ) {
                        [self.dataSource insertObject:advert atIndex:(advert.position.integerValue + i * 2)];
                        [self.dataSource insertObject:advert atIndex:(advert.position.integerValue + i * 2 + 1)];
                    }
                }

                [self.dataTableView reloadData];
            }
             [self settipsContent];
            [self.dataTableView.pullToRefreshView stopAnimating];
            
        } error:^(NSError *error) {
            @strongify(self);
            if (error.code>=-1009&&error.code<=-1001){
                @strongify(self);
                [self toastAnimation:@"你的网络不给力"];
                
            }else{
                @strongify(self);
                [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
            [self.dataTableView.pullToRefreshView stopAnimating];
            
        } completed:^{
            NSLog(@"完成");
        }];
    }];
}

#pragma mark 上拉翻页
-(void)CMTmoreVideoInfIniteRefresh{
    @weakify(self);
[self.dataTableView addInfiniteScrollingWithActionHandler:^{
    @strongify(self);
    if (self.dataSource.count<30) {
        [self toastAnimation:@"没有更多课程"];
        [self.dataTableView.infiniteScrollingView stopAnimating];
        return ;
    }
    CMTLivesRecord *Record=[[CMTLivesRecord alloc]init];
    Record.pageOffset=@"0";
    if(self.dataSource.count>0){
        Record=self.dataSource.lastObject;
    }
    CMTSeriesDetails *SeriesRecord=nil;
    if(self.classType.integerValue==1){
       SeriesRecord=[[CMTSeriesDetails alloc]init];
        SeriesRecord.pageOffset=@"0";
        if(self.dataSource.count>0){
            SeriesRecord=self.dataSource.lastObject;
        }

    }
    NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                          @"pageOffset":self.classType.integerValue==0?Record.pageOffset:SeriesRecord.pageOffset,
                          @"pageSize":@"30",
                          @"themeUuid":self.mynavigation.themeUuid?:@"0",
                          @"navigationId":self.mynavigation.navigationId?:@"0",
                          @"collegeId":self.myCollege.collegeId?:@"0",
                          @"incrIdFlag":@"1",
                          @"queryType":self.queryType,
                          @"assortmentId":self.assortmentId,
                          };
    @weakify(self);
    [[(self.classType.integerValue==0?[CMTCLIENT CMTGetmoreVideo:param]:[CMTCLIENT CMTColledgeSeriesSelectList:param]) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *VideoArray) {
        @strongify(self);
        if (VideoArray.count==0) {
            [self toastAnimation:@"没有更多课程"];
        }else{
            [self.dataSource addObjectsFromArray:VideoArray];
            [self.dataTableView reloadData];
        }
         [self settipsContent];
        [self.dataTableView.infiniteScrollingView stopAnimating];
        
    } error:^(NSError *error) {
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            @strongify(self);
            [self toastAnimation:@"你的网络不给力"];
            
        }else{
            @strongify(self);
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
        [self.dataTableView.infiniteScrollingView stopAnimating];
        
    } completed:^{
        NSLog(@"完成");
    }];
 }];
}



#pragma mark 重新加载
-(void)animationFlash{
    [super animationFlash];
    [self setContentState:CMTContentStateLoading moldel:@"1" height:self.CollegeHeadView.height];
    [self getDataSource];
    if(self.myCollege.collegeId.length>0){
        [self getCollegeDeteil];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.optiomType==CMTCollCollegeVideo){
        [self.navigationController setNavigationBarHidden:YES animated:animated];
   }
     [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.optiomType==CMTCollCollegeVideo){
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
  [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    self.queryType=@"1";
    self.assortmentId=@"0";
    self.classType=@"0";
    oldclassType=self.classType;
    oldqueryType=self.queryType;
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CmtMoreVideoViewController willDeallocSignal");
    }];
    if (self.optiomType==CMTTAllRecommendedVideo) {
        self.titleText=@"全部课程";
    }else if(self.optiomType==CMTSeriesLabelMoreVideo){
        self.titleText=self.mynavigation.navigationName;
         [self setContentState:CMTContentStateLoading];
    }else if(self.optiomType==CMTCollCollegeVideo){
          self.titleText=self.myCollege.collegeName;
        [self.navigationController setNavigationBarHidden:YES];
        self.dataTableView.frame=CGRectMake(0,self.CollegeHeadView.height, SCREEN_WIDTH, SCREEN_HEIGHT-self.CollegeHeadView.height);
        self.mToastView.frame=CGRectMake(self.mToastView.left,64, self.mToastView.width, self.mToastView.height);
        [self getCollegeDeteil];
        [self setContentState:CMTContentStateLoading moldel:@"1" height:self.CollegeHeadView.height];
    }
    self.dataSource=[[NSMutableArray alloc]init];
    [self getDataSource];
    [self getAdvertData];
    [self CMTmoreVideoPullIniteRefresh];
    [self CMTmoreVideoInfIniteRefresh];
    @weakify(self);
    self.shareItem.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self cancelFilterdView];
        if (self.LiveShareView==nil) {
            self.LiveShareView=[[CMTLiveShareView alloc]init];
            CMTLivesRecord *rect=[[CMTLivesRecord alloc]init];
            rect.sharePic=self.myCollege.sharePic;
            rect.shareUrl=self.myCollege.shareUrl;
            rect.shareDesc=self.myCollege.shareDesc;
            rect.title=[@"壹生大学-"stringByAppendingString:self.myCollege.collegeName];
            rect.classRoomId=self.myCollege.collegeId;
            rect.classRoomType=@"5";
            self.LiveShareView.LivesRecord=rect;
            self.LiveShareView.parentView=self;
        }
        [self.LiveShareView showSharaAction];
        return [RACSignal empty];
        
    }];
    
    RAC(self,isReloadDate) = [[RACSignal combineLatest:@[[RACObserve(self, advertRequstHaveResponse)distinctUntilChanged],
                                                         [RACObserve(self, dataRequstHaveResponse)distinctUntilChanged]]reduce:^(NSNumber *a,NSNumber *b){
                                                             BOOL lighted = a.integerValue == 1 && b.integerValue == 1;
                                                             return @(lighted);
                                                             
                                                         }] deliverOn:[RACScheduler mainThreadScheduler]];
    [[RACObserve(self, isReloadDate)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber * x) {
        if (x.integerValue == 1) {
            if (self.dataSource.count > 0) {
                for (int i = 0; i < self.advertArr.count; i ++ ) {
                    CMTAdvert *advert = self.advertArr[i];
                    //位置须为偶数且插入位置包含在数组中
                    if (self.dataSource.count - 1 > advert.position.integerValue && advert.position.integerValue%2 == 0 ) {
                        [self.dataSource insertObject:advert atIndex:(advert.position.integerValue + i * 2)];
                        [self.dataSource insertObject:advert atIndex:(advert.position.integerValue + i * 2 + 1)];
                    }
                }
            }
            [self.dataTableView reloadData];
            [self setContentState:CMTContentStateNormal];
            
        }
    }];
    
}
#pragma mark UItableDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    if(self.classType.integerValue==0){
         NSInteger number=self.dataSource.count;
      NSInteger rows=0;
      if(number%2==1){
            rows=number/2+1;
        }else{
            rows=number/2;
        }
       return rows;
    }
    return self.dataSource.count;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.optiomType==CMTCollCollegeVideo){
     return 160/3;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return  cell.frame.size.height;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.classType.integerValue==0&&[self.dataSource[0] isKindOfClass:[CMTLivesRecord class]]){
    
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (NSInteger i=0; i<2; i++) {
        if(indexPath.row*2+i<self.dataSource.count){
            [array addObject:self.dataSource[indexPath.row*2+i]];
        }
        
     }
        if ([array[0] isKindOfClass:[CMTLivesRecord class]]) {
            CMTCourseCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell==nil) {
                cell=[[CMTCourseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                cell.delegate=self;
            }
            if(self.optiomType==CMTSeriesLabelMoreVideo){
                [cell reloadCellWithData:[array copy] withBoolHeader:indexPath.row==0];
            }else{
                [cell reloadCellWithData:[array copy]];
            }
            array=nil;
            return cell;
        }else{
            CMTAdvertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adCell"];
            if (cell == nil) {
                cell = [[CMTAdvertCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"adCell"];
            }
            cell.delegate = self;
            [cell reloadCellWithModel:array[0]];
            return cell;
        }
    
    }else{
    
    #pragma mark 系列课
    CMTSeriousListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Seriouscell"];
    if(cell==nil){
        cell=[[CMTSeriousListViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Seriouscell"];
    }
    [cell reloadCellWithModel:self.dataSource[indexPath.row]];
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
    return nil;

}

#pragma mark__点击广告
- (void)didSelectAdvert:(CMTAdvert *)advert{
    if (advert.jumpLinks.length > 0) {
        BOOL flag=[advert.jumpLinks handleWithinArticle:advert.jumpLinks viewController:self];
        if(flag){
            CMTWebBrowserViewController *web=[[CMTWebBrowserViewController alloc]initWithURL:advert.jumpLinks];
            [self.navigationController pushViewController:web animated:YES];
        }
    }
    NSDictionary *params = @{
                             @"adverId":advert.adverId
                             };
    [[[CMTCLIENT GetAdClickStatistics:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        CMTLog(@"统计失败");
    }];

//    CMTCLIENT
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable){
        [self toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }

    if([self.dataSource[indexPath.row] isKindOfClass:[CMTSeriesDetails class]]){
        CMTSeriesDetailsViewController *det=[[CMTSeriesDetailsViewController alloc]initWithParam:[self.dataSource[indexPath.row] copy]];
        @weakify(self);
        det.updatevideoList=^(NSString *themuUId){
            @strongify(self);
            [self setContentState:CMTContentStateLoading moldel:@"1" height:self.CollegeHeadView.height];
            [self getDataSource];
        };
        
        [self.navigationController pushViewController:det animated:YES];
    }
}

//点击事件
- (void)didSelecteVideo:(CMTLivesRecord*)Record{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable){
        [self toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }
    if(Record.themeInfo.themeUuid.length>0){
        CMTSeriesDetails *seriesDetails=[[CMTSeriesDetails alloc]init];
        seriesDetails.themeUuid=Record.themeInfo.themeUuid;
        CMTSeriesDetailsViewController *series=[[CMTSeriesDetailsViewController alloc]initWithParam:seriesDetails];
        @weakify(self);
        series.updatevideoList=^(NSString* themUUid){
            @strongify(self);
            Record.themeInfo.themeUuid=@"";
            Record.themeInfo.picUrl=@"";
            [self.dataTableView reloadData];
        };
        [self.navigationController pushViewController:series animated:YES];
    }else{
         if(Record.type.integerValue==1) {
                CMTLightVideoViewController *lightVideoViewController = [[CMTLightVideoViewController alloc]init];
                  lightVideoViewController.myliveParam = Record;
                @weakify(self);
            lightVideoViewController.updateReadNumber=^(CMTLivesRecord *rec){
                @strongify(self);
                if (rec==nil) {
                    [self setContentState:CMTContentStateLoading moldel:@"1"];
                    self.advertShow = YES;
                    [self getDataSource];
                    if (self.updateseriesContent!=nil) {
                        self.updateseriesContent(nil);
                    }
                }else{
                    Record.users=rec.users;
                    [self.dataTableView reloadData];
                }
            };
                [self.navigationController pushViewController:lightVideoViewController animated:YES];
                
            }else{
                CMTRecordedViewController *recordView=[[CMTRecordedViewController alloc]initWithRecordedParam:[Record copy]];
                @weakify(self)
                recordView.updateReadNumber=^(CMTLivesRecord *rec){
                    @strongify(self);
                    if (rec==nil) {
                        [self setContentState:CMTContentStateLoading moldel:@"1"];
                        self.advertShow = YES;
                        [self getDataSource];
                        if (self.updateseriesContent!=nil) {
                            self.updateseriesContent(nil);
                        }
                    }else{
                        Record.users=rec.users;
                        [self.dataTableView reloadData];
                    }
                };

                [self.navigationController pushViewController:recordView animated:YES];
                
                
            }
    }
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.dataTableView.width, 160/3)];
    sectionView.backgroundColor=COLOR(c_ffffff);
    float with=[CMTGetStringWith_Height CMTGetLableTitleWith:@"最新课程" fontSize:16];
    UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(10*XXXRATIO,0,with,sectionView.height)];
    namelable.font=[UIFont systemFontOfSize:16];
    namelable.text=self.queryType.integerValue==1?@"最新课程":@"最热课程";
    namelable.textColor=[UIColor colorWithHexString:@"#3cc6c1"];
    namelable.center=CGPointMake(namelable.center.x, sectionView.height/2);
    [sectionView addSubview:namelable];
    
    float screeeningWith=[CMTGetStringWith_Height CMTGetLableTitleWith:@"筛选" fontSize:14]+35;
    CMTScreeningButton *screeeningbutton=[[CMTScreeningButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-screeeningWith-10*XXXRATIO, 10, screeeningWith, 90/3)];
    [sectionView addSubview:screeeningbutton];
    screeeningbutton.center=CGPointMake(screeeningbutton.center.x, sectionView.height/2);
    [screeeningbutton addTarget:self action:@selector(CMTScreeningAction:) forControlEvents:UIControlEventTouchUpInside];
    if(self.assortmentId.integerValue!=0||self.classType.integerValue!=0){
        [screeeningbutton drawSelectedComponent];
    }
    
    float queryButtomwith=280/3;
      UIButton *querybutton=[UIButton buttonWithType:UIButtonTypeCustom];
     if(self.myCollege.assortmentArray.count>0){
       querybutton.frame=CGRectMake(screeeningbutton.left-queryButtomwith-10*XXXRATIO, 10, queryButtomwith, screeeningbutton.height);
          screeeningbutton.hidden=NO;
     }else{
           querybutton.frame=CGRectMake(SCREEN_WIDTH-queryButtomwith-10*XXXRATIO, 10, queryButtomwith, screeeningbutton.height);
         screeeningbutton.hidden=YES;
     }
     querybutton.center=CGPointMake(querybutton.center.x, sectionView.height/2);
     querybutton.layer.cornerRadius=5;
     querybutton.userInteractionEnabled=YES;
     querybutton.titleLabel.font=FONT(14);
     [querybutton addTarget:self action:@selector(queryTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    [sectionView addSubview:querybutton];
     [self querybuttonChange:querybutton];
    return sectionView;
}
//按照时间和热度查询
-(void)queryTypeAction:(UIButton*)button{
    [self cancelFilterdView];
    button.userInteractionEnabled=NO;
   [self setContentState:CMTContentStateLoading moldel:@"1" height:self.CollegeHeadView.height];
    if(self.queryType.integerValue==1){
        self.queryType=@"2";

    }else if(self.queryType.integerValue==2){
        self.queryType=@"1";
    }
    [self ChangeListOfCoordinates];
    self.advertShow = YES;
    [self getDataSource];
}
-(void)querybuttonChange:(UIButton*)querybutton{
    if(self.queryType.integerValue==2){
        [querybutton setTitle:@"√按热度排序" forState:UIControlStateNormal];
        querybutton.layer.borderWidth=1;
        querybutton.layer.borderColor=[UIColor colorWithHexString:@"#3cc6c1"].CGColor;
        querybutton.backgroundColor=[UIColor clearColor];
        [querybutton setTitleColor:[UIColor colorWithHexString:@"#3cc6c1"] forState:UIControlStateNormal];
    }else{
        [querybutton setTitle:@"按热度排序" forState:UIControlStateNormal];
        querybutton.layer.borderWidth=0;
        querybutton.layer.borderColor=[UIColor colorWithHexString:@"#3cc6c1"].CGColor;
        querybutton.backgroundColor=[UIColor colorWithHexString:@"#e9ebee"];
        [querybutton setTitleColor:[UIColor colorWithHexString:@"#545659"] forState:UIControlStateNormal];
    }
 }

-(void)CMTScreeningAction:(CMTScreeningButton*)button{
    if(self.ScreeningControl==nil){
        self.dataTableView.scrollEnabled=NO;
      [button drawSelectedComponent];
      self.bgView=[[UIView alloc]initWithFrame:CGRectMake(0, [button superview].bottom, self.dataTableView.width,self.dataTableView.height)];
        self.bgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
     UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelFilterdView)];
     [self.bgView addGestureRecognizer:tap];
     [self.dataTableView addSubview:self.bgView];
    float ScreeningControlHeight=self.dataTableView.top==20?self.dataTableView.height-50*XXXRATIO-20:self.dataTableView.height-50*XXXRATIO;
    self.ScreeningControl=[[CMTScreeningControlView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,ScreeningControlHeight)];
     CMTAssortments *Assort=[[CMTAssortments alloc]initWithDictionary:@{} error:nil];
     Assort.assortmentId=@"0";
     Assort.assortmentName=@"全部学科";
     NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:Assort, nil];
     [array addObjectsFromArray:self.myCollege.assortmentArray];
     [self.ScreeningControl DrawTagMakerMangeView:array assortmentId:self.assortmentId classType:self.classType];
      [self.bgView addSubview:self.ScreeningControl];
        @weakify(self);
        self.ScreeningControl.updateScreening=^(NSString*assortmentId,NSString*classType){
            @strongify(self);
            self.classType=classType;
            self.assortmentId=assortmentId;
            self.dataTableView.scrollEnabled=YES;
            [self.bgView removeFromSuperview];
            [self.ScreeningControl removeFromSuperview];
            self.ScreeningControl=nil;
            self.bgView=nil;
            [self settipsContent];
            [self setContentState:CMTContentStateLoading moldel:@"1" height:self.CollegeHeadView.height];
            [self ChangeListOfCoordinates];
            [self getDataSource];
        };
    }else{
        [self cancelFilterdView];
    }
}
//取消过滤
-(void)cancelFilterdView{
    if(self.bgView!=nil){
        self.dataTableView.scrollEnabled=YES;
        [self.bgView removeFromSuperview];
        [self.ScreeningControl removeFromSuperview];
        self.ScreeningControl=nil;
        self.bgView=nil;
        [self.dataTableView reloadData];
        [self settipsContent];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    
    if (self.optiomType == CMTTAllRecommendedVideo ||self.optiomType == CMTSeriesLabelMoreVideo ) {
        return UIStatusBarStyleDefault;
    }else{
        return UIStatusBarStyleLightContent;  //默认的值是白色的
    }
    
    
}
@end
