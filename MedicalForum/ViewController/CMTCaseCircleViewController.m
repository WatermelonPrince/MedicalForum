//
//  CMTCaseCircleViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/10/9.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTCaseCircleViewController.h"
#import "CMTBindingViewController.h"
#import "CMTGroupInfoViewController.h"
#import "CMTBarButtonItem.h"
#import "CMTBadge.h"
#import "CMTCaseSystemNoticeViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTCaseSearchViewController.h"
#import "CMTGroupTypeChoiceTableViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTGroupDisclaimerViewController.h"

NSString * const CMTCaseCircleIdentifier = @"CMTCellListCell";
static NSString * const CMTCaseListRequestDefaultPageSize = @"30";



@interface CMTCaseCircleViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) CMTTabBar *bottomTabBar; //底部导航条按钮
@property(nonatomic,strong)UITableView *GrouptableView; //小组列表
@property(nonatomic,strong)NSMutableArray *GrouplistArray; //未加入的小组
@property(nonatomic,strong)NSMutableArray *GroupALLlistArray; //全部小组接口
@property(nonatomic,strong)NSMutableArray *GroupJoinlistArray; //已经加入的小组
@property(nonatomic,strong)NSString *concernIds;  //已经订阅的学课id
@property (nonatomic, strong) CMTBarButtonItem *NavleftItem;//打开左侧栏按钮
@property (nonatomic, strong) NSArray *leftItems;                               // 导航左侧按钮
@property (nonatomic, strong) CMTHomePageSideBar *sideBar;                      // 侧边栏
@property (nonatomic, strong)CMTBarButtonItem *NavRightItem;//系统通知导航按钮
@property (nonatomic, strong)NSArray *rightItems;//导航items数组
@property(nonatomic,strong)CMTGroup *mygroup;
@property(nonatomic,strong)UIBarButtonItem *creatbarItem;
@property(nonatomic,strong)UIButton *creatbutton;

@end

@implementation CMTCaseCircleViewController
//底部按钮
- (CMTTabBar *)bottomTabBar {
    if (_bottomTabBar == nil) {
        _bottomTabBar = [[CMTTabBar alloc] init];
        [_bottomTabBar fillinContainer:self.tabBarContainer WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        _bottomTabBar.backgroundColor = COLOR(c_clear);
        self.tabBarContainer.hidden = NO;
    }
    
    return _bottomTabBar;
}
- (CMTBarButtonItem *)NavleftItem {
    if (_NavleftItem == nil) {
        CMTBadgePoint *badge = [[CMTBadgePoint alloc] init];
        badge.frame = CGRectMake(22,-2, kCMTBadgeWidth, kCMTBadgeWidth);
        badge.hidden = YES;
        _NavleftItem = [CMTBarButtonItem itemWithImage:IMAGE(@"caseSearch") badge:badge imageEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
    }
    
    return _NavleftItem;
}
-(UIBarButtonItem*)creatbarItem{
    if (_creatbarItem==nil) {
        self.creatbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 30)];
        [ self.creatbutton setTitle:@"创建" forState:UIControlStateNormal];
         self.creatbutton.titleLabel.font=[UIFont boldSystemFontOfSize:18];
        [ self.creatbutton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        [ self.creatbutton addTarget:self action:@selector(creatGroupAction)  forControlEvents:UIControlEventTouchUpInside];
        _creatbarItem=[[UIBarButtonItem alloc]initWithCustomView: self.creatbutton];
    }
    return _creatbarItem;
}
- (NSArray *)leftItems {
    if (_leftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _leftItems = @[leftFixedSpace, self.NavleftItem];
    }
    
    return _leftItems;
}

- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
       FixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        if(CMTAPPCONFIG.CaseSystemNoticeNumber.integerValue != 0){
            _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.creatbarItem,self.NavRightItem, nil];
            self.NavRightItem.badgeValue.text=CMTAPPCONFIG.CaseSystemNoticeNumber;
        }else{
            _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.creatbarItem, nil];;
            
        }
    }
    
    return _rightItems;
}

-(CMTBarButtonItem*)NavRightItem{
    if (_NavRightItem==nil) {
        CMTBadge *badge = [[CMTBadge alloc] init];
        badge.frame = CGRectMake(15,-5.5, kCMTBadgeWidth,kCMTBadgeWidth);
        badge.hidden = NO;
        _NavRightItem = [CMTBarButtonItem itemWithImage:IMAGE(@"bell")  badgeValue:badge imageEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];    }
    
    return _NavRightItem;
}

//列表
-(UITableView*)GrouptableView{
    if (_GrouptableView==nil) {
        _GrouptableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, self.contentBaseView.height-CMTNavigationBarBottomGuide-CMTTabBarHeight)];
        _GrouptableView.backgroundColor = COLOR(c_efeff4);
        _GrouptableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _GrouptableView.dataSource = self;
        _GrouptableView.delegate = self;
        [_GrouptableView registerClass:[CMTCaseGroupTableViewCell class]forCellReuseIdentifier:CMTCaseCircleIdentifier];
        [self.contentBaseView addSubview:_GrouptableView];
    }
    return _GrouptableView;
}
//未加入的小组
-(NSMutableArray*)GrouplistArray{
    if (_GrouplistArray==nil) {
        _GrouplistArray=[[NSMutableArray alloc]init];
    }
    return _GrouplistArray;
}
//已经加入的小组
-(NSMutableArray*)GroupJoinlistArray{
    if (_GroupJoinlistArray==nil) {
        _GroupJoinlistArray=[[NSMutableArray alloc]init];
    }
    return _GroupJoinlistArray;
}
//全部小组数据
-(NSMutableArray*)GroupALLlistArray{
    if (_GroupALLlistArray==nil) {
        _GroupALLlistArray=[[NSMutableArray alloc]init];
    }
    return _GroupALLlistArray;
}


- (CMTHomePageSideBar *)sideBar {
    if (_sideBar == nil) {
        _sideBar = [[CMTHomePageSideBar alloc] initWithModel:@"1"];
    }
    
    return _sideBar;
}
#pragma 控制器生命周期
-(void)viewDidLoad{
    
    [super viewDidLoad];
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal");
    }];
    self.titleText=@"论吧";
    //跳立方
    [self setContentState:CMTContentStateLoading];
    
#pragma mark--点击导航栏消息按钮
    self.navigationItem.rightBarButtonItems = self.rightItems;
    [self.NavRightItem.touchSignal subscribeNext:^(id x) {
        CMTCaseSystemNoticeViewController *caseSystemNoticeController = [[CMTCaseSystemNoticeViewController alloc]init];
        
        caseSystemNoticeController.updateNoticeCount=^(){
            [CMTAPPCONFIG updateCaseSysNoticeUnreadNumber];
        };
        
        [self.navigationController pushViewController:caseSystemNoticeController animated:YES];
        
    }];
    [RACObserve(CMTAPPCONFIG, CaseSystemNoticeNumber)subscribeNext:^(id x) {
        @strongify(self);
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
          FixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        if(CMTAPPCONFIG.CaseSystemNoticeNumber.integerValue!=0){
            _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.creatbarItem, self.NavRightItem,nil];
            self.NavRightItem.badgeValue.text=CMTAPPCONFIG.CaseSystemNoticeNumber;
        }else{
            _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.creatbarItem, nil];
            
        }
        self.navigationItem.rightBarButtonItems=self.rightItems;

        
    } completed:^{
        
    }];
    // 点击左侧栏按钮
    [self.NavleftItem.touchSignal subscribeNext:^(id x) {
        CMTCaseSearchViewController *caseSearch=[[CMTCaseSearchViewController alloc]init];
        [self.navigationController pushViewController:caseSearch animated:YES];
        
    }];
    
    
    
    self.bottomTabBar.selectedIndex=1;
    // 未读专题文章数
    RACSignal *themeUnreadNumberSignal = [RACObserve(CMTAPPCONFIG, UnreadCaseNumber_Slide) ignore:nil];
    // 导航栏标记红点
    [[themeUnreadNumberSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        self.NavleftItem.badge.hidden =CMTAPPCONFIG.UnreadCaseNumber_Slide.integerValue==0;
    }];
    if(CMTAPPCONFIG.reachability.integerValue==0){
        if ([[NSFileManager defaultManager]fileExistsAtPath:PATH_CACHE_ALL_TEAM])
        {
            NSArray  *listdata=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_ALL_TEAM];
            self.GroupALLlistArray=[listdata mutableCopy];
            [self creatData];
            [self.GrouptableView reloadData];
            [self setContentState:CMTContentStateNormal];
            [self stopAnimation];
        }

    }else{
         //强制刷新小组
         [self getCaseTeamlistData];
        [self CMTnfIniteRefresh];
    }
    self.navigationItem.leftBarButtonItems = self.leftItems;
   
#pragma mark 网络判断
    [[RACObserve(CMTAPPCONFIG, reachability)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
            self.mToastView.backgroundColor = COLOR(c_f07e7e);
            self.mToastView.mLbContent.text = @"无法连接到网络, 请检查网络设置";
            self.mToastView.netImageView.hidden = NO;
            [self.view addSubview:self.mToastView];
            self.mToastView.alpha = 1.0;
            // pullToRefreshView stopAnimating 会使tableView contentOffset回复到初始值 所以次处不能使用contentInset做位移
            self.GrouptableView.frame=CGRectMake(0, CMTNavigationBarBottomGuide+self.mToastView.height, SCREEN_WIDTH, self.contentBaseView.height-CMTNavigationBarBottomGuide-CMTTabBarHeight);
        }
        else if ([CMTAPPCONFIG.reachability isEqual:@"1"]||[CMTAPPCONFIG.reachability isEqual:@"2"]) {
            self.mToastView.netImageView.hidden = YES;
            self.mToastView.alpha = 0.0;
            self.mToastView.backgroundColor = COLOR(c_fbc36b);
            self.GrouptableView.frame=CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, self.contentBaseView.height-CMTNavigationBarBottomGuide-CMTTabBarHeight);
        }
        else {
            CMTLogError(@"APPCONFIG Reachability Error Value: %@", CMTAPPCONFIG.reachability);
        }
    }];
    //监听是否登陆
    [[[RACObserve(CMTUSER, login)distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        if (!CMTUSER.login) {
            self.creatbutton.userInteractionEnabled=YES;
            [ self.creatbutton setTitle:@"创建" forState:UIControlStateNormal];
            [ self.creatbutton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        }
        
    } error:^(NSError *error) {
        
    } completed:^{
        
    }];
    //监听创建按钮状态
    [[[RACObserve(CMTAPPCONFIG,updateCreatebutton)distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        if (CMTAPPCONFIG.updateCreatebutton.integerValue==1) {
            if ([CMTUSER.userInfo.authStatus isEqualToString:@"5"]) {
                self.creatbutton.userInteractionEnabled=NO;
                [ self.creatbutton setTitle:@"等待" forState:UIControlStateNormal];
                [ self.creatbutton setTitleColor:[UIColor colorWithHexString:@"#d4d4d4"] forState:UIControlStateNormal];
                
            }else{
                if (![CMTUSER.userInfo.authStatus isEqualToString:@"5"]){
                    self.creatbutton.userInteractionEnabled=YES;
                    [ self.creatbutton setTitle:@"创建" forState:UIControlStateNormal];
                    [ self.creatbutton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
                }
                
            }
            CMTAPPCONFIG.updateCreatebutton=@"0";
        }
   } error:^(NSError *error) {
       
   } completed:^{
       
   }];

  }
//呈现加载数据
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //强制涮新页面
    if ([CMTAPPCONFIG.refreshmodel isEqualToString:@"1"]||[CMTAPPCONFIG.isrefreahCase isEqualToString:@"1"]) {
        if (CMTUSER.login) {
            [self setContentState:CMTContentStateLoading];
            [self getCaseTeamlistData];
        }else{
            [self.GroupJoinlistArray removeAllObjects];
            self.GrouplistArray=self.GroupALLlistArray;
            CMTAPPCONFIG.CaseSystemNoticeNumber=@"0";
            CMTAPPCONFIG.CaseNoticeNumber=@"0";
            [self.GrouptableView reloadData];
        }
        
        CMTAPPCONFIG.refreshmodel=@"0";
        CMTAPPCONFIG.isrefreahCase=@"0";
    }
    if (CMTUSER.userInfo.authStatus.integerValue==5) {
        [CMTAPPCONFIG updateCaseSysNoticeUnreadNumber];
    }
    if (CMTUSER.login) {
        if ([CMTUSER.userInfo.authStatus isEqualToString:@"5"]) {
            self.creatbutton.userInteractionEnabled=NO;
            [ self.creatbutton setTitle:@"等待" forState:UIControlStateNormal];
            [ self.creatbutton setTitleColor:[UIColor colorWithHexString:@"#d4d4d4"] forState:UIControlStateNormal];
            
        }else{
            if (![CMTUSER.userInfo.authStatus isEqualToString:@"5"]){
                self.creatbutton.userInteractionEnabled=YES;
                [ self.creatbutton setTitle:@"创建" forState:UIControlStateNormal];
                [ self.creatbutton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
            }
            
        }
    }else{
            self.creatbutton.userInteractionEnabled=YES;
            [ self.creatbutton setTitle:@"创建" forState:UIControlStateNormal];
            [ self.creatbutton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CaseAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

}
#pragma 从后台切换到前台 刷新小组列表
-(void)CaseAppDidBecomeActive:(NSNotification *)aNotification{
    if (CMTAPPCONFIG.isrefreahGroupList) {
        if (CMTUSER.login) {
            [self setContentState:CMTContentStateLoading];
            [self getCaseTeamlistData];
        }else{
            [self.GroupJoinlistArray removeAllObjects];
            self.GrouplistArray=self.GroupALLlistArray;
            CMTAPPCONFIG.CaseSystemNoticeNumber=@"0";
            CMTAPPCONFIG.CaseNoticeNumber=@"0";
            [self.GrouptableView reloadData];
        }
        CMTAPPCONFIG.isrefreahGroupList=NO;
    }

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}
#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self getCaseTeamlistData];
}
#pragma mark 创建小组
-(void)creatGroupAction{
    if (CMTUSERINFO.authStatus.integerValue==7) {
         [MobClick event:@"B_lunBa_SetUp"];
        CMTGroupDisclaimerViewController *disclaimerVC = [[CMTGroupDisclaimerViewController alloc]init];
        [self.navigationController pushViewController:disclaimerVC animated:YES];
    }else{
        if (!CMTUSER.login) {
            CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
            bing.nextvc=kComment;
            [self.navigationController pushViewController:bing animated:YES];
            return;
        }
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"暂无创建小组权限\n认证后可创建小组" message:nil delegate:nil
                                           cancelButtonTitle:@"取消" otherButtonTitles:@"去完善信息", nil];
        [alert show];
        @weakify(self);
        [[alert rac_buttonClickedSignal]subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if (index.integerValue == 1) {
                
                [MobClick event:@"B_lunBa_Certificate"];
            CMTUpgradeViewController *upgradeVC = [[CMTUpgradeViewController alloc]init];
                upgradeVC.updateCreatebuttonState=^(NSString* state){
                    CMTUSERINFO.authStatus=state;
                };
            upgradeVC.lastVC = @"CaseCircle";
            [self.navigationController pushViewController:upgradeVC animated:YES];
            }
        }];


    }
   
  
}
//获取所有小组
-(void)getCaseTeamlistData{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"incrId":@"0",
                           @"followSubjectIds":@"",
                           @"incrIdFlag":@"0",
                           @"isPrivate":@"1",
                           @"type":@"0",
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    @weakify(self);
    [[[CMTCLIENT getOpenGroupList:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamArray) {
        @strongify(self);
        if ([teamArray count]>0) {
            self.GroupALLlistArray=[teamArray mutableCopy];
            
            [self creatData];
            [self.GrouptableView reloadData];
            
            [self setContentState:CMTContentStateNormal];
            
        }else{
                [self setContentState:CMTContentStateEmpty];
                self.contentEmptyView.contentEmptyPrompt=@"没有小组存在";
                
        }
        [NSKeyedArchiver archiveRootObject:self.GroupALLlistArray toFile:PATH_CACHE_ALL_TEAM];
        [self stopAnimation];
    }error:^(NSError *error) {
        @strongify(self);
            [self setContentState:CMTContentStateReload];
    
        [self stopAnimation];
    }];
}


//上拉翻页
-(void)CMTnfIniteRefresh{
    @weakify(self);
    [self.GrouptableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTGroup *group=self.GroupALLlistArray.lastObject;
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?: @"0",
                               @"incrId":group.incrId?:@"0",
                               @"followSubjectIds":self.concernIds ?: @"",
                               @"incrIdFlag":@"1",
                               @"type":@"2",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [self.rac_deallocDisposable addDisposable:[[[CMTCLIENT getOpenGroupList:params]deliverOn:[RACScheduler scheduler]]subscribeNext:^(NSArray *listdata) {
            @strongify(self);
            if ([listdata count]>0) {
                [self.GroupALLlistArray addObjectsFromArray:listdata];
                self.GroupALLlistArray=[self.GroupALLlistArray mutableCopy];
                [self creatData];
                  dispatch_async(dispatch_get_main_queue(), ^{
                          [self.GrouptableView reloadData];
                       [self setContentState:CMTContentStateNormal];
                       [self.GrouptableView.infiniteScrollingView stopAnimating];
                       [NSKeyedArchiver archiveRootObject: self.GroupALLlistArray toFile:PATH_CACHE_ALL_TEAM];
                  });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self toastAnimation:@"没有更多小组"];
                     [self.GrouptableView.infiniteScrollingView stopAnimating];
                });
               
            }
            
           
            
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.GrouptableView.infiniteScrollingView stopAnimating];
            });
           
            
        }]];
    }];
    
    
}
//创建加入和未加入小组的数据
-(void)creatData{
    [self.GroupJoinlistArray removeAllObjects];
    [self.GrouplistArray removeAllObjects];
    for (CMTGroup *group in self.GroupALLlistArray) {
        if (group.isJoinIn.integerValue==1&&CMTUSER.login) {
            [self.GroupJoinlistArray addObject:group];
        }else{
            [self.GrouplistArray addObject:group];
        }
    }
    if ([self.GroupJoinlistArray count]>0) {
        self.GroupJoinlistArray = [[[self.GroupJoinlistArray mutableCopy] sortedArrayUsingComparator:^NSComparisonResult(CMTGroup* obj1, CMTGroup* obj2) {
            return [obj2.joinTime compare:obj1.joinTime options:NSCaseInsensitiveSearch];
        }]mutableCopy];

    }
  
}

#pragma tableView  dataSource代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        if ([self.GroupJoinlistArray count]>0) {
            return [self.GroupJoinlistArray count];
        }else{
            return [self.GrouplistArray count];
        }
    }else{
        return [self.GrouplistArray count];
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTCaseGroupTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCaseCircleIdentifier];
    if (cell==nil) {
        cell=[[CMTCaseGroupTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CMTCaseCircleIdentifier];
    }
    if (indexPath.section==0) {
        if ([self.GroupJoinlistArray count]>0) {
            CMTGroup *group=[self.GroupJoinlistArray objectAtIndex:indexPath.row];
            [cell reloadSelectGroupCell:group];
            cell.groupName.textColor = ColorWithHexStringIndex(c_000000);
        }else{
            CMTGroup *group=[self.GrouplistArray objectAtIndex:indexPath.row];
            [cell reloadCell:group];
            cell.groupName.textColor = ColorWithHexStringIndex(c_424242);
        }
    }else{
        CMTGroup *group=[self.GrouplistArray objectAtIndex:indexPath.row];
        [cell reloadCell:group];
        cell.groupName.textColor = ColorWithHexStringIndex(c_424242);

    }
    return cell;

}

#pragma tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    if ([self.GroupJoinlistArray count]>0&&[self.GrouplistArray count]>0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTGroup *group=nil;
    if (indexPath.section==0) {
        if ([self.GroupJoinlistArray count]>0) {
            group=[self.GroupJoinlistArray objectAtIndex:indexPath.row];
        }else{
           group=[self.GrouplistArray objectAtIndex:indexPath.row];
        }
    }else{
       group=[self.GrouplistArray objectAtIndex:indexPath.row];
      
        
    }
    self.mygroup=group;
    if (group.groupType.integerValue>0) {
        if (!CMTUSER.login) {
            CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
            bing.nextvc=kComment;
            [self.navigationController pushViewController:bing animated:YES];
            return;
        }
        if (CMTUSERINFO.roleId.integerValue==0) {
            if (group.isJoinIn.integerValue==0&&CMTUSERINFO.authStatus.integerValue!=1) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"该小组已设置加入权限\n完善信息后可申请加入" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去完善信息",nil];
                [alert show];
                return;
            }
        }
    }
    @weakify(self);
    CMTGroupInfoViewController *groupInfo=[[CMTGroupInfoViewController alloc]initWithGroup:group];
    groupInfo.updateGroup=^(CMTGroup *group1){
        @strongify(self);
        self.mygroup.isJoinIn=group1.isJoinIn;
        self.mygroup.memberGrade=group1.memberGrade;
        [self setContentState:CMTContentStateLoading];
        if (CMTUSER.login) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
              [self creatData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.GrouptableView reloadData];
                 [self setContentState:CMTContentStateNormal];
            });
        });
      }
    };
    groupInfo.updateGroupBubbles=^(void){
        CMTAPPCONFIG.isrefreahCase=@"1";
        [CMTAPPCONFIG updateCaseNoticeUnreadNumber];
     };
    
    [self.navigationController pushViewController:groupInfo animated:YES];

    }
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        CMTUpgradeViewController *upgrade=[[CMTUpgradeViewController alloc]initWithGroup:self.mygroup];
        [self.navigationController pushViewController:upgrade animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.GroupJoinlistArray count]>0) {
         return 30;
    }else{
        return 60;
    }
   
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView  *view=nil;
    if ([self.GroupJoinlistArray count]>0) {
        view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        view.backgroundColor=COLOR(c_efeff4);
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, view.width-10, 30)];
        lable.text=section==0?@"我的小组":@"其他小组";
        lable.font=[UIFont systemFontOfSize:14];
        lable.textAlignment=NSTextAlignmentLeft;
        lable.textColor=[UIColor colorWithHexString:@"#ADADAD"];
        [view addSubview:lable];

    }else{
      view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
      view.backgroundColor=COLOR(c_efeff4);
      UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width, 60)];
      lable.text=@"加入小组,发现同好";
      lable.font=[UIFont systemFontOfSize:14];
      lable.textAlignment=NSTextAlignmentCenter;
      lable.textColor=[UIColor colorWithHexString:@"#ADADAD"];
      [view addSubview:lable];
     }
    return view;
    
    
 }
-(void)dealloc{
   [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}



@end
