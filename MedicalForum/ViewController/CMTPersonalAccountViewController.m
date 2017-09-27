//
//  CMTPersonalAccountViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/24.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTPersonalAccountViewController.h"
#import "CMTCenterViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTJoinAuthorGroupViewController.h"
#import "VPImageCropperViewController.h"
#import "CMTNickNameSettingViewController.h"
#import "CMTWithoutPermissionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CMTPersonalCell.h"
#import "MypageTableViewCell.h"
#import "CMTMyWorkViewController.h"
#import "CMTCommentEditListViewController.h"
#import "CMTAddressesInfoViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface CMTPersonalAccountViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,VPImageCropperDelegate>

@property (strong, nonatomic) UIImageView *mNickNameImaeView;
@property (strong, nonatomic) UIImageView *mAuthImageView;
@property (strong, nonatomic) UIImageView *mGroupImageView;

@property (strong, nonatomic) NSMutableString *mSubcriptionResult;


/*视图控制器*/

@property (strong, nonatomic) CMTUpgradeViewController *mUpgradeVC;
@property (strong, nonatomic) CMTJoinAuthorGroupViewController *mJoinAuthorVC;
@property (strong, nonatomic) CMTNickNameSettingViewController *mNickNameVC;

@end
@implementation CMTPersonalAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleText = @"我的账号";
    self.view.backgroundColor = COLOR(c_f7f7f7);
    [self.view addSubview:self.mTableView];
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    
    self.mNickNameImaeView = [[UIImageView alloc]initWithImage:IMAGE(@"right")];
    self.mAuthImageView = [[UIImageView alloc]initWithImage:IMAGE(@"right")];
    self.mGroupImageView = [[UIImageView alloc]initWithImage:IMAGE(@"right")];
}

- (void)initViewControllers
{
    self.mUpgradeVC = [[CMTUpgradeViewController alloc]init];
    self.mJoinAuthorVC = [[CMTJoinAuthorGroupViewController alloc]init];
    self.mNickNameVC = [[CMTNickNameSettingViewController alloc]init];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self initViewControllers];
//    [MobClick beginLogPageView:@"P_MyProfile"];
    
    // to do tabBar 新的界面跳转层级
//    UINavigationController *pNav = (UINavigationController *)self.mm_drawerController.centerViewController;
    if( CMTUSER.login == YES && [[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]] == NO)
    {
        [self.mHeadImageView setImageURL:CMTUSERINFO.picture placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(48.0, 48.0)];
    }
    else if (CMTUSER.login == YES && [[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]])
    {
        UIImage *pImage = [UIImage imageWithContentsOfFile:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]];
        [self setHeadImage:pImage];
    }
    else
    {
        //获取设置头像
        UIImage *pImage = IMAGE(@"ic_default_head");
        self.mHeadImageView.image = pImage;
    }
    
    /*设置订阅信息*/
    
    CMTUserInfo *info = CMTUSERINFO;

    if(CMTUSER.login == YES)
    {
        NSMutableString *pResultSubs = [NSMutableString string];
        
        NSMutableArray *userArr = [NSMutableArray array];
        for (CMTFollow *follow in CMTUSERINFO.follows)
        {
            CMTConcern *concern = [[CMTConcern alloc]init];
            concern.subject = follow.subject;
            concern.subjectId = follow.subjectId;
            concern.opTime = follow.opTime;
            concern.concernFlag = nil;
            concern.authors = nil;
            [userArr addObject:concern];
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
                if ([concern1.subject isEqualToString:concern2.subject])
                {
                    [userArr removeObject:concern2];
                }
                
            }
        }
        NSMutableArray *pTotleArray = [NSMutableArray array];
        [pTotleArray addObjectsFromArray:cacheArr];
        [pTotleArray addObjectsFromArray:userArr];
        
        pTotleArray = [[pTotleArray sortedArrayUsingComparator:^NSComparisonResult(CMTConcern* obj1, CMTConcern* obj2) {
            return  [obj1.subjectId compare:obj2.subjectId options:NSCaseInsensitiveSearch];
        }]mutableCopy];
        
        //[pTotleArray addObjectsFromArray:pTotleArray];
        
        for (CMTConcern *concern in pTotleArray)
        {
            if (![concern.subjectId isEqualToString:@"0"])
            {
                [pResultSubs appendString:concern.subject];
                [pResultSubs appendString:@"、"];
            }
            
        }
        if ([pResultSubs hasSuffix:@"、"])
        {
            [pResultSubs deleteCharactersInRange:NSMakeRange(pResultSubs.length-1, 1)];
        }
        self.mLbSubscription.textColor = COLOR(c_ababab);
        self.mLbSubscription.text = pResultSubs;
        if (pResultSubs.length <= 0)
        {
            self.mLbSubscription.text = @"未订阅学科";
        }
        [pTotleArray removeAllObjects];
    }
    else
    {
        self.mLbSubscription.text = @"未订阅学科";
        self.mLbSubscription.textColor = COLOR(c_ababab);
    }
    /*订阅结果已完成,下一步设置认证状态*/
//    int authStatus = info.authStatus.intValue;
//    if (CMTUSER.login == YES && (authStatus == 1 || authStatus == 4 || authStatus == 5 || authStatus == 6 || authStatus == 7))
//    {
//        self.mAuthImageView.hidden = NO;
//    }
//    else if(CMTUSER.login == YES && authStatus == 2)
//    {
//        CMTLog(@"首次认证失败");
//        self.mAuthImageView.hidden = YES;
//    }
//    else if (CMTUSER.login == YES && authStatus == 3)
//    {
//        CMTLog(@"二次认证失败,不能发起认证");
//        self.mAuthImageView.hidden = YES;
//    }
//    else
//    {
//        CMTLog(@"其他情况");
//        self.mAuthImageView.hidden = YES;
//    }
    int roleId = CMTUSERINFO.roleId.intValue;
    // roleId	用户角色	0 普通用户；1 认证用户；2 自媒体作者；3 科室作者；4 官方帐号；5 管理员；6 超级管理员	int
    if (CMTUSER.login == YES && roleId >= 2)
    {
        self.mNickNameImaeView.hidden = NO;
        self.mGroupImageView.hidden = NO;
    }
    else
    {
        self.mNickNameImaeView.hidden = YES;
        self.mGroupImageView.hidden = YES;
    }
    
    self.mLbNickName.text = CMTUSERINFO.nickname;
    CGSize nickNameLbSize = [self.mLbNickName.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]}];
    CMTLog(@"nickNameLbSize的内容长度:%@",NSStringFromCGSize(nickNameLbSize));
//    float index = SCREEN_WIDTH - self.mLbNickName.text.length * 13 - self.mNickNameImaeView.frame.size.width-15*RATIO;
//    if (self.mLbNickName.text.length * 13 > self.mLbNickName.frame.size.width)
//    {
//        self.mNickNameImaeView.centerX = 120*RATIO - self.mNickNameImaeView.frame.size.width;
//    }
//    else
//    {
//        self.mNickNameImaeView.centerX = index;
//    }
    
    [self.mTableView reloadData];
    
    CMTLog(@"isHidden=%d",self.mNickNameImaeView.isHidden);
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



- (UITableView *)mTableView
{
    if (!_mTableView)
    {
        _mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _mTableView.delegate  = self;
        _mTableView.dataSource = self;
        _mTableView.bounces = NO;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mTableView.backgroundColor = COLOR(c_f7f7f7);
    }
    return _mTableView;
}

- (UIImageView *)mHeadImageView
{
    if (!_mHeadImageView)
    {
        _mHeadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 6, 48, 48)];
        _mHeadImageView.layer.masksToBounds = YES;
        _mHeadImageView.layer.cornerRadius = _mHeadImageView.frame.size.height/2;
        [_mHeadImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_mHeadImageView setClipsToBounds:YES];
    }
    return _mHeadImageView;
}

- (void)setHeadImage:(UIImage *)image
{
    self.mHeadImageView.image = image;
}

-(UILabel *)mLbNickName
{
    if (!_mLbNickName)
    {
        /*根据当前用户的名字长度动态创建label的大小，暂时写成固定长度*/
        _mLbNickName = [[UILabel alloc]initWithFrame:CGRectMake(120*RATIO, 0, SCREEN_WIDTH-120*RATIO-10*RATIO, 45)];
        _mLbNickName.textAlignment = NSTextAlignmentRight;
        _mLbNickName.numberOfLines = 0;
        _mLbNickName.textColor = COLOR(c_4766a8);
        _mLbNickName.font = [UIFont systemFontOfSize:15.0];
        _mLbNickName.adjustsFontSizeToFitWidth = YES;
        
    }
    return _mLbNickName;
    
}

- (void)setNickName:(NSString *)nickName
{
    self.mLbNickName.text = nickName;
    [self.mTableView reloadData];
}
- (UILabel *)mLbSubscription
{
    if (!_mLbSubscription)
    {
        _mLbSubscription = [[UILabel alloc]initWithFrame:CGRectMake(120*RATIO, 0, SCREEN_WIDTH-120*RATIO-10*RATIO, 45)];
        _mLbSubscription.textAlignment = NSTextAlignmentRight;
        _mLbSubscription.numberOfLines = 0;
        _mLbSubscription.textAlignment = NSTextAlignmentRight;
        _mLbSubscription.font = [UIFont systemFontOfSize:15];
        _mLbSubscription.lineBreakMode = NSLineBreakByWordWrapping;
        _mLbSubscription.adjustsFontSizeToFitWidth = YES;

    }
    return _mLbSubscription;
}


- (void)setSubjectText:(NSString *)subText
{
    self.mLbSubscription.text = subText;
}

- (UIActionSheet *)pActionSheetView
{
    if (!_pActionSheetView)
    {
        _pActionSheetView = [[UIActionSheet alloc]initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
       
    }
    return _pActionSheetView;
}
//- (UIImageView *)mNickNameImaeView
//{
//    if (!_mNickNameImaeView)
//    {
//        _mNickNameImaeView = [[UIImageView alloc]initWithImage:IMAGE(@"right")];
//    }
//    return _mNickNameImaeView;
//}
//- (UIImageView *)mAuthImageView
//{
//    if (_mAuthImageView)
//    {
//        _mAuthImageView = [[UIImageView alloc]initWithImage:IMAGE(@"right")];
//    }
//    return _mAuthImageView;
//}
//- (UIImageView *)mGroupImageView
//{
//    if (_mGroupImageView)
//    {
//        _mGroupImageView = [[UIImageView alloc]initWithImage:IMAGE(@"right")];
//    }
//    return _mGroupImageView;
//}





#pragma mark  table  delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    CMTPersonalCell *pCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!pCell)
    {
        pCell = [[CMTPersonalCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
        pCell.textLabel.textColor=[UIColor colorWithHexString:@"#737373"];
       
    }
    MypageTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if (!myCell) {
        myCell = [[MypageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
//        myCell.textLabel.textColor=[UIColor colorWithHexString:@"#737373"];

    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {

                    [pCell reloadWithLeftString:nil rightString:@"修改头像" WithImage:YES];
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 1:
                {

                    [pCell reloadWithLeftString:@"昵称" rightString:self.mLbNickName.text WithImage:NO];
                    pCell.rightLabel.textColor = COLOR(c_4766a8);
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 2:
                {

                    [pCell reloadWithLeftString:@"订阅学科" rightString:self.mLbSubscription.text WithImage:NO];
                    pCell.rightLabel.left = pCell.rightLabel.left+20;
                    
                }
                    break;
                case 3:
                {
                    
                    [pCell reloadWithLeftString:@"作品" rightString:nil WithImage:NO];
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    
                }
                    break;
                case 4:
                {
                    
                    [pCell reloadWithLeftString:@"评论" rightString:nil WithImage:NO];
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0)
            {

//                [pCell reloadWithLeftString:@"升级为认证用户" rightString:nil WithImage:NO];
                [myCell reloadData:@"升级为认证用户"];
//                myCell.accessoryView = self.mAuthImageView;
                myCell.leftImageView.hidden = YES;
                myCell.titleLable.left = 20;
                myCell.rightImageView.right = SCREEN_WIDTH - 17;
                return myCell;
            }else if (indexPath.row == 1){
                [pCell reloadWithLeftString:@"加入作者群体" rightString:nil WithImage:NO];
                pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0)
            {

                [pCell reloadWithLeftString:@"收货信息" rightString:nil WithImage:NO];
                pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

              

            }
        }
            break;
        default:
            break;
    }
    
    pCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return pCell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else{
        return 15;
    }
   
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectoion = indexPath.section;
    NSInteger row = indexPath.row;

    switch (sectoion)
    {
        case 0:
        {
            switch (row)
            {
                case 0:
                {
                    CMTLog(@"设置头像");
                    //UIActionSheet *pActionSheetView = [[UIActionSheet alloc]initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
                    [self.pActionSheetView showInView:self.view];
                }
                    break;
                case 1:
                {
                    CMTLog(@"设置昵称");
                    if (CMTUSER.login == YES && CMTUSERINFO.roleId.intValue < 2)
                    {
                        
                        self.mNickNameVC.mCurrentName = self.mLbNickName.text;
                        [self.navigationController pushViewController:self.mNickNameVC animated:YES];
                    }
                }
                    break;
                case 2:
                {
                    CMTLog(@"设置订阅学科");
                }
                    break;
                case 3:
                {
                    CMTLog(@"进入作品列表");
                    //作品
                    [MobClick event:@"B_Works_MN"];
                    CMTLog(@"我的作品");
                    if (CMTUSER.login == YES)
                    {
                        
                        CMTMyWorkViewController *otherPostVC = [[CMTMyWorkViewController alloc]init];
                        [ self.navigationController pushViewController:otherPostVC animated:YES];
                    }else {
                        
                        CMTBindingViewController *mBindVC = [[CMTBindingViewController alloc]initWithNibName:nil bundle:nil];
                        mBindVC.nextvc = kLeftVC;
                        [self.navigationController pushViewController:mBindVC animated:YES];
                    }
                }
                    break;
                case 4:
                {
                    CMTLog(@"进入评论列表");
                    //评论
                    [MobClick event:@"B_Comment_MN"];
                    if (CMTUSER.login == YES)
                    {
                        [MobClick event:@"B_LeftNavi_Comments"];
                        [self.navigationController pushViewController:[[CMTCommentEditListViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
                    }
                    else {
                        
                        CMTBindingViewController *mBindVC = [[CMTBindingViewController alloc]initWithNibName:nil bundle:nil];
                        mBindVC.nextvc = kLeftVC;
                        [self.navigationController pushViewController:mBindVC animated:YES];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (row == 0)
            {
                CMTLog(@"升级为认证用户");
                [self.navigationController pushViewController:self.mUpgradeVC animated:YES];
            }else if (row == 1){
                CMTLog(@"加入作者群体");
                if (CMTUSERINFO.roleId.intValue < 2)
                {
                    [self.navigationController pushViewController:self.mJoinAuthorVC animated:YES];
                }
                else
                {
                    CMTLog(@"你已经是作者");
                }
            }
        }
            break;
        case 2:
        {
            if (row == 0)
            {
                CMTLog(@"进入收货信息页面");
                CMTAddressesInfoViewController *addVC = [[CMTAddressesInfoViewController alloc]init];
                [self.navigationController pushViewController:addVC animated:YES];
            }
        }
            break;
        
            
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 120;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]init];
    if (section == 2) {
        view.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 360/3);
        view.backgroundColor = COLOR(c_f7f7f7);
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(80, 110/3, SCREEN_WIDTH - 160, 140/3);
        [button setTitle:@"退出登录" forState:UIControlStateNormal];
        [button setTitleColor:ColorWithHexStringIndex(c_3CC6C1) forState:UIControlStateNormal];
        button.layer.borderColor = ColorWithHexStringIndex(c_3CC6C1).CGColor;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 5;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(loginOutAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    return view;
}
#pragma mark退出登录
- (void)loginOutAction:(UIButton *)action{
    CMTLog(@"退出登录");
    @try {
        [[[CMTCLIENT logout:@{
                           @"userId":CMTUSERINFO.userId?:@"0",
                           }]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            CMTLogError(@"userId:%@退出登录接口成功",CMTUSERINFO.userId);
            CMTAPPCONFIG.seriesDtlUnreadNumber = @"0";


        } error:^(NSError *error) {
            CMTLogError(@"退出登录几口调取失败");
            CMTAPPCONFIG.seriesDtlUnreadNumber = @"0";

        }];
        [CMTFOCUSMANAGER uploadFollows:YES];
        [self deleteCache:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"CMTUploadFollows"];
        CMTAPPCONFIG.isrefreahCase=@"1";
        [CMTAPPCONFIG clearThemeUnreadNumber];
        [CMTAPPCONFIG cleareGuideUnreadNumber];
        [CMTAPPCONFIG clearPostUnreadNumber];
        [CMTAPPCONFIG clearCaseUnreadNumber];
        [CMTAPPCONFIG clearCaseNoticeNumber];
        [CMTAPPCONFIG clearHomeNoticeUnreadNumber];





    }
    @catch (NSException *exception) {
        CMTLog(@"退出----》》》");
    }
}

- (void)deleteCache:(id)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"subCount"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"loginState"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"logout"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLogin"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"cacheImage"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self removeItemAtPaths:@[
                              PATH_USERS,
                              PATH_CACHES,
                              ]
               OnCompletion:^{
                   CMTLog(@"CMTUSER 退出登录");
                   CMTUSER.login = NO;
                   [CMTUSER save];
                   [self.navigationController popToRootViewControllerAnimated:YES];
               }];
}

- (void)removeItemAtPaths:(NSArray *)itemPaths OnCompletion:(void(^)())completion {
    if (itemPaths == nil || ![itemPaths isKindOfClass:[NSArray class]]) {
        CMTLogError(@"Remove Item At Paths Error: Wrong ItemPaths");
        return;
    }
    
    dispatch_queue_t ioQueue = dispatch_queue_create("com.MedicalForum.deleteCache", DISPATCH_QUEUE_SERIAL);
    __block NSFileManager *fileManager = nil;
    dispatch_sync(ioQueue, ^{
        fileManager = [NSFileManager new];
    });
    dispatch_async(ioQueue, ^{
        for (NSString *itemPath in itemPaths) {
            [fileManager removeItemAtPath:itemPath error:nil];
            [fileManager createDirectoryAtPath:itemPath
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:NULL];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

#pragma mark  table dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 5;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
            
        default:
            return 0;
    }
}


/*自定义协议。选择头像确认后*/
#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
   
    if ([AFNetworkReachabilityManager sharedManager].isReachable){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"headImage"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        BOOL suc = [UIImagePNGRepresentation(editedImage) writeToFile:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"] atomically:YES];
        if (suc)
        {
            CMTLog(@"缓存头像成功");
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"cacheImage"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        else
        {
            CMTLog(@"缓存头像失败");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setHeadImage:editedImage];
            NSDictionary *pDic = @{
                                   @"picture": editedImage,
                                   @"nickname": self.mLbNickName.text ?: @"",
                                   @"userId": CMTUSER.userInfo.userId ?: @"",
                                   };
            
            [self.rac_deallocDisposable addDisposable:[[CMTCLIENT modifyPicture:pDic]subscribeNext:^(CMTPicture * picture) {
                
                DEALLOC_HANDLE_SUCCESS
                CMTLog(@"picture=%@",picture.picture);
                if (CMTUSER.login)
                {
                    CMTUSERINFO.picture = picture.picture;
                }
                [self toastIntegralAnimation:@"10" title:@"完成个人形象"];
                
            } error:^(NSError *error) {
                CMTLog(@"error");
                DEALLOC_HANDLE_SUCCESS
                NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                if ([errorCode integerValue] > 100) {
                    NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                    CMTLog(@"errMes = %@",errMes);
                } else {
                    CMTLogError(@"modifypicture System Error: %@", error);
                }
                
            }]];
            
            [self.mTableView reloadData];
        });
        [cropperViewController dismissViewControllerAnimated:YES completion:^{
            // TO DO
        }];
    }
    else{
        [cropperViewController dismissViewControllerAnimated:YES completion:^{
            [self toastAnimation:@"你的网络不给力"];
        }];
    }
    
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
    //self.hasChosImage = NO;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    CMTLog(@"index = %ld", (long)buttonIndex);
    if(buttonIndex==0){
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            
            NSLog(@"相机权限受限");
            CMTWithoutPermissionViewController *per= [[CMTWithoutPermissionViewController alloc]init];
            UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:per];
            [self presentViewController:nav animated:YES completion:nil];
            
            return;
        }
    }
    if (buttonIndex==1) {
        ALAuthorizationStatus authStatus =[ALAssetsLibrary authorizationStatus];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            
            NSLog(@"相册权限受限");
            CMTWithoutPermissionViewController *per= [[CMTWithoutPermissionViewController alloc]initWithType:@"1"];
            UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:per];
            [self presentViewController:nav animated:YES completion:nil];
            return;
        }
        
    }

    if (buttonIndex == 0) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            
            NSLog(@"相机权限受限");
            CMTWithoutPermissionViewController *per= [[CMTWithoutPermissionViewController alloc]init];
            UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:per];
            [self presentViewController:nav animated:YES completion:nil];
            
            return;
        }

        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 CMTLog(@"Picker View Controller is presented");
                             }];
        }
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 CMTLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
            
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) CMTLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [MobClick endLogPageView:@"P_MyProfile"];
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
