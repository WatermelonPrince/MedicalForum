//
//  CMTHomePageSideBar.m
//  MedicalForum
//
//  Created by fenglei on 15/5/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTHomePageSideBar.h"
#import "CMTSubcritionListCell.h"
#import "CMTSubject.h"
#import "CMTCenterViewController.h"     // 首页文章列表
#import "CMTBindingViewController.h"
#import "CMTEnterCell.h"
#import "CMTSubcriotionCell.h"
//展开更多的cell
#import "CMTGetMoreSubjectCell.h"
//1.8.3学科下文章列表
#import "CMTSubjectPostsViewController.h"
#import "CMTOtherPostListViewController.h"
#import "CMTEnterSubjectionViewController.h"        //  我的专题列表
#import "CMTOtherPostListViewController.h"
#define FILEMANGER  [NSFileManager defaultManager]


@interface CMTHomePageSideBar ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (strong, nonatomic) UIImageView *mAnimationImageView;
@property (copy, nonatomic) CMTToastView *mToastView;
@property (strong, nonatomic) NSMutableArray *mArrImages;
@property(nonatomic,assign) BOOL isreloadtableView;
@property(nonatomic,strong) NSString *model;//模式参数 0 首页 1 病例 2 指南
@property(nonatomic,strong) UIView *titleView;//标题
@property(nonatomic,strong)CMTSubject *mySubject; //记录按钮点下时获取订阅的学科信息
@property(nonatomic,strong)CMTButton *mybutton;
@end

@implementation CMTHomePageSideBar
-(instancetype)initWithModel:(NSString *)model{
      self=[super init];
    if (self) {
        self.model=model;
    }
    return self;
}
- (CMTToastView *)mToastView
{
    if (!_mToastView)
    {
        _mToastView = [[CMTToastView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 30)];
    }
    return _mToastView;
}

-(UIView*)titleView{
    if (_titleView==nil) {
        _titleView=[[UIView alloc]initWithFrame:CGRectMake(0, 20, self.sideBarWidth, 44)];
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.sideBarWidth, 43)];
        lable.text=@"我的订阅";
        lable.textAlignment=NSTextAlignmentCenter;
        lable.textColor = COLOR(c_151515);
        lable.font=[UIFont systemFontOfSize:18.5];
        UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 43, self.sideBarWidth, 1)];
        lineView.backgroundColor = COLOR(c_eaeaea);

        [_titleView addSubview:lable];
        [_titleView addSubview:lineView];
    }
    return _titleView;
}
- (UITableView *)mSubscriptionTableView
{
    if (!_mSubscriptionTableView)
    {
        _mSubscriptionTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.sideBarWidth, self.view.height -44) style:UITableViewStylePlain];
        _mSubscriptionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mSubscriptionTableView.delegate = self;
        _mSubscriptionTableView.dataSource = self;
        _mSubscriptionTableView.backgroundColor = COLOR(c_f5f5f5);
        //_mSubscriptionTableView.scrollEnabled = YES;
    }
    return _mSubscriptionTableView;
}
- (NSMutableDictionary *)mBtnDic
{
    if (!_mBtnDic)
    {
        _mBtnDic = [NSMutableDictionary dictionary];
    }
    return _mBtnDic;
}

- (NSMutableArray *)mArrSubscription
{
    if (!_mArrSubscription)
    {
        _mArrSubscription = [NSMutableArray array];
    }
    return _mArrSubscription;
}
- (NSMutableArray *)mArrTotleSubs
{
    if (!_mArrTotleSubs)
    {
        _mArrTotleSubs = [NSMutableArray array];
    }
    return _mArrTotleSubs;
}
- (NSMutableArray *)mArrSorted
{
    if (!_mArrSorted)
    {
        _mArrSorted = [NSMutableArray array];
    }
    return _mArrSorted;
}
- (NSMutableArray *)mArrImages
{
    if (!_mArrImages)
    {
        _mArrImages = [NSMutableArray array];
        for (int i = 0 ; i < 10; i++)
        {
            NSString *imageName = [NSString stringWithFormat:@"PR_4_0000%d",i];
            UIImage *pImage = [UIImage imageNamed:imageName];
            [self.mArrImages addObject:pImage];
        }
        for (int i = 10; i < 39; i++)
        {
            NSString *imageName = [NSString stringWithFormat:@"PR_4_000%d",i];
            UIImage *pImage = [UIImage imageNamed:imageName];
            [self.mArrImages addObject:pImage];
        }
    }
    return _mArrImages;
}
- (UIImageView *)mAnimationImageView
{
    if (!_mAnimationImageView)
    {
        _mAnimationImageView = [[UIImageView alloc]initWithImage:IMAGE(@"PR_4_00000")];
        //
        _mAnimationImageView.frame = CGRectMake(0, 0, 64, 64);
        _mAnimationImageView.animationImages = self.mArrImages;
        _mAnimationImageView.animationDuration = 1.5f;
        _mAnimationImageView.animationRepeatCount = 0;
    }
    return _mAnimationImageView;
}
- (void)runAnimationInPosition:(CGPoint)point
{
    [self.contentView addSubview:self.mAnimationImageView];
    self.mAnimationImageView.center = point;
    [self.mAnimationImageView startAnimating];
}
- (void)stopAnimation
{
    [self.mAnimationImageView stopAnimating];
    [self.mAnimationImageView resignFirstResponder];
    if (self.mAnimationImageView) {
        [self.mAnimationImageView removeFromSuperview];
    }
}

- (NSString *)strSubListCachePath
{
    return [PATH_USERS stringByAppendingPathComponent:@"subscription"];//@"subsList"];
}
- (NSString *)strTotleListCachePath
{
    return [PATH_USERS stringByAppendingPathComponent:@"totleList"];
}
- (NSString *)strSortedArrCachePath
{
    return [PATH_USERS stringByAppendingPathComponent:@"sortedList"];
}
- (UIButton *)mBtnLogin
{
    if (!_mBtnLogin)
    {
        _mBtnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        _mBtnLogin.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH*2.0/3.0, 50);
        _mBtnLogin.backgroundColor = COLOR(c_32c7c2);
        [_mBtnLogin setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        _mBtnLogin.titleLabel.font = FONT(18);
        [_mBtnLogin setTitle:@"登录，同步订阅信息" forState:UIControlStateNormal];
        [_mBtnLogin addTarget:self action:@selector(synchronizationSub:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mBtnLogin;
}

//订阅信息与未订阅信息，排序后的集合
- (NSMutableArray *)mArrSortedTot
{
    if (!_mArrSortedTot)
    {
        _mArrSortedTot = [NSMutableArray array];
    }
    return _mArrSortedTot;
}

- (void)toastAnimation:(NSString *)prompt
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mToastView.mLbContent.text = prompt;
        [self.contentView addSubview:self.mToastView];
        [self hidden:self.mToastView];
    });
    
}
- (void)hidden:(CMTToastView *)view
{
    view.alpha = 1.0;
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:2.0];
    view.alpha = 0.0;
    [UIView commitAnimations];
    
}

///已订阅状态
- (void)subcrition:(CMTButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [btn setTitle:@"已订阅" forState:UIControlStateNormal];
        [btn setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
        [btn setBackgroundColor:COLOR(c_dfdfdf)];
        btn.layer.borderColor = COLOR(c_ababab).CGColor;
        btn.layer.borderWidth = PIXEL;
        
        btn.userInteractionEnabled = YES;
    });
}

///未订阅状态
- (void)noSubcition:(CMTButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [btn setTitle:@"+ 订阅" forState:UIControlStateNormal];
        [btn setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        [btn setBackgroundColor:COLOR(c_ffffff)];
        btn.layer.borderWidth = PIXEL;
        btn.layer.borderColor = COLOR(c_32c7c2).CGColor;
        btn.userInteractionEnabled = YES;
    });
}

///订阅取消订阅关联方法
- (void)addSubcrition:(CMTButton *)btn
{
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable){
        [self toastAnimation:@"你的网络不给力"];
      return;
    }
    CMTAPPCONFIG.refreshmodel=[@"" stringByAppendingFormat:@"%ld", (long)(self.model.integerValue+1)];
    CMTLog(@"%s",__func__);
    //发送请求
    if ([btn.titleLabel.text isEqualToString:@"+ 订阅"])
    {
        if ([AFNetworkReachabilityManager sharedManager].isReachable) {
            [self subcrition:btn];
            if (btn.tag <= self.mArrSortedTot.count)
            {
                CMTSubject *pSubject = [self.mArrSortedTot objectAtIndex:btn.tag];
                CMTConcern *concern = [[CMTConcern alloc]init];
                concern.subject = pSubject.subject;
                concern.subjectId =pSubject.subjectId;
                concern.opTime = [NSDate UNIXTimeStampFromNow];
                [self.mArrSubscription addObject:concern];
                CMTUserInfo *info = CMTUSERINFO;
                NSString *subjectId = concern.subjectId;
                CMTUser *pUser = CMTUSER;
                //if([[NSUserDefaults standardUserDefaults]boolForKey:@"firstLogin"] == YES)
                if (pUser.login)
                {
                    // 登录状态的添加订阅学科接口
                    NSDictionary *pDic = @{@"userId":info.userId?:@"0",@"subjectId":subjectId?:@"",@"cancelFlag":[NSNumber numberWithInt:0]?:@""};
                    @weakify(self);
                    [self.rac_deallocDisposable addDisposable:[[CMTCLIENT fetchConcern:pDic] subscribeNext:^(CMTConcern * pConcern) {
                        @strongify(self);
                        DEALLOC_HANDLE_SUCCESS
                        BOOL isArchSucess = [NSKeyedArchiver archiveRootObject:self.mArrSubscription toFile:self.strSubListCachePath];
                        if (isArchSucess)
                        {
                            CMTLog(@"订阅%@缓存到本地成功",concern.subject);
                        }
                        else
                        {
                            CMTLog(@"订阅%@缓存到本地失败",concern.subject);
                        }
                        CMTLog(@"订阅%@同步到服务器端成功",concern.subject);
                        CMTUSERINFO.follows = self.mArrSubscription;
                        
                        // 刷新首页和疾病文章列表
                        [self refreshPostList];
                        
                        [CMTUSER save];
                    } error:^(NSError *error) {
                        DEALLOC_HANDLE_SUCCESS
                        CMTLog(@"%@",error);
                        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                        if ([errorCode integerValue] > 100) {
                            NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                            CMTLog(@"errMes = %@",errMes);
                        } else {
                            CMTLogError(@"add subcription System Error: %@", error);
                        }
                        
                    }]];
                }
                else
                {
                    BOOL isArchSucess = [NSKeyedArchiver archiveRootObject:self.mArrSubscription toFile:self.strSubListCachePath];
                    if (isArchSucess)
                    {
                        CMTLog(@"订阅%@缓存到本地成功",concern.subject);
                    }
                    else
                    {
                        CMTLog(@"订阅%@缓存到本地失败",concern.subject);
                    }
                    CMTUSERINFO.follows = self.mArrSubscription;
                    [CMTUSER save];
                    
                    // 刷新首页和疾病文章列表
                    [self refreshPostList];
                    
                    // 未登录状态的添加订阅学科接口
                    NSDictionary *pDic = @{@"userId":@"0",@"subjectId":subjectId?:@"",@"cancelFlag":[NSNumber numberWithInt:0]?:@""};
                    [[CMTCLIENT fetchConcern:pDic] subscribeNext:^(CMTConcern * pConcern) {
                        CMTLog(@"未登录状态的添加订阅学科接口 成功:\n%@", pConcern);
                    } error:^(NSError *error) {
                        DEALLOC_HANDLE_SUCCESS
                        CMTLog(@"未登录状态的添加订阅学科接口 失败:\n%@", error);
                    }];
                }
            }
            else
            {
                [self noSubcition:btn];
            }
            
        }
        else{
//            [self toastAnimation:@"你的网络不给力"];
            
        }
    }else{
        self.mybutton=btn;
        self.mySubject = [self.mArrSortedTot objectAtIndex:btn.tag];
       UIAlertView  *mAlertView = [[UIAlertView alloc]initWithTitle:@"确定不再订阅该学科吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [mAlertView show];
    }
    
}
#pragma mark  点击警告框上的按钮


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable){
        switch (buttonIndex)
        {
            case 0:
            {
                CMTLog(@"取消取消订阅");
            }
                break;
            case 1:
            {
                CMTLog(@"确认取消订阅");
                if ([AFNetworkReachabilityManager sharedManager].isReachable) {
                    if (CMTUSER.login)
                    {
                        // 登录状态的取消订阅学科接口
                        CMTLog(@"服务器端删除");
                        NSDictionary *pDic =@{
                                              @"userId":CMTUSERINFO.userId ?: @"0",
                                              @"subjectId":self.mySubject.subjectId ?: @"",
                                              @"cancelFlag":[NSNumber numberWithInt:1]
                                              };
                        [self.rac_deallocDisposable addDisposable:[[CMTCLIENT fetchConcern:pDic] subscribeNext:^(CMTConcern * pConcern) {
                            DEALLOC_HANDLE_SUCCESS
                            CMTLog(@"服务端取消订阅%@成功",self.mySubject.subject);
                            
                        } error:^(NSError *error) {
                            DEALLOC_HANDLE_SUCCESS
                            CMTLog(@"%@",error);
                            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                            if ([errorCode integerValue] > 100) {
                                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                                CMTLog(@"errMes = %@",errMes);
                            } else {
                                CMTLogError(@"delete Subscription System Error: %@", error);
                            }
                            
                        } ]];
                        
                    }
                    else {
                        // 未登录状态的取消订阅学科接口
                        NSDictionary *pDic = @{@"userId":@"0",@"subjectId":self.mySubject.subjectId?:@"",@"cancelFlag":[NSNumber numberWithInt:1]?:@""};
                        [[CMTCLIENT fetchConcern:pDic] subscribeNext:^(CMTConcern * pConcern) {
                            CMTLog(@"未登录状态的取消订阅学科接口 成功:\n%@", pConcern);
                        } error:^(NSError *error) {
                            DEALLOC_HANDLE_SUCCESS
                            CMTLog(@"未登录状态的取消订阅学科接口 失败:\n%@", error);
                        }];
                        
                    }
                    //本地删除
                    for (CMTConcern *concern in self.mArrSubscription)
                    {
                        if ([concern.subjectId isEqualToString:self.mySubject.subjectId])
                        {
                            [self.mArrSubscription removeObject:concern];
                            break;
                        }
                    }
                    
                    BOOL cache = [NSKeyedArchiver archiveRootObject:self.mArrSubscription toFile:self.strSubListCachePath];
                    if (cache)
                    {
                        CMTLog(@"本地取消订阅%@成功",self.mySubject.subject);
                        [self noSubcition:self.mybutton];
                        [self refreshPostList];
                    }
                    else
                    {
                        CMTLog(@"本地取消订阅%@失败",self.mySubject.subject);
                    }
                }
              }
                break;
                
            default:
                break;
        }
        CMTUSERINFO.follows = self.mArrSubscription;
        [CMTUSER save];
    }
}

///获取学科总列表,同时完成与已订阅数据的同步(匿名用户传0 或者不传)
- (void)allSubcription:(NSString *)userId
{
    //跳跃的立方
    self.mSubscriptionTableView.hidden = YES;
    [self runAnimationInPosition:CGPointMake(self.view.frame.size.width/3,self.view.center.y)];
    
    NSDictionary *pDic = @{
                           @"userId": userId ?: @"0",
                           @"isNew" : @"1"
                           };
    @weakify(self);
    [[[CMTCLIENT getSubjectList:pDic] deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]]subscribeNext:^(NSArray * totleSubs) {
        DEALLOC_HANDLE_SUCCESS;
        @strongify(self);
        self.mArrTotleSubs = [totleSubs mutableCopy];
        
        /*请求完成，完成数据筛选*/
        
        NSMutableArray *tempTotleArr = [totleSubs mutableCopy];
        /*订阅数据筛选*/
        for (CMTConcern *concern in self.mArrSubscription)
        {
            for (CMTSubject *subject in totleSubs)
            {
                if ([concern.subjectId isEqualToString:subject.subjectId])
                {   concern.subject=subject.subject;
                    [tempTotleArr removeObject:subject];
                }
            }
        }
        [self.mArrSortedTot removeAllObjects];
        //排序已关注的学科
        [self subscriptionArrSorted:[totleSubs mutableCopy]];
        [self.mArrSortedTot addObjectsFromArray:self.mArrSubscription];
        [self.mArrSortedTot addObjectsFromArray:tempTotleArr];
        dispatch_async(dispatch_get_main_queue(), ^{
        [NSKeyedArchiver archiveRootObject:self.mArrSubscription toFile:self.strSubListCachePath];
            CMTLog(@"获取订阅总列表成功");

            self.mSubscriptionTableView.hidden = NO;
//            self.mReloadBaseView.hidden = YES;
            [self.mSubscriptionTableView reloadData];
                        [self stopAnimation];
        });
        
        
    } error:^(NSError *error) {
        
        CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAnimation];
            self.mSubscriptionTableView.hidden = NO;
            
            [self DealWithoutInternet];
            
        });
//        [self toastAnimation:@"你的网络不给力"];
    }];
    [self subcritonSort:nil];
    
}
//固定已订阅的顺序，综合第一，口腔最后
- (void)subscriptionArrSorted:(NSMutableArray*)allSubject{
    NSMutableArray *mArrSub=[[NSMutableArray alloc]init];
    for (CMTSubject *subject in allSubject) {
        for (CMTConcern *concern2 in self.mArrSubscription) {
            if ([subject.subjectId isEqualToString:concern2.subjectId]) {
                [mArrSub addObject:concern2];
            }
        }
    }
    self.mArrSubscription=[mArrSub mutableCopy];
    
}
///根据已订阅选项,去重，排序
- (void)subcritonSort:(id)sender
{
    CMTLog(@"%s",__func__);
    if ([FILEMANGER fileExistsAtPath:self.strSubListCachePath])
    {
        self.mArrSubscription = [NSKeyedUnarchiver unarchiveObjectWithFile:self.strSubListCachePath];
        
        //将订阅的排序
        self.mArrSubscription = [[self.mArrSubscription sortedArrayUsingComparator:^NSComparisonResult(CMTConcern* obj1, CMTConcern* obj2) {
            return [obj1.subjectId compare:obj2.subjectId options:NSCaseInsensitiveSearch];
        }]mutableCopy];
    }
    else
    {
        self.mArrSubscription = [[self.mArrSubscription sortedArrayUsingComparator:^NSComparisonResult(CMTConcern* obj1, CMTConcern* obj2) {
            return [obj1.subjectId compare:obj2.subjectId options:NSCaseInsensitiveSearch];
        }]mutableCopy];
    }
    if (([[NSUserDefaults standardUserDefaults]boolForKey:@"firstLogin_subcrition"]==YES))
    {
        NSMutableArray *userArr = [NSMutableArray array];
        for (CMTFollow *follow in CMTUSERINFO.follows)
        {
            CMTConcern *concern = [[CMTConcern alloc]init];
            concern.subject = follow.subject;
            concern.subjectId = follow.subjectId;
            concern.opTime = follow.opTime;
            concern.concernFlag = nil;
            concern.authors = nil;
            //默认添加一个subjectId为0的学科。
            if (concern.subjectId.intValue != 0)
            {
                [userArr addObject:concern];
            }
            
        }
        NSMutableArray *cacheArr = [NSMutableArray array];
        if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscription"]])
        {
            cacheArr =[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
        }
        for (int i = 0;i < cacheArr.count;i++)
        {
            CMTConcern *concern1 = [cacheArr objectAtIndex:i];
            for (int j = 0;j < userArr.count;j++)
            {
                CMTConcern *concern2 = [userArr objectAtIndex:j];
                if ([concern1.subjectId isEqualToString:concern2.subjectId])
                {
                    [userArr removeObject:concern2];
                }
                
            }
        }
        NSMutableArray *pTotleArray = [NSMutableArray array];
        [pTotleArray addObjectsFromArray:cacheArr];
        [pTotleArray addObjectsFromArray:userArr];
        self.mArrSubscription = pTotleArray;
        //将订阅的排序
        self.mArrSubscription = [[self.mArrSubscription sortedArrayUsingComparator:^NSComparisonResult(CMTConcern* obj1, CMTConcern* obj2) {
            return [obj1.subjectId compare:obj2.subjectId options:NSCaseInsensitiveSearch];
        }]mutableCopy];
        CMTLog(@"%@",self.mArrSubscription);
        
        
        
        [NSKeyedArchiver archiveRootObject:self.mArrSubscription toFile:self.strSubListCachePath];
        
        /*给服务器端同步数据*/
        NSMutableArray *pTempArr = [NSMutableArray array];
        for (CMTConcern *concer in self.mArrSubscription)
        {
            NSMutableDictionary *pDic = [NSMutableDictionary dictionary];
            [pDic setObject:concer.subjectId?:@"" forKey:@"subjectId"];
            
            if (concer.opTime.length > 0)
            {
                long long scannedNumber;
                NSScanner *scanner = [NSScanner scannerWithString:concer.opTime];
                [scanner scanLongLong:&scannedNumber];
                NSNumber *number = [NSNumber numberWithLongLong: scannedNumber];
                [pDic setObject:number?:@"" forKey:@"opTime"];
            }
            else
            {
                CMTLog(@"缺少时间参数");
            }
            [pTempArr addObject:pDic];
        }
        long long userId;
        NSScanner *scanner2 = [NSScanner scannerWithString:CMTUSER.userInfo.userId];
        [scanner2 scanLongLong:&userId];
        NSNumber *number2 = [NSNumber numberWithLongLong:userId];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pTempArr options:NSJSONWritingPrettyPrinted error:nil];
        NSString *pStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        CMTLog(@"%@",pStr);
        
        NSDictionary *pDic = @{
                               @"userId":number2,
                               @"items":pStr
                               };
        /*同步给服务器一份*/
        [self.rac_deallocDisposable addDisposable:[[CMTCLIENT syncConcern:pDic]subscribeNext:^(NSArray * array)
                                                   {
                                                       DEALLOC_HANDLE_SUCCESS
                                                       CMTLog(@"array=%@",array);
                                                   } error:^(NSError *error)
                                                   {
                                                       DEALLOC_HANDLE_SUCCESS
                                                       CMTLog(@"error=%@",error);
                                                       NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                                                       if ([errorCode integerValue] > 100) {
                                                           NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                                                           CMTLog(@"errMes = %@",errMes);
                                                       } else {
                                                           CMTLogError(@"syncConcern Subscription System Error: %@", error);
                                                       }
                                                   } ]];
    }
    
}
//处理无网络登陆
-(void)DealWithoutInternet{
        self.mArrSubscription = [NSKeyedUnarchiver unarchiveObjectWithFile:self.strSubListCachePath];
        NSArray*totleSubs= [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_TOTALSUBSCRIPTION];
      self.mArrTotleSubs = [totleSubs mutableCopy];

    /*请求完成，完成数据筛选*/
    
    NSMutableArray *tempTotleArr = [totleSubs mutableCopy];
    /*订阅数据筛选*/
    for (CMTConcern *concern in self.mArrSubscription)
    {
        for (CMTSubject *subject in totleSubs)
        {
            if ([concern.subjectId isEqualToString:subject.subjectId])
            {    concern.subject=subject.subject;
                [tempTotleArr removeObject:subject];
            }
        }
    }
    //排序已关注的学科
    [self subscriptionArrSorted:[totleSubs mutableCopy]];
    [self.mArrSortedTot removeAllObjects];
    [self.mArrSortedTot addObjectsFromArray:self.mArrSubscription];
    [self.mArrSortedTot addObjectsFromArray:tempTotleArr];
    
        CMTLog(@"获取订阅总列表成功");
        //            [self stopAnimation];
        self.mSubscriptionTableView.hidden = NO;
        //            self.mReloadBaseView.hidden = YES;
        [self.mSubscriptionTableView reloadData];

}
#pragma mark ViewDidload
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.contentView addSubview:self.titleView];
    [CMTFOCUSMANAGER subcriptions:nil];
    self.isLeftEnter = YES;
    self.isreloadtableView=NO;
    ///设置导航标题
    [self.contentView addSubview:self.mSubscriptionTableView];
    [self.contentView addSubview:self.mBtnLogin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark willAppear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [MobClick beginLogPageView:[NSString
                                stringWithUTF8String:object_getClassName([self class])]];

#pragma mark 隐藏导航栏
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    self.mSubscriptionTableView.hidden = NO;
    
    /*底部按钮是否显示*/
    if (CMTUSER.login)
    {
        self.mBtnLogin.hidden = YES;
    }
    else
    {
        BOOL isLogout = [[NSUserDefaults standardUserDefaults]boolForKey:@"logout"];
        if (isLogout == YES)
        {
            self.mBtnLogin.hidden = NO;
        }
        else
        {
            self.mBtnLogin.hidden = YES;
        }
    }
    //按钮隐藏
    if (self.mBtnLogin.isHidden == NO)
    {
        self.mSubscriptionTableView.contentInset = UIEdgeInsetsMake(0, 0, self.mBtnLogin.frame.size.height+20, 0);
    }
    else
    {
        self.mSubscriptionTableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    }
    
    //添加无网络时读取缓存 有网络时请求网络数据刷新列表 add by guoyuanchao
    [self reloadSubTableView];
    
//#pragma mark 刷新首页文章列表
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.mArrSubscription.count > 0)
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLogin_subcrition"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    //    [self stopAnimation];
    self.isLeftEnter = NO;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [MobClick endLogPageView:[NSString
                                stringWithUTF8String:object_getClassName([self class])]];
}

#pragma mark 通过缓存数据刷新列表

- (void)refreshFormCache {
   
    if (CMTUSER.login != NO) {
        self.isreloadtableView=YES;
    }
  
}
//重新加载tableView
-(void)reloadSubTableView{
    if (self.isreloadtableView) {
//        [self.mSubscriptionTableView reloadData];
        [self DealWithoutInternet];
        self.isreloadtableView=NO;
        
    }else{
        if (CMTUSER.login == NO) {
             [self DealWithoutInternet];

        }else{
                if (self.isLeftEnter||[[NSUserDefaults standardUserDefaults]boolForKey:@"firstLogin_subcrition"]==YES) {
                    if (![AFNetworkReachabilityManager sharedManager].reachable) {
                        [self DealWithoutInternet];
                    }else{
                        
                        [self allSubcription:CMTUSERINFO.userId];
                    }
                }
                else {
                    [self DealWithoutInternet];
                }
        }
    }
}
#pragma mark  登录同步按钮关联方法
- (void)synchronizationSub:(id)sender
{
    /*数据同步逻辑,界面跳转*/
    UINavigationController *navi =[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
    CMTBindingViewController *pBindVC = [CMTBindingViewController shareBindVC];
    [navi pushViewController:pBindVC animated:YES];

#pragma mark 进入专题页 隐藏侧边栏
    
    self.needReOpen = YES;
    [self dismissAnimated:YES completion:nil];
}
//刷新数据首页或者病例数据
- (void)refreshPostList {
    if (self.delegete!=nil) {
        [self.delegete refreshListdata];
    }
}

//获取疾病Id拼接字符串
-(NSString*)getDiseaseListString{
    NSString *Str=@"";
    NSArray *arry;
    if([[NSFileManager defaultManager] fileExistsAtPath:PATH_FOUSTAG]){
        arry=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG];
    }
    for (NSInteger number=0;number<[arry count];number++) {
        CMTDisease *dis=[arry objectAtIndex:number];
        if (number==0) {
            Str=[@"" stringByAppendingString:dis.diseaseId];
        }else{
            Str=[Str stringByAppendingFormat:@",%@",dis.diseaseId];

        }
        
    }
    CMTLog(@"hshshshshshshshsh%@",Str);
    return Str;
    
}
//更新阅读时间
-(void)UpdateReadTime{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    if ([[NSFileManager defaultManager]fileExistsAtPath:PATH_FOUSTAG]) {
        array=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]mutableCopy];
    }
    if ([self.model isEqualToString:@"0"]) {
        for (CMTDisease *dis in array) {
            dis.postReadtime=TIMESTAMP;
        }
    }else if([self.model isEqualToString:@"1"]){
        for (CMTDisease *dis in array) {
            dis.caseReadtime=TIMESTAMP;
        }
    }
    [NSKeyedArchiver archiveRootObject:[array mutableCopy] toFile:PATH_FOUSTAG];

}
#pragma mark   UITableViewDelegate
#pragma mark 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return 50;
}
#pragma mark 选中动作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"%s",__func__);
    CMTConcern *concern;
    CMTSubject *sub;
    
    UINavigationController *navi = [[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
    
    if (indexPath.section == 0) {
        switch (indexPath.row)
        {
            case 0:
            {
                if ([self.model integerValue]==0) {
                    CMTLog(@"进入专题接口");
                    [MobClick event:@"B_Topic_Navi"];
                    CMTEnterSubjectionViewController *pEnterSubjectVC = [[CMTEnterSubjectionViewController alloc]initWithNibName:nil bundle:nil];
                    pEnterSubjectVC.needRequest = YES;
                    [navi pushViewController:pEnterSubjectVC animated:YES];

                }else{
                    CMTOtherPostListViewController *other=[[CMTOtherPostListViewController alloc]initWithDisease:nil diseaseIds:[self getDiseaseListString] module:self.model];
                    
                    [navi pushViewController:other animated:YES];
                    self.needReOpen = YES;
                    [self dismissAnimated:YES completion:nil];


                }
                
#pragma mark 进入专题页 隐藏侧边栏
                
                self.needReOpen = YES;
                [self dismissAnimated:YES completion:nil];
                
            }
              break;
            case 1:{
                [MobClick event:@"B_Tag_Navi"];
                [self UpdateReadTime];
                CMTOtherPostListViewController *other=[[CMTOtherPostListViewController alloc]initWithDisease:nil diseaseIds:[self getDiseaseListString] module:self.model];
                
                [navi pushViewController:other animated:YES];
                self.needReOpen = YES;
                [self dismissAnimated:YES completion:nil];

                
            }
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        @try {
            self.needRequest = YES;
            id obj = [self.mArrSortedTot objectAtIndex:indexPath.row];
            if ([obj isKindOfClass:[CMTSubject class]])
            {
                self.subject = obj;
            }
            else if ([obj isKindOfClass:[CMTConcern class]])
            {
                concern = obj;
                sub = [[CMTSubject alloc]init];
                sub.subject = concern.subject;
                sub.subjectId =concern.subjectId;
                sub.opTime = concern.opTime;
                sub.concernFlag = concern.concernFlag;
                self.subject = sub;
            }
            switch (self.subject.subjectId.integerValue) {
                case 1:
                    [MobClick event:@"B_Tumour_Navi"];
                    break;
                case 2:
                    [MobClick event:@"B_Cardio_Navi"];
                    break;
                case 3:
                    [MobClick event:@"B_Endocrine_Navi"];
                    break;
                case 4:
                    [MobClick event:@"B_Digestion_Navi"];
                    break;
                case 5:
                    [MobClick event:@"B_Nerve_Navi"];
                    break;
                case 6:
                    [MobClick event:@"B_General_Navi"];
                    break;
                case 7:
                    [MobClick event:@"B_Dental_Navi"];
                    break;
                case 8:
                    [MobClick event:@"B_JAMA_Navi"];
                    break;
                case 9:
                    [MobClick event:@"B_Culture_Navi"];
                    break;
                default:
                    break;
            }
            CMTSubcritionListCell *cell = (CMTSubcritionListCell*)[tableView cellForRowAtIndexPath:indexPath];
            
            CMTSubjectPostsViewController *subPostVC = [[CMTSubjectPostsViewController alloc]init];
            subPostVC.mSubject = self.subject;
            subPostVC.mBtnSubListBtn = cell.mBtnSub;
            subPostVC.mArrSubscription = self.mArrSubscription;
            subPostVC.mArrTotleSubs = self.mArrTotleSubs;
            subPostVC.mArrSorted = self.mArrSortedTot;
            subPostVC.strSortedArrCachePath = self.strSubListCachePath;
            subPostVC.strSubListCachePath = self.strSubListCachePath;
            subPostVC.strTotleListCachePath = self.strTotleListCachePath;
            subPostVC.requestNewLeast = YES;
            @weakify(self);
            subPostVC.refreshList = ^(void){
                @strongify(self);
                [self refreshFormCache];
            };
            [navi pushViewController:subPostVC animated:YES];

#pragma mark 进入学科文章列表 隐藏侧边栏
            
            self.needReOpen = YES;
            [self dismissAnimated:YES completion:nil];
        }
        @catch (NSException *exception) {
            CMTLog(@"从self.mArrSortedTot 取值错误");
        }
        
    }
}


#pragma mark  UITableViewDataSource
#pragma mark 绘制行
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"cell";
    static NSString *identifer2 = @"enterCell";
    CMTSubject *subject;
    CMTConcern *concern;
    CMTSubcritionListCell *pCell = [tableView dequeueReusableCellWithIdentifier:identifer];
    CMTEnterCell *pEnderCell = [tableView dequeueReusableCellWithIdentifier:identifer2];
    if (!pCell)
    {
        pCell = [[CMTSubcritionListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    if (!pEnderCell)
    {
        pEnderCell = [[CMTEnterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer2];

        pEnderCell.mImageAccView.frame = CGRectMake(SCREEN_WIDTH*2.0/3.0-25,(50-21)/2, 21, 21);
    }
    //判断已订阅学科是否包含当前cell的标题,设置对应按钮的标题,等接口
    if (indexPath.section == 1)
    {
        //按钮关联方法
        [pCell.mBtnSub addTarget:self action:@selector(addSubcrition:) forControlEvents:UIControlEventTouchUpInside];
        pCell.mBtnSub.tag=indexPath.row;
        pCell.separatorLine.hidden = NO;
        pCell.bottomLine.hidden = YES;
        pCell.mImageAcc.hidden=YES;
        [self noSubcition:pCell.mBtnSub];
        if ([tableView.dataSource tableView:tableView numberOfRowsInSection:1] == indexPath.row+1)
        {
            pCell.bottomLine.hidden = NO;
        }
        if (indexPath.row ==0)
        {
            [pCell.separatorLine builtinContainer:pCell.contentView WithLeft:0 Top:0 Width:SCREEN_WIDTH*2.0/3.0 Height:PIXEL];
        }
        CMTLog(@"row = %ld",(long)indexPath.row);
    
        id obj = [self.mArrSortedTot objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[CMTConcern class]])
                    {
                        concern = obj;
                        for (CMTConcern *con in self.mArrSubscription)
                        {
                            if ([con.subjectId isEqualToString:concern.subjectId])
                            {
                                [self subcrition:pCell.mBtnSub];
                            }
                        }
                        pCell.mLbSub.text = concern.subject.length>0?concern.subject:@"";
                        [pCell.mBtnSub setTag:indexPath.row];
                        
                    }
                    else if ([obj isKindOfClass:[CMTSubject class]])
                    {
                        subject = obj;
                        for (CMTConcern *con in self.mArrSubscription)
                        {
                            if ([con.subject isEqualToString:subject.subject])
                            {
                                [self subcrition:pCell.mBtnSub];
                            }
                        }
                        pCell.mLbSub.text = subject.subject.length>0?subject.subject:@"";
                        [pCell.mBtnSub setTag:indexPath.row];
                    }
                   return pCell;
                }
    else
    {
        if ([self.model integerValue]==0) {
            if (indexPath.row==0) {
                pEnderCell.mImageLeft.image = IMAGE(@"enterSubject");
                pEnderCell.accessoryType = UITableViewCellAccessoryNone;
                pEnderCell.mLabelDes.text = @"专题";
                pEnderCell.bottomLine.hidden = YES;
                pEnderCell.badgePoint.hidden = (CMTAPPCONFIG.themeUnreadNumber.integerValue == 0);
                pEnderCell.badge.hidden=YES;
               
            }else{
                pEnderCell.mImageLeft.image = IMAGE(@"Slide_tag");
                pEnderCell.accessoryType = UITableViewCellAccessoryNone;
                pEnderCell.mLabelDes.text = @"标签";
                pEnderCell.bottomLine.hidden = NO;
                pEnderCell.badgePoint.hidden=YES;
                pEnderCell.badge.hidden =[self.model integerValue]==0? (CMTAPPCONFIG.UnreadPostNumber_Slide.integerValue == 0):(CMTAPPCONFIG.UnreadCaseNumber_Slide.integerValue == 0);
                pEnderCell.badge.text=[self.model integerValue]==0?CMTAPPCONFIG.UnreadPostNumber_Slide:CMTAPPCONFIG.UnreadCaseNumber_Slide;

            }
          
        }else {
                pEnderCell.mImageLeft.image = IMAGE(@"Slide_tag");
                pEnderCell.accessoryType = UITableViewCellAccessoryNone;
                pEnderCell.mLabelDes.text = @"标签";
                pEnderCell.bottomLine.hidden = NO;
                pEnderCell.badgePoint.hidden=YES;
                pEnderCell.badge.hidden =[self.model integerValue]==0? (CMTAPPCONFIG.UnreadPostNumber_Slide.integerValue == 0):(CMTAPPCONFIG.UnreadCaseNumber_Slide.integerValue == 0);
                pEnderCell.badge.text=[self.model integerValue]==0?CMTAPPCONFIG.UnreadPostNumber_Slide:CMTAPPCONFIG.UnreadCaseNumber_Slide;
        }
       
        return pEnderCell;
    }
    
}
//static NSInteger right_Rows;
#pragma mark 分行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if(self.model.integerValue==1){
            return 1;
        }else{
            return 2;
        }
    }
    else
    {
        return self.mArrSortedTot.count;
        
    }
    
    
}
#pragma mark 分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
#pragma mark 页眉高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
#pragma mark 页眉视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*2.0/3.0, 10)];
    pView.backgroundColor = COLOR(c_f5f5f5);
    return pView;
}

@end
