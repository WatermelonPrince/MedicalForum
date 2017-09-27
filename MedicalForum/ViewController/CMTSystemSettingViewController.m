//
//  CMTSystemSettingViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTSystemSettingViewController.h"
#import "CMTCenterViewController.h"
#import "CMTAboutViewController.h"
#import "CMTCustomFontSizeViewController.h"
#include <dirent.h>
#include <sys/stat.h>
#import "SDWebImageManager.h"           // 图片缓存
#import "CMTContactViewController.h"
#import "CMTLiveShareView.h"
@interface CMTSystemSettingViewController ()<UINavigationControllerDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) CMTAboutViewController *mCMTAboutVC;
@property(strong,nonatomic)UISwitch *switchButton;
@property (assign) BOOL isClearn;
@property(strong,nonatomic)CMTLiveShareView *recommendView;
@end

@implementation CMTSystemSettingViewController
@synthesize switchButton;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal");
    }];
    self.titleText = @"设置";
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    [self.view addSubview:self.mTableView];
    [self.view addSubview:self.lbBufferSize];
    [self.view addSubview:self.lbSoftVersion];
    
    [self initViewControllers:nil];
}
-(CMTLiveShareView*)recommendView{
    if(_recommendView==nil){
        _recommendView=[[CMTLiveShareView alloc]init];
        _recommendView.parentView=self;
        CMTLivesRecord *record=[[CMTLivesRecord alloc]init];
        CMTPicture *pic=[[CMTPicture alloc]init];
        pic.picFilepath=CMTAPPCONFIG.contact.recommend.shareImg;
        record.sharePic=pic;
        record.title=CMTAPPCONFIG.contact.recommend.shareTitle;
        record.shareUrl=CMTAPPCONFIG.contact.recommend.shareUrl;
        record.shareDesc=CMTAPPCONFIG.contact.recommend.shareBrief;
        _recommendView.LivesRecord=record;
    }
    return _recommendView;
}
- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHES stringByAppendingPathComponent:@"appcommonget_all_hospital.json?"]])
    {
        [[NSFileManager defaultManager]removeItemAtPath:[PATH_CACHES stringByAppendingPathComponent:@"appcommonget_all_hospital.json?"] error:nil];
    }

}
//改变开关按钮状态
-(void)changeSwitchState{
    NSString *state=[[NSUserDefaults standardUserDefaults]objectForKey:@"CMTnoticeState"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (setting.types==UIUserNotificationTypeNone) {
            switchButton.on=NO;
        }else{
            if ([state isEqualToString:@"false"]) {
                 switchButton.on=NO;
            }else{
                switchButton.on=YES;
            }
        }
    }else{
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (type==UIUserNotificationTypeNone) {
            switchButton.on=NO;
        }else{
            if ([state isEqualToString:@"false"]) {
                switchButton.on=NO;
            }else{
                switchButton.on=YES;
            }
        }
        
    }

    
}

/*初始化所有视图控制器*/
- (void)initViewControllers:(id)sender
{
    self.mCMTAboutVC = [[CMTAboutViewController alloc]init];
}

- (NSMutableArray *)mAllFiles
{
    if (!_mAllFiles)
    {
        _mAllFiles = [NSMutableArray array];
    }
    return _mAllFiles;
}
- (UITableView *)mTableView
{
    if (!_mTableView)
    {
        _mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH,SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.scrollEnabled = NO;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mTableView;
}
- (UIView *)separatorLine {
    if (_separatorLine == nil) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _separatorLine;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _bottomLine;
}


- (void)initAlertView:(NSString *)title mes:(NSString *)mes buttonTitlt:(NSString *)sureBtnTitle cancelBtn:(NSString *)cancelBtnTitle
{
    if (_mAlertView == nil)
    {
        _mAlertView = [[UIAlertView alloc]initWithTitle:title message:mes delegate:self cancelButtonTitle:cancelBtnTitle otherButtonTitles:sureBtnTitle,nil];
    }
}



#pragma mark  UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 20;
    }
    return 32;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"%@",NSStringFromCGPoint(CGPointMake(indexPath.section, indexPath.row)));
    NSString *sureButtonTitle = @"确定";
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [self initAlertView:nil mes:@"确定清理缓存吗?" buttonTitlt:sureButtonTitle cancelBtn:@"取消"];
                    if (self.isClearn || [self.lbBufferSize.text isEqualToString:@"0.00M"])
                    {
                        [self toastAnimation:@"没有缓存暂时无法处理"];
                    }
                    else
                    {
                        [_mAlertView show];
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
            switch (indexPath.row)
            {
                case 0:
                {
                    CMTLog(@"设置字体大小");
                    CMTCustomFontSizeViewController *customFontSizeViewController = [[CMTCustomFontSizeViewController alloc] initWithNibName:nil bundle:nil];
                    [self.navigationController pushViewController:customFontSizeViewController animated:YES];
                }
                    break;
                case 1:
                {
                    CMTLog(@"");
                    [self.navigationController pushViewController:self.mCMTAboutVC animated:YES];
                    
                }
                    break;

                case 2:
                {
                    CMTLog(@"联系我们");
                    [self.navigationController pushViewController:[[CMTContactViewController alloc]init] animated:YES];
                    
                }
                    break;

                case 3:
                {
                    CMTLog(@"推荐");
                    [MobClick event:@"B_Mine_Recommendation"];
                    [self.recommendView showSharaAction];
                    
                }

                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}
#pragma mark  UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.mUpDateAlertView)
    {
        CMTLog(@"版本测试");
        switch (buttonIndex)
        {
            case 0:
            {
                CMTLog(@"%@",[alertView buttonTitleAtIndex:buttonIndex]);
                
            }
                break;
            case 1:
            {
                 CMTLog(@"%@",[alertView buttonTitleAtIndex:buttonIndex]);
                if (self.path.length > 0)
                {
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.path]];
                }
            }
                break;
            default:
                break;
        }
    }
    else
    {
        switch (buttonIndex)
        {
            case 0:
            {
                //CMTLog([alertView buttonTitleAtIndex:0]);
                self.isClearn = NO;
            }
                break;
            case 1:
            {
                //CMTLog([alertView buttonTitleAtIndex:1]);
                [self clearBuffer:nil];
                self.isClearn = YES;
            }
                break;
            default:
                break;
        }
    }
    
}

- (void)clearBuffer:(id)sender
{
    BOOL sucess = NO;
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManger fileExistsAtPath:PATH_CACHES])
    {
        CMTLog(@"%@",PATH_CACHES);
        sucess = [fileManger removeItemAtPath:PATH_CACHES error:&error];
        
    }
    
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    [[SDWebImageManager sharedManager].imageCache cleanDisk];
    [[SDWebImageManager sharedManager].imageCache clearDiskOnCompletion:^{
        CMTLog(@"清空PATH_SDWEBIMAGE成功");
    }];
   
    if (sucess)
    {
        CMTLog(@"缓存清除成功");
        self.mToastView.mLbContent.text = @"缓存清除成功";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:self.mToastView];
            [self hidden:self.mToastView];
            [self.mTableView reloadData];
        });
    }

}

#pragma mark  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return 2;
        }
        case 1:
        {
            return 4;
        }
        default:
            return 0;
            break;
    }
}
///获取指定文件尺寸大小
- (float)fileSizeAtPath:(NSString *)path
{
    float fileSize = 0.0;
    if ([[NSFileManager defaultManager]fileExistsAtPath:path])
    {
        fileSize = [[[NSFileManager defaultManager]attributesOfItemAtPath:path error:nil]fileSize]/(1024.0*1024.0);
    }
    return fileSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    UIView *sepLine = [[UIView alloc]init];
    sepLine.backgroundColor = COLOR(c_eaeaea);
    if (!pCell)
    {
        pCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifer];
        pCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [pCell.contentView addSubview:sepLine];
        [sepLine builtinContainer:pCell.contentView WithLeft:0 Top:0 Width:SCREEN_WIDTH Height:PIXEL];
    }
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    pCell.textLabel.text = @"手动清理缓存";
                    float cacheSize = ([CMTSystemSettingViewController folderSizeAtPath3:PATH_CACHES]+[CMTSystemSettingViewController folderSizeAtPath3:PATH_SDWEBIMAGE])/(1024.0 * 1024.0);
                    CMTLog(@"cacheSize = %.2f",cacheSize);
                    //系统隐藏文件
                    if (cacheSize <= 0.02)
                    {
                        cacheSize = 0.00;
                    }
                    
                    NSString *pCacheSize = [NSString stringWithFormat:@"%.2fM",cacheSize];
                    if (self.isClearn)
                    {
                        self.lbBufferSize.text = @"0.00M";
                    }
                    else
                    {
                        [self bufferSize:pCacheSize];
                    }
                    pCell.accessoryView = self.lbBufferSize;
                    UIView *bottomLine = [[UIView alloc]init];
                    bottomLine.backgroundColor = COLOR(c_eaeaea);
                    [pCell.contentView addSubview:bottomLine];
                    [bottomLine builtinContainer:pCell.contentView WithLeft:0 Top:45-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
                    
                }
                    break;
                case 1:{
                    pCell.textLabel.text = @"允许推送通知";
                    switchButton=[[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 80*RATIO, 30)];
                    switchButton.onTintColor=[UIColor colorWithHexString:@"#3CC6C1"];
                    switchButton.tintColor=[UIColor colorWithHexString:@"#D1D1D1"];
                    [self changeSwitchState];
                    pCell.accessoryView=switchButton;
                    [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    pCell.textLabel.text = @"设置字体大小";
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    [pCell.contentView addSubview:self.separatorLine];
                    
                }
                    break;
                case 1:
                {
                    pCell.textLabel.text = @"关于我们";
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    UIView *bottomLine = [[UIView alloc]init];
                    bottomLine.backgroundColor = COLOR(c_eaeaea);
                    [pCell.contentView addSubview:bottomLine];
                    [bottomLine builtinContainer:pCell.contentView WithLeft:0 Top:45-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
                }
                    break;
                case 2:
                {
                    pCell.textLabel.text = @"联系我们";
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    UIView *bottomLine = [[UIView alloc]init];
                    bottomLine.backgroundColor = COLOR(c_eaeaea);
                    [pCell.contentView addSubview:bottomLine];
                    [bottomLine builtinContainer:pCell.contentView WithLeft:0 Top:45-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
                }
                    break;
                case 3:
                {
                    pCell.textLabel.text = @"把壹生推荐给好友";
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    UIView *bottomLine = [[UIView alloc]init];
                    bottomLine.backgroundColor = COLOR(c_eaeaea);
                    [pCell.contentView addSubview:bottomLine];
                    [bottomLine builtinContainer:pCell.contentView WithLeft:0 Top:45-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
                }
                    break;

                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
   
    
    return pCell;
}
//打开设置通知打开和关闭通知
-(void)switchAction:(UISwitch*)sender{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (setting.types==UIUserNotificationTypeNone) {
            switchButton.on=NO;
            UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"请打开“设置”-“通知”，找到“壹生”，打开允许通知按钮" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:^{
                
            }];

        }else{
           [self setCMTnoticeState:sender];
        }
    }else{
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (type==UIUserNotificationTypeNone) {
            switchButton.on=NO;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请打开“设置”-“通知”，找到“壹生”，打开允许通知按钮" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"CMTnoticeState"];
            [CMTSOCIAL stopGexinSdk];
        }else{
            [self setCMTnoticeState:sender];
        }
        
    }
    
}
//设置状态
-(void)setCMTnoticeState:(UISwitch*)sender{
    if (sender.on) {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"CMTnoticeState"]boolValue]) {
           NSDictionary *Dic=@{@"clientId":CMTSOCIAL.clientId,@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"pushSwitch":@"1"};
            CMTLog(@"推送打开成功");
          [[[CMTCLIENT getPushInit:Dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSDictionary *state) {
            [[NSUserDefaults standardUserDefaults]setObject:@"true" forKey:@"CMTnoticeState"];
          } error:^(NSError *error) {
              sender.on=NO;
               CMTLog(@"推送打开失败");
              [self toastAnimation:@"你的网络不给力"];
          }];
        }

        
    }else{
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CMTnoticeState"]boolValue]){
            NSDictionary *Dic=@{@"clientId":CMTSOCIAL.clientId,@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"pushSwitch":@"2"};
            [[[CMTCLIENT getPushInit:Dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSDictionary *state) {
                [[NSUserDefaults standardUserDefaults]setObject:@"false" forKey:@"CMTnoticeState"];
                 CMTLog(@"推送关闭");
                
            } error:^(NSError *error) {
                sender.on=YES;
                [self toastAnimation:@"你的网络不给力"];
            }];
        }

    }

}

- (void)fontSizeSetting:(id)sender
{
    CMTLog(@"%s",__func__);
}
- (void)softVersion
{
    /*网络请求版本号*/
    self.lbSoftVersion.text = APP_VERSION;
   
}
- (UILabel *)lbSoftVersion
{
    if (_lbSoftVersion == nil)
    {
        _lbSoftVersion = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80*RATIO, 30)];
        _lbSoftVersion.textAlignment = NSTextAlignmentRight;
        _lbSoftVersion.adjustsFontSizeToFitWidth = YES;
    }
    return _lbSoftVersion;
}

- (void)bufferSize:(NSString *)currentSize
{
    self.lbBufferSize.text = currentSize;
}
- (UILabel *)lbBufferSize
{
    if (!_lbBufferSize)
    {
        _lbBufferSize = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80*RATIO, 30)];
        _lbBufferSize.adjustsFontSizeToFitWidth = YES;
        _lbBufferSize.textAlignment = NSTextAlignmentRight;
    }
    return _lbBufferSize;
}

+ (long long) folderSizeAtPath3:(NSString*) folderPath{
    return [self _folderSizeAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}
//Private
+ (long long) _folderSizeAtPath: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        NSUInteger folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self _folderSizeAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }
    }
    return folderSize;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isClearn = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
