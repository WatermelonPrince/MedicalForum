//
//  CMTGroupMembersViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/24.
//  Copyright (c) 2015年 CMT. All rights reserved.
//
NSString * const NSUserDefaultsLanchGroup = @"NSUserDefaultsLanchGroup";

#import "CMTGroupMembersViewController.h"
#import "CMTPartcell.h"
#import "CMTCustomScrollView.h"
#import "CMTSearchView.h"
#import "CMTSearchMemberViewController.h"
#import "CMTGroupCardViewController.h"


//组长个数
//static NSInteger managerCount = 0;
static NSString * const CMTCaseListRequestDefaultPageSize = @"30";

@interface CMTGroupMembersViewController ()<UIActionSheetDelegate,UIGestureRecognizerDelegate,CMTSearchViewDelegate>
//参与者列表
@property(nonatomic,strong)UITableView *membertableView;
//参与者属数组
@property(nonatomic,strong)NSMutableArray *memberListArray;
//排序数组
@property(nonatomic, strong)NSMutableArray *sortedmemberArr;
//成员数组
@property (nonatomic, strong)NSMutableArray *parterArr;
@property (nonatomic, strong)NSMutableArray *parterListArr;
//管理员数组
@property (nonatomic, strong)NSMutableArray *managerArr;
@property (nonatomic, strong)NSMutableArray *managerListArr;
//黑名单数组
@property (nonatomic, strong)NSMutableArray *blackListArr;
@property (nonatomic, strong)NSMutableArray *blackListListArr;
//参与者字典
@property(nonatomic,strong)NSMutableDictionary *memberListDic;
//排序好的key值
@property(nonatomic, strong)NSMutableArray *sortedKeys;

@property (nonatomic, strong)NSMutableArray *deleteArr;

@property (nonatomic, strong)NSIndexPath *indexPath;

@property (nonatomic, strong)UIImageView *lanchImage;//iOS版本更新启动图
@property (nonatomic, strong)UIButton *lanchButton;
@property (nonatomic, assign)BOOL currentPageFirstLaunch;//当前页面是否初次加载

@property (nonatomic, strong)CMTSearchView *searchView; // 搜索框
@property (nonatomic, strong)UIView *backgroundView; //搜索框和成员，管理员，黑名单按钮的背景视图
@property (nonatomic, strong)UIView *switchButtonBackgroundView; // 3个按钮的背景视图
@property (nonatomic, strong)UIButton *parterButton; //成员按钮
@property (nonatomic, strong)UIButton *managerButton; // 管理者按钮
@property (nonatomic, strong)UIButton *blacklistButton; // 黑名单
@property (nonatomic, strong)UIBarButtonItem *infoGroupItem;//组名片item
@property (nonatomic, strong)CMTContentEmptyView *contentEmptyView1;//空白提示语




@property (nonatomic, assign)BOOL reloadMark; //刷新标志
@property (nonatomic, strong)UIView *lineView;//button下面的线





@end

@implementation CMTGroupMembersViewController
-(instancetype)initWithGroup:(CMTGroup*)group{
    self=[super init];
    if(self){
        self.mygroup=group;
        self.showType = @"1";
        self.leaderCount = group.leaderCount;
    }
    return self;
}

- (CMTContentEmptyView *)contentEmptyView1 {
    if (_contentEmptyView1 == nil) {
        _contentEmptyView1 = [[CMTContentEmptyView alloc] init];
        _contentEmptyView1.frame = CGRectMake(0, CMTNavigationBarBottomGuide+ 80, SCREEN_WIDTH, SCREEN_HEIGHT - CMTNavigationBarBottomGuide - 80);
        UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction)];
        Swipe.numberOfTouchesRequired=1;
        Swipe.direction=UISwipeGestureRecognizerDirectionRight;
        [Swipe setDelaysTouchesBegan:YES];
        Swipe.delegate=self;
        [_contentEmptyView1 addGestureRecognizer:Swipe];

        [_contentEmptyView1 setBackgroundColor:COLOR(c_clear)];
        [_contentEmptyView1 setHidden:YES];
        [self.contentBaseView addSubview:_contentEmptyView1];
    }
    
    return _contentEmptyView1;
}
//组名片item
- (UIBarButtonItem *)infoGroupItem{
    if (_infoGroupItem == nil) {
        _infoGroupItem = [[UIBarButtonItem alloc]initWithTitle:@"组名片" style:UIBarButtonItemStylePlain target:self action:@selector(pushInToGroupInfoVC)];
    }
    return _infoGroupItem;
}

//空白替代视图

#pragma mark 小组名片
-(void)pushInToGroupInfoVC{
    @weakify(self);
    CMTGroupCardViewController *card=[[CMTGroupCardViewController alloc]initWithGroup:self.mygroup];
    card.ModifyGroupSucess=^(CMTGroup *group){
        @strongify(self);
        self.mygroup.groupDesc=group.groupDesc;
        self.mygroup.groupLogo=group.groupLogo;
        if (self.ModifyGroupSucess!=nil) {
            self.ModifyGroupSucess(self.mygroup);
        }
        
    };
    [self.navigationController pushViewController:card animated:YES];
}
//配置成员，管理员，黑名单switch按钮的显示fram
- (void)setUpSwitchButtonBackgroudView{
    
    self.blacklistButton.hidden = YES;
        self.switchButtonBackgroundView.frame = CGRectMake(0, self.searchView.bottom + 10, SCREEN_WIDTH, 30);
        self.backgroundView.frame = CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, 80);
        if ((self.mygroup.memberGrade.integerValue == 2 || self.mygroup.isJoinIn.integerValue == 0 || self.mygroup.memberGrade.integerValue == -1) && self.leaderCount.integerValue > 0) {
            //非小组成员且小组的管理员数目> 0 双列表显示
            self.backgroundView.frame = CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, 80);
            [self.switchButtonBackgroundView addSubview:self.parterButton];
            [self.switchButtonBackgroundView addSubview:self.managerButton];
            [self.switchButtonBackgroundView addSubview:self.lineView];
            self.parterButton.frame = CGRectMake(0, 0, SCREEN_WIDTH / 2, 30);
            self.managerButton.frame = CGRectMake(self.parterButton.right, 0, SCREEN_WIDTH/2, 30);
            self.lineView.frame = CGRectMake(0, 28, SCREEN_WIDTH/2, 2);
        }else if(self.mygroup.memberGrade.integerValue == 0 || self.mygroup.memberGrade.integerValue == 1){
            //是小组成员且为管理员  三列表显示
            self.backgroundView.frame = CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, 80);
            self.blacklistButton.hidden = NO;
            [self.switchButtonBackgroundView addSubview:self.parterButton];
            [self.switchButtonBackgroundView addSubview:self.managerButton];
            [self.switchButtonBackgroundView addSubview:self.blacklistButton];
            [self.switchButtonBackgroundView addSubview:self.lineView];
            self.parterButton.frame = CGRectMake(0, 0, SCREEN_WIDTH / 3, 30);
            self.managerButton.frame = CGRectMake(self.parterButton.right, 0, SCREEN_WIDTH/3, 30);
            self.blacklistButton.frame = CGRectMake(self.managerButton.right, 0, SCREEN_WIDTH/3, 30);
            self.lineView.frame = CGRectMake(0, 28, SCREEN_WIDTH/3, 2);
            
        }else if(self.leaderCount.integerValue == 0){
            //小组管理员数目为0 // 单列表显示
            self.backgroundView.frame = CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, 50);
            self.switchButtonBackgroundView.hidden = YES;
            self.membertableView.frame = CGRectMake(0, 114, SCREEN_WIDTH, SCREEN_HEIGHT - 114);
        }
    
    
}
//按钮下面的线
- (UIView *)lineView{
    if (_lineView == nil) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = ColorWithHexStringIndex(c_00b899);
    }
    return _lineView;
}
// 3个按钮的背景视图
- (UIView *)switchButtonBackgroundView{
    if (_switchButtonBackgroundView == nil) {
        _switchButtonBackgroundView = [[UIView alloc]init];
        
//        _switchButtonBackgroundView.backgroundColor = [UIColor redColor];
       
    }
    return _switchButtonBackgroundView;
}

- (UIButton *)parterButton{
    if (_parterButton == nil) {
        _parterButton = [[UIButton alloc]init];
        [_parterButton setTitle:@"成员" forState:UIControlStateNormal];
        _parterButton.titleLabel.font = FONT(15);
        _parterButton.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 5, 0);
        _parterButton.backgroundColor = [UIColor clearColor];
        [_parterButton setTitleColor:[UIColor colorWithHexString:@"#3dcb9a"] forState:UIControlStateNormal];
        [_parterButton addTarget:self action:@selector(switchToNeedAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _parterButton;
}

- (UIButton *)managerButton{
    if (_managerButton == nil) {
        _managerButton = [[UIButton alloc]init];
        [_managerButton setTitle:@"管理员" forState:UIControlStateNormal];
        _managerButton.titleLabel.font = FONT(15);
        _managerButton.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 5, 0);

        _managerButton.backgroundColor = [UIColor clearColor];
        [_managerButton setTitleColor:[UIColor colorWithHexString:@"#99999d"] forState:UIControlStateNormal];
        [_managerButton addTarget:self action:@selector(switchToNeedAction:) forControlEvents:UIControlEventTouchUpInside];
        

    }
    return _managerButton;
}

- (UIButton *)blacklistButton{
    if (_blacklistButton == nil) {
        _blacklistButton = [[UIButton alloc]init];
        [_blacklistButton setTitle:@"黑名单" forState:UIControlStateNormal];
        _blacklistButton.titleLabel.font = FONT(15);
        _blacklistButton.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 5, 0);
        _blacklistButton.backgroundColor = [UIColor clearColor];
        [_blacklistButton setTitleColor:[UIColor colorWithHexString:@"#99999d"] forState:UIControlStateNormal];
        [_blacklistButton addTarget:self action:@selector(switchToNeedAction:) forControlEvents:UIControlEventTouchUpInside];
        

    }
    return _blacklistButton;
}

//搜索框和成员，管理员，黑名单按钮的背景视图
- (UIView *)backgroundView{
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc]init];
        _backgroundView.frame = CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, 80);
        _backgroundView.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
        [_backgroundView addSubview:self.searchView];
        [_backgroundView addSubview:self.switchButtonBackgroundView];
    }
    return _backgroundView;
}

- (CMTSearchView*)searchView {
    if (_searchView==nil) {
        _searchView=[[CMTSearchView alloc]initWithFrame:CGRectMake(10,10, SCREEN_WIDTH-20, 30)];
        _searchView.lastController=self;
        _searchView.titlefontSize=13;
        _searchView.module=@"3";
        _searchView.delegate = self;
        [_searchView setBackgroundColor:ColorWithHexStringIndex(c_ffffff)];
        [_searchView drawSearchButton:@"搜索"];
        
    }
    return _searchView;
}
#pragma CMTSearchViewDelegate++代理
- (void)pushToNextVC{
    CMTSearchMemberViewController *searchMemVC = [[CMTSearchMemberViewController alloc]initWithGroup:self.mygroup managerCount:self.managerCount showType:self.showType reloadblock:^(NSString *action,CMTParticiPators *part) {
        //回调界面在成员，管理员，拉黑处理不同的结果
        if (self.showType.integerValue == 1) {
            if ([action isEqualToString:@"设为组长"]) {
                [self getpartlistData];
            }else if ([action isEqualToString:@"拉黑"]||[action isEqualToString:@"移除此人"]){
                [self.deleteArr addObject:part];
                [self getpartlistData];
            }
        }else if (self.showType.integerValue == 2){
            //当返回界面在管理员界面，回调 数据的相关处理
            if ([action isEqualToString:@"取消组长"]) {
                [self getmanagerData];
            }else if ([action isEqualToString:@"拉黑"]||[action isEqualToString:@"移除此人"]){
                [self.deleteArr addObject:part];
                [self getmanagerData];
            }
            
        }else{
            //当返回界面在拉黑界面的相关数据处理
            if ([action isEqualToString:@"取消拉黑"]) {
                [self getblacklistData];
            }
            
        }
    }];
    [self.navigationController pushViewController:searchMemVC animated:YES];
}

- (NSMutableArray *)managerArr{
    if (_managerArr == nil) {
        _managerArr = [NSMutableArray array];
    }
    return _managerArr;
}
- (NSMutableArray *)managerListArr{
    if (_managerListArr == nil) {
        _managerListArr = [NSMutableArray array];
    }
    return _managerListArr;
}
- (NSMutableArray *)parterArr{
    if (_parterArr == nil) {
        _parterArr = [NSMutableArray array];
    }
    return _parterArr;
}
- (NSMutableArray *)parterListArr{
    if (_parterListArr == nil) {
        _parterListArr = [NSMutableArray array];
    }
    return _parterListArr;
}
- (NSMutableArray *)blackListArr{
    if (_blackListArr == nil) {
        _blackListArr = [NSMutableArray array];
    }
    return _blackListArr;
}

- (NSMutableArray *)blackListListArr{
    if (_blackListListArr == nil) {
        _blackListListArr = [NSMutableArray array];
    }
    return _blackListListArr;
}


- (NSMutableArray *)deleteArr{
    if (_deleteArr == nil) {
        _deleteArr = [NSMutableArray array];
    }
    return _deleteArr;
}

-(NSMutableArray*)memberListArray{
    if (_memberListArray==nil) {
        _memberListArray=[[NSMutableArray alloc]init];
    }
    return _memberListArray;
}
- (NSMutableArray *)sortedmemberArr{
    if (_sortedmemberArr == nil) {
        _sortedmemberArr = [[NSMutableArray alloc]init];
    }
    return _sortedmemberArr;
}
-(UITableView*)membertableView{
    if (_membertableView==nil) {

        _membertableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 144, SCREEN_WIDTH, SCREEN_HEIGHT-144)];
        _membertableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _membertableView.delegate=self;
        _membertableView.backgroundColor=COLOR(c_efeff4);
          [_membertableView setAllowsSelection:NO];
        _membertableView.sectionIndexBackgroundColor  = [UIColor clearColor];

        _membertableView.dataSource=self;
        UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction)];
        Swipe.numberOfTouchesRequired=1;
        Swipe.direction=UISwipeGestureRecognizerDirectionRight;
        [Swipe setDelaysTouchesBegan:YES];
        Swipe.delegate=self;
        [_membertableView addGestureRecognizer:Swipe];
    }
    return _membertableView;
}

- (NSMutableDictionary *)memberListDic{
    if (_memberListDic == nil) {
        _memberListDic = [NSMutableDictionary dictionary];
    }
    return _memberListDic;
}
- (NSMutableArray *)sortedKeys{
    if (_sortedKeys == nil) {
        _sortedKeys = [NSMutableArray array];
    }
    return _sortedKeys;
}

#pragma mark 成员 管理者 黑名单切换button事件
- (void)switchToNeedAction:(UIButton *)action{
    [action setTitleColor:[UIColor colorWithHexString:@"#3dcb9a"] forState:UIControlStateNormal];
    if ([action.currentTitle isEqualToString:@"成员"]) {
        [self.managerButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
        [self.blacklistButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
        self.contentEmptyView1.hidden = YES;
        if (self.reloadMark) {
            [self getpartlistData];
            self.reloadMark = NO;
        }else{
            self.sortedmemberArr = [self.parterArr mutableCopy];
            [self.membertableView reloadData];
            if (self.sortedmemberArr.count == 0 ) {
                self.contentEmptyView1.hidden = NO;
                self.contentEmptyView1.contentEmptyPrompt = @"小组成员为空";
            }
           
        }
        
        self.showType = @"1";
        if (self.mygroup.memberGrade.integerValue == 2 || self.mygroup.isJoinIn.integerValue == 0 || self.mygroup.memberGrade.integerValue == -1) {
            self.lineView.frame = CGRectMake(0, 28, SCREEN_WIDTH/2, 2);
        }else{
            self.lineView.frame = CGRectMake(0, 28, SCREEN_WIDTH/3, 2);
        }
    }else if ([action.currentTitle isEqualToString:@"管理员"]){
        [self.parterButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
        [self.blacklistButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
        self.contentEmptyView1.hidden = YES;
        if (self.reloadMark) {
            [self getmanagerData];
            self.reloadMark = NO;
        }else{
            self.sortedmemberArr = [self.managerArr mutableCopy];
            [self.membertableView reloadData];
        }
        self.showType = @"2";
        if (self.mygroup.memberGrade.integerValue == 2 || self.mygroup.isJoinIn.integerValue == 0 || self.mygroup.memberGrade.integerValue == -1) {
            self.lineView.frame = CGRectMake(SCREEN_WIDTH/2, 28, SCREEN_WIDTH/2, 2);
        }else{
            self.lineView.frame = CGRectMake(SCREEN_WIDTH/3, 28, SCREEN_WIDTH/3, 2);
        }
    }else{
        [self.managerButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
        [self.parterButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
        self.contentEmptyView1.hidden = YES;
        if (self.reloadMark) {
            [self getblacklistData];
            self.reloadMark = NO;
        }else{
            self.sortedmemberArr = [self.blackListArr mutableCopy];
            [self.membertableView reloadData];
            if (self.sortedmemberArr.count == 0) {
                self.contentEmptyView1.hidden = NO;
                self.contentEmptyView1.contentEmptyPrompt = @"黑名单为空";
            }
           
        }
       
        self.showType = @"3";
        self.lineView.frame = CGRectMake(SCREEN_WIDTH/3*2, 28, SCREEN_WIDTH/3, 2);
        
    }
        
    
}

#pragma mark 返回上一级页面
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
        [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTGroupMembersViewController willDeallocSignal");
    }];
    [self.contentBaseView addSubview:self.membertableView];
    [self.contentBaseView addSubview:self.backgroundView];


    [self setUpSwitchButtonBackgroudView];
    //添加右导航按钮
    self.navigationItem.rightBarButtonItem =self.infoGroupItem;
   
    self.titleText=@"参与成员";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsLanchGroup] isEqual:APP_VERSION]) {
        self.currentPageFirstLaunch = NO;
    }else{
        self.currentPageFirstLaunch = YES;
    }
    if (self.currentPageFirstLaunch && [UIDevice currentDevice].systemVersion.floatValue < 8.0 && (self.mygroup.groupType.integerValue == 1 || self.mygroup.groupType.integerValue == 2) && (self.mygroup.memberGrade.integerValue == 0 || self.mygroup.memberGrade.integerValue == 1)) {
        [self configureAppLauchScreen];
        //存储当前版本号
        [[NSUserDefaults standardUserDefaults] setObject:APP_VERSION forKey:NSUserDefaultsLanchGroup];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSLog(@"____________%@",CMTUSERINFO.userId);
    //跳立方
    //[self setContentState:CMTContentStateLoading];
    [self CMTnfIniteRefreshPartlist];
    if (self.membertableView.contentSize.height>=self.membertableView.height) {
        self.membertableView.showsInfiniteScrolling=YES;
    }else{
        self.membertableView.showsInfiniteScrolling=NO;
        
    }
//    [self CMTPullToRefreshPartlist];
//    [self.membertableView.pullToRefreshView stopAnimating];
    [self getpartlistData];
    //重新更新个人权限身份，self.mygroup.memberGrade,
    [self updateMineMemberGrade];
    if ([[[UIDevice currentDevice]systemVersion]floatValue] < 8.0) {
        [self longPressGesturecaselistManager];
    }
    self.membertableView.sectionIndexColor = [UIColor grayColor];
    
}

// 更新个人权限
- (void)updateMineMemberGrade{
    NSDictionary *params = @{
                             @"groupId":self.mygroup.groupId?:@"0",
                             @"incrId":@"0",
                             @"incrIdFlag":@"0",
                             @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                             @"showType": @"0",
                             };
    [[[CMTCLIENT getMember_list:params] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *allMembers) {
        if (allMembers.count > 0) {
            for (CMTParticiPators *part in allMembers) {
                //防止当前用户停留在成员管理页面的时候，成员权限发生改变，---这样从小组详情页再次进入的时候，self.mygroup.memberGrade的权限会更新
                if ([part.userId isEqualToString:CMTUSERINFO.userId]) {
                    self.mygroup.memberGrade = part.memberGrade;
                }
            }
            [self setUpSwitchButtonBackgroudView];
        }
        
    }];
}

//配置iOS7.0启动图
- (void)configureAppLauchScreen{
    if (_lanchImage == nil) {
        _lanchImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _lanchImage.image = IMAGE(@"versionapplaunch");
        _lanchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _lanchButton.frame = CGRectMake((SCREEN_WIDTH -  266/2)/2, 701/2, 266/2, 81/2);
        [_lanchButton setBackgroundColor:[UIColor clearColor]];
        [_lanchButton setTitleColor:[UIColor colorWithHexString:@"f3f7f8"] forState:UIControlStateNormal];
        _lanchButton.layer.cornerRadius = 5;
        _lanchButton.layer.masksToBounds = YES;
        _lanchButton.layer.borderWidth = 0.5;
        _lanchButton.layer.borderColor = [UIColor colorWithHexString:@"f3f7f8"].CGColor;
        [_lanchButton setTitle:@"我知道了" forState:UIControlStateNormal];
        [_lanchButton addTarget:self action:@selector(actionIKonw:) forControlEvents:UIControlEventTouchUpInside];
        _lanchImage.userInteractionEnabled = YES;
        [_lanchImage addSubview:_lanchButton];
        [self.contentBaseView addSubview:_lanchImage];
        
    }
}

-(void)actionIKonw:(UIButton *)button{
    [_lanchImage removeFromSuperview];
}

//第一次获取小组数据
-(void)getpartlistData{
    self.managerButton.enabled = NO;
    self.blacklistButton.enabled = NO;
    self.contentEmptyView1.hidden = YES;
    int i;
    for (i = 1; i < 4; i++) {
        NSDictionary *params = @{
                                 @"groupId":self.mygroup.groupId?:@"0",
                                 @"incrId":@"0",
                                 @"incrIdFlag":@"0",
                                 @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                                 @"showType": @(i),
                                 };
        @weakify(self);
        [[[CMTCLIENT getMember_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamArray) {
            @strongify(self);
            self.managerButton.enabled = YES;
            self.blacklistButton.enabled = YES;
            if ([teamArray count]>0) {
                if (i == 1) {
                    self.parterListArr = [teamArray mutableCopy];
                    self.parterArr = [teamArray mutableCopy];
                    self.sortedmemberArr = [teamArray mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                    if(self.membertableView.contentSize.height<self.membertableView.height){
                        self.membertableView.showsInfiniteScrolling=NO;
                    }else{
                        self.membertableView.showsInfiniteScrolling=YES;
                        
                    }
                }else if (i == 2){
                    self.managerListArr = [teamArray mutableCopy];
                    self.managerArr = [teamArray mutableCopy];
                    _managerCount = teamArray.count - 1;
                }else{
                    self.blackListArr = [teamArray mutableCopy];
                    self.blackListListArr = [teamArray mutableCopy];
                }
                
            }else {
                if (i == 1) {
                    [self setContentState:CMTContentStateNormal];
                    self.contentEmptyView1.hidden = NO;
                    self.contentEmptyView1.contentEmptyPrompt = @"小组成员为空";
                }
                
            }
        }error:^(NSError *error) {
            @strongify(self);
            
            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
            if ([errorCode integerValue] > 100) {
                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                [self toastAnimation:errMes];
                NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
                if (errcode.integerValue == 1001) {
                    self.mLbupload.text = @"暂无操作权限";
                }
                [self setContentState:CMTContentStateReload];
                [self stopAnimation];
                CMTLog(@"errMes = %@",errMes);
            } else {
                CMTLogError(@" Error: %@", error);
            }

            
        }];
    }
//    NSDictionary *params=@{
//                           @"groupId":self.mygroup.groupId?:@"0",
//                           @"incrId":@"0",
//                           @"incrIdFlag":@"0",
//                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
//                           };
//    @weakify(self);
//    [[[CMTCLIENT getMember_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamArray) {
//        @strongify(self);
//        if ([teamArray count]>0) {
//            self.memberListArray=[teamArray mutableCopy];
//            self.sortedmemberArr = [NSMutableArray arrayWithArray:self.memberListArray];
//            [self memberListDicWithArr:self.sortedmemberArr];
//            
//            [self.membertableView reloadData];
//            
//            [self setContentState:CMTContentStateNormal];
//            if(self.membertableView.contentSize.height<self.membertableView.height){
//                self.membertableView.showsInfiniteScrolling=NO;
//            }else{
//                self.membertableView.showsInfiniteScrolling=YES;
//                
//            }
//
//            
//        }else {
//            [self setContentState:CMTContentStateEmpty];
//            self.contentEmptyView.contentEmptyPrompt=@"没有参与成员";
//        }
//    }error:^(NSError *error) {
//        @strongify(self);
//        [self setContentState:CMTContentStateReload];
//        [self stopAnimation];
//    }];
    
}

//请求管理员的数据

- (void)getmanagerData{
    self.contentEmptyView1.hidden = YES;
    int i;
    for (i = 1; i < 4; i++) {
        NSDictionary *params = @{
                                 @"groupId":self.mygroup.groupId?:@"0",
                                 @"incrId":@"0",
                                 @"incrIdFlag":@"0",
                                 @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                                 @"showType": @(i),
                                 };
        @weakify(self);
        [[[CMTCLIENT getMember_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamArray) {
            @strongify(self);
            if ([teamArray count]>0) {
                if (i == 1) {
                    self.parterListArr = [teamArray mutableCopy];
                    self.parterArr = [teamArray mutableCopy];
                }else if (i == 2){
                    self.managerListArr = [teamArray mutableCopy];
                    self.managerArr = [teamArray mutableCopy];
                    _managerCount = teamArray.count - 1;
                    self.sortedmemberArr = [teamArray mutableCopy];
                    [self.membertableView reloadData];
                    
                    [self setContentState:CMTContentStateNormal];
                    if(self.membertableView.contentSize.height<self.membertableView.height){
                        self.membertableView.showsInfiniteScrolling=NO;
                    }else{
                        self.membertableView.showsInfiniteScrolling=YES;
                        
                    }

                }else{
                    self.blackListArr = [teamArray mutableCopy];
                    self.blackListListArr = [teamArray mutableCopy];
                }
                
            }else {
                if (i == 2) {
                    [self setContentState:CMTContentStateNormal];
                    self.contentEmptyView1.hidden = NO;
                    self.contentEmptyView1.contentEmptyPrompt = @"小组管理员为空";
                }
                
            }
        }error:^(NSError *error) {
            @strongify(self);
            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
            if ([errorCode integerValue] > 100) {
                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                [self toastAnimation:errMes];
                CMTLog(@"errMes = %@",errMes);
            } else {
                CMTLogError(@" Error: %@", error);
            }
            
            
        }];
    }
    
}

//请求黑名单数据
- (void)getblacklistData{
    self.contentEmptyView1.hidden = YES;
    int i;
    for (i = 1; i < 4; i++) {
        NSDictionary *params = @{
                                 @"groupId":self.mygroup.groupId?:@"0",
                                 @"incrId":@"0",
                                 @"incrIdFlag":@"0",
                                 @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                                 @"showType": @(i),
                                 };
        @weakify(self);
        [[[CMTCLIENT getMember_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamArray) {
            @strongify(self);
            if ([teamArray count]>0) {
                if (i == 1) {
                    self.parterListArr = [teamArray mutableCopy];
                    self.parterArr = [teamArray mutableCopy];
                }else if (i == 2){
                    self.managerListArr = [teamArray mutableCopy];
                    self.managerArr = [teamArray mutableCopy];
                    _managerCount = teamArray.count - 1;
                   
                }else{
                    self.blackListArr = [teamArray mutableCopy];
                    self.blackListListArr = [teamArray mutableCopy];
                    self.sortedmemberArr = [teamArray mutableCopy];
                    [self.membertableView reloadData];
                    
                    [self setContentState:CMTContentStateNormal];
                    if(self.membertableView.contentSize.height<self.membertableView.height){
                        self.membertableView.showsInfiniteScrolling=NO;
                    }else{
                        self.membertableView.showsInfiniteScrolling=YES;
                        
                    }
                    
                }
                
            }else {
                if (i == 3) {
                    [self setContentState:CMTContentStateNormal];
                    self.contentEmptyView1.hidden = NO;
                    self.contentEmptyView1.contentEmptyPrompt = @"没有参与成员";
                }
                
            }
        }error:^(NSError *error) {
            @strongify(self);
            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
            if ([errorCode integerValue] > 100) {
                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                [self toastAnimation:errMes];
                CMTLog(@"errMes = %@",errMes);
            } else {
                CMTLogError(@" Error: %@", error);
            }
            
        }];
    }

}
#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self getpartlistData];
}
//下拉刷新数据方法
-(void)CMTPullToRefreshPartlist{
    @weakify(self);
    [self.membertableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTParticiPators *Part;
        switch (self.showType.integerValue) {
            case 1:
                if (self.parterListArr.count > 0) {
                    Part=[self.parterListArr objectAtIndex:0];
                }
                break;
            case 2:
                if (self.managerListArr.count > 0) {
                    Part=[self.managerListArr objectAtIndex:0];
                }
                break;
            case 3:
                if (self.blackListArr.count > 0) {
                    Part=[self.blackListArr objectAtIndex:0];
                }
                break;
            default:
                break;
        }
    
        NSDictionary *params=@{
                               @"groupId":self.mygroup.groupId?:@"0",
                               @"incrId":Part.incrId?: @"0",
                               @"incrIdFlag":@"0",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               @"showType": self.showType?:@""
                               };
        @weakify(self);
        [[[CMTCLIENT getParticipatorsList:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamdata) {
            @strongify(self);
            if ([teamdata count]>0) {
                NSMutableArray *casetableArray=[[NSMutableArray alloc]initWithArray:teamdata];
                //分类提取数据
                if (self.showType.integerValue == 1) {
                    [casetableArray addObjectsFromArray:[self.parterArr mutableCopy]];
                    self.parterListArr = [casetableArray mutableCopy];
                    NSUInteger pageSize = CMTCaseListRequestDefaultPageSize.integerValue;
                    while (self.parterListArr.count > pageSize) {
                        [self.parterListArr removeObjectAtIndex:pageSize];
                    }
                    self.sortedmemberArr = [self.parterListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                    casetableArray=nil;
                }else if (self.showType.integerValue == 2){
                    [casetableArray addObjectsFromArray:[self.managerArr mutableCopy]];
                    self.managerListArr = [casetableArray mutableCopy];
                    NSUInteger pageSize = CMTCaseListRequestDefaultPageSize.integerValue;
                    while (self.managerListArr.count > pageSize) {
                        [self.managerListArr removeObjectAtIndex:pageSize];
                    }
                    self.sortedmemberArr = [self.managerListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                    casetableArray=nil;
                }else{
                    [casetableArray addObjectsFromArray:[self.blackListArr mutableCopy]];
                    self.blackListArr = [casetableArray mutableCopy];
                    NSUInteger pageSize = CMTCaseListRequestDefaultPageSize.integerValue;
                    while (self.blackListArr.count > pageSize) {
                        [self.blackListArr removeObjectAtIndex:pageSize];
                    }
                    self.sortedmemberArr = [self.blackListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                    casetableArray=nil;
                }
                
            }else{
                [self toastAnimation:@"没有新加入的成员"];
            }
            [self.membertableView.pullToRefreshView stopAnimating];
        }error:^(NSError *error) {
            @strongify(self);
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
            if ([errorCode integerValue] > 100) {
                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                [self toastAnimation:errMes];
                CMTLog(@"errMes = %@",errMes);
            } else {
                CMTLogError(@" Error: %@", error);
            }
            
            [self.membertableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
}

//上拉翻页
-(void)CMTnfIniteRefreshPartlist{
    @weakify(self);
    [self.membertableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTParticiPators *Part;
        switch (self.showType.integerValue) {
            case 1:
                if (self.parterListArr.count > 0) {
                    Part=[self.parterListArr lastObject];
                }
                break;
            case 2:
                if (self.managerListArr.count > 0) {
                    Part=[self.managerListArr lastObject];
                }
                break;
            case 3:
                if (self.blackListArr.count > 0) {
                    Part=[self.blackListArr lastObject];
                }
                break;
            default:
                break;
        }        NSDictionary *params=@{
                               @"groupId":self.mygroup.groupId?:@"0",
                               @"incrId":Part.incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               @"showType": self.showType?:@""
                               };
        @weakify(self);
        [[[CMTCLIENT getMember_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *listdata) {
            @strongify(self);
            if ([listdata count]>0) {
                if (self.showType.integerValue == 1) {
                    [self.parterArr addObjectsFromArray:listdata];
                    self.parterListArr = [self.parterArr mutableCopy];
                    self.sortedmemberArr = [self.parterListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                    
                }else if (self.showType.integerValue == 2){
                    [self.managerArr addObjectsFromArray:listdata];
                    self.managerListArr = [self.managerArr mutableCopy];
                    self.sortedmemberArr = [self.managerListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                    
                }else{
                    [self.blackListArr addObjectsFromArray:listdata];
                    self.blackListListArr = [self.blackListArr mutableCopy];
                    self.sortedmemberArr = [self.blackListListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                }

            }else{
                [self toastAnimation:@"没有更多小组成员"];
            }
            
            [self.membertableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            @strongify(self);
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
            if ([errorCode integerValue] > 100) {
                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                [self toastAnimation:errMes];
                CMTLog(@"errMes = %@",errMes);
            } else {
                CMTLogError(@" Error: %@", error);
            }

            [self.membertableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
    
    
}




#pragma tableView  dataSource代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sortedmemberArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const CMTCellTeamCellIdentifier = @"CMTCellListCellTeam";
    CMTPartcell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellTeamCellIdentifier];
    if(cell==nil){
        cell=[[CMTPartcell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
    }
    CMTParticiPators *particiPators = [self.sortedmemberArr objectAtIndex:indexPath.row];
    [cell reloadCell:particiPators];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
#pragma mark--  编辑代理方法
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row+1 > self.sortedmemberArr.count) {
        return NO;
    }
    CMTParticiPators *part = [self.sortedmemberArr objectAtIndex:indexPath.row];
    if (self.mygroup.memberGrade.integerValue == 0) {
        if (part.memberGrade.integerValue == 0) {
            return NO;
        }
        return YES;
    }else if (self.mygroup.memberGrade.integerValue == 1){
        if (part.memberGrade.integerValue == 0 ) {
            return NO;
        }
        return YES;
    }
    return NO;
}
#pragma mark 设置编辑的样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
#pragma mark 设置处理编辑情况
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTParticiPators *particiPators = [self.sortedmemberArr objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       [self deleteMembers:particiPators AtIndexPath:indexPath];
        
        // 2. 更新UI
       
    }
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"移除此人";
}


- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTParticiPators *particiPators = [self.sortedmemberArr objectAtIndex:indexPath.row];
    //操作者是群主时
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        if (self.showType.integerValue == 3 && self.mygroup.memberGrade.integerValue != 2) {
            @weakify(self);
            UITableViewRowAction *cancleBlackListAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消拉黑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                @strongify(self);
                [self cancleBlackMembers:particiPators AtIndexPath:indexPath];
                
            }];
            return @[cancleBlackListAction];
        }
        @weakify(self);
        
        //拉黑动作
        UITableViewRowAction *blackListAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"拉黑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            [self blackMembers:particiPators AtIndexPath:indexPath];
            
        }];
        blackListAction.backgroundColor = [UIColor grayColor];
        //移除动作
        UITableViewRowAction *rowActionDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"移除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            [self deleteMembers:particiPators AtIndexPath:indexPath];
            
        }];
        
        //设为组长动作
        UITableViewRowAction *rowAction1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设为组长" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            
            [self changeMemberGradeManager:particiPators AtIndexPath:indexPath];
            rowAction1.backgroundColor = [UIColor orangeColor];
        }];
        rowAction1.backgroundColor = [UIColor colorWithHexString:@"fd9b28"];
        
        //取消组长动作
        UITableViewRowAction *rowAction2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消组长" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            [self revokeGradeManager:particiPators AtIndexPath:indexPath];
            
        }];
        rowAction2.backgroundColor = [UIColor colorWithHexString:@"c7c7cc"];
        
        
        if (self.mygroup.memberGrade.integerValue == 0) {
            
            
            //组长已满时
            if (_managerCount == 5 && particiPators.memberGrade.integerValue == 2) {
                
                return @[rowActionDelete,blackListAction];
            }
            
            
            UITableViewRowAction *rowActionManager = particiPators.memberGrade.integerValue == 1?rowAction2:rowAction1;
            return @[blackListAction,rowActionDelete,rowActionManager];
        }
        //操作者身份是组长时
        if (self.mygroup.memberGrade.integerValue == 1 ) {
            //            if (particiPators.memberGrade.integerValue == 2) {
            //                 return @[rowActionDelete,blackListAction];
            //            }
            
            //组长已满时
            if (_managerCount == 5 && particiPators.memberGrade.integerValue == 2) {
                
                return @[rowActionDelete,blackListAction];
            }
            
            
            UITableViewRowAction *rowActionManager = particiPators.memberGrade.integerValue == 1?rowAction2:rowAction1;
            return @[blackListAction,rowActionDelete,rowActionManager];
            
            
        }
        return nil;
        
    }else{
        return nil;
    }
    
    
}
//取消拉黑
- (void)cancleBlackMembers:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"",
                            @"groupId":self.mygroup.groupId,
                            @"beUserId":participator.userId,
                            @"flag":@"1",
                            @"userType":@"0",
                            };
    @weakify(self);
    [[[CMTCLIENT cancleBlackListMember:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        [self.sortedmemberArr removeObject:participator];
        if (self.sortedmemberArr.count == 0) {
            self.contentEmptyView1.hidden = NO;
            self.contentEmptyView1.contentEmptyPrompt = @"黑名单为空";
        }
        [self.blackListArr removeObject:participator];
        [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];
    }];
   
}

// 拉黑用户

- (void)blackMembers:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"",
                            @"groupId":self.mygroup.groupId,
                            @"beUserId":participator.userId,
                            @"flag":@"0",
                            };
    @weakify(self);
    [[[CMTCLIENT sendBlackListMember:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        
        [self.deleteArr addObject:participator];
        [self.sortedmemberArr removeObject:participator];
        if (self.showType.integerValue == 1) {
            [self.parterListArr removeObject:participator];
            [self.parterArr removeObject:participator];
            if (self.sortedmemberArr.count == 0) {
                self.contentEmptyView1.hidden = NO;
                self.contentEmptyView1.contentEmptyPrompt = @"小组成员为空";
            }
        }else{
            [self.managerListArr removeObject:participator];
            [self.managerArr removeObject:participator];
            if (self.sortedmemberArr.count == 0) {
                self.contentEmptyView1.hidden = NO;
                self.contentEmptyView1.contentEmptyPrompt = @"管理员为空";
            }
        }
        [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.reloadMark = YES;
        
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];

    }];
}

//移除用户
- (void)deleteMembers:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"",
                            @"groupId":self.mygroup.groupId,
                            @"beUserId":participator.userId,
                            };
     @weakify(self);
    [[[CMTCLIENT sendDeleteMember:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
            [self.deleteArr addObject:participator];
            [self.sortedmemberArr removeObject:participator];
        if (self.showType.integerValue == 1) {
            [self.parterListArr removeObject:participator];
            [self.parterArr removeObject:participator];
            if (self.sortedmemberArr.count == 0) {
                self.contentEmptyView1.hidden = NO;
                self.contentEmptyView1.contentEmptyPrompt = @"小组成员为空";
            }
        }else{
            [self.managerListArr removeObject:participator];
            [self.managerArr removeObject:participator];
            if (self.sortedmemberArr.count == 0) {
                self.contentEmptyView1.hidden = NO;
                self.contentEmptyView1.contentEmptyPrompt = @"管理员为空";
            }
        }
            [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        

    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];

    }];

    
}
//设为组长
- (void)changeMemberGradeManager:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"",
                             @"groupId":self.mygroup.groupId,
                             @"beUserId":participator.userId,
                             @"memberGrade":@"1"
                             };
     @weakify(self);
    [[[CMTCLIENT sendChangeMemberGrade:params]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (_managerCount < 5) {
            participator.memberGrade = @"1";
            _managerCount = _managerCount + 1;
            
//            [self memberListDicWithArr:self.sortedmemberArr];
            [self.sortedmemberArr removeObject:participator];
            if (self.sortedmemberArr.count == 0) {
                self.contentEmptyView1.hidden = NO;
                self.contentEmptyView1.contentEmptyPrompt = @"小组成员为空";
            }
            [self.parterListArr removeObject:participator];
            [self.parterArr removeObject:participator];
            [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            self.reloadMark = YES;
        }
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];

    }];
    
}

//降为组员
- (void)revokeGradeManager:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"",
                             @"groupId":self.mygroup.groupId,
                             @"beUserId":participator.userId,
                             @"memberGrade":@"2"
                             };
    @weakify(self);
    [[[CMTCLIENT revokeGradeManager:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        _managerCount = _managerCount - 1;
        participator.memberGrade = @"2";
        [self.sortedmemberArr removeObject:participator];
        if (self.sortedmemberArr.count == 0) {
            self.contentEmptyView1.hidden = NO;
            self.contentEmptyView1.contentEmptyPrompt = @"管理员为空";
        }
        [self.managerListArr removeObject:participator];
        [self.managerArr removeObject:participator];
        [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.membertableView reloadData];
        self.reloadMark = YES;
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];

    }];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    //

    //监听页面的类型
    [[RACObserve(self, showType) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString *showType) {
        if (showType.integerValue == 1) {
            [self.parterButton setTitleColor:[UIColor colorWithHexString:@"#3dcb9a"] forState:UIControlStateNormal];
            [self.managerButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
            [self.blacklistButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
            if ((self.mygroup.memberGrade.integerValue == 2 || self.mygroup.isJoinIn.integerValue == 0 || self.mygroup.memberGrade.integerValue == -1) && self.leaderCount.integerValue > 0) {
                //非小组成员且小组的管理员数目> 0 双列表显示
                
                self.lineView.frame = CGRectMake(0, 28, SCREEN_WIDTH/2, 2);
            }else if(self.mygroup.memberGrade.integerValue == 0 || self.mygroup.memberGrade.integerValue == 1){
                //是小组成员且为管理员  三列表显示
                
                self.lineView.frame = CGRectMake(0, 28, SCREEN_WIDTH/3, 2);
                
            }else if(self.leaderCount.integerValue == 0){
                //小组管理员数目为0 // 单列表显示
               
            }
            
        }else if (showType.integerValue == 2){
            [self.parterButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
            [self.managerButton setTitleColor:[UIColor colorWithHexString:@"#3dcb9a"] forState:UIControlStateNormal];
            [self.blacklistButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
            if ((self.mygroup.memberGrade.integerValue == 2 || self.mygroup.isJoinIn.integerValue == 0 || self.mygroup.memberGrade.integerValue == -1) && self.leaderCount.integerValue > 0) {
                //非小组成员且小组的管理员数目> 0 双列表显示
                
                self.lineView.frame = CGRectMake(SCREEN_WIDTH/2, 28, SCREEN_WIDTH/2, 2);
            }else if(self.mygroup.memberGrade.integerValue == 0 || self.mygroup.memberGrade.integerValue == 1){
                //是小组成员且为管理员  三列表显示
                
                self.lineView.frame = CGRectMake(SCREEN_WIDTH/3, 28, SCREEN_WIDTH/3, 2);
                
            }else if(self.leaderCount.integerValue == 0){
                //小组管理员数目为0 // 单列表显示
                
            }
        }else{
            [self.parterButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
            [self.managerButton setTitleColor:[UIColor colorWithHexString:@"#9a9a9e"] forState:UIControlStateNormal];
            [self.blacklistButton setTitleColor:[UIColor colorWithHexString:@"#3dcb9a"] forState:UIControlStateNormal];
            
           
                //是小组成员且为管理员  三列表显示
                
                self.lineView.frame = CGRectMake(SCREEN_WIDTH/3*2, 28, SCREEN_WIDTH/3, 2);
                
      
        }
    }];
    [self setUpSwitchButtonBackgroudView];
    [self.membertableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.deleteArrBlock != nil && self.deleteArr.count !=0) {
        self.deleteArrBlock(self.deleteArr);
    }
    
}

//初始化一个长按手势
- (void)longPressGesturecaselistManager{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 1;
    [self.membertableView addGestureRecognizer:longPress];
}

-(void)longPressAction:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint tmpPointTouch = [gestureRecognizer locationInView:self.membertableView];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.membertableView indexPathForRowAtPoint:tmpPointTouch];
        if (indexPath == nil) {
            NSLog(@"not tableView");
        }else{
            
            self.indexPath = indexPath;
            CMTParticiPators *particiPator = self.sortedmemberArr[indexPath.row];
            //仅当操作者为群主时
            if (self.mygroup.memberGrade.integerValue == 0) {
                if (particiPator.memberGrade.integerValue == 2) {
                    NSArray *actionSheetArr = @[@"设为组长"];
                    UIActionSheet *caseManagerSheet = [[UIActionSheet alloc]init];
                    caseManagerSheet.delegate = self;
                    for (NSString *sheetType in actionSheetArr) {
                        [caseManagerSheet addButtonWithTitle:sheetType];
                    }
                    caseManagerSheet.destructiveButtonIndex = 0;
                    [caseManagerSheet addButtonWithTitle:@"取消"];
                    caseManagerSheet.cancelButtonIndex = actionSheetArr.count;
                    [caseManagerSheet showInView:self.view];
                }else if (particiPator.memberGrade.integerValue == 1){
                    NSArray *actionSheetArr = @[@"取消组长"];
                    UIActionSheet *caseManagerSheet = [[UIActionSheet alloc]init];
                    caseManagerSheet.delegate = self;
                    for (NSString *sheetType in actionSheetArr) {
                        [caseManagerSheet addButtonWithTitle:sheetType];
                    }
                    caseManagerSheet.destructiveButtonIndex = 0;
                    [caseManagerSheet addButtonWithTitle:@"取消"];
                    caseManagerSheet.cancelButtonIndex = actionSheetArr.count;
                    [caseManagerSheet showInView:self.view];
                }
            }
        }
    }
}

#pragma mark--actionsheet代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        return;
    }
    CMTParticiPators *part = self.sortedmemberArr[self.indexPath.row];
    NSDictionary *params1 = @{
                              @"userId":CMTUSERINFO.userId?:@"",
                              @"groupId":self.mygroup.groupId,
                              @"beUserId":part.userId,
                              @"memberGrade":@"1"
                              };
    NSDictionary *params2 = @{
                              @"userId":CMTUSERINFO.userId?:@"",
                              @"groupId":self.mygroup.groupId,
                              @"beUserId":part.userId,
                              @"memberGrade":@"2"
                              };
    NSDictionary *params = part.memberGrade.integerValue == 2 ? params1 : params2;
    @weakify(self);
    [[[CMTCLIENT sendChangeMemberGrade:params] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (part.memberGrade.integerValue == 2) {
            if (_managerCount < 5) {
                part.memberGrade = @"1";
                [self.membertableView reloadData];
            }
        }else if (part.memberGrade.integerValue == 1){
            part.memberGrade = @"2";
            [self.membertableView reloadData];
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];
    }];
}
#pragma 搜索框代理


@end
