//
//  CMTColledgeVedioViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/7/20.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTColledgeVedioViewController.h"
#import "CMTUniversityViewController.h"
#import "CMTCustomScrollView.h"
#import "CMTListCollegeViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "CMTMySubscribeViewController.h"
#import "CMTSearchColledgeDataViewController.h"
#import "CMTAppConfig.h"
#import "CMTHolidayViewController.h"
#import "CMTLearnRecordViewController.h"
@interface CMTColledgeVedioViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) CMTUniversityViewController *universityViewController;//直播
@property (nonatomic, strong) CMTListCollegeViewController *listCollegeViewController;//学院
@property (nonatomic, strong) UIView *switchBackGroudView;
@property (nonatomic, strong) UIButton *collegeButton;//学院
@property (nonatomic, strong) UIButton *liveButton;//直播
@property (nonatomic, strong) CMTBarButtonItem *personalItem;                   // 个人按钮
@property (nonatomic, strong) NSArray *leftItems;                               // 导航左侧按钮
@property (nonatomic, strong) NSString *currentPage;                            //当前页面（学院或者直播）
@property (nonatomic, strong)UIView *hiddenleftItemsView;                       //隐藏leftItem的视图
@property (nonatomic, strong)NSArray *rightItems;                               //
@property (nonatomic, strong)CMTBarButtonItem *NavRightItem;                    //搜索
@property (nonatomic, strong)CMTBarButtonItem *HomepageRecord;                //学习记录
@end
@implementation CMTColledgeVedioViewController

-(CMTBarButtonItem*)NavRightItem{
    if (_NavRightItem == nil) {
        CMTBadge *badge = [[CMTBadge alloc] init];
        badge.frame = CGRectMake(31.0,-7.5, kCMTBadgeWidth, kCMTBadgeWidth);
        badge.hidden = YES;
        CMTBadgePoint *badgePoint = [[CMTBadgePoint alloc] init];
        badgePoint.frame = CGRectMake(35.0, -2.0, CMTBadgePointWidth, CMTBadgePointWidth);
        badgePoint.hidden = YES;
        
        _NavRightItem = [CMTBarButtonItem itemWithImage:IMAGE(@"search_Item")badge:badgePoint badgeValue:badge imageEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
        [[[_NavRightItem.customButton rac_signalForControlEvents:UIControlEventTouchUpInside]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
           [MobClick event:@"B_College_Search"];
            CMTSearchColledgeDataViewController *searchColledgeDataVC = [[CMTSearchColledgeDataViewController alloc]init];
            [self.navigationController pushViewController:searchColledgeDataVC animated:YES];
        }];
    }
    
   return _NavRightItem;
}
-(CMTBarButtonItem*)HomepageRecord{
    if (_HomepageRecord == nil) {
        _HomepageRecord = [CMTBarButtonItem itemWithImage:IMAGE(@"B_Homepage_Record")imageEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
        @weakify(self);
        [[_HomepageRecord.touchSignal deliverOn:[RACScheduler mainThreadScheduler] ] subscribeNext:^(id x) {
            @strongify(self);
            if(!CMTUSER.login){
                CMTBindingViewController *mBindVC = [[CMTBindingViewController alloc]initWithNibName:nil bundle:nil];
                mBindVC.nextvc = kLeftVC;
                
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"请登录之后查看学习记录"
                                                              message:nil
                                                             delegate:nil
                                                    cancelButtonTitle:@"取消"
                                                    otherButtonTitles:@"确定", nil];
                [alert show];
                [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber*x) {
                    if(x.intValue==1){
                        [self.navigationController pushViewController:mBindVC animated:YES];
                    }
                    
                }];
                return ;
            }
            [MobClick event:@"B_Homepage_Record"];
            CMTLearnRecordViewController *LearnRecord=[[CMTLearnRecordViewController alloc]init];
            [self.navigationController pushViewController:LearnRecord animated:YES];
        } error:^(NSError *error) {
            
        }];
        }
    
    return _HomepageRecord;
}

- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        FixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.NavRightItem,self.HomepageRecord, nil];
    }
    return _rightItems;
}

- (UIView *)hiddenleftItemsView{
    if (!_hiddenleftItemsView) {
        _hiddenleftItemsView = [[UIView alloc]init];
        _hiddenleftItemsView.frame = CGRectMake(10, 0, 60, 40);
        _hiddenleftItemsView.backgroundColor = [UIColor redColor];
    }
    return _hiddenleftItemsView;
}

- (CMTBarButtonItem *)personalItem {
    if (_personalItem == nil) {
        CMTBadge *badge = [[CMTBadge alloc] init];
        badge.frame = CGRectMake(31.0,-7.5, kCMTBadgeWidth, kCMTBadgeWidth);
        badge.hidden = YES;
        CMTBadgePoint *badgePoint = [[CMTBadgePoint alloc] init];
        badgePoint.frame = CGRectMake(35.0, -2.0, CMTBadgePointWidth, CMTBadgePointWidth);
        badgePoint.hidden = YES;
        
        _personalItem = [CMTBarButtonItem itemWithImage:IMAGE(@"naviBar_subscribed")badge:badgePoint badgeValue:badge imageEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 1.0, 0.0)];
        [[[_personalItem.customButton rac_signalForControlEvents:UIControlEventTouchUpInside]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            CMTMySubscribeViewController *mysubVC = [[CMTMySubscribeViewController alloc]init];
            [self.navigationController pushViewController:mysubVC animated:YES];
        }];
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

- (UIView *)switchBackGroudView{
    if (!_switchBackGroudView) {
        _switchBackGroudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
        _switchBackGroudView.layer.cornerRadius = 15;
        _switchBackGroudView.layer.borderWidth = 1;
        _switchBackGroudView.layer.borderColor = ColorWithHexStringIndex(c_3CC6C1).CGColor;
        _switchBackGroudView.layer.masksToBounds = YES;
    }
    return _switchBackGroudView;
}
-(UIButton *)collegeButton{
    if (!_collegeButton) {
        _collegeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _collegeButton.frame = CGRectMake(0.5, 0, 82.5, 30);
        _collegeButton.layer.cornerRadius = 15;
        _collegeButton.layer.masksToBounds = YES;
        _collegeButton.titleLabel.font = FONT(15);
        [_collegeButton setTitleColor:[UIColor colorWithHexString:@"f9f9f9"] forState:UIControlStateNormal];
        [_collegeButton setBackgroundColor:ColorWithHexStringIndex(c_3CC6C1)];
        [_collegeButton addTarget:self action:@selector(scrollToCollege:) forControlEvents:UIControlEventTouchUpInside];
        [_collegeButton setTitle:@"学院" forState:UIControlStateNormal];
    }
    return _collegeButton;
}

- (UIButton *)liveButton{
    if (!_liveButton) {
        _liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _liveButton.frame = CGRectMake(67, 0, 82.5, 30);
        _liveButton.layer.cornerRadius = 15;
        _liveButton.layer.masksToBounds = YES;
        _liveButton.titleLabel.font = FONT(15);
        [_liveButton setTitleColor:ColorWithHexStringIndex(c_3CC6C1) forState:UIControlStateNormal];
        [_liveButton setBackgroundColor:[UIColor clearColor]];
        [_liveButton addTarget:self action:@selector(scrollToLive:) forControlEvents:UIControlEventTouchUpInside];
        [_liveButton setTitle:@"直播" forState:UIControlStateNormal];
    }
    return _liveButton;
}

- (void)configureTitileView{
    [self.switchBackGroudView addSubview:self.liveButton];
    [self.switchBackGroudView addSubview:self.collegeButton];
    self.navigationItem.titleView = self.switchBackGroudView;
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

- (UIScrollView *)switchCustomScrollView{
    if (!_switchCustomScrollView) {
        _switchCustomScrollView = [[CMTCustomScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _switchCustomScrollView.pagingEnabled = YES;
        _switchCustomScrollView.contentSize = CGSizeMake(SCREEN_WIDTH *2, 0);
        _switchCustomScrollView.bounces = NO;
        _switchCustomScrollView.delegate = self;
    }
    return _switchCustomScrollView;
}

- (CMTUniversityViewController *)universityViewController{
    if (!_universityViewController) {
        _universityViewController = [[CMTUniversityViewController alloc]init];
    }
    return _universityViewController;
}

- (CMTListCollegeViewController *)listCollegeViewController{
    if (!_listCollegeViewController) {
        _listCollegeViewController = [[CMTListCollegeViewController alloc]init];
        _listCollegeViewController.parentVC=self;
    }
    return _listCollegeViewController;
}

//学院 直播点击事件
- (void)scrollToCollege:(UIButton *)button{
    [self.switchCustomScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    self.currentPage = @"学院";
    [_collegeButton setTitleColor:[UIColor colorWithHexString:@"f9f9f9"] forState:UIControlStateNormal];
    [_collegeButton setBackgroundColor:ColorWithHexStringIndex(c_3CC6C1)];
    [_liveButton setTitleColor:ColorWithHexStringIndex(c_3CC6C1) forState:UIControlStateNormal];
    [_liveButton setBackgroundColor:[UIColor clearColor]];
}
- (void)scrollToLive:(UIButton *)button{
    [MobClick event:@"B_College_Live"];
    [self.switchCustomScrollView setContentOffset:CGPointMake(SCREEN_WIDTH,0) animated:YES];
    self.currentPage = @"直播";
    [_liveButton setTitleColor:[UIColor colorWithHexString:@"f9f9f9"] forState:UIControlStateNormal];
    [_liveButton setBackgroundColor:ColorWithHexStringIndex(c_3CC6C1)];
    [_collegeButton setTitleColor:ColorWithHexStringIndex(c_3CC6C1) forState:UIControlStateNormal];
    [_collegeButton setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
   self.currentPage = @"学院";
    //启动app获取更新本地数据
    if(CMTAPPCONFIG.subscriptionCached ==YES||CMTAPPCONFIG.currentVersionSubscribed == YES){
        NSLog(@"%d...%d",CMTAPPCONFIG.subscriptionCached,CMTAPPCONFIG.currentVersionSubscribed);
        [CMTAPPCONFIG MandatoryUpdateNotificationAndSubscription];
    }
    // 左侧栏按钮
    self.navigationItem.leftBarButtonItems = self.leftItems;
    self.navigationItem.rightBarButtonItems = self.rightItems;
    [[RACObserve(self, currentPage)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString * x) {
        if ([x isEqualToString:@"学院"]) {
            self.NavRightItem.customButton.hidden = NO;
              NSArray *countArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
            if (countArr.count == 0) {
                self.personalItem.customButton.hidden = YES;
                

            }else{
                self.personalItem.customButton.hidden = NO;

            }
            
        }else{
            self.personalItem.customButton.hidden = YES;
        }
        
    }];
    [[RACObserve(CMTAPPCONFIG, seriesDtlUnreadNumber)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString * x) {
        if ([self.currentPage isEqualToString:@"学院"]) {
            //当订阅列表数据为空时，隐藏item;
            NSArray *countArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
            if (countArr.count == 0) {
                self.personalItem.customButton.hidden = YES;
            }else{
                self.personalItem.customButton.hidden = NO;
                self.personalItem.badgeValue.hidden = YES;
            }
            
            if (x.integerValue > 0) {
                self.personalItem.badge.hidden = NO;
            }else{
                self.personalItem.badge.hidden = YES;
            }
        }
        
       
       
    }];
    
    self.bottomTabBar.selectedIndex = 2;
    [self configureTitileView];
    [self.contentBaseView addSubview:self.switchCustomScrollView];
    self.universityViewController.view.frame = CGRectMake(SCREEN_WIDTH,0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.universityViewController.parentVC = self;
    self.listCollegeViewController.view.frame = CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.listCollegeViewController.parentVC = self;
    [self.switchCustomScrollView addSubview:self.listCollegeViewController.view];
    [self.switchCustomScrollView addSubview:self.universityViewController.view];
    //版本更新和首页启动图
    [self StartDiagramAndUpdatedVersion];
}
#pragma scrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.switchCustomScrollView.contentOffset.x == 0) {
        [_collegeButton setTitleColor:[UIColor colorWithHexString:@"f9f9f9"] forState:UIControlStateNormal];
        [_collegeButton setBackgroundColor:ColorWithHexStringIndex(c_3CC6C1)];
        [_liveButton setTitleColor:ColorWithHexStringIndex(c_3CC6C1) forState:UIControlStateNormal];
        [_liveButton setBackgroundColor:[UIColor clearColor]];
        self.currentPage = @"学院";
    }else if(self.switchCustomScrollView.contentOffset.x/SCREEN_WIDTH == 1){
        [MobClick event:@"B_College_Live"];
        [_liveButton setTitleColor:[UIColor colorWithHexString:@"f9f9f9"] forState:UIControlStateNormal];
        [_liveButton setBackgroundColor:ColorWithHexStringIndex(c_3CC6C1)];
        [_collegeButton setTitleColor:ColorWithHexStringIndex(c_3CC6C1) forState:UIControlStateNormal];
        [_collegeButton setBackgroundColor:[UIColor clearColor]];
        self.currentPage = @"直播";
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    if (self.listCollegeViewController.focusPageShuffling!=nil) {
        [self.listCollegeViewController.focusPageShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
     NSArray *countArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
    
    if (self.switchCustomScrollView.contentOffset.x == 0) {
       
        if (countArr.count == 0) {
            self.personalItem.customButton.hidden = YES;
            
        }else{
            self.personalItem.customButton.hidden = NO;
            self.personalItem.badgeValue.hidden = YES;

            
        }
        
    }else{
        self.personalItem.customButton.hidden = YES;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    if (self.listCollegeViewController.focusPageShuffling!=nil) {
        [self.listCollegeViewController.focusPageShuffling setFireDate:[NSDate distantFuture]];
    }

}
@end
