//
//  MineViewController.m
//  MedicalForum
//
//  Created by jiahongfei on 15/5/14.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "MineViewController.h"
#import "CMTBindingViewController.h"
#import "CMTPersonalAccountViewController.h"
#import "CMTCollectionViewController.h"
#import "CMTSystemSettingViewController.h"
#import "CMTCommentEditListViewController.h"
#import "CMTIntegralViewController.h"
#import "CMTMyWorkViewController.h"

#import "CMTTabBar.h"                           // 底部导航栏
#import <YWFeedbackFMWK/YWFeedbackKit.h>
#import <YWFeedbackFMWK/YWFeedbackViewController.h>
#import "CMTLearningRecordCell.h"
#import "LiveVideoPlayViewController.h"
#import "CMTLightVideoViewController.h"
#import "CMTRecordedViewController.h"
#import "CMTLearnRecordViewController.h"
#import "CMTDownCenterViewController.h"
#import "MypageTableViewCell.h"
#import "GeneralHTMLViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTMailViewController.h"
@interface MineViewController ()<UINavigationControllerDelegate>

@property(strong, nonatomic) UIView *topWidget;
@property(strong, nonatomic) UIImageView *headImageView;
@property(strong, nonatomic) UILabel *nickNameUILabel;
@property(strong, nonatomic) UILabel *authenticationLabel;
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) CMTTabBar *bottomTabBar;
@property(strong, nonatomic) NSString *scoreCount;
@property(nonatomic, strong) YWFeedbackKit *feedbackKit;
@property(nonatomic, strong) UIImageView *tableHeaderView;
@property(nonatomic, strong) UIButton *feedbackButton;
@property(nonatomic, strong) UIButton *settingButton;
@property(nonatomic,strong) NSArray *learningRecordList;
@property(nonatomic,strong)NSArray *section1;
@property(nonatomic,strong)NSArray *section2;
@property(nonatomic,strong)UIImageView *CertificationMarks;
@property(nonatomic,strong)UIControl *levelControl;

#define TABLE_HEIGHT 50

@end

@implementation MineViewController{
    NSUInteger lastDividerCount;
    
    NSMutableArray *tableViewDivider;
}

- (UIButton *)feedbackButton{
    if (!_feedbackButton) {
        _feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _feedbackButton.frame = CGRectMake(10, 25, 30, 30);
        [_feedbackButton setImage:IMAGE(@"ic_mine_left_feedback") forState:UIControlStateNormal];
        [_feedbackButton addTarget:self action:@selector(feedbackAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _feedbackButton;
}

- (UIButton *)settingButton{
    if (!_settingButton) {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingButton.frame = CGRectMake(SCREEN_WIDTH - 40, 25, 30, 30);
        [_settingButton setImage:IMAGE(@"setting") forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(seettingAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return _settingButton;
}
- (void)feedbackAction{
    self.navigationController.navigationBar.hidden = NO;
                [MobClick event:@"B_Feedback_MN"];
                CMTLog(@"反馈意见");
                [self openFeedbackViewController];
}
- (void)seettingAction{
                [MobClick event:@"B_Option_MN"];
                [self.navigationController pushViewController:[[CMTSystemSettingViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
}
#pragma mark getter
- (YWFeedbackKit *)feedbackKit {
    if (!_feedbackKit) {
        _feedbackKit = [[YWFeedbackKit alloc] initWithAppKey:@"23552123"];
    }
    return _feedbackKit;
}

- (UIImageView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_mine_top"]];
        _tableHeaderView.userInteractionEnabled=YES;
        [_tableHeaderView addSubview:self.topWidget];
        [_tableHeaderView addSubview:self.headImageView];
        [_tableHeaderView addSubview:self.nickNameUILabel];
        [_tableHeaderView addSubview:self.authenticationLabel];
        [_tableHeaderView addSubview:self.CertificationMarks ];
        [_tableHeaderView addSubview:self.levelControl];
        _tableHeaderView.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.authenticationLabel.bottom+20);
        self.topWidget.height=_tableHeaderView.height;
    }
    return _tableHeaderView;
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

-(UIView *)topWidget{
    if(nil == _topWidget){
        
        _topWidget = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, SCREEN_WIDTH+2, 190)];
        UILabel *feedbackLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.feedbackButton.left, self.feedbackButton.bottom, 30, 10)];
        UILabel *settingLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.settingButton.left, self.feedbackButton.bottom, 30, 10)];
        settingLabel.textAlignment = NSTextAlignmentCenter;
        feedbackLabel.textAlignment = NSTextAlignmentCenter;
        feedbackLabel.font = FONT(10);
        
        settingLabel.font = FONT(10);
        settingLabel.text = @"设置";
        feedbackLabel.text = @"反馈";
        feedbackLabel.textColor = ColorWithHexStringIndex(c_32c7c2);
        settingLabel.textColor = ColorWithHexStringIndex(c_32c7c2);
        [_topWidget addSubview:self.feedbackButton];
        [_topWidget addSubview:self.settingButton];
        [_topWidget addSubview:settingLabel];
        [_topWidget addSubview:feedbackLabel];
        
    }
    return  _topWidget;
}

-(void)onClickTopWidget :(UIView *) view{
    /*先判断当前用户是否登陆，来决定界面跳转逻辑*/
    
    CMTBindingViewController *mBindVC = [[CMTBindingViewController alloc]initWithNibName:nil bundle:nil];
    mBindVC.nextvc = kLeftVC;
    CMTLog(@"界面跳转逻辑");
    if (!CMTUSER.login)
    {
        [self.navigationController pushViewController:mBindVC animated:YES];
    }
    else
    {
        [MobClick event:@"B_PersonalC_MN"];
        [self.navigationController pushViewController:[[CMTPersonalAccountViewController alloc]initWithNibName:nil bundle:nil] animated:YES];
        
    }
    
}
-(UIImageView*)CertificationMarks{
    if(_CertificationMarks==nil){
        _CertificationMarks=[[UIImageView alloc]initWithFrame:CGRectMake(_headImageView.right-16,_headImageView.bottom-16, 16, 16)];
    }
    return _CertificationMarks;
}
-(UIImageView *)headImageView{
    if(nil ==_headImageView){
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickTopWidget:)];
        _headImageView = [[UIImageView  alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-65/2,self.feedbackButton.bottom, 65, 65)];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = self.headImageView.frame.size.height/2;
        [_headImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_headImageView setClipsToBounds:YES];
       _headImageView.image = [UIImage imageNamed:@"comment_defaultPicture"];
        _headImageView.userInteractionEnabled = YES;
        [_headImageView addGestureRecognizer:tapGesture];
    }
    return _headImageView;
}

-(UILabel *)nickNameUILabel{
    if(nil == _nickNameUILabel){
        float height=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:14 width: SCREEN_WIDTH];
        _nickNameUILabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.headImageView.bottom+15, SCREEN_WIDTH, height)];
        _nickNameUILabel.textAlignment = NSTextAlignmentCenter;
        _nickNameUILabel.font = FONT(14);
        _nickNameUILabel.text = @"未登录";
        _nickNameUILabel.shadowOffset = CGSizeMake(0, 0);
        _nickNameUILabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:193.8];
        _nickNameUILabel.textColor = [UIColor colorWithHexString:@"#424242"];
    }
    return _nickNameUILabel;
}

-(UILabel *)authenticationLabel{
    if(_authenticationLabel==nil){
        float height=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:12 width: SCREEN_WIDTH];
        _authenticationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,self.nickNameUILabel.bottom+5, SCREEN_WIDTH, height)];
        _authenticationLabel.textAlignment = NSTextAlignmentCenter;
        _authenticationLabel.font = FONT(12);
        _authenticationLabel.shadowOffset = CGSizeMake(0, 0);
        _authenticationLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:193.8];
        _authenticationLabel.textColor = [UIColor colorWithHexString:@"#00bb9c"];
    }
    return _authenticationLabel;
}
-(UIControl*)levelControl{
    if(_levelControl==nil){
        _levelControl=[[UIControl alloc]init];
        @weakify(self);
        [[[_levelControl rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            GeneralHTMLViewController *html=[[GeneralHTMLViewController alloc]initWithName:@"我的等级" url:CMTUSERINFO.inviteUrl];
            [self.navigationController pushViewController:html animated:YES];
        } error:^(NSError *error) {
            
        }];
    }
    return _levelControl;
}
-(UITableView *)tableView{
    if(nil == _tableView){
        _tableView = [[UITableView alloc] initWithFrame: CGRectMake( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-CMTTabBarHeight-10) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = COLOR(c_f5f5f5);
        _tableView.bounces=NO;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    lastDividerCount = 0;
    tableViewDivider = [[NSMutableArray alloc] initWithCapacity:5];
    
    self.contentBaseView.backgroundColor = COLOR(c_f5f5f5);
    
    [self.contentBaseView addSubview:self.tableView];
    self.tableHeaderView.frame = CGRectMake(0, 0, self.topWidget.width, self.topWidget.height);
    self.tableHeaderView.backgroundColor = COLOR(c_dcdcdc);
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    // 设置底部导航栏当前选中的条目
    self.bottomTabBar.selectedIndex = 4;
    self.section1=@[@"",@"下载中心",@"我的收藏"];
    self.section2=@[@"壹贝商城",@"邀请好友赢壹贝",@"签到赢壹贝",@"升级为认证用户"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   //获取积分总数
    [self getScoreCountParam];
    [self AccessToLearningRecordList];
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    if (!CMTUSER.login)
    {
        self.nickNameUILabel.text = @"未登录";
        self.authenticationLabel.hidden = YES;
        self.headImageView.image = IMAGE(@"comment_defaultPicture");
         self.CertificationMarks.hidden=!CMTUSER.login;
    }
    else
    {
         dispatch_async(dispatch_get_main_queue(), ^{
            [self.headImageView setImageURL:CMTUSERINFO.picture placeholderImage:IMAGE(@"head_default") contentSize:CGSizeMake(100, 100)];
             [self.CertificationMarks setImageURL:CMTUSERINFO.authPic placeholderImage:IMAGE(@"placeholder_college_default") contentSize:CGSizeMake(16, 16)];
             self.CertificationMarks.hidden=!CMTUSER.login;
        });
        
        /*从缓存读取设置的昵称*/
        NSString *nickName = CMTUSERINFO.nickname;
        self.nickNameUILabel.text = nickName;
        /*从缓存读取认证情况*/
        CMTUserInfo *info = CMTUSERINFO;
        CMTLog(@"authstatus=%d",info.authStatus.intValue);
        self.authenticationLabel.hidden = NO;
        self.authenticationLabel.text = [@"我的等级LV." stringByAppendingString:CMTUSERINFO.rank];
        float with=[CMTGetStringWith_Height CMTGetLableTitleWith: self.authenticationLabel.text fontSize:12];
        self.authenticationLabel.width=with;
        self.authenticationLabel.center=CGPointMake(SCREEN_WIDTH/2, self.authenticationLabel.center.y);
        self.levelControl.frame=CGRectMake((SCREEN_WIDTH-with)/2,self.authenticationLabel.top, with,  self.authenticationLabel.height+20);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==1) {
        return 4;
    }else if(0 == section){
         return 3;
    }else{
        return 1;
    }
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
       UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
       UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 10, view.frame.size.width, 1)];
       lineView.backgroundColor=COLOR(c_eaeaea);
       [view addSubview:lineView];
       return view;
 }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==0&&indexPath.section==0){
        CMTLearningRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if(cell==nil){
            cell=[[CMTLearningRecordCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            @weakify(self);
            cell.WatchVideo=^(CMTLivesRecord * live){
                @strongify(self);
                [self didLearnVideo:live];
            };
            [[[cell.cellView rac_signalForControlEvents:UIControlEventTouchUpInside]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
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
                [MobClick event:@"B_Mine_Record"];
                CMTLearnRecordViewController *learn=[[CMTLearnRecordViewController alloc]initWithData:self.learningRecordList];
                [self.navigationController pushViewController:learn animated:YES];
            }];
        }
        [cell reloadCell:self.learningRecordList];
        return cell;
    }else{
        MypageTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if(cell==nil){
            cell=[[MypageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            
        }
        [cell reloadData:indexPath.section==0?self.section1[indexPath.row]:self.section2[indexPath.row]];
        return cell;
    }

    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0&& indexPath.row==0){
        UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    }
    return TABLE_HEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        return 10;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    CMTLog(@"table selected");
    //    @"作品",@"评论",@"收藏",@"设置"
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   if(indexPath.section==0){
        
        if(indexPath.row == 1){
            CMTDownCenterViewController *center=[[CMTDownCenterViewController alloc]initWith:YES];
            [self.navigationController pushViewController:center animated:YES];
        }else if (indexPath.row == 2){
              [MobClick event:@"B_Favorite_MN"];
            CMTCollectionViewController *mCollectionVC = [[CMTCollectionViewController alloc]initWithNibName:nil bundle:nil];
            mCollectionVC.isLeftEnter = YES;
            [self.navigationController pushViewController:mCollectionVC animated:YES];
        }
   } else if(indexPath.section==1){
       if(indexPath.row!=0){
           if(!CMTUSER.login){
               CMTBindingViewController *mBindVC = [[CMTBindingViewController alloc]initWithNibName:nil bundle:nil];
               mBindVC.nextvc = kLeftVC;
               [self.navigationController pushViewController:mBindVC animated:YES];
               return;
           }else{
               [MobClick event:@"B_Mine_Invite"];
               if(indexPath.row==1){
                   GeneralHTMLViewController *html=[[GeneralHTMLViewController alloc]initWithName:self.section2[indexPath.row] url:CMTUSERINFO.inviteUrl];
                   [self.navigationController pushViewController:html animated:YES];
               }else if(indexPath.row==2) {
                   [MobClick event:@"B_Mine_Signin"];

                   GeneralHTMLViewController *html=[[GeneralHTMLViewController alloc]initWithName:self.section2[indexPath.row] url:CMTUSERINFO.signUrl];
                   [self.navigationController pushViewController:html animated:YES];
               }else{
                   [MobClick event:@"B_Mine_Authentication"];
                   if(CMTUSERINFO.authStatus.integerValue==1||CMTUSERINFO.authStatus.integerValue==5){
                       return;
                   }
                   CMTUpgradeViewController *upgrade=[[CMTUpgradeViewController alloc]init];
                   
                  [self.navigationController pushViewController:upgrade animated:YES];
               }
               
           }
           
           
           
       }else{
           CMTMailViewController *myMail=[[CMTMailViewController alloc]init];
           [self.navigationController pushViewController:myMail animated:YES];
           
       }
   }
}
//获取学习记录列表
-(void)AccessToLearningRecordList{
    if(!CMTUSER.login){
        self.learningRecordList=@[];
        return;
    }
    [self setContentState:CMTContentStateLoading moldel:@"1" height:0];
    @weakify(self);
    NSDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:CMTUSER.userInfo.userId forKey:@"userId"];
    [[[CMTCLIENT CMTPersonalLearningList:param]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *array) {
        @strongify(self);
          self.learningRecordList=array;
          [self.tableView reloadData];
          [self setContentState:CMTContentStateNormal];
        } error:^(NSError *error) {
            @strongify(self);
            if (error.code>=-1009&&error.code<=-1001) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
          [self setContentState:CMTContentStateNormal];
       }
     ];

}

///根据参数获取积分总数
-(void)getScoreCountParam {
    if (!CMTUSER.login)
    {
        _scoreCount = @"";
        [_tableView reloadData];
        return ;
    }
    NSDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:CMTUSER.userInfo.userId forKey:@"userId"];
    [[[CMTCLIENT getScoreCount:param]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(ScoreCount *scoreCount) {
        if((nil == scoreCount)){
            
        }else{
            _scoreCount = [[NSString alloc] initWithFormat:@"可用%@积分", scoreCount.count];
            [_tableView reloadData];
        }
        } error:^(NSError *error) {
    }];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
#pragma mark - methods
/** 打开用户反馈页面 */
- (void)openFeedbackViewController {
    /** 设置App自定义扩展反馈数据 */
    self.feedbackKit.extInfo = @{@"loginTime":[[NSDate date] description],
                                 @"visitPath":@"登陆->关于->反馈",
                                 @"userid":[CMTUSERINFO.userId stringByAppendingFormat:@"_%@",CMTUSERINFO.userUuid]?:@"CMTAPPUSERS",
                                 @"应用自定义扩展信息":@"开发者可以根据需要设置不同的自定义信息，方便在反馈系统中查看"};
    
    __weak typeof(self) weakSelf = self;
    [self.feedbackKit makeFeedbackViewControllerWithCompletionBlock:^(YWFeedbackViewController *viewController, NSError *error) {
        if (viewController != nil) {
            viewController.title = @"意见反馈";
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
            [weakSelf presentViewController:nav animated:YES completion:nil];
            
            [viewController setCloseBlock:^(UIViewController *aParentController){
                [aParentController dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            /** 使用自定义的方式抛出error时，此部分可以注释掉 */
            NSString *title = [error.userInfo objectForKey:@"msg"]?:@"接口调用失败，请保持网络通畅！";
            [weakSelf toastAnimation:title];
        }
    }];
}
-(void)DeleteLearningRecord:(CMTLivesRecord *)LivesRecord{
    @weakify(self);
    [self setContentState:CMTContentStateLoading moldel:@"1" height:CMTNavigationBarBottomGuide];
    NSError *JSONSerializationError = nil;
    NSData *itemsJSONData = [NSJSONSerialization dataWithJSONObject:@[LivesRecord.dataId] options:NSJSONWritingPrettyPrinted error:&JSONSerializationError];
    if (JSONSerializationError != nil) {   CMTLogError(@"AppConfig Cached Theme Info JSONSerialization Error: %@", JSONSerializationError);
    }
    NSString *itemsJSONString = [[NSString alloc] initWithData:itemsJSONData encoding:NSUTF8StringEncoding];
    NSDictionary *param=@{ @"userId":CMTUSER.userInfo.userId?:@"0",
                           @"items":itemsJSONString?:@"",
                           @"delType":@"0"
                           };
    [self DeleteLearningRecord:param sucess:^(CMTObject *x) {
    } error:^(NSError *error) {
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力"];
        }else{
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
      [self setContentState:CMTContentStateNormal];
    }];
    
}

#pragma 学习记录点击
- (void)didLearnVideo:(CMTLivesRecord*)Record{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if([self getNetworkReachabilityStatus].integerValue==0){
        
        [self toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }else{
         [MobClick event:@"B_Mine_Record"];
        if (Record.type.integerValue==1) {
            @weakify(self);
            CMTLightVideoViewController *lightVideoViewController = [[CMTLightVideoViewController alloc]init];
            //  播放网络
            lightVideoViewController.myliveParam = [Record copy];
            lightVideoViewController.updateReadNumber=^(CMTLivesRecord *live){
                @strongify(self);
                if(live==nil){
                    [self DeleteLearningRecord:Record];
                }
            };

            [self.navigationController pushViewController:lightVideoViewController animated:YES];
            
        }else{
            CMTRecordedViewController *recordView=[[CMTRecordedViewController alloc]initWithRecordedParam:[Record copy]];
              @weakify(self);
              recordView.updateReadNumber=^(CMTLivesRecord *live){
                @strongify(self);
                if(live==nil){
                    [self DeleteLearningRecord:Record];
                }
            };

            [self.navigationController pushViewController:recordView animated:YES];
            
        }
    }
    
    
}

@end
