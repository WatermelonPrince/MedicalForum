//
//  CMTBindingViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/22.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBindingViewController.h"
#import "CMTSettingViewController.h"
#import "CMTCenterViewController.h"
#import "CMTNavigationController.h"
#import "CMTUpgradeViewController.h"
#import "CMTPostDetailCenter.h"
#import "CMTPersonalAccountViewController.h"

#define NUMBERS @"0123456789 "

@interface CMTBindingViewController ()<UINavigationControllerDelegate>

@property (strong, nonatomic) CMTSettingViewController *mCMTSettingVC;

@property (strong, nonatomic) CMTAuthCode *mAuthCode;
/*离线订阅的学科信息*/
@property (strong, nonatomic) NSArray *mArrOffLineSubs;

@property (nonatomic, copy, readwrite) NSString *requestPostMessage;    // 请求提示信息

@end
@implementation CMTBindingViewController

+ (instancetype)shareBindVC
{
   
    return [[CMTBindingViewController alloc]init];
}

- (NSArray *)mArrOffLineSubs
{
    if (!_mArrOffLineSubs)
    {
        _mArrOffLineSubs = [NSArray array];
    }
    return _mArrOffLineSubs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"Binding willDeallocSignal");
    }];
    
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255  blue:242.0/255  alpha:1.0];
    self.titleText = @"绑定手机";
    //初始化按钮点击后的冷却时间
    self.mSeconds = 30;
}

- (void)viewWillAppear:(BOOL)animated {
    CMTLog(@"%s", __FUNCTION__);
    
    self.titleText = @"绑定手机";
    [super viewWillAppear:animated];
    [self.view addSubview:self.mTfPhontNum];
    [self.view addSubview:self.mTfVerification];
    [self.view addSubview:self.mBtnVer];
    [self.view addSubview:self.mBtnSure];
    [self.mTfPhontNum becomeFirstResponder];
    
    if (self.mTfPhontNum.text.length == 0)
    {
        [self textFieldNoTouched:self.mBtnVer];
    }
    if (self.mTfVerification.text.length == 0)
    {
        [self textFieldNoTouched:self.mBtnSure];
    }
    
    CMTLog(@"mTfPhontNum:%@",self.mTfPhontNum.text);
    CMTLog(@"mTfVerification:%@",self.mTfVerification.text);
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
    self.isLeftVC = NO;
    [self.mTfPhontNum resignFirstResponder];
    [self.mTfVerification resignFirstResponder];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
    if ([self.mTimer isValid] == YES) {
        [self.mTimer invalidate];
    };
}

- (void)textFieldNoTouched:(UIButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        btn.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
        [btn setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
        btn.userInteractionEnabled = NO;
    });
}

- (void)popViewController
{
    switch (self.nextvc)
    {
        case kHomeVC:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case kLeftVC:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case kDisVC:
        {
            CMTUpgradeViewController *pUpgradeVC = [[CMTUpgradeViewController alloc]init];
            pUpgradeVC.nextVC = kDisVC;
            switch (CMTUSERINFO.authStatus.intValue)
            {
                case 0:
                    if (CMTUSER.login == YES)
                    {
                        [self.navigationController pushViewController:pUpgradeVC animated:YES];
                    }
                    else
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    
                    break;
                case 1:
                case 4:
                    [self.navigationController popViewControllerAnimated:YES];
                    break;
                case 2:
                    [self.navigationController pushViewController:pUpgradeVC animated:YES];
                    break;
                case 3:
                    [self.navigationController popViewControllerAnimated:YES];
                    CMTLog(@"二次认证失败，无法完成认证");
                    break;
                default:
                    break;
            }
            
            break;
        }
        case kComment:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case FromDigitalAndLogin:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
  
        default:
            break;
    }
}
/*手机号*/
- (NSString *)mPhoneNum
{
    if (!_mPhoneNum)
    {
        _mPhoneNum = [NSMutableString string];
    }
    return _mPhoneNum;
}

- (UITextField *)mTfPhontNum
{
    if (!_mTfPhontNum)
    {
        _mTfPhontNum = [[UITextField alloc]initWithFrame:CGRectMake(-1*RATIO, 83, 220*RATIO, 45)];
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc]initWithString:@"填写手机号" attributes:@{NSFontAttributeName:FONT(15*XXXRATIO)}];
        _mTfPhontNum.attributedPlaceholder = placeholder;
        _mTfPhontNum.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        _mTfPhontNum.clearsOnBeginEditing = NO;
        _mTfPhontNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _mTfPhontNum.borderStyle = UITextBorderStyleNone;
        _mTfPhontNum.delegate = self;
        UIView *pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15*RATIO, 45)];
        _mTfPhontNum.leftView = pView;
        _mTfPhontNum.leftViewMode = UITextFieldViewModeAlways;
        _mTfPhontNum.keyboardType = UIKeyboardTypeNumberPad;
        
    }
    
    return _mTfPhontNum;
}
- (UITextField *)mTfVerification
{
    if (!_mTfVerification)
    {
        _mTfVerification = [[UITextField alloc]initWithFrame:CGRectMake(0, 137, 220*RATIO, 45)];
        _mTfVerification.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        _mTfVerification.clearsOnBeginEditing = YES;
        _mTfVerification.clearButtonMode = UITextFieldViewModeWhileEditing;
        _mTfVerification.borderStyle = UITextBorderStyleNone;
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc]initWithString:@"短信验证码" attributes:@{NSFontAttributeName:FONT(15*XXXRATIO)}];
        _mTfVerification.attributedPlaceholder = placeholder;
        [_mTfVerification limitTextLength:10];
        _mTfVerification.delegate = self;
        UIView *pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15*RATIO, 45)];        
        _mTfVerification.leftView = pView;
        _mTfVerification.leftViewMode = UITextFieldViewModeAlways;
        _mTfVerification.keyboardType = UIKeyboardTypeNumberPad;
    }
   
    return _mTfVerification;
}


- (UIButton *)mBtnVer
{
    if (!_mBtnVer)
    {
        _mBtnVer = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mBtnVer setFrame:CGRectMake(self.mTfPhontNum.frame.size.width-1*RATIO, 83, SCREEN_WIDTH-self.mTfPhontNum.frame.size.width, self.mTfPhontNum.frame.size.height)];
        [_mBtnVer setUserInteractionEnabled:NO];
        _mBtnVer.titleLabel.font=FONT(15*XXXRATIO);
        _mBtnVer.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
        [_mBtnVer setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
        [_mBtnVer setTitle:@"获取验证码" forState:UIControlStateNormal];
        
        [_mBtnVer addTarget:self action:@selector(btnGetVerification:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mBtnVer;
}

- (UIButton *)mBtnSure
{
    if (!_mBtnSure)
    {
        _mBtnSure = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mBtnSure setFrame:CGRectMake(self.mBtnVer.frame.origin.x, self.mTfVerification.frame.origin.y, self.mBtnVer.frame.size.width, self.mBtnVer.frame.size.height)];
        [_mBtnSure setUserInteractionEnabled:NO];
         _mBtnSure.titleLabel.font=FONT(15*XXXRATIO);
        _mBtnSure.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
        [_mBtnSure setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
        [_mBtnSure setTitle:@"确定" forState:UIControlStateNormal];
        [_mBtnSure addTarget:self action:@selector(btnPostVerification:) forControlEvents:UIControlEventTouchUpInside];
    }                               
    return _mBtnSure;
}

#pragma mark   正则---判断手机号
-(BOOL) isValidateMobile:(NSString *)mobileNum
{
    
     NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
     NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
     NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
     NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
     NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
     NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
     NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
     NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark  Button Action
/**
 *@brief 获取验证码
 *@param sender 按钮
 */
- (void)btnGetVerification:(id)sender
{
    CMTLog(@"请求验证码");
    /*号码判断*/
    self.mPhoneNum = self.mTfPhontNum.text;
    BOOL validate = self.mPhoneNum.length==11?YES:NO;//[self isValidateMobile:self.mPhoneNum];
    NSDictionary *pDic = @{
                           @"cellphone":self.mPhoneNum
                           };
    /*如果手机号正确,发送请求,获取验证码*//*修改为只判断11位*/
    if (validate)
    {
        @weakify(self);
        if ([AFNetworkReachabilityManager sharedManager].isReachable)//
        {
            [self.rac_deallocDisposable addDisposable:[[CMTCLIENT getAuthCode:pDic] subscribeNext:^(CMTAuthCode * cmtAuthCode) {
                @strongify(self);
                DEALLOC_HANDLE_SUCCESS
                CMTLog(@"cmtAuthCode %@", cmtAuthCode);
                self.mAuthCode = cmtAuthCode;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.mToastView.mLbContent.text = @"验证码已发送，请等待";
//                    [self.view addSubview:self.mToastView];
//                    [self hidden:self.mToastView];
//                });
                
                CMTLog(@"验证码已发送,请耐心等待");
            } error:^(NSError *error) {
                DEALLOC_HANDLE_SUCCESS
                @try {
                    NSString *errorMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                    CMTLog(@"error:%@",errorMes);
                    [self toastAnimation:errorMes];
                }
                @catch (NSException *exception) {
                    CMTLogError(@"verification code HandleError:%@\nException: %@", error, exception);
                }
                
                
            } completed:^{
                DEALLOC_HANDLE_SUCCESS
                CMTLog(@"cmtAuthCode completed");
            }]];
            self.mBtnVer.userInteractionEnabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mBtnVer setTitle:[NSString stringWithFormat:@"%ld 秒",(long)self.mSeconds] forState:UIControlStateNormal];
                [self.mBtnVer setBackgroundColor:[UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0]];
                [self.mBtnVer setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
            });
            self.mTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateBtnTitle) userInfo:nil repeats:YES];
            [self.mTfVerification becomeFirstResponder];
        }
        else
        {
            [self toastAnimation: @"你的网络不给力"];
        }
        
    }
    else
    {
        CMTLog(@"请确认手机号是否正确");
    }
    
}
- (void)updateBtnTitle
{
    self.mSeconds--;
    NSString *btnTitlt = [NSString stringWithFormat:@"%ld 秒",(long)self.mSeconds];
    if (self.mSeconds < 30 && self.mSeconds > 0)
    {
        self.mBtnVer.userInteractionEnabled = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mBtnVer setTitle:btnTitlt forState:UIControlStateNormal];
            [self.mBtnVer setBackgroundColor:[UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0]];
            [self.mBtnVer setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
        });
    }
   else if(self.mSeconds == 0)
    {
        self.mBtnVer.userInteractionEnabled = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mBtnVer setTitle:@"获取验证码" forState:UIControlStateNormal];
            [self.mBtnVer setBackgroundColor: [UIColor colorWithRed:46.0/255 green:190.0/255 blue:181.0/255 alpha:1.0]];
            [self.mBtnVer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        });
        if ([self.mTimer isValid] == YES) {
            [self.mTimer invalidate];
        };
        self.mSeconds = 30;
    }
}

/**
 *@brief 提交验证
 *@param sender 按钮
 */
- (void)btnPostVerification:(UITextField *)textField
{
    CMTLog(@"提交验证");
   // NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    if (self.mBtnSure.userInteractionEnabled == YES && self.mTfPhontNum.text.length == 11)
    {
        [self runAnimationInPosition:self.view.center];
        NSString *author = self.mTfVerification.text;
        NSString *cellPhone = self.mTfPhontNum.text;
        UIImage *pImage = IMAGE(CMTUSERINFO.picture);
        NSString *nickName = CMTUSERINFO.nickname;
        NSDictionary *pDic = [NSDictionary dictionaryWithObjectsAndKeys:author,@"authcode",cellPhone,@"cellphone",pImage,@"picture",nickName,@"nickname", nil];
        self.mCMTSettingVC = [[CMTSettingViewController alloc]init];
        if ([AFNetworkReachabilityManager sharedManager].isReachable)
        {
            
            @weakify(self);
            [self.rac_deallocDisposable addDisposable:[[CMTCLIENT verifyAuthCode:pDic]subscribeNext:^(CMTUserInfo * info) {
                @strongify(self);
                DEALLOC_HANDLE_SUCCESS
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopAnimation];
                });
                
                /*记录订阅界面登陆同步按钮是否显示*/
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"logout"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                if (info.nickname.length > 0)
                {
                    CMTLog(@"服务器返回info=%@",info);
                    
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLogin_collection"];
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLogin_subcrition"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    //刷新病例列表
                     CMTAPPCONFIG.isrefreahCase=@"1";
                    // 同步订阅学科信息
                    [CMTFOCUSMANAGER allCollectionsWithFollows:info.follows userId:info.userId];
                    
                    //同步订阅系列课程
                    [CMTFOCUSMANAGER asyneSeriesListForUser:info];
                    
                    CMTUSER.login = YES;
                    info.canRead=info.epaperSubjectResult.canRead;
                    info.rcodeState=info.epaperSubjectResult.rcodeState;
                    info.decryptKey=info.epaperSubjectResult.decryptKey;
                    CMTUSER.userInfo = info;
                    [CMTUSER save];
                    //获取用户信息
                    [CMTAPPCONFIG getUserInfo];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSArray *items = @[];
                        NSData *pData = [NSJSONSerialization dataWithJSONObject:items options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *pStr = [[NSString alloc]initWithData:pData encoding:NSUTF8StringEncoding];
                        NSDictionary *pCollectionDic = @{
                                                         @"userId":CMTUSER.userInfo.userId,
                                                         @"items":pStr,
                                                         };
                        // 同步收藏信息
                        [CMTFOCUSMANAGER loginToSych:pCollectionDic];
                        // 同步订阅专题信息
                        [CMTFOCUSMANAGER loginToSychThemes:pCollectionDic];
                        
                        /**2.4 9:34**/
                        // 获取订阅总列表
                        [CMTFOCUSMANAGER subcriptions:nil];
                        
                        //获取订阅疾病标签
                        [CMTFOCUSMANAGER CMTSysFocusDiseaseTag:CMTUSER.userInfo.userId?:@"0"];
                        //更新论吧系统通知数目
                        [CMTAPPCONFIG updateCaseSysNoticeUnreadNumber];
                        [CMTAPPCONFIG updateCaseNoticeUnreadNumber];
                        
                        [self popViewController];
                        
                    });
                }
                else
                {
                    self.mCMTSettingVC.mUserInfo = info;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.mCMTSettingVC.nextvc = self.nextvc;
                        [self.navigationController pushViewController:self.mCMTSettingVC animated:YES];
                    });
                    
                }
                
            } error:^(NSError *error) {
                @strongify(self);
                DEALLOC_HANDLE_SUCCESS
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopAnimation];
                });
                
                NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                if ([errorCode integerValue] > 100) {
                    self.requestPostMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                    CMTLog(@"errMes:%@",self.requestPostMessage);
                    
                    [self toastAnimation:self.requestPostMessage];
                    
                } else {
                    [self toastAnimation:@"你的网络不给力"];
                    CMTLogError(@"Request verification code System Error: %@", error);
                }
                
            }]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
            });
            [self toastAnimation:@"你的网路不给力"];
        }
        
    }
    else
    {
        CMTLog(@"请确保输入信息完整");
    }
}


#pragma mark  UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.mTfPhontNum)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.mBtnVer.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
            [self.mBtnVer setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
            _mBtnVer.userInteractionEnabled = NO;
        });
    }
    else if( textField == self.mTfVerification)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mBtnSure.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
            [self.mBtnSure setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
            _mBtnSure.userInteractionEnabled = NO;
        });
    }
    return YES;
}

bool isNum = NO;
bool isTel = NO;
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        return YES;
    }
    if (self.mTfPhontNum == textField)
    {
         NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //CMTLog(toBeString);
        if ([toBeString length] < 11 && toBeString.length > 0)
        {
             NSString* firstCharacter = [toBeString substringWithRange:NSMakeRange(0, 1)];
            if (![firstCharacter isEqualToString:@"1"])
            {
                CMTLog(@"输入错误");
                textField.text = @"";
                [textField shake];
                return YES;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mBtnVer.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
                    [self.mBtnVer setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
                });
            }
            NSCharacterSet *cs;
            cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS]invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
            BOOL isNum = [string isEqualToString:filtered];
            if (!isNum)
            {
                CMTLog(@"输入的不是字符,请输入字符");

                return NO;
            }

           
        }
        else if ([toBeString length] == 11)
        {
            for (int i = 0; i < toBeString.length; i++)
            {
                int a = [toBeString characterAtIndex:i];
                if (a >=48 && a <= 57)
                {
                    isTel = YES;
                }
                else
                {
                    isTel = NO;
                    break;
                }
               
            }
            int b = [toBeString characterAtIndex:0];
            if (b != 49)
            {
                isTel = NO;
            }
            if (isTel == YES && self.mSeconds== 30)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mBtnVer.backgroundColor = [UIColor colorWithRed:46.0/255 green:190.0/255 blue:181.0/255 alpha:1.0];
                    [self.mBtnVer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    self.mBtnVer.userInteractionEnabled = YES;
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mBtnVer.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
                    [self.mBtnVer setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
                    self.mBtnVer.userInteractionEnabled = NO;;
                });
            }
//           dispatch_async(dispatch_get_main_queue(), ^{
//               self.mBtnVer.backgroundColor = [UIColor colorWithRed:46.0/255 green:190.0/255 blue:181.0/255 alpha:1.0];
//               [self.mBtnVer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//               _mBtnVer.userInteractionEnabled = YES;
//           });
        }
        else if([toBeString length]>11)
        {
            return NO;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mBtnVer.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
                [self.mBtnVer setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
            });
        }
        
    }
    
    if (self.mTfVerification == textField)
    {
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //CMTLog(toBeString);
        
        
        if (toBeString.length <= 10)
        {
            if ([toBeString isEqualToString:@""])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mBtnSure.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
                    [self.mBtnSure setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
                    _mBtnSure.userInteractionEnabled = NO;;
                });
            }
            else
            {
                for (int i = 0; i < toBeString.length; i++)
                {
                    int a = [toBeString characterAtIndex:i];
                    if (a >=48 && a <= 57)
                    {
                        isNum = YES;
                    }
                    else
                    {
                        isNum = NO;
                        break;
                    }
                }
                if (isNum == YES)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.mBtnSure.backgroundColor = [UIColor colorWithRed:46.0/255 green:190.0/255 blue:181.0/255 alpha:1.0];
                    [self.mBtnSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        self.mBtnSure.userInteractionEnabled = YES;
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.mBtnSure.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
                        [self.mBtnSure setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
                        _mBtnSure.userInteractionEnabled = NO;;
                    });
                }
            }
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

///关闭粘贴功能
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
