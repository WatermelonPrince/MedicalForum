//
//  CMTNickNameSettingViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//



#import "CMTNickNameSettingViewController.h"
#import "CMTPersonalAccountViewController.h"


@interface CMTNickNameSettingViewController ()<UITextFieldDelegate>

@end

@implementation CMTNickNameSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.mTfField];
    [self.mTfField limitTextLength:20];
    self.navigationItem.leftBarButtonItem = self.mLeftItem;
    self.navigationItem.rightBarButtonItem = self.mRightItem;
    self.titleText = @"修改昵称";
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mTfField.text = self.mCurrentName;
    
}

- (UITextField *)mTfField
{
    if (!_mTfField)
    {
        _mTfField = [[UITextField alloc]initWithFrame:CGRectMake(0, 83, SCREEN_WIDTH, 45)];
        _mTfField.clearsOnBeginEditing = NO;
        _mTfField.clearButtonMode = UITextBorderStyleLine;
        _mTfField.layer.borderColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0].CGColor;
        _mTfField.delegate = self;
        _mTfField.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        _mTfField.placeholder = @"填写昵称";
        UIImageView *pImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10*RATIO, 45)];
        _mTfField.leftView = pImageView;
        _mTfField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _mTfField;
}

- (UIBarButtonItem *)mLeftItem
{
    if (!_mLeftItem)
    {
        NSString *pTempStr = @"取消" ;
        NSString*pTitleStr = [self string:pTempStr WithColor:COLOR(c_32c7c2)];
        _mLeftItem = [[UIBarButtonItem alloc]initWithTitle:pTitleStr style:UIBarButtonItemStyleDone target:self action:@selector(buttonCancel:)];
    }
    return _mLeftItem;
}
- (UIBarButtonItem *)mRightItem
{
    if (!_mRightItem)
    {
        NSString *pTitle = [self string:@"保存" WithColor:COLOR(c_32c7c2)];
        
        _mRightItem = [[UIBarButtonItem alloc]initWithTitle:pTitle style:UIBarButtonItemStyleDone target:self action:@selector(buttonSave:)];
    }
    return _mRightItem;
}
//- (NSString *)string:(NSString *)str WithColor:(UIColor *)color
//{
//    NSMutableAttributedString *pAttStr = [[NSMutableAttributedString alloc]initWithString:str];
//    [pAttStr addAttribute:NSForegroundColorAttributeName value:color range:NSRangeFromString(str)];
//    return [pAttStr string];
//}
#pragma mark  Item method
- (void)buttonSave:(UIBarButtonItem *)item
{
    //完成跨界面数据传递,同时完成弹栈
    NSString *pName = self.mTfField.text;
    /*调用修改用户信息接口,同步到服务器端一份*/
    if (pName.length > 0)
    {
        UIImage *pImage;
        if ([pName isEqualToString:self.mCurrentName])
        {
            CMTLog(@"你没有做出修改");
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if ([AFNetworkReachabilityManager sharedManager].isReachable) {
                NSData *pData;
                NSDictionary *pDic = [NSDictionary dictionary];
                if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]])
                {
                    pData =[NSData dataWithContentsOfFile:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]];
                }
                else
                {
                    pData = [NSData dataWithContentsOfURL:[NSURL URLWithString:CMTUSERINFO.picture]];
                    
                }
                if (pData.length > 0)
                {
                    pImage = [UIImage imageWithData:pData];
                    
                    pDic = @{
                             @"picture":pImage,
                             @"nickname":pName,
                             @"userId":CMTUSERINFO.userId,
                             };
                }
                else
                {
                    pDic = @{
                             @"picture":@"",
                             @"nickname":pName,
                             @"userId":CMTUSERINFO.userId,
                             };
                }
                
                
                
                //pDic = [NSDictionary dictionaryWithObjectsAndKeys:pImage,@"picture",pName,@"nickname",CMTUSERINFO.userId,@"userId", nil];
                @weakify(self);
                [self.rac_deallocDisposable addDisposable:[[CMTCLIENT modifyPicture:pDic]subscribeNext:^(CMTPicture * picture) {
                    @strongify(self);
                    DEALLOC_HANDLE_SUCCESS
                    CMTLog(@"picture=%@",picture.picture);
                    CMTLog(@"个人信息修改完成");
                    
                    CMTUSER.userInfo.nickname = pName;
                    [CMTUSER save];
                    //                CMTUser *user = CMTUSER;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)])
                        {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    });
                    
                } error:^(NSError *error) {
                    DEALLOC_HANDLE_SUCCESS
                    CMTLog(@"error");
                    [self toastAnimation:@"你的网络不给力"];
                    NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                    if ([errorCode integerValue] > 100) {
                        NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                        CMTLog(@"errMes = %@",errMes);
                        
                    } else {
                        CMTLogError(@"modifypicture System Error: %@", error.userInfo);
                    }
                    
                }]];
            }
            else{
            
                [self toastAnimation:@"你的网络不给力"];
            }

        }
    }
    else
    {
        CMTLog(@"昵称不可为空");
        [self toastAnimation:@"请输入昵称"];
        [self.mTfField becomeFirstResponder];
    }
}

/*取消按钮关联方法*/
- (void)buttonCancel:(UIBarButtonItem *)item
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

#pragma mark  textField  delegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.mTfField.text = @"";
}

@end
