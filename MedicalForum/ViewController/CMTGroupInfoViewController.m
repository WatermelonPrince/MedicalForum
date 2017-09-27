//
//  CMTGroupInfoViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/22.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTGroupInfoViewController.h"
#import "CMTBarButtonItem.h"
#import "CMTBindingViewController.h"
#import "UITableView+CMTExtension_PlaceholderView.h"
#import "CMTGroupMembersViewController.h"
#import "CMTPostDetailCenter.h"
#import "CMTSendCaseViewController.h"
#import "CMTPostProgressView.h"
#import "CMTCasefilterView.h"
#import "CMTNoticeViewController.h"
#import "CMTBaseViewController+CMTExtension.h"
static NSString * const CMTCaseListRequestDefaultPageSize = @"10";
@interface CMTGroupInfoViewController ()<UIActionSheetDelegate,CMTPostProgressViewDelegate,UIAlertViewDelegate,CMTCasefilterViewDelegate,UIGestureRecognizerDelegate>
//小组列表
@property(nonatomic,strong)UITableView *groupInfoTableView;
//病例数据列表
@property(nonatomic,strong)NSMutableArray *groupCaselistArray;
//置顶病例数据列表
@property (nonatomic,strong)NSMutableArray *topDiseaseList;
//普通病例数据列表
@property (nonatomic,strong)NSMutableArray *diseaseList;
@property(nonatomic,strong)NSString *concernIds;  //已经订阅的学课id
@property (nonatomic, strong) CMTBarButtonItem *NavrightItem;//文章发布按钮
//病例数据
@property(nonatomic,strong)CMTCaseLIstData *groupdata;
//是否存在缓存
@property(nonatomic,assign)BOOL ishaveCache;
//我的小组数据
@property(nonatomic,strong)CMTGroup *mygroup;
//缓存
@property(nonatomic,strong)NSMutableDictionary *groupCachDic;
//小组head头
@property(nonatomic,strong)UIView *groupHeadView;
//小组信息视图
@property(nonatomic,strong)UIView *groupInfoView;
//添加小组视图
@property(nonatomic,strong)UIView *addTeamView;
//退出小组视图
@property(nonatomic,strong)UIView *outTeanView;
//小组成员
@property(nonatomic,strong)UIControl *teamMember;
@property(nonatomic,strong)UIBarButtonItem *backItem;
@property (nonatomic, strong) CMTBarButtonItem *addPostItem;//打开发帖按钮
//右侧工具按钮
@property (nonatomic, strong) NSArray *rightItems;
//左侧工具按钮
@property (nonatomic, strong) NSArray *leftItems;
//列表头
@property(nonatomic,strong)UIView *tableheadView;
@property (strong, nonatomic) NSString *shareTitle;                             // 分享title
@property (strong, nonatomic) NSString *shareBrief;                             // 分享brief
@property (strong, nonatomic) NSString *shareUrl;
@property(nonatomic,strong) CMTPostProgressView *progressView;//进度条
@property(nonatomic,strong)NSString *scroce;//积分
@property(nonatomic,strong)NSString *filterTypeName;//过滤名称
//过滤视图
@property(nonatomic,strong) CMTCasefilterView *filterView;
//过滤按钮
@property(nonatomic,strong) UIButton *filterbutton;
//底部视图
@property(nonatomic,strong) UIView *bgview;
//数据类型
@property(nonatomic,strong)NSString *screenType;
@property(strong,nonatomic)UIControl *noticeView;
@property(strong,nonatomic)UILabel *noticelalbe;
@property(nonatomic,strong)UILabel *tipsLable;//提示语
@property(nonatomic)NSInteger focusRow;//存储手势在tableView上的位置
@property(nonatomic)NSInteger focusSection;
@property(nonatomic, strong)NSIndexPath *indexPath;
@property(nonatomic,strong)NSString *groupUuId;

@end
@implementation CMTGroupInfoViewController
-(instancetype)initWithGroup:(CMTGroup*)group{
    self=[super init];
    if(self){
        self.mygroup=group;
         self.filterTypeName=@"最新讨论";
         self.screenType=@"0";
    }
    return self;
}
-(instancetype)initWithGroupUuid:(NSString*)pUuid{
    self=[super init];
    if(self){
        self.groupUuId=pUuid;
        self.filterTypeName=@"最新讨论";
        self.screenType=@"0";
    }
    return self;

}
- (NSArray *)leftItems {
    if (_leftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _leftItems = @[leftFixedSpace, self.backItem];
    }
    
    return _leftItems;
}

- (UIBarButtonItem *)backItem {
    if (_backItem == nil) {
        _backItem = [[UIBarButtonItem alloc]initWithImage:IMAGE(@"naviBar_back") style:UIBarButtonItemStyleDone target:self action:@selector(popViewController)];
        [_backItem setBackgroundVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsDefault];
    }
    return _backItem;
}

-(CMTGroup*)mygroup{
    if (_mygroup==nil) {
        _mygroup=[[CMTGroup alloc]init];
    }
    return _mygroup;
}
-(NSMutableDictionary*)groupCachDic{
    if (_groupCachDic==nil) {
        _groupCachDic=[[NSMutableDictionary alloc]init];
    }
    return _groupCachDic;
}
-(UITableView*)groupInfoTableView{
    if (_groupInfoTableView==nil) {
        _groupInfoTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, self.contentBaseView.height-CMTNavigationBarBottomGuide)];
        _groupInfoTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _groupInfoTableView.delegate=self;
        _groupInfoTableView.backgroundColor=COLOR(c_efeff4);
        _groupInfoTableView.dataSource=self;
        [_groupInfoTableView registerClass:[CMTCaseListCell class] forCellReuseIdentifier:@"CMTCellListCellTeam"];
        [_groupInfoTableView addSubview:self.tipsLable];
    }
    return _groupInfoTableView;
}
-(UIView*)groupInfoView{
    if(_groupInfoView==nil) {
        _groupInfoView=[[UIView alloc]init];
        _groupInfoView.tag=10006;
    }
    return _groupInfoView;
}
-(UIView*)tableheadView{
    if(_tableheadView==nil) {
        _tableheadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        _tableheadView.backgroundColor=COLOR(c_efeff4);
        [_tableheadView addSubview:self.noticeView];
    }
    return _tableheadView;
}

-(NSMutableArray*)groupCaselistArray{
    if (_groupCaselistArray==nil) {
        _groupCaselistArray=[[NSMutableArray alloc]init];
    }
    return _groupCaselistArray;
}
-(UIView*)groupHeadView{
    if (_groupHeadView==nil) {
        _groupHeadView=[[UIView alloc]initWithFrame:CGRectMake(10, self.noticeView.bottom+10, SCREEN_WIDTH-20, 0)];
        _groupHeadView.backgroundColor=COLOR(c_ffffff);
        _groupHeadView.tag=10005;
    }
    return _groupHeadView;
}
-(UIView*)addTeamView{
    if (_addTeamView==nil) {
        _addTeamView=[[UIView alloc]init];
        _addTeamView.backgroundColor=COLOR(c_ffffff);
        _addTeamView.tag=10003;

    }
    return _addTeamView;
}
-(UIView*)outTeanView{
    if (_outTeanView==nil) {
        _outTeanView=[[UIView alloc]init];
        _outTeanView.tag=10002;
    }
    return _outTeanView;
}
-(UIControl*)teamMember{
    if (_teamMember==nil) {
        _teamMember=[[UIControl alloc]init];
        _teamMember.tag=10001;
        [_teamMember addTarget:self action:@selector(showMembers) forControlEvents:UIControlEventTouchUpInside];
    }
    return _teamMember;
}
-(CMTBarButtonItem*)addPostItem{
    if(_addPostItem==nil){
        _addPostItem = [CMTBarButtonItem itemWithImage:IMAGE(@"addCasePost")imageEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
    }
    return _addPostItem;
}
- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        FixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.addPostItem, nil];
        
    }
    
    return _rightItems;
}
-(UIControl*)noticeView{
    if (_noticeView==nil) {
        _noticeView=[[UIControl alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH,40)];
        _noticeView.backgroundColor=COLOR(c_clear);
        [_noticeView addSubview:self.noticelalbe];
        _noticelalbe.autoresizesSubviews=YES;
        [_noticeView addTarget:self action:@selector(shownoticeViewController) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _noticeView;
}
-(UILabel*)noticelalbe{
    if (_noticelalbe==nil) {
        _noticelalbe=[[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,40)];
        _noticelalbe.layer.cornerRadius=5;
        _noticelalbe.layer.masksToBounds=YES;
        _noticelalbe.font=[UIFont boldSystemFontOfSize:15];
        _noticelalbe.textColor=[UIColor whiteColor];
        _noticelalbe.textAlignment=NSTextAlignmentCenter;
        _noticelalbe.backgroundColor=[UIColor colorWithHexString:@"#373B3A"];
    }
    return _noticelalbe;
}
-(UILabel*)tipsLable{
    if (_tipsLable==nil) {
        _tipsLable=[[UILabel alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-60-64-50)/2, SCREEN_WIDTH, 60)];
        _tipsLable.text=[@"没有"stringByAppendingFormat:@"%@的文章",_filterTypeName];
        _tipsLable.textAlignment=NSTextAlignmentCenter;
        _tipsLable.textColor=COLOR(c_d2d2d2);
        _tipsLable.font=[UIFont boldSystemFontOfSize:18.0];
        
    }
    return _tipsLable;
    
}
#pragma  设置是否显示提示语句
-(void)settipsContent{
    self.tipsLable.hidden=self.groupCaselistArray.count>0;
    self.tipsLable.text=[self gettipstitle];
    self.tipsLable.frame=CGRectMake(0,self.tableheadView.height+(self.groupInfoTableView.height-self.tableheadView.height)/2, self.tipsLable.width, self.tipsLable.height);
    
}
-(NSString*)gettipstitle{
    if (self.screenType.integerValue==0) {
        return @"暂无最新的文章";
    }else if(self.screenType.integerValue==1){
        return @"暂无推荐的文章";
    }else if(self.screenType.integerValue==2){
        return @"暂无有结论的文章";
    }
   return @"暂无最新的文章";
        
}
-(void)popViewController{
    if (self.fromController==FromUpgrade) {
         CMTAPPCONFIG.isrefreahCase=@"1";
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    NSLog(@" CMTAPPCONFIG.isrefreahCase%@", CMTAPPCONFIG.isrefreahCase);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTGroupInfoViewController willDeallocSignal");
    }];
    self.scroce=nil;
    self.titleText=self.mygroup.groupName?:@"";
    [self.contentBaseView addSubview:self.groupInfoTableView];
    //跳立方
    [self setContentState:CMTContentStateLoading];
    //添加下拉刷新方法
    [self CMTPullToGroupInfoRefresh];
    //添加上拉翻页方法
    [self CMTnfIniteGroupInfoRefresh];
    //获取病例数据
    if ([[NSFileManager defaultManager]fileExistsAtPath:PATH_CACHE_CASE_TEAM]&&[CMTAPPCONFIG.reachability isEqualToString:@"0"])
    {
        if (self.mygroup.groupId!=nil) {
            dispatch_async(dispatch_get_global_queue(0,0),^{
                self.groupCachDic=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_CASE_TEAM];
                self.groupdata=[self.groupCachDic objectForKey:self.mygroup.groupId];
                if (self.groupdata.groupInfo.topMemList.count>0) {
                    if([[self.groupdata.groupInfo.topMemList objectAtIndex:0]isKindOfClass:[NSArray class]]){
                        self.groupdata.groupInfo.topMemList=[self.groupdata.groupInfo.topMemList objectAtIndex:0];
                    }
                    
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (self.groupdata!=nil){
                        NSMutableArray *arrry=[NSMutableArray arrayWithArray:[self.groupdata.topDiseaseList copy]];
                        [arrry addObjectsFromArray:[self.groupdata.diseaseList copy]];
                        self.groupCaselistArray=[arrry mutableCopy];
                        self.ishaveCache=YES;
                        [self showGroupnoticeLable];
                        [self CMTDrawheadView];
                        self.groupInfoTableView.tableHeaderView=self.tableheadView;
                        [self settipsContent];
                        [self.groupInfoTableView reloadData];
                        [self stopAnimation];
                        [self setContentState:CMTContentStateNormal];
                        
                    }
                });
            });

        }
    }
   //强制刷新列表数据
    [self getCaseLIstData];
    //增加手势返回
    if(self.fromController == FromUpgrade){
             UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(popViewController)];
               Swipe.numberOfTouchesRequired=1;
                Swipe.direction=UISwipeGestureRecognizerDirectionRight;
                [Swipe setDelaysTouchesBegan:YES];
                Swipe.delegate=self;
              [self.groupInfoTableView addGestureRecognizer:Swipe];
     }
//    //添加长按文章管理方法
//    [self longPressGesturecaselistManager];
    
     @weakify(self);
    self.navigationItem.rightBarButtonItems=self.rightItems;
    self.navigationItem.leftBarButtonItems=self.leftItems;
    [[RACObserve(CMTAPPCONFIG,addGroupPostData.addPostStatus) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
         @strongify(self);
        if (CMTAPPCONFIG.addGroupPostData.addPostStatus.integerValue==1) {
          if (self.progressView==nil) {
                self.progressView=[[CMTPostProgressView alloc]initWithFrame:CGRectMake(self.groupHeadView.left,10,self.groupHeadView.width,30) module:CMTSendCaseTypeAddGroupPost];
                self.progressView.delegate=self;
                [self.tableheadView addSubview:self.progressView];
              self.noticeView.frame=CGRectMake(self.noticeView.left, self.progressView.bottom+10, self.noticeView.width, self.noticeView.height);
                self.groupHeadView.frame=CGRectMake(self.groupHeadView.left,self.noticeView.bottom+10, self.groupHeadView.width, self.groupHeadView.height);
                self.tableheadView.frame=CGRectMake(0, 0,SCREEN_WIDTH, self.groupHeadView.bottom);
                self.groupInfoTableView.tableHeaderView=self.tableheadView;
                [self.progressView start];
          }else{
              [self.progressView start];
          }
        }else if(CMTAPPCONFIG.addGroupPostData.addPostStatus.integerValue==3){
            if (self.progressView==nil) {
                self.progressView=[[CMTPostProgressView alloc]initWithFrame:CGRectMake(self.groupHeadView.left,10,self.groupHeadView.width,30) module:CMTSendCaseTypeAddGroupPost];
                self.progressView.delegate=self;
                [self.tableheadView addSubview:self.progressView];
                self.noticeView.frame=CGRectMake(self.noticeView.left, self.progressView.bottom+10, self.noticeView.width, self.noticeView.height);
                self.groupHeadView.frame=CGRectMake(self.groupHeadView.left,self.noticeView.bottom+10, self.groupHeadView.width, self.groupHeadView.height);
                self.tableheadView.frame=CGRectMake(0, 0,SCREEN_WIDTH, self.groupHeadView.bottom);
                self.groupInfoTableView.tableHeaderView=self.tableheadView;
                [self.progressView SendFailure];

            }else{
                [self.progressView SendFailure];

            }

        }
        
    }];

#pragma mark 点击发帖
    // 点击发帖按钮
    [self.addPostItem.touchSignal subscribeNext:^(id x) {
        @strongify(self);
        if(!CMTUSER.login){
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [self.navigationController pushViewController:loginVC animated:YES];

        }else if(self.mygroup.isJoinIn.integerValue!=1){
                [self toastAnimation:@"你还未加入该小组"];
            
        }else if(CMTAPPCONFIG.addGroupPostData.addPostStatus.integerValue!=0){
            [self toastAnimation:@"还有未发送成功的文章"];
        }else {
//            // 弹出病例类型选择器
//            [postTypeActionSheet showInView:self.view];
            CMTType *postType = [[CMTType alloc] initWithDictionary:@{@"postTypeId": @"1", @"postType": @"病例"}  error:nil];
            [self sendCasePost:postType];
        }
    }];
    //监听发帖错误信息提示
    [[[RACObserve(CMTAPPCONFIG, addPosterror)ignore:nil] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString *x) {
        @strongify(self);
        if (x.length>0) {
             [self toastAnimation: CMTAPPCONFIG.addPosterror];
            CMTAPPCONFIG.addPosterror=nil;
        }
       
    } error:^(NSError *error) {
       
    } completed:^{
        
    }];

}
#pragma mark 发布病例
-(void)sendCasePost:(CMTType*)postType{
    @weakify(self);
    CMTSendCaseViewController *sendCaseViewController = [[CMTSendCaseViewController alloc] initWithSendCaseType:CMTSendCaseTypeAddGroupPost
                                                                                                         postId:nil
                                                                                                     postTypeId:postType.postTypeId
                                                                                                        groupId:self.mygroup.groupId
                                                                                                 groupSubjectId:[self.mygroup.viewRange firstObject]];
    sendCaseViewController.updateCaseList = ^(CMTAddPost *newCase) {
        @strongify(self);
        CMTLog(@"newCase.postBrief: %@", newCase.postBrief);
        CMTLog(@"newCase.score: %@", newCase.score);
        self.scroce=newCase.score;
        [self.progressView SendSuccess];
        self.mygroup.postCount=[NSString stringWithFormat:@"%ld",(long)self.mygroup.postCount.integerValue+1];
        NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:newCase.postBrief, nil];
        [array addObjectsFromArray:[self.diseaseList copy]];
        self.diseaseList=[array mutableCopy];
        NSMutableArray *toplistArr = [NSMutableArray arrayWithArray:self.topDiseaseList];
        [toplistArr addObjectsFromArray:array];
        self.groupCaselistArray= [toplistArr mutableCopy];
        self.groupdata.diseaseList=[array copy];
        [self settipsContent];
        [self.groupInfoTableView reloadData];
        [self.groupCachDic setObject:self.groupdata forKey:self.mygroup.groupId];
        [NSKeyedArchiver archiveRootObject:self.groupCachDic toFile:PATH_CACHE_CASE_TEAM];
        
    };
    CMTNavigationController *navi = [[CMTNavigationController alloc] initWithRootViewController:sendCaseViewController];
    [self presentViewController:navi animated:YES completion:nil];
}
#pragma shownotice
-(void)showGroupnoticeLable{
    if ((self.mygroup.noticeCount.integerValue>0&&((self.mygroup.isJoinIn.integerValue==1&&self.mygroup.groupType.integerValue>0)||self.mygroup.groupType.integerValue==0))&&CMTUSER.login) {
        if (self.progressView==nil) {
            self.noticeView.frame=CGRectMake(0, 10, SCREEN_WIDTH, 40);
            self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,40);
            self.groupHeadView.frame=CGRectMake(10, self.noticeView.bottom+10, SCREEN_WIDTH-20, self.groupHeadView.height);
        }else{
            self.noticeView.frame=CGRectMake(0, self.progressView.bottom+10, SCREEN_WIDTH, 40);
            self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,40);
            self.groupHeadView.frame=CGRectMake(10, self.noticeView.bottom+10, SCREEN_WIDTH-20,self.groupHeadView.height);
        }
        
        self.noticelalbe.text=[self.mygroup.noticeCount stringByAppendingString:@"条新消息"];
    }else{
        if (self.progressView==nil) {
            self.noticeView.frame=CGRectMake(0, 10, SCREEN_WIDTH, 0);
            self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,0);
            self.groupHeadView.frame=CGRectMake(10, self.noticeView.bottom, SCREEN_WIDTH-20, self.groupHeadView.height);
            
        }else{
            self.noticeView.frame=CGRectMake(0, self.progressView.bottom+10, SCREEN_WIDTH, 0);
            self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,0);
            self.groupHeadView.frame=CGRectMake(10, self.noticeView.bottom, SCREEN_WIDTH-20, self.groupHeadView.height);
        }
        
    }
    
    
}
//展示通知
-(void)shownoticeViewController{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        CMTNoticeViewController *noticViewController=[[CMTNoticeViewController alloc]initWithGroup:self.mygroup];
        @weakify(self);
        noticViewController.updatenotice=^( NSString *count){
            @strongify(self);
            self.mygroup.noticeCount=count;
            [self showGroupnoticeLable];
            [self CMTDrawheadView];
            self.groupInfoTableView.tableHeaderView=self.tableheadView;
            if (self.updateGroupBubbles!=nil) {
                 CMTAPPCONFIG.isrefreahCase=@"0";
                 self.updateGroupBubbles();
            }
        };
        noticViewController.ShieldingArticleSucess=^(CMTPost *post){
            @strongify(self);
            [self.topDiseaseList removeAllObjects];
            [self.diseaseList removeAllObjects];
            [self.groupCaselistArray removeAllObjects];
            [self getCaseLIstData];
        };
        noticViewController.PlacedTheTopSucess=^(CMTPost *post1){
            @strongify(self);
            [self.topDiseaseList removeAllObjects];
            [self.diseaseList removeAllObjects];
            [self.groupCaselistArray removeAllObjects];
            [self getCaseLIstData];
        };

        [self.navigationController pushViewController:noticViewController animated:YES];
    }

    
}
#pragma 进度条消失
-(void)DeletePosting{
    self.progressView=nil;
    self.noticeView.frame=CGRectMake(self.noticeView.left,10, self.noticeView.width, self.noticeView.height);
    self.groupHeadView.frame=CGRectMake(self.groupHeadView.left,self.noticeView.bottom+10, self.groupHeadView.width, self.groupHeadView.height);
    self.tableheadView.frame=CGRectMake(0, 0,SCREEN_WIDTH, self.groupHeadView.bottom);
    self.groupInfoTableView.tableHeaderView=self.tableheadView;
    if (self.scroce!=nil) {
         [self toastIntegralAnimation:self.scroce title:@"发表文章"];
    }
    self.scroce=nil;


}
//重新发送 刷新文章列表
-(void)reloadCaselistData:(CMTAddPost*)newCase{
    self.scroce=newCase.score;
    [self.progressView SendSuccess];
    NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:newCase.postBrief, nil];
    [array addObjectsFromArray:[self.diseaseList copy]];
      self.diseaseList=[array mutableCopy];
    NSMutableArray *toparr = [NSMutableArray arrayWithArray:self.topDiseaseList];
    [toparr addObjectsFromArray:array];
    self.groupCaselistArray= [toparr mutableCopy];
    self.groupdata.diseaseList=[self.diseaseList copy];
    self.mygroup.postCount=[NSString stringWithFormat:@"%ld",(long)self.mygroup.postCount.integerValue+1];
    [self settipsContent];
    [self.groupInfoTableView reloadData];
     [self.groupCachDic setObject:self.groupdata forKey:self.mygroup.groupId];
      [NSKeyedArchiver archiveRootObject:self.groupCachDic toFile:PATH_CACHE_CASE_TEAM];
    
}


//绘制head
-(void)CMTDrawheadView{

    //小组成员数目
    UIView *groupnameView=[self.groupHeadView viewWithTag:1005];
    if(groupnameView==nil){
        groupnameView=[[UIView alloc]initWithFrame:CGRectMake(10, 0, self.groupHeadView.width-10, 35)];
        groupnameView.tag=1005;
       [self.groupHeadView addSubview:groupnameView];
    }
    
    UILabel *lable=(UILabel*)[groupnameView viewWithTag:1006];
    if (lable==nil) {
        lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, groupnameView.width-40, 35)];
        [groupnameView addSubview:lable];
        lable.textColor=[UIColor colorWithHexString:@"#5C5B5C"];
        lable.font=[UIFont systemFontOfSize:16];
        lable.tag=1006;
    }
     lable.text=[@"小组成员" stringByAppendingFormat:@"%@人",((CMTGroup*)(self.groupdata.groupInfo)).memNum];
    
    //下拉收回按钮
    UIButton *Dropbutton=(UIButton*)[groupnameView viewWithTag:1007];
    if (Dropbutton==nil) {
        Dropbutton=[[UIButton alloc]initWithFrame:CGRectMake(lable.right+10, 0, 30,  30)];
        [Dropbutton setBackgroundImage:IMAGE(@"down-drop") forState:UIControlStateNormal];
        [Dropbutton addTarget:self action:@selector(showGroupInfoView:) forControlEvents:UIControlEventTouchUpInside];
        Dropbutton.tag=1007;
        [groupnameView addSubview:Dropbutton];

    }
    
    //绘制参与人员
    CMTGroup *group=self.groupdata.groupInfo;
    NSInteger number=[group.topMemList count]>10?11:[group.topMemList count];
    NSInteger imagenumber=(number<=10?10:11);
    float partPeopleViewheight=ceilf((self.groupHeadView.width-10*(imagenumber+1))/imagenumber);
    if(SCREEN_WIDTH>414){
        partPeopleViewheight=40;
    }
    if ([group.topMemList count]==0) {
        self.teamMember.frame=CGRectMake(0,groupnameView.bottom+10,self.groupHeadView.width,1);
        for (UIView *view in [self.teamMember subviews]) {
             view.hidden=YES;
            
        }
        UIView *topLine1=[self.teamMember viewWithTag:100];
        if (topLine1==nil) {
            topLine1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.teamMember.width,1)];
            topLine1.tag=100;
            topLine1.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
            [self.teamMember addSubview:topLine1];
        }
        if ([self.groupHeadView viewWithTag:10001]==nil) {
            [self.groupHeadView addSubview:self.teamMember];

        }
        
    }else{
        self.teamMember.frame=CGRectMake(0, groupnameView.bottom+10, self.groupHeadView.width,partPeopleViewheight);
        [self drawTeamPeopleView];
        if ([self.groupHeadView viewWithTag:10001]==nil) {
            [self.groupHeadView addSubview:self.teamMember];
            
        }
    }

    
    //小组信息视图
    self.groupInfoView.frame=CGRectMake(0, self.teamMember.bottom,self.groupHeadView.width,130);
    [self CMTgroupInfoView];
    if ([self.groupHeadView viewWithTag:10006]==nil) {
        [self.groupHeadView addSubview:self.groupInfoView];
    }

   
        self.groupHeadView.frame=CGRectMake(self.groupHeadView.frame.origin.x, self.groupHeadView.frame.origin.y, self.groupHeadView.width, self.groupInfoView.bottom);
    if ([self.tableheadView viewWithTag:10005]==nil) {
        [self.tableheadView addSubview:self.groupHeadView];
    }
    self.tableheadView.frame=CGRectMake(0, 0,SCREEN_WIDTH, self.groupHeadView.bottom);
}
//绘制小组信息
-(void)CMTgroupInfoView{
    CMTGroup *group=self.groupdata.groupInfo;
      //小组图片
    UIImageView *teamimage=(UIImageView*)[self.groupInfoView viewWithTag:101];
    if (teamimage==nil) {
         teamimage=[[UIImageView alloc]initWithFrame:CGRectMake(10,10 ,70, 70)];
        teamimage.contentMode=UIViewContentModeScaleAspectFill;
        teamimage.clipsToBounds=YES;
        teamimage.tag=100+1;
        [self.groupInfoView addSubview:teamimage];

    }
    [teamimage setImageURL:group.groupLogo.picFilepath
          placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(70, 70)];
    
    UIImageView *advertiseView=nil;
    float advertiseViewwith=0;
    if (group.adSwitch.boolValue) {
        advertiseView=[[UIImageView alloc]initWithFrame:CGRectMake(self.groupInfoView.width-108,teamimage.top,98, 30)];
        [advertiseView setImageURL:group.advertisement.adPic placeholderImage:IMAGE(@"xg_default_icon_click")  contentSize:CGSizeMake(110, 30)];
        advertiseView.clipsToBounds=YES;
        advertiseView.contentMode=UIViewContentModeScaleAspectFill;
        [self.groupInfoView addSubview:advertiseView];
        advertiseViewwith=108;
    }
    //小组名称
    float nameLableheight=ceilf([CMTGetStringWith_Height getTextheight:group.groupName fontsize:16 width:self.groupInfoView.width-teamimage.right-10-advertiseViewwith])>30?ceilf([CMTGetStringWith_Height getTextheight:group.groupName fontsize:15 width:self.groupInfoView.width-teamimage.right-10-advertiseViewwith]):30;
       UILabel *groupnameLable=(UILabel*)[self.groupInfoView viewWithTag:102];
      if (groupnameLable==nil) {
        groupnameLable=[[UILabel alloc]initWithFrame:CGRectMake(teamimage.right+5, teamimage.top, self.groupInfoView.width-teamimage.right-10-advertiseViewwith, nameLableheight)];
        groupnameLable.textColor=[UIColor colorWithHexString:@"#3F3F3F"];
        groupnameLable.font=[UIFont systemFontOfSize:15];
        groupnameLable.numberOfLines=0;
        groupnameLable.lineBreakMode = NSLineBreakByCharWrapping;
        groupnameLable.tag=100+2;
        [self.groupInfoView addSubview:groupnameLable];

      }
       groupnameLable.text=isEmptyString(group.groupName)?@"":group.groupName;
   
    //小组描述
    float groupDescLableheight=ceilf([CMTGetStringWith_Height getTextheight:group.groupDesc fontsize:13 width:self.groupInfoView.width-teamimage.right-10])>40?ceilf([CMTGetStringWith_Height getTextheight:group.groupDesc fontsize:14 width:self.groupInfoView.width-teamimage.right-10]):40;
    UILabel *groupDescLable=(UILabel*)[self.groupInfoView viewWithTag:103];
    if (groupDescLable==nil) {
       groupDescLable=[[UILabel alloc]initWithFrame:CGRectMake(teamimage.right+5, groupnameLable.bottom, self.groupInfoView.width-teamimage.right-10, groupDescLableheight)];
        groupDescLable.textColor=[UIColor colorWithHexString:@"#C4C4C4"];
        groupDescLable.font=[UIFont systemFontOfSize:13];
        groupDescLable.numberOfLines=0;
        groupDescLable.lineBreakMode = NSLineBreakByCharWrapping;
        groupDescLable.tag=100+3;
        [self.groupInfoView addSubview:groupDescLable];
    }
     groupDescLable.text=isEmptyString(group.groupDesc)?@"":group.groupDesc;
    
    if (group.isJoinIn.integerValue==1) {
        self.outTeanView.frame=CGRectMake(0, groupDescLable.bottom+10, self.groupInfoView.width, 60);
        self.addTeamView.hidden=YES;
        self.outTeanView.hidden=NO;
        [self drawOutTeamView];
        
        if ([self.groupInfoView viewWithTag:10002]==nil) {
            [self.groupInfoView addSubview:self.outTeanView];
        }
        self.groupInfoView.frame=CGRectMake(0,self.groupInfoView.frame.origin.y,self.groupHeadView.width,self.outTeanView.bottom);

    }else{
        
        self.addTeamView.frame=CGRectMake(0, groupDescLable.bottom+10, self.groupInfoView.width, 60);
        [self drawaddTeamView];
        self.addTeamView.hidden=NO;
        self.outTeanView.hidden=YES;
        if ([self.groupInfoView viewWithTag:10003]==nil) {
            [self.groupInfoView addSubview:self.addTeamView];
        }
       
        self.groupInfoView.frame=CGRectMake(0,self.groupInfoView.frame.origin.y,self.groupHeadView.width,self.addTeamView.bottom);
    }
    
    
}
//展示小组信息
-(void)showGroupInfoView:(UIButton*)sender{

    if (self.groupInfoView.hidden) {
            self.groupInfoView.hidden=NO;
            [sender setBackgroundImage:IMAGE(@"down-drop") forState:UIControlStateNormal];
            self.groupHeadView.frame=CGRectMake(self.groupHeadView.frame.origin.x, self.groupHeadView.frame.origin.y, self.groupHeadView.width, self.groupInfoView.bottom);
            self.groupHeadView.frame=CGRectMake(self.groupHeadView.frame.origin.x, self.groupHeadView.frame.origin.y, self.groupHeadView.width, self.groupInfoView.bottom);
            self.tableheadView.frame=CGRectMake(0, 0,SCREEN_WIDTH, self.groupHeadView.bottom);
            self.groupInfoTableView.placeholderViewOffset = [NSValue valueWithCGPoint:
                                                         CGPointMake(0.0, self.groupInfoTableView.tableHeaderView.height/2.0)];
        }else{
            [sender setBackgroundImage:IMAGE(@"drop-down") forState:UIControlStateNormal];
            self.groupInfoView.hidden=YES;
            self.groupHeadView.frame=CGRectMake(self.groupHeadView.frame.origin.x, self.groupHeadView.frame.origin.y, self.groupHeadView.width, self.groupInfoView.top);
            self.tableheadView.frame=CGRectMake(0, 0,SCREEN_WIDTH, self.groupHeadView.bottom);
            self.groupInfoTableView.placeholderViewOffset = [NSValue valueWithCGPoint:
                                                             CGPointMake(0.0, self.groupInfoTableView.tableHeaderView.height/2.0)];
        }
    self.groupInfoTableView.tableHeaderView=self.tableheadView;
      [self settipsContent];
}

//绘制加入小组视图
-(void)drawaddTeamView{
      for (UIView *view in [self.outTeanView subviews]) {
         [view removeFromSuperview];
       }
        UIView * lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.addTeamView.width, 1)];
        lineView.backgroundColor=COLOR(c_EBEBEE);
        lineView.tag=1004;
        [self.addTeamView addSubview:lineView];
  
       UIButton *  buttom=[UIButton buttonWithType:UIButtonTypeCustom];
        buttom.frame=CGRectMake(10, 10, self.addTeamView.width-20, self.addTeamView.height-20);
        buttom.backgroundColor=[UIColor colorWithHexString:@"#3CC6C1"];
        buttom.titleLabel.font=[UIFont systemFontOfSize:16];
        buttom.layer.cornerRadius=5;
        buttom.tag=1005;
        
        [buttom setTitle:@"+加入小组" forState:UIControlStateNormal];
    [buttom addTarget:self action:@selector(addAndoutTeamAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.addTeamView addSubview:buttom];
}
//加入或者退出小组
-(void)addAndoutTeamAction:(UIButton*)sender{
    if (!CMTUSER.login) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];

    }else if(self.mygroup.isJoinIn.integerValue==1){
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"确定要退出小组吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }else if(self.mygroup.isJoinIn.integerValue==2){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"你的申请已提交成功\n请耐心等待管理员审核" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        
    }else{
        [self addAndoutnetAction:sender];
    }
    
}
//代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self addAndoutnetAction:[self.outTeanView viewWithTag:1002]];
    }
}
-(void)addAndoutnetAction:(UIButton*)sender{
    @weakify(self);
    sender.userInteractionEnabled=NO;
       NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?: @"0",
                           @"groupId":self.mygroup.groupId?:@"",
                           @"flag":self.mygroup.isJoinIn,
                           };
    [[[CMTCLIENT addTeam:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTGroup * group) {
        //判断是否刷新我的小组页面
          @strongify(self);
        self.mygroup.isJoinIn=group.isJoinIn;
        self.mygroup.memberGrade=group.memberGrade;
        ((CMTGroup*)self.groupdata.groupInfo).memberGrade=group.memberGrade;
        ((CMTGroup*)self.groupdata.groupInfo).isJoinIn=group.isJoinIn;
        if (self.mygroup.isJoinIn.integerValue==2) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"你的申请已提交成功\n请耐心等待管理员审核" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
            [alert show];
            
        }else if (self.mygroup.isJoinIn.integerValue==1) {
            CMTParticiPators *part=[[CMTParticiPators alloc]init];
            part.userId=CMTUSER.userInfo.userId;
            part.nickname=CMTUSER.userInfo.nickname;
            part.picture=CMTUSER.userInfo.picture;
            part.opTime=TIMESTAMP;
            NSMutableArray *mutable=[[NSMutableArray alloc]initWithObjects:part, nil];
            NSMutableArray *muale2=[[NSMutableArray alloc ]initWithArray:self.groupdata.groupInfo.topMemList];
            for (CMTParticiPators *CMTpart in [muale2 copy]) {
                if ([CMTpart.userId isEqualToString:part.userId]) {
                    [muale2 removeObject:CMTpart];
                }
            }
            [mutable addObjectsFromArray:muale2];
            self.groupdata.groupInfo.topMemList=mutable;
            self.groupdata.groupInfo.memNum=[NSString stringWithFormat:@"%ld",(long)self.groupdata.groupInfo.memNum.integerValue+1];
            self.mygroup.memNum=[NSString stringWithFormat:@"%ld",(long)self.groupdata.groupInfo.memNum.integerValue+1];
            self.mygroup.joinTime=group.opTime;
            [self showGroupnoticeLable];
            [self CMTDrawheadView];
             self.groupInfoTableView.tableHeaderView=self.tableheadView;

            
        }else if(self.mygroup.isJoinIn.integerValue==0){
            NSMutableArray *muale2=[[NSMutableArray alloc ]initWithArray:self.groupdata.groupInfo.topMemList];
            for (CMTParticiPators *CMTpart in [muale2 copy]) {
                if ([CMTpart.userId isEqualToString:CMTUSER.userInfo.userId]) {
                    [muale2 removeObject:CMTpart];
                }
            }
            self.groupdata.groupInfo.topMemList=muale2;
            self.groupdata.groupInfo.memNum=[NSString stringWithFormat:@"%ld",(long)self.groupdata.groupInfo.memNum.intValue-1];
            [self showGroupnoticeLable];
            [self CMTDrawheadView];
            self.groupInfoTableView.tableHeaderView=self.tableheadView;
        }
        [self.groupCachDic setObject:self.groupdata forKey:self.mygroup.groupId];
        [NSKeyedArchiver archiveRootObject:self.groupCachDic toFile:PATH_CACHE_CASE_TEAM];
        [self.groupInfoTableView reloadData];
        if(self.updateGroup!=nil){
            CMTAPPCONFIG.isrefreahCase=@"0";
            self.updateGroup(self.mygroup);
        }
        sender.userInteractionEnabled=YES;


    } error:^(NSError *error) {
         @strongify(self);
        if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
            [self toastAnimation:@"你的网络不给力"];
        }else{
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
          sender.userInteractionEnabled=YES;
    } completed:^{
        
    }];

    
}
//加入成功之后小组视图
-(void)drawOutTeamView{
    for (UIView *view in [self.outTeanView subviews]) {
        [view removeFromSuperview];
    }
        UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.outTeanView.width, 1)];
        lineView.backgroundColor=COLOR(c_EBEBEE);
        lineView.tag=1001;
        [self.outTeanView addSubview:lineView];
    
        UIButton *invitationbutton=[UIButton buttonWithType:UIButtonTypeCustom];
        invitationbutton.frame=CGRectMake(10, 10, self.outTeanView.width-20, self.outTeanView.height-20);
        invitationbutton.backgroundColor=[UIColor colorWithHexString:@"#FDC744"];
        invitationbutton.titleLabel.font=[UIFont systemFontOfSize:16];
        [invitationbutton setTitle:@"邀请好友加入" forState:UIControlStateNormal];
        invitationbutton.layer.cornerRadius=5;
        invitationbutton.tag=1003;
        [invitationbutton addTarget:self action:@selector(Invitefriends) forControlEvents:UIControlEventTouchUpInside];
        [self.outTeanView addSubview:invitationbutton];
}
//邀请好友
- (void)Invitefriends{
        [self.mShareView.mBtnFriend addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.mShareView.mBtnWeix addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.mShareView.cancelBtn addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
        // 自定义分享
        [self shareViewshow:self.mShareView bgView:self.tempView currentViewController:self.navigationController];
//      self.mShareView.frame = CGRectMake(self.mShareView.left,CMTNavigationBarBottomGuide+20,self.mShareView.width, 100);
      self.mShareView.mBtnMail.hidden=YES;
      self.mShareView.mBtnSina.hidden=YES;
      self.mShareView.lbMail.hidden=YES;
      self.mShareView.lbSina.hidden=YES;
    
     self.mShareView.mBtnFriend.frame=CGRectMake((self.mShareView.width-(self.mShareView.mBtnFriend.width+self.mShareView.mBtnWeix.width))/3,self.mShareView.mBtnFriend.top,self.mShareView.mBtnFriend.width, self.mShareView.mBtnFriend.height);
    self.mShareView.lbFriend.frame=CGRectMake(self.mShareView.mBtnFriend.left-5,self.mShareView.lbFriend.top,self.mShareView.mBtnFriend.width+10, self.mShareView.lbFriend.height);

     self.mShareView.mBtnWeix.frame=CGRectMake(self.mShareView.mBtnFriend.right + self.mShareView.mBtnFriend.left,self.mShareView.mBtnWeix.top,self.mShareView.mBtnWeix.width, self.mShareView.mBtnWeix.height);
    self.mShareView.lbWeix.frame=CGRectMake(self.mShareView.mBtnWeix.left-5,self.mShareView.lbWeix.top,self.mShareView.mBtnWeix.width+10, self.mShareView.lbWeix.height);
    
    
    }
    

//绘制teamPeopleView
-(void)drawTeamPeopleView{
    CMTGroup *group=self.groupdata.groupInfo;
    NSInteger number=[group.topMemList count]>10?11:[group.topMemList count];
    NSInteger imagenumber=(number<=10?10:11);
    float partPeopleViewheight=ceilf((self.groupHeadView.width-10*(imagenumber+1))/imagenumber);
    float space=10;
    if(SCREEN_WIDTH>414){
        partPeopleViewheight=40;
        space=(self.groupHeadView.width-partPeopleViewheight*number)/(imagenumber+1);
    }
    for (UIView *view in [self.teamMember subviews]) {
        view.hidden=YES;
    }
    UIView *topLine1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.teamMember.width,1)];
    topLine1.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
    [self.teamMember addSubview:topLine1];
    for (int i=0; i<number;i++) {
        UIImageView *imageview=(UIImageView*)[self.teamMember viewWithTag:i+1];
        if (imageview==nil) {
            imageview=[[UIImageView alloc]initWithFrame:CGRectMake(space*(i+1)+partPeopleViewheight*i,10, partPeopleViewheight, partPeopleViewheight)];
            imageview.layer.cornerRadius =partPeopleViewheight/2;
            imageview.layer.masksToBounds=YES;
            imageview.contentMode=UIViewContentModeScaleAspectFill;
            imageview.tag=i+1;
        }else{
            imageview.frame=CGRectMake(space*(i+1)+partPeopleViewheight*i,10, partPeopleViewheight, partPeopleViewheight);
              imageview.hidden=NO;
        }
      
      
        if (i==10) {
            [imageview setImageURL:nil placeholderImage:IMAGE(@"caseMore")contentSize:CGSizeMake(partPeopleViewheight, partPeopleViewheight)];
        }else{
            [imageview setQuadrateScaledImageURL:((CMTParticiPators*)[group.topMemList objectAtIndex:i]).picture placeholderImage:IMAGE(@"ic_default_head") width:40.0];
        }
        [self.teamMember addSubview:imageview];
    }
   
   self.teamMember.frame=CGRectMake(self.teamMember.frame.origin.x, self.teamMember.frame.origin.y, self.teamMember.width,partPeopleViewheight+20);
    UIView *buttomLine1=[self.teamMember viewWithTag:number+2];
    if (buttomLine1==nil) {
       buttomLine1= [[UIView alloc]initWithFrame:CGRectMake(0, self.teamMember.height-1, self.teamMember.width,1)];
        buttomLine1.tag=number+2;
        buttomLine1.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
        [self.teamMember addSubview:buttomLine1];

    }
    buttomLine1.hidden=NO;
   

    
}
#pragma mark 展示小组成员
-(void)showMembers{
    
    @weakify(self);
    CMTGroupMembersViewController *members=[[CMTGroupMembersViewController alloc]initWithGroup:self.mygroup];
    members.deleteArrBlock=^(NSArray* array){
        @strongify(self);
        [self getGroupInfo];
        
    };
    members.ModifyGroupSucess=^(CMTGroup *group){
        @strongify(self);
        self.mygroup.groupDesc=group.groupDesc;
        self.mygroup.groupLogo=group.groupLogo;
        self.groupdata.groupInfo.groupDesc=group.groupDesc;
        self.groupdata.groupInfo.groupLogo=group.groupLogo;
        [self showGroupnoticeLable];
        [self CMTDrawheadView];
        self.groupInfoTableView.tableHeaderView=self.tableheadView;
        [self.groupInfoTableView reloadData];

    };
    [self.navigationController pushViewController:members animated:YES];
}
#pragma  mark 退出成功
-(void)logoutSucess:(CMTGroup *)group{
    self.mygroup.isJoinIn=group.isJoinIn;
    self.groupdata.groupInfo.isJoinIn=group.isJoinIn;
    self.mygroup.memberGrade=group.memberGrade;
    NSMutableArray *muale2=[[NSMutableArray alloc ]initWithArray:self.groupdata.groupInfo.topMemList];
    for (CMTParticiPators *CMTpart in [muale2 copy]) {
        if ([CMTpart.userId isEqualToString:CMTUSER.userInfo.userId]) {
            [muale2 removeObject:CMTpart];
        }
    }
    self.groupdata.groupInfo.topMemList=muale2;
    self.groupdata.groupInfo.memNum=[NSString stringWithFormat:@"%ld",(long)self.groupdata.groupInfo.memNum.intValue-1];
    self.mygroup.memNum=self.groupdata.groupInfo.memNum;
    [self showGroupnoticeLable];
    [self CMTDrawheadView];
    self.groupInfoTableView.tableHeaderView=self.tableheadView;
    [self.groupCachDic setObject:self.groupdata forKey:self.mygroup.groupId];
    [NSKeyedArchiver archiveRootObject:self.groupCachDic toFile:PATH_CACHE_CASE_TEAM];
    [self.groupInfoTableView reloadData];
    if(self.updateGroup!=nil){
        CMTAPPCONFIG.isrefreahCase=@"0";
        self.updateGroup(self.mygroup);
    }

}
//获取小组详情
-(void)getGroupInfo{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"groupId":self.mygroup.groupId?:@"",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"screenType":self.screenType,
                           @"onlyGroupInfo":@"1",
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    @weakify(self);
    [[[CMTCLIENT getGroupDetails:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTCaseLIstData *Casedata) {
        @strongify(self);
        if (Casedata!=nil) {
             self.groupdata.groupInfo=Casedata.groupInfo;
            [self.groupCachDic setObject: self.groupdata forKey:self.mygroup.groupId];
            if(![self.mygroup.isJoinIn isEqualToString:Casedata.groupInfo.isJoinIn]){
                self.mygroup=self.groupdata.groupInfo;
                    if (self.updateGroup!=nil) {
                     CMTAPPCONFIG.isrefreahCase=@"0";
                    self.updateGroup(self.mygroup);
                }
            }
            self.mygroup.isJoinIn=self.groupdata.groupInfo.isJoinIn;
            self.mygroup.joinTime=self.groupdata.groupInfo.joinTime;
            self.mygroup.memberGrade = self.groupdata.groupInfo.memberGrade;
            self.shareTitle=self.groupdata.groupInfo.groupName;
            self.shareBrief=self.groupdata.groupInfo.groupDesc;
            self.shareUrl=self.groupdata.groupInfo.url;
            [self showGroupnoticeLable];
            [self CMTDrawheadView];
            self.groupInfoTableView.tableHeaderView=self.tableheadView;
            //从首页跳进小组详情
            if ([self.mygroup.jumpFrom isEqualToString:@"center"]) {
                CMTAPPCONFIG.isrefreahCase=@"1";
            }
            if (self.groupdata.groupInfo.status.integerValue==1||self.groupdata.groupInfo.status.integerValue==2) {
                [self setContentState:CMTContentStateEmpty];
                self.contentEmptyView.contentEmptyPrompt=@"该小组已被解散";
                 self.navigationItem.rightBarButtonItems=nil;
            }else {
                [self setContentState:CMTContentStateNormal];
            }


        }
        [NSKeyedArchiver archiveRootObject:self.groupCachDic toFile:PATH_CACHE_CASE_TEAM];
      [self stopAnimation];
    }error:^(NSError *error) {
         @strongify(self);
        [self setContentState:CMTContentStateNormal];
        if(error.code==1001){
            self.mLbupload.text=@"暂无操作权限!";
        }
        [self stopAnimation];
    }];
    
}

//如果存在初次加载获取数据方法
-(void)getCaseLIstData{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"groupId":self.mygroup.groupId?:@"",
                           @"groupUuid":self.groupUuId?:@"",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"screenType":self.screenType,
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    @weakify(self);
    [[[CMTCLIENT getGroupDetails:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTCaseLIstData *Casedata) {
        @strongify(self);
        if (Casedata!=nil) {
            
           
             self.groupdata=Casedata;
            self.groupdata.groupInfo.noticeCount=self.mygroup.noticeCount;
            self.mygroup=[self.groupdata.groupInfo copy];
                self.titleText=self.mygroup.groupName;
                 [self.groupCachDic setObject:Casedata forKey:self.mygroup.groupId];
            if(![self.mygroup.isJoinIn isEqualToString:self.groupdata.groupInfo.isJoinIn]){
                self.mygroup=self.groupdata.groupInfo;
                if (self.updateGroup!=nil) {
                    CMTAPPCONFIG.isrefreahCase=@"0";
                    self.updateGroup(self.mygroup);
                }
            }
            self.mygroup.isJoinIn=self.groupdata.groupInfo.isJoinIn;
            self.mygroup.memberGrade = self.groupdata.groupInfo.memberGrade;
            self.mygroup.leaderCount = self.groupdata.groupInfo.leaderCount;
            if (self.groupdata.groupInfo.topMemList.count>0) {
                if([[self.groupdata.groupInfo.topMemList objectAtIndex:0]isKindOfClass:[NSArray class]]){
                    self.groupdata.groupInfo.topMemList=[self.groupdata.groupInfo.topMemList objectAtIndex:0];
                }
                
            }

            self.shareTitle=self.groupdata.groupInfo.groupName;
            self.shareBrief=self.groupdata.groupInfo.groupDesc;
            self.shareUrl=self.groupdata.groupInfo.url;
            self.topDiseaseList = [NSMutableArray arrayWithArray:Casedata.topDiseaseList];
            self.diseaseList = [NSMutableArray arrayWithArray:Casedata.diseaseList];
            NSMutableArray *mutArray = [NSMutableArray arrayWithArray:Casedata.topDiseaseList];
            [mutArray addObjectsFromArray:Casedata.diseaseList];
                self.groupCaselistArray = [mutArray mutableCopy];
                [self showGroupnoticeLable];
                [self CMTDrawheadView];
                self.groupInfoTableView.tableHeaderView=self.tableheadView;
                [self settipsContent];
                [self.groupInfoTableView reloadData];
            if (self.groupdata.groupInfo.status.integerValue==1||self.groupdata.groupInfo.status.integerValue==2) {
                 [self setContentState:CMTContentStateEmpty];
                self.contentEmptyView.contentEmptyPrompt=@"该小组已被解散";
                self.navigationItem.rightBarButtonItems=nil;
            }else {
               [self setContentState:CMTContentStateNormal];
            }
            
            
        }else{
            if(!self.ishaveCache){
                [self setContentState:CMTContentStateEmpty];
                self.contentEmptyView.contentEmptyPrompt=@"该小组不存在";
                
            }else {
                [self setContentState:CMTContentStateNormal];
            }
        }
        [NSKeyedArchiver archiveRootObject:self.groupCachDic toFile:PATH_CACHE_CASE_TEAM];
        self.ishaveCache=NO;
        [self stopAnimation];
         //从首页跳进小组详情
        
        if ([self.mygroup.jumpFrom isEqualToString:@"center"]) {
            CMTAPPCONFIG.isrefreahCase=@"1";
        }

    }error:^(NSError *error) {
        @strongify(self);
        if (!self.ishaveCache) {
            [self setContentState:CMTContentStateReload];
        }else{
            [self setContentState:CMTContentStateNormal];
        }
        if(error.code==1001){
            self.mLbupload.text=@"暂无操作权限!";
        }
        self.ishaveCache=NO;
        [self stopAnimation];
    }];
}
//筛选过滤
-(void)CMTRefreshGrouplistData{
    //每次重新刷新小组详情防止多人员操作导致的数据不统一
    [self getGroupInfo];
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"groupId":self.mygroup.groupId?:@"",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"screenType":self.screenType,
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    @weakify(self);
    [[[CMTCLIENT getGroupCaseFilter:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTCaseLIstData *Casedata) {
        @strongify(self);
           self.groupdata=Casedata;
          self.topDiseaseList = [NSMutableArray arrayWithArray:Casedata.topDiseaseList];
          self.diseaseList = [NSMutableArray arrayWithArray:Casedata.diseaseList];
            NSMutableArray *arr = [NSMutableArray arrayWithArray:Casedata.topDiseaseList];
            [arr  addObjectsFromArray:Casedata.diseaseList];
            self.groupCaselistArray= arr;
            [self settipsContent];
            [self.groupInfoTableView reloadData];
      }error:^(NSError *error) {
           @strongify(self);
          if (error.code>=-1009&&error.code<=-1001) {
              [self toastAnimation:@"你的网络不给力"];
          }else{
             NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            [self toastAnimation:errMes];
          }
        NSLog(@"过滤失败");
    }];

    
}
#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self getCaseLIstData];
}


//下拉刷新数据方法
-(void)CMTPullToGroupInfoRefresh{
    @weakify(self);
    [self.groupInfoTableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTPost *post=[[CMTPost alloc]init];
          post.incrId=@"0";
        if (self.groupdata.diseaseList.count>0) {
            post=[self.groupdata.diseaseList objectAtIndex:0];
        }
       
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"groupId":self.mygroup.groupId?:@"0",
                               @"incrId":post.incrId?: @"",
                               @"incrIdFlag":@"0",
                               @"screenType":self.screenType,
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"30",
                               };
        @weakify(self);
        [[[CMTCLIENT getGroupCaseFilter:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTCaseLIstData *Casedata) {
            CMTLog(@"jsjsjsjsjjs%@",Casedata);
            @strongify(self);
            if ([Casedata.diseaseList  count]>0 || [Casedata.topDiseaseList count]  > 0 ) {
                NSMutableArray *casetableArray=[[NSMutableArray alloc]initWithArray:Casedata.diseaseList];
                 [casetableArray addObjectsFromArray:self.diseaseList];
                
               
                if(Casedata.topDiseaseList.count>0){
                    self.topDiseaseList=[[NSMutableArray alloc]initWithArray:Casedata.topDiseaseList];
                }
                self.diseaseList=[casetableArray mutableCopy];
                
                NSMutableArray *arr = [NSMutableArray arrayWithArray:self.topDiseaseList];
                [arr addObjectsFromArray:casetableArray];
                
                self.groupCaselistArray= [arr mutableCopy];
                
                self.groupdata.diseaseList=[self.diseaseList copy];
                [self.groupInfoTableView reloadData];
                [self setContentState:CMTContentStateNormal];
                [self.groupCachDic setObject:Casedata forKey:self.mygroup.groupId];
                [NSKeyedArchiver archiveRootObject:self.groupCachDic toFile:PATH_CACHE_CASE_TEAM];
                casetableArray=nil;
            }
             if ([Casedata.diseaseList  count]==0) {
                  [self toastAnimation:@"没有最新文章"];
             }
            [self.groupInfoTableView.pullToRefreshView stopAnimating];
        }error:^(NSError *error) {
            @strongify(self);
            NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            [self toastAnimation:errMes];
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.groupInfoTableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
}

//上拉翻页
-(void)CMTnfIniteGroupInfoRefresh{
    @weakify(self);
    [self.groupInfoTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        if(self.groupCaselistArray.count==0){
            [self.groupInfoTableView.infiniteScrollingView stopAnimating];
            return ;
        }

        CMTPost *post=[[CMTPost alloc]init];
        if (self.groupdata.diseaseList.count>0) {
            post=self.groupdata.diseaseList.lastObject;
        }
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?: @"0",
                               @"groupId":self.mygroup.groupId ?: @"",
                               @"incrId":post.incrId?:@"",
                               @"incrIdFlag":@"1",
                               @"screenType":self.screenType,
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               @"module":@"1"
                               };
        @weakify(self);
        [[[CMTCLIENT getGroupCaseFilter:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTCaseLIstData *Casedata) {
            @strongify(self);
            if ([Casedata.diseaseList  count]>0) {
                [self.diseaseList addObjectsFromArray:Casedata.diseaseList];
                NSMutableArray *arr = [NSMutableArray arrayWithArray:self.topDiseaseList];
                [arr addObjectsFromArray:self.diseaseList];
                self.groupCaselistArray=[arr  mutableCopy];
                [self.groupInfoTableView reloadData];
                self.groupdata.diseaseList=[self.diseaseList copy];
                [self setContentState:CMTContentStateNormal];
                [self.groupCachDic setObject:Casedata forKey:self.mygroup.groupId];
                [NSKeyedArchiver archiveRootObject: self.groupCachDic toFile:PATH_CACHE_CASE_TEAM];
            }else{
                [self toastAnimation:@"没有更多文章"];
            }
            
            [self.groupInfoTableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            @strongify(self);
            NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            [self toastAnimation:errMes];
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.groupInfoTableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
    
    
}
#pragma tableView  dataSource代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return [self.groupCaselistArray count];
  
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
           UIView *view=nil;
            view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
            view.backgroundColor=COLOR(c_efeff4);
            UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, view.width-60, 30)];
            lable.text=self.filterTypeName;
            lable.font=[UIFont systemFontOfSize:14];
            lable.textColor=[UIColor colorWithHexString:@"#ADADAD"];
            [view addSubview:lable];
    
            self.filterbutton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-47, 1.5, 27, 27)];
            [ self.filterbutton setBackgroundImage:[UIImage imageNamed:@"caseMore"] forState:UIControlStateNormal];
            [ self.filterbutton setTitleColor:[UIColor colorWithHexString:@"#75D2D1"] forState:UIControlStateNormal];
            [ self.filterbutton addTarget:self action:@selector(CMTPostfiltered:) forControlEvents:UIControlEventTouchUpInside];
            [ view addSubview:self.filterbutton];
    
          return view;
}
//过滤
-(void)CMTPostfiltered:(UIButton*)sender{
    if (self.filterView==nil) {
        self.groupInfoTableView.scrollEnabled=NO;
        self.bgview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.groupInfoTableView.width,  [sender superview].bottom+self.groupInfoTableView.height)];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelFilterdView)];
        [self.bgview addGestureRecognizer:tap];
        [self.groupInfoTableView addSubview:self.bgview];
        self.filterView=[[CMTCasefilterView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-140, [sender superview].bottom-10, 130,130)];
        self.filterView.layer.cornerRadius=5;
        self.filterView.delegate=self;
        [self.groupInfoTableView addSubview:_filterView];
    }else{
        [self cancelFilterdView];
    }
}
//取消过滤
-(void)cancelFilterdView{
    self.groupInfoTableView.scrollEnabled=YES;
    [self.bgview removeFromSuperview];
    [self.filterView removeFromSuperview];
    self.filterView=nil;
    self.bgview=nil;
}
//过滤页面代理
-(void)filterData:(NSInteger)index{
    [self cancelFilterdView];
    self.screenType=[@"" stringByAppendingFormat:@"%ld",(long)index];
    [self CMTRefreshGrouplistData];
    NSArray *arry=[[NSArray alloc]initWithObjects:@"最新讨论",@"推荐",@"有结论的讨论", nil];
    self.filterTypeName=[arry objectAtIndex:index];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     NSString * const CMTCellListCellIdentifier = @"CMTCellListCellTeam";
        CMTCaseListCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellListCellIdentifier];
        if(cell==nil){
            cell=[[CMTCaseListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
        }
        CMTPost *post=[[self.groupCaselistArray mutableCopy] objectAtIndex:indexPath.row];
        post.groupId=@"";
        cell.ishaveSectionHeadView=YES;
        cell.lastController=self;
        cell.ISCanShowBigImage=(self.mygroup.isJoinIn.integerValue==1||self.mygroup.groupType.integerValue==0)?YES:NO;
        cell.delegate=self;
        [cell reloadCaseCell:post index:indexPath];
    
    //设置选中颜色区域
    if (cell.selectedBackgroundView.tag==1000) {
        cell.selectedBackgroundView.frame=cell.frame;
        [cell.selectedBackgroundView viewWithTag:10001].frame=CGRectMake(cell.insets.left, cell.insets.top, cell.frame.size.width-cell.insets.left-cell.insets.right, cell.frame.size.height-cell.insets.top-cell.insets.bottom);
        }else{
            UIView *view=[[UIView alloc]initWithFrame:cell.frame];
             view.tag=1000;
            UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(cell.insets.left, cell.insets.top, cell.frame.size.width-cell.insets.left-cell.insets.right, cell.frame.size.height-cell.insets.top-cell.insets.bottom)];
            backView.tag=10001;
            backView.backgroundColor=[UIColor colorWithHexString:@"#d9d9d9"];
            [view addSubview:backView];
             cell.selectedBackgroundView=view;
    }
        return cell;
        
   }
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (self.mygroup.isJoinIn.integerValue!=1 && self.mygroup.groupType.integerValue != 0) {
            [self toastAnimation:@"你还未加入该小组"];
            return;
        }
    
        //病例详情
        CMTPost *post = [self.groupCaselistArray objectAtIndex:indexPath.row];
        CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                    isHTML:post.isHTML
                                                                    postURL:post.url
                                                                    group:self.mygroup
                                                                    postModule:post.module
                                                                    postDetailType:CMTPostDetailTypeCaseGroup];
        @weakify(self);
        postDetailCenter.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
            @strongify(self);
            [self updatePost:post withPostStatistics:postStatistics];
        };
    postDetailCenter.ShieldingArticleSucess=^(CMTPost *post1){
        @strongify(self);
        [self.topDiseaseList removeAllObjects];
        [self.diseaseList removeAllObjects];
        [self.groupCaselistArray removeAllObjects];
        [self getCaseLIstData];
       
      };
     postDetailCenter.PlacedTheTopSucess=^(CMTPost *post1){
        @strongify(self);
         [self.topDiseaseList removeAllObjects];
         [self.diseaseList removeAllObjects];
         [self.groupCaselistArray removeAllObjects];
        [self getCaseLIstData];
     };

        [self.navigationController pushViewController:postDetailCenter animated:YES];
}


//点击赞的操作
-(void)CMTSomePraise:(BOOL)ISCancelPraise index:(NSIndexPath*)indexpath{
        if (self.mygroup.isJoinIn.integerValue!=1 && self.mygroup.groupType.integerValue != 0) {
            [self toastAnimation:@"你还未加入该小组"];
            return;
        }
        if (!CMTUSER.login) {
        CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
        [self.navigationController pushViewController:bing animated:YES];
        return;
        }
        CMTPost *post=[self.groupCaselistArray objectAtIndex:indexpath.row];
        @weakify(self)
        NSDictionary *params=@{
                               @"userId":CMTUSERINFO.userId ?:@"0",
                               @"praiseType":@"4",
                               @"postId":post.postId,
                               @"cancelFlag":!post.isPraise.boolValue?@"0":@"1"
                               };
        
        [[[CMTCLIENT Praise:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            @strongify(self)
            [self changepost:post];
            if (ISCancelPraise) {
                post.isPraise=@"1";
                post.praiseCount=[@"" stringByAppendingFormat:@"%ld",(long)post.praiseCount.integerValue+1];
            }else{
                post.isPraise=@"0";
                post.praiseCount=[@"" stringByAppendingFormat:@"%ld",(long)(post.praiseCount.integerValue-1>0?post.praiseCount.integerValue-1:0)];
                
            }
            [self.groupInfoTableView reloadData];
            [self saveCachePostList];
            
        } error:^(NSError *error) {
            if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                 [self toastAnimation:error.userInfo[@"errmsg"]];
            }
            
        }completed:^{
            
        }];
    
}
//改变文章对象
-(void)changepost:(CMTPost*)post{
    CMTParticiPators *part=[[CMTParticiPators alloc]init];
    part.userId=CMTUSER.userInfo.userId;
    part.nickname=CMTUSER.userInfo.nickname;
    part.picture=CMTUSER.userInfo.picture;
    part.opTime=TIMESTAMP;
    NSMutableArray *mutable=[[NSMutableArray alloc]initWithObjects:part, nil];
    NSMutableArray *muale2=[[NSMutableArray alloc ]initWithArray:post.participators];
    for (CMTParticiPators *CMTpart in [muale2 copy]) {
        if ([CMTpart.userId isEqualToString:part.userId]) {
            [muale2 removeObject:CMTpart];
        }
    }
    [mutable addObjectsFromArray:muale2];
    post.participators=mutable;
}

// 文章列表 手动缓存
- (void)saveCachePostList {
    @weakify(self);
    [[RACScheduler scheduler] schedule:^{
        @strongify(self);
        // 存储
        if (![NSKeyedArchiver archiveRootObject:self.groupCachDic toFile:PATH_CACHE_CASE_TEAM]) {
            CMTLogError(@"PostList Archive PostList:%@\nto Store Error: %@", self.groupCachDic, PATH_CACHE_CASE_TEAM);
        }
    }];
}

//点击评论
-(void)CMTClickComments:(NSIndexPath*)indexPath{
        if (self.mygroup.isJoinIn.integerValue!=1 && self.mygroup.groupType.integerValue != 0) {
            [self toastAnimation:@"你还未加入该小组"];
            return;
        }
        if (!CMTUSER.login) {
        CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
        [self.navigationController pushViewController:bing animated:YES];
        return;
        }
        CMTPost *post=[self.groupCaselistArray objectAtIndex:indexPath.row];
        CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                   isHTML:post.isHTML
                                                                                  postURL:post.url
                                                                                group:self.mygroup
                                                                               postModule:post.module
                                                                           postDetailType:(post.commentCount.integerValue>0?CMTPostDetailTypeCaseListSeeReply:CMTPostDetailTypeCaseListWithReply)];
        @weakify(self);
        postDetailCenter.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
            @strongify(self);
            [self updatePost:post withPostStatistics:postStatistics];
        };
       postDetailCenter.ShieldingArticleSucess=^(CMTPost *post1){
              @strongify(self);
           [self.topDiseaseList removeAllObjects];
           [self.diseaseList removeAllObjects];
           [self.groupCaselistArray removeAllObjects];
           [self getCaseLIstData];
       };
       postDetailCenter.PlacedTheTopSucess=^(CMTPost *post1){
              @strongify(self);
           [self.topDiseaseList removeAllObjects];
           [self.diseaseList removeAllObjects];
           [self.groupCaselistArray removeAllObjects];
           [self getCaseLIstData];
       };
    
        [self.navigationController pushViewController:postDetailCenter animated:YES];
}
- (void)updatePost:(CMTPost *)post withPostStatistics:(CMTPostStatistics *)postStatistics {
    
    // 刷新文章
    post.heat = postStatistics.heat;
    post.postAttr = postStatistics.postAttr;
    post.themeStatus = postStatistics.themeStatus;
    post.themeId = postStatistics.themeId;
    post.commentCount=postStatistics.commentCount;
    post.praiseCount=postStatistics.praiseCount;
    post.isPraise=postStatistics.isPraise;
    if([postStatistics.commentModified boolValue]){
        [self changepost:post];
    }
    
    // 刷新文章列表
    [self.groupInfoTableView reloadData];
    
    // 保存文章列表
    [self saveCachePostList];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)showShare:(UIButton *)btn
{
    [MobClick event:@"B_lunBa_Invite"];

    [self methodShare:btn];
}

///平台按钮关联的分享方法
- (void)methodShare:(UIButton *)btn {
    // 没有网络连接
    if (!NET_WIFI && !NET_CELL && btn.tag != 5555) {
        [self toastAnimation:@"你的网络不给力"];
        [self shareViewDisapper];
        return;
    }
    
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
           default:
            CMTLog(@"其他分享");
            break;
    }
    if ([self respondsToSelector:@selector(removeTargets)]) {
        [self performSelector:@selector(removeTargets) withObject:nil afterDelay:0.2];
    }
    
    [self shareViewDisapper];
}
- (void)removeTargets
{
    [self.mShareView.mBtnFriend removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
}
/// 朋友圈分享
- (void)friendCircleShare
{
    NSString *shareType = @"1";
    CMTLog(@"朋友圈");
   NSString *shareText =[CMTUSER.userInfo.userId isEqualToString:self.mygroup.createUserId]?[@"我创建了【" stringByAppendingFormat:@"%@】讨论组 ，邀请你一起来讨论!",self.mygroup.groupName]:[@"我加入了【"stringByAppendingFormat:@"%@ 】讨论组，你也来吧!",self.mygroup.groupName];
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:self.mygroup.groupDesc sharetype:shareType sharepic:CMTUSERINFO.picture shareUrl:self.shareUrl StatisticalType:@"groupinfo" shareData:self.groupdata];
}
/// 微信好友分享
- (void)weixinShare
{
    NSString *shareType = @"2";
    NSString *shareText =[CMTUSER.userInfo.userId isEqualToString:self.mygroup.createUserId]?[@"我创建了【" stringByAppendingFormat:@"%@】讨论组 ，邀请你一起来讨论!",self.mygroup.groupName]:[@"我加入了【"stringByAppendingFormat:@"%@ 】讨论组，你也来吧!",self.mygroup.groupName];
    NSString *shareURL = self.shareUrl;
    if (BEMPTY(shareText)) {
        shareText =@"壹生文章分享";
    }
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareText sharetext:self.mygroup.groupDesc sharetype:shareType sharepic:CMTUSERINFO.picture shareUrl:shareURL StatisticalType:@"groupinfo" shareData:self.groupdata];
}
@end

