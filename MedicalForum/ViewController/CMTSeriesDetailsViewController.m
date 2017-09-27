//
//  CMTSeriesDetailsViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSeriesDetailsViewController.h"
#import "CMTGetStringWith_Height.h"
#import "CMTSeresLabelsView.h"
#import "CMTCourseCell.h"
#import "CMTLiveShareView.h"
#import "CMTLightVideoViewController.h"
#import "CMTRecordedViewController.h"
#import "CmtMoreVideoViewController.h"
#import "CmtSeresHeadToolView.h"
@interface CMTSeriesDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,CmtSeresHeadToolViewDelegate,CMTVedioCellDelegate>
@property(nonatomic,strong)UIView *headView;
@property(nonatomic,strong)UIImageView *Seriesimage;
@property(nonatomic,strong)UILabel*TheSeriesLable;
@property(nonatomic,strong)CMTSeriesDetails*mySeriesDetails;
@property(nonatomic,strong)CMTSeresLabelsView*SeresLabelsView;
@property(nonatomic,strong)UITableView *dataTableView;
@property (nonatomic, strong) UIBarButtonItem *shareItem;  // 分享按钮
@property (nonatomic, strong) NSArray *rightItems;      // 分享按钮
@property(nonatomic,strong)CMTLiveShareView *LiveShareView;
@property(nonatomic,strong) UIView *lineView;
@property(nonatomic,strong)CmtSeresHeadToolView *SeresHeadTool;
@property (nonatomic, strong) UIAlertView *alertView;                               // 弹窗警告
@property(nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation CMTSeriesDetailsViewController
-(NSMutableArray*)dataArray{
    if(_dataArray==nil){
        _dataArray=[[NSMutableArray alloc]init];
    }
    return _dataArray;
}
- (UIAlertView *)alertView
{
    if (!_alertView)
    {
        _alertView = [[UIAlertView alloc] initWithTitle:@"你确定要取消订阅该课程吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
    return _alertView;
}
-(UIImageView*)Seriesimage{
    if (_Seriesimage==nil) {
        _Seriesimage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0 ,SCREEN_WIDTH,SCREEN_WIDTH/16*9)];
        [_Seriesimage setImageURL:self.mySeriesDetails.picUrl placeholderImage:IMAGE(@"Placeholderdefault") contentSize:_Seriesimage.frame.size];
        _Seriesimage.userInteractionEnabled=YES;
        _Seriesimage.clipsToBounds=YES;
        _Seriesimage.contentMode=UIViewContentModeScaleAspectFill;
        self.SeresHeadTool=[[CmtSeresHeadToolView alloc]initWithFrame:CGRectMake(0, _Seriesimage.height-40, _Seriesimage.width, 40) CMTSeriesDetails:[self.mySeriesDetails copy]];
        [_Seriesimage addSubview:self.SeresHeadTool];
        _SeresHeadTool.delegate = self;
    }
    return _Seriesimage;
}
-(UILabel*)TheSeriesLable{
    if (_TheSeriesLable==nil) {
        float height=ceilf([CMTGetStringWith_Height getTextheight:self.mySeriesDetails.seriesDesc?:@"" fontsize:13.5 width:self.headView.width-20*XXXRATIO])+15;
        _TheSeriesLable=[[UILabel alloc]initWithFrame:CGRectMake(10*XXXRATIO, self.Seriesimage.bottom,self.Seriesimage.width-20*XXXRATIO,self.mySeriesDetails.seriesDesc.length==0?0: height)];
        _TheSeriesLable.font=[UIFont systemFontOfSize:13.5];
        [_TheSeriesLable setTextColor:ColorWithHexStringIndex(c_151515)];
        _TheSeriesLable.text=self.mySeriesDetails.seriesDesc?:@"";
        _TheSeriesLable.numberOfLines=0;
        _TheSeriesLable.lineBreakMode=NSLineBreakByWordWrapping;
         _TheSeriesLable.backgroundColor = COLOR(c_clear);
    }
    return _TheSeriesLable;
}
-(CMTSeresLabelsView*)SeresLabelsView{
    if (_SeresLabelsView==nil) {
        _SeresLabelsView=[[CMTSeresLabelsView alloc]initWithFrame:CGRectMake(0, self.TheSeriesLable.bottom+1,self.TheSeriesLable.width,0)];
        @weakify(self);
        _SeresLabelsView.SeresLabelAction=^(NSInteger index){
            @strongify(self);
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
           [self.dataTableView scrollToRowAtIndexPath:scrollIndexPath
                                     atScrollPosition:UITableViewScrollPositionTop animated:YES];
        };
    }
    return _SeresLabelsView;
}
-(UIView*)headView{
    if (_headView==nil) {
        _headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,0)];
        [_headView addSubview:self.Seriesimage];
        [_headView addSubview:self.TheSeriesLable];
         self.lineView =[[UIView alloc]initWithFrame:CGRectMake(0, self.TheSeriesLable.bottom, SCREEN_WIDTH, 1)];
         self.lineView.backgroundColor=[UIColor colorWithHexString:@"#ededed"];
        [_headView addSubview:self.lineView];
        [_headView addSubview:self.SeresLabelsView];
        _headView.height=self.SeresLabelsView.bottom;
        
    }
    return _headView;
    
}
-(UITableView*)dataTableView{
    if (_dataTableView==nil) {
        _dataTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide) style:UITableViewStylePlain];
        _dataTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _dataTableView.dataSource=self;
        _dataTableView.delegate=self;
        _dataTableView.allowsSelection=NO;
        _dataTableView.backgroundColor=COLOR(c_ffffff);
        _dataTableView.placeholderView=[self tableViewPlaceholderView:_dataTableView text:@"该系列下还未创建课程"];
        [_dataTableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-_dataTableView.height/2+self.headView.height)]];

    }
    return _dataTableView;
}
-(instancetype)initWithParam:(CMTSeriesDetails*)SeriesDetails{
    self=[super init];
    if (self) {
        self.mySeriesDetails=SeriesDetails;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTSeriesDetailsViewController willDeallocSignal");
    }];
    [self.contentBaseView addSubview: self.dataTableView];
    self.dataTableView.tableHeaderView=self.headView;
    self.titleText=self.mySeriesDetails.seriesName;
    [self setContentState:CMTContentStateLoading];
    [self getData];
    @weakify(self);
    self.SeresHeadTool.shareButton.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        if (self.LiveShareView==nil) {
            self.LiveShareView=[[CMTLiveShareView alloc]init];
            CMTLivesRecord *rect=[[CMTLivesRecord alloc]init];
            rect.sharePic=self.mySeriesDetails.sharePic;
            rect.shareUrl=self.mySeriesDetails.shareUrl;
            rect.shareDesc=self.mySeriesDetails.shareDesc;
            rect.title=self.mySeriesDetails.seriesName;
            rect.classRoomId=self.mySeriesDetails.themeUuid;
            rect.classRoomType=@"4";
            self.LiveShareView.LivesRecord=rect;
            self.LiveShareView.parentView=self;
        }
        [self.LiveShareView showSharaAction];
        return [RACSignal empty];
        
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
#pragma mark 获取数据
-(void)getData{
    @weakify(self);
    
    NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                          @"themeUuid":self.mySeriesDetails.themeUuid?:@""
                          };
    [[[CMTCLIENT CMTGetSeriesDetail:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTSeriesDetails *details) {
         self.mySeriesDetails=details;
        self.titleText=details.seriesName;
        if ([self.mySeriesDetails.navigations count]>0) {
            if(self.mySeriesDetails.navigations.count==1){
                self.dataArray= [((CMTSeriesNavigation*)[self.mySeriesDetails.navigations objectAtIndex:0]).video mutableCopy];
                 [self CMTmoreVideoInfIniteRefresh];
            }
            [self.Seriesimage setImageURL:self.mySeriesDetails.picUrl placeholderImage:IMAGE(@"Placeholderdefault") contentSize:self.Seriesimage.frame.size];
            self.SeresLabelsView.navigationArray=self.mySeriesDetails.navigations;
            float height=[CMTGetStringWith_Height getTextheight:self.mySeriesDetails.seriesDesc?:@"" fontsize:13.5 width:self.headView.width-20*XXXRATIO]+15;
            self.TheSeriesLable.frame=CGRectMake(10*XXXRATIO, self.Seriesimage.bottom,self.Seriesimage.width-20*XXXRATIO,self.mySeriesDetails.seriesDesc.length==0?0:height);
            self.TheSeriesLable.text=self.mySeriesDetails.seriesDesc?:@"";
             self.lineView.frame=CGRectMake(0, self.TheSeriesLable.bottom, SCREEN_WIDTH, 1);
            self.SeresLabelsView.frame=CGRectMake(0, self.TheSeriesLable.bottom+1,self.TheSeriesLable.width,0);
            if([self.mySeriesDetails.navigations count]>1){
                [self.SeresLabelsView CreatSeresLable];
            }
            self.headView.height=self.SeresLabelsView.bottom;;
            self.dataTableView.tableHeaderView=self.headView;
            [_dataTableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-(_dataTableView.height-self.headView.height)/2+50)]];
            [self.dataTableView reloadData];
            [self.dataTableView layoutIfNeeded];

        }
        [self setContentState:CMTContentStateNormal];
    } error:^(NSError *error) {
        if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
            @strongify(self);
            [self setContentState:CMTContentStateReload];
            [self toastAnimation:@"你的网络不给力"];
            

        }else{
            @strongify(self);
            if (error.code==122) {
                [self setContentState:CMTContentStateEmpty];
                self.contentEmptyView.contentEmptyPrompt=[error.userInfo objectForKey:@"errmsg"];
                @weakify(self);
                if(self.updatevideoList!=nil){
                    @strongify(self);
                    self.updatevideoList(@"");
                    [self cancleSubscribe:_mySeriesDetails];
                    
                }
            }else{
                
                [self setContentState:CMTContentStateReload];
                [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
        }

        
    } completed:^{
        NSLog(@"完成");
    }];
}
#pragma mark 上拉翻页
-(void)CMTmoreVideoInfIniteRefresh{
    @weakify(self);
    [self.dataTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTLivesRecord *Record=[[CMTLivesRecord alloc]init];
        Record.pageOffset=@"0";
        if(self.dataArray.count>0){
            Record=self.dataArray.lastObject;
        }
        NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                              @"pageOffset":Record.pageOffset,
                              @"pageSize":@"30",
                              @"themeUuid":self.mySeriesDetails.themeUuid?:@"0",
                              @"navigationId":((CMTSeriesNavigation*)[self.mySeriesDetails.navigations objectAtIndex:0]).navigationId?:@"0",
                              @"incrIdFlag":@"1",
                              };
        @weakify(self);
        [[[CMTCLIENT CMTGetmoreVideo:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *VideoArray) {
            @strongify(self);
            if (VideoArray.count==0) {
                [self toastAnimation:@"没有更多课程"];
            }else{
                [self.dataArray addObjectsFromArray:VideoArray];
                [self.dataTableView reloadData];
            }
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
    [self getData];
}
#pragma mark tableViewdelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.mySeriesDetails.navigations count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger number=tableView.numberOfSections==1?self.dataArray.count:((CMTSeriesNavigation*)[self.mySeriesDetails.navigations objectAtIndex:section]).video.count;
     NSInteger rows=5;
    if(tableView.numberOfSections>1){
        number=number>10?10:number;
        if(number<10){
            if(number%2==1){
                rows=number/2+1;
            }else{
                rows=number/2;
            }
        }

    }else{
        if(number%2==1){
            rows=number/2+1;
        }else{
            rows=number/2;
        }

    }
    return rows;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTCourseCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[CMTCourseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.delegate=self;
    }
    NSArray *navigations=tableView.numberOfSections==1?self.dataArray:((CMTSeriesNavigation*)self.mySeriesDetails.navigations[indexPath.section]).video;
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (NSInteger i=0; i<2; i++) {
        if(indexPath.row*2+i<navigations.count){
            [array addObject:navigations[indexPath.row*2+i]];
        }
        
    }
    [cell reloadCellWithData:[array copy]];
    array=nil;
    return cell;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CMTSeriesNavigation *navgation=self.mySeriesDetails.navigations[section];
    UIView *sectionView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.dataTableView.width, 30)];
    sectionView.backgroundColor=COLOR(c_f5f5f5);
    UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(10*XXXRATIO,0, SCREEN_WIDTH-70,sectionView.height)];
    namelable.textColor=[UIColor colorWithHexString:@"#545659"];
    NSString *str=[@"" stringByAppendingFormat:@"%ld/%lu%@",section+1,(unsigned long)self.mySeriesDetails.navigations.count,navgation.navigationName];
    NSRange range = [str rangeOfString:[NSString stringWithFormat:@"%ld",section+1]];
    NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:str];
    [pStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#18bfa2"] range:range];
    namelable.attributedText = pStr;
    namelable.font=[UIFont systemFontOfSize:14];
    [sectionView addSubview:namelable];
    
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(namelable.right, 0, 60, sectionView.height)];
    [button setTitle:@"更多>" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#18bfa2"] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font=[UIFont systemFontOfSize:14];
    [sectionView addSubview:button];
    @weakify(self);
    button.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        navgation.seriesName=self.mySeriesDetails.seriesName;
        navgation.themeUuid=self.mySeriesDetails.themeUuid;
        CmtMoreVideoViewController *more=[[CmtMoreVideoViewController alloc]initWithSeresParam:navgation type:CMTSeriesLabelMoreVideo];
        @weakify(self);
        more.updateseriesContent=^(CMTSeriesNavigation* nav){
            @strongify(self);
            [self setContentState:CMTContentStateLoading];
            [self getData];
        };
        [self.navigationController pushViewController:more animated:YES];
        
        return  [RACSignal empty];
    }];

    if (navgation.video.count>10) {
        button.hidden=NO;
    }else{
        button.hidden=YES;
    }
    return sectionView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView.numberOfSections==1){
      return 0;
    }
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return  cell.frame.size.height;
}
//点击事件
- (void)didSelecteVideo:(CMTLivesRecord*)Record{
            if (Record.type.integerValue==1) {
            CMTLightVideoViewController *lightVideoViewController = [[CMTLightVideoViewController alloc]init];
            lightVideoViewController.myliveParam = Record;
              @weakify(self);
            lightVideoViewController.updateReadNumber=^(CMTLivesRecord *record){
                @strongify(self);
                if (record==nil) {
                    [self setContentState:CMTContentStateLoading];
                    [self getData];
                }else{
                    Record.users=record.users;
                    [self.dataTableView reloadData];
                }
                
            };
            [self.navigationController pushViewController:lightVideoViewController animated:YES];
            
        }else{
            CMTRecordedViewController *recordView=[[CMTRecordedViewController alloc]initWithRecordedParam:[Record copy]];
            @weakify(self)
            recordView.updateReadNumber=^(CMTLivesRecord *record){
                @strongify(self);
                if (record==nil) {
                    [self setContentState:CMTContentStateLoading];
                    [self getData];
                }else{
                    Record.users=record.users;
                    [self.dataTableView reloadData];
                }
                
            };
            [self.navigationController pushViewController:recordView animated:YES];
            
            
        }
}
-(void)GobackAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark__CmtSeresHeadToolViewDelegate
- (void)subscribeAction:(UIButton *)action{
    if ([action.currentTitle isEqualToString:@"订阅"]) {
        if (CMTAPPCONFIG.seriesFocusedRecordedVersion == nil) {
            // 显示提示
            [[[UIAlertView alloc] initWithTitle:nil message:@"订阅成功，请到学院左侧“已订”处查看" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
            // 记录强制订阅版本
            CMTAPPCONFIG.seriesFocusedRecordedVersion = APP_VERSION;
        }
        [self subscribe:self.mySeriesDetails];
        
    }else{
        [self.alertView.rac_buttonClickedSignal subscribeNext:^(NSNumber * x) {
            if (x.integerValue == 1) {
                [self cancleSubscribe:self.mySeriesDetails];
            }
        }];
        [self.alertView show];
    }
}
//订阅系列课程
- (void)subscribe:(CMTSeriesDetails *)seriesDetail{
    
    
    __block NSMutableArray *cachArr = [NSMutableArray array];
    if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]])
    {
        cachArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
    }
    //CMTUSER.userInfo;
    //self.viewModel.postDetail;
    CMTLog(@"订阅系列课程");
    
    
    NSDictionary *pDic = @{
                           @"userId":[NSNumber numberWithInteger:CMTUSERINFO.userId.integerValue?:0],
                           @"themeUuid":seriesDetail.themeUuid,
                           @"cancelFlag":[NSNumber numberWithInteger:0],
                           };
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        if (CMTUSER.login == YES)
        {
            @weakify(self);
            [[CMTCLIENT cmtSubscribeSeriesDetail:pDic]subscribeNext:^(CMTSeriesDetails *seriesDetailfromNet) {
                @strongify(self);
                CMTLog(@"后返回对象的操作时间为%@",seriesDetailfromNet.opTime);
                CMTLog(@"订阅成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    /*弹出收藏成功视图*/
                    
                    
                    
                    [self.SeresHeadTool.focusButton setTitle:@"已订阅" forState:UIControlStateNormal];
                    self.SeresHeadTool.focusImage.image = IMAGE(@"theme_focused");
                    
                    
                    
                    seriesDetail.opTime = seriesDetailfromNet.opTime;
                    seriesDetail.viewTime = seriesDetailfromNet.opTime;
                    NSUInteger seriesCount = cachArr.count;
                    BOOL isContained = NO;
                    NSUInteger index = 0;
                    if (seriesCount > 0)
                    {
                        /*去重,缓存本地*/
                        for (NSUInteger i = 0; i < seriesCount; i++)
                        {
                            if ([[cachArr objectAtIndex:i]isKindOfClass:[CMTSeriesDetails class]])
                            {
                                CMTSeriesDetails *pTempSeriesDetail = [cachArr objectAtIndex:i];
                                if ([pTempSeriesDetail.themeUuid isEqualToString: seriesDetail.themeUuid])
                                {
                                    isContained = YES;
                                    index = i;
                                    break;
                                }
                            }
                        }
                        if (isContained)
                        {
                            [cachArr removeObjectAtIndex:index];
                            CMTLog(@"已经有这条订阅系列课程信息,订阅时间将更新");
                        }
                    }
                    [cachArr addObject:seriesDetail];
                    
                    
                    BOOL suc = [NSKeyedArchiver archiveRootObject:cachArr toFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
                    if (suc)
                    {
                        CMTLog(@"缓存到本地成功");
                    }
                    else
                    {
                        CMTLog(@"缓存本地失败");
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
                    CMTLogError(@"Request subscriptionSeriesSystem Error: %@", error);
                }
                
                // 添加缓存系列课程
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addCacheSeriesDetailForErrorWithSeriesDetail:seriesDetail];
                    
                });
                
            }];
        }
        else
        {
            // 添加缓存系列课程
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addCacheSeriesDetailForErrorWithSeriesDetail:seriesDetail];
                
            });        }
    }
    else
    {
        // 添加缓存系列课程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addCacheSeriesDetailForErrorWithSeriesDetail:seriesDetail];
            
        });    }
}
//取消订阅
- (void)cancleSubscribe:(CMTSeriesDetails *)seriesDetail{
    __block NSMutableArray *cachArr = [NSMutableArray array];
    if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]])
    {
        cachArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
    }
    NSInteger index = 0;
    CMTSeriesDetails *seriesDe;
    for (int i = 0; i < cachArr.count; i ++) {
        if ([[cachArr objectAtIndex:i]isKindOfClass:[CMTSeriesDetails class]]) {
            seriesDe = [cachArr objectAtIndex:i];
            if ([seriesDetail.themeUuid isEqual:seriesDe.themeUuid]) {
                index = i;
                break;
            }
        }
    }
    /*有无网络*/
    BOOL netState = [AFNetworkReachabilityManager sharedManager].isReachable;
    if (netState) {
        if (CMTUSER.login) {
            NSDictionary *pDic = @{
                                   @"userId":[NSNumber numberWithInteger:CMTUSERINFO.userId.integerValue?:0],
                                   @"themeUuid":seriesDetail.themeUuid,
                                   @"cancelFlag":[NSNumber numberWithInt:1],
                                   };
            //调用删除接口
            [[[CMTCLIENT cmtSubscribeSeriesDetail:pDic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTSeriesDetails * x) {
                CMTLog(@"网络删除订阅系列课程成功");
            }error:^(NSError *error) {
                CMTLog(@"error:%@",error);
                NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                if ([errorCode integerValue] > 100) {
                    NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                    CMTLog(@"errMes = %@",errMes);
                } else {
                    CMTLogError(@"deleteSubscribeSeriesDetail System Error: %@", error);
                }
            }];
            
        }
    }
    if (index <= cachArr.count && cachArr.count> 0) {
        [cachArr removeObjectAtIndex:index];
        BOOL sucess = [NSKeyedArchiver archiveRootObject:cachArr toFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
        if (sucess) {
            CMTLog(@"本地删除成功");
            [self.SeresHeadTool.focusButton setTitle:@"订阅" forState:UIControlStateNormal];
            self.SeresHeadTool.focusImage.image = IMAGE(@"theme_focus");
        }else{
            CMTLog(@"本地删除失败");
        }
    }
    
    
}
//添加订阅数据到本地
- (void)addCacheSeriesDetailForErrorWithSeriesDetail:(CMTSeriesDetails *)seriesDetail{
    seriesDetail.opTime = TIMESTAMP;
    seriesDetail.viewTime = TIMESTAMP;
    __block NSMutableArray *cachArr = [NSMutableArray array];
    if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]])
    {
        cachArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
    }
    NSInteger index = cachArr.count;
    BOOL isContained = NO;
    if (index > 0) {
        for (NSInteger i = 0; i < index; i ++ ) {
            if ([[cachArr objectAtIndex:i]isKindOfClass:[CMTSeriesDetails class]]) {
                CMTSeriesDetails *seriesD = [cachArr objectAtIndex:i];
                if ([seriesD.themeUuid isEqual:seriesDetail.themeUuid]) {
                    index = i;
                    isContained = YES;
                    break;
                }
            }
        }
        if (isContained) {
            [cachArr removeObjectAtIndex:index];
        }
    }
    [cachArr addObject:seriesDetail];
    BOOL sucess = [NSKeyedArchiver archiveRootObject:cachArr toFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
    if (sucess) {
        CMTLog(@"订阅系列课程成功");
        self.SeresHeadTool.focusImage.image = IMAGE(@"theme_focused");
        [self.SeresHeadTool.focusButton setTitle:@"已订阅" forState:UIControlStateNormal];
    }else{
        CMTLogError(@"订阅系列课程失败");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
