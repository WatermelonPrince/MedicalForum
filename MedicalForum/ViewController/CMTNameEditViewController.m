//
//  CMTNameEditViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/25.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


#import "CMTNameEditViewController.h"
#import "CMTUpgradeViewController.h"

#define kMaxLength 20
#define NUMBERS @"0123456789 "

@interface CMTNameEditViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) CMTUpgradeViewController *mCMTUpgradeVC;

@end

@implementation CMTNameEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mTfField.text = self.lastVCStr;
    [self.contentBaseView addSubview:self.mTfField];
    self.navigationItem.leftBarButtonItem = self.mLeftItem;
    self.navigationItem.rightBarButtonItem = self.mRightItem;
}
- (void)viewWillAppear:(BOOL)animated
{
   
    NSArray *pArr = self.navigationController.childViewControllers;
//    if ([[pArr objectAtIndex:pArr.count-2] isKindOfClass:[CMTUpgradeViewController class]])
//    {
//        self.mCMTUpgradeVC = [pArr objectAtIndex:pArr.count-2];
//    }
    for (id vc in pArr) {
        if ([vc isKindOfClass:[CMTUpgradeViewController class]]) {
            self.mCMTUpgradeVC = (CMTUpgradeViewController *)vc;
        }
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];
    [super viewWillAppear:animated];
    if([self.type isEqualToString:@"邀请码"]){
        self.titleText = @"邀请码";
        self.mTfField.placeholder = @"请输入邀请码";
        [self.mTfField limitTextLength:20];
    }else if (self.row == 0)
    {
            self.titleText = @"";
            self.mTfField.placeholder = @"请输入真实姓名";
            [self.mTfField limitTextLength:20];
    }
    else if (self.row == 5)
    {
        self.titleText = @"执业医师号";
        self.mTfField.placeholder = @"请输入执业医师号";
        [self.mTfField limitTextLength:50];
    }else if (self.row == 3)
    {
        self.titleText = @"级别";
        self.mTfField.placeholder = @"请输入医生级别";
        [self.mTfField limitTextLength:20];
    }else if(self.row==7){
        self.titleText = @"昵称";
        self.mTfField.placeholder = @"输入参与讨论时显示的昵称";
        [self.mTfField limitTextLength:20];
    }
    
    
#pragma mark收货信息界面修改
    if ([self.inputClass isEqualToString:@"收货人"]) {
        self.titleText = @"收货人";
        self.mTfField.placeholder = @"请输入收货人姓名";
        [self.mTfField limitTextLength:20];
    }else if ([self.inputClass isEqualToString:@"E-mail"]){
        self.titleText = @"E-mail";
        self.mTfField.placeholder = @"请输入邮箱地址";
        [self.mTfField limitTextLength:20];
    }else if ([self.inputClass isEqualToString:@"联系电话"]){
        self.titleText = @"联系电话";
        self.mTfField.placeholder = @"请输入联系电话";
        self.mTfField.keyboardType = UIKeyboardTypePhonePad;
        [self.mTfField limitTextLength:11];
    }else if ([self.inputClass isEqualToString:@"联系地址"]){
        self.titleText = @"联系地址";
        self.mTfField.placeholder = @"请输入联系地址";
        [self.mTfField limitTextLength:50];
    }
}

- (UITextField *)mTfField
{
    if (!_mTfField)
    {
        _mTfField = [[UITextField alloc]initWithFrame:CGRectMake(0, 83, SCREEN_WIDTH, 45)];
        _mTfField.borderStyle = UITextBorderStyleNone;
        _mTfField.layer.borderWidth = 0.5;
        _mTfField.clearsOnBeginEditing = NO;
        _mTfField.clearButtonMode = UITextBorderStyleLine;
        _mTfField.layer.borderColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0].CGColor;
        _mTfField.delegate = self;
        _mTfField.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        UIImageView *pImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10*RATIO, 45)];
        _mTfField.leftView = pImageView;
        _mTfField.leftViewMode = UITextFieldViewModeAlways;
        //[_mTfField setAutocorrectionType:UITextAutocorrectionTypeNo];
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

/*取消按钮关联方法*/
- (void)buttonCancel:(UIBarButtonItem *)item
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
bool isAllEmpty = NO;
- (void)buttonSave:(UIBarButtonItem *)item
{
           CMTLog(@"%@",self.mTfField.text);
    if([self.type isEqualToString:@"邀请码"]){
        if(self.updatRealname!=nil){
            self.updatRealname(self.mTfField.text);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if (self.row == 0||self.row==7)
        {
            /*过滤换行符,空格符*/
            self.mTfField.text = [self.mTfField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (self.mCMTUpgradeVC != nil)
            {
                if (self.mTfField.text.length == 0)
                {
                    [self toastAnimation:@"姓名不能全为空格"];
                }
                else
                {
                    self.mCMTUpgradeVC.mStrRealy = self.mTfField.text;
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else{
                if (self.mTfField.text.length == 0)
                {
                    
                    [self toastAnimation:self.row==0?@"姓名不能全为空格":@"昵称不能全为空格"];
                    return;
                }

                if(self.updatRealname!=nil){
                    self.updatRealname(self.mTfField.text);
                }
                 [self.navigationController popViewControllerAnimated:YES];

            }
        }
        else if (self.row == 5)
        {
            if ((self.mTfField.text.length < 15 || self.mTfField.text.length > 50) && self.mTfField.text.length !=0)
            {
                
                [self toastAnimation:@"您输入的职业医师号不合法"];
            }
            else
            {
                BOOL isValid = NO;
                //self.mCMTUpgradeVC.mLbDoctorNum.text = self.mTfField.text;
                for (int i = 0; i < self.mTfField.text.length; i++)
                {
                    int a = [self.mTfField.text characterAtIndex:i];
                    if (a >= 48 && a<= 57)
                    {
                        isValid = YES;
                    }
                    else
                    {
                        isValid = NO;
                        break;
                    }
                }
                if (self.mTfField.text.length == 0) {
                    isValid = YES;
                }
                if (isValid)
                {
                    self.mCMTUpgradeVC.mStrDoctorNum = self.mTfField.text;
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    CMTLog(@"执业医师号输入不合法");
                    [self toastAnimation:@"您输入的职业医师号不合法"];
                }
            
            }
            
        }
        else if (self.row == 3)
        {
            /*过滤换行符,空格符*/
            self.mTfField.text = [self.mTfField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (self.mCMTUpgradeVC != nil)
            {
                if (self.mTfField.text.length == 0)
                {
                    [self toastAnimation:@"级别不能为空"];
                }
                else
                {
                    self.mCMTUpgradeVC.mStrGrade = self.mTfField.text;
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
   
        }
#pragma mark收货信息编辑保存
    /*过滤换行符,空格符*/
    self.mTfField.text = [self.mTfField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.inputClass isEqualToString:@"收货人"])
    {
        
        if (self.mTfField.text.length == 0)
        {
            [self toastAnimation:@"收货人姓名不能为空"];
        }
        else
        {
            if (self.updatRealname!=nil) {
                self.updatRealname(self.mTfField.text);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else if ([self.inputClass isEqualToString:@"E-mail"])
    {
        if (self.mTfField.text.length == 0)
        {
            [self toastAnimation:@"邮箱地址不能为空"];
        }else
        {
            if ([self isValidateEmail:self.mTfField.text])
            {
                if (self.updatRealname !=nil)
                {
                    self.updatRealname(self.mTfField.text);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self toastAnimation:@"邮箱格式不正确"];
            }
        }
        
    }else if ([self.inputClass isEqualToString:@"联系电话"])
    {
        if (self.mTfField.text.length == 0)
        {
            [self toastAnimation:@"联系电话不能为空"];
        }else
        {
            BOOL validate = self.mTfField.text.length==11?YES:NO;

            if (validate)
            {
                if (self.updatRealname !=nil)
                {
                    self.updatRealname(self.mTfField.text);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self toastAnimation:@"手机格式不正确"];
            }
        }
    }else if ([self.inputClass isEqualToString:@"联系地址"])
    {
        if (self.mTfField.text.length == 0)
        {
            [self toastAnimation:@"联系地址不能为空"];
        }else
        {
            BOOL validate = self.mTfField.text.length>=5?YES:NO;
            
            if (validate)
            {
                if (self.updatRealname !=nil)
                {
                    self.updatRealname(self.mTfField.text);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self toastAnimation:@"不能少于5个字"];
            }
        }

        
    }
    
    
   
    
    
}
#pragma mark利用正则表达式验证邮箱是否合法
-(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark  UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.mTfField.placeholder isEqualToString:@"请输入执业医师号"])
    {
       
        if (self.mTfField.text.length >= 50)
        {
            /*1.15 am9.20 如果输入的是删除,则允许操作*/
            if ([string isEqualToString:@""])
            {
                return YES;
            }
            
            [self toastAnimation:@"已经到达输入的最大长度"];
            CMTLog(@"已经到达输入的最大长度");
            return NO;
        }
        NSCharacterSet *cs;
        cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS]invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
        BOOL isNum = [string isEqualToString:filtered];
        if (!isNum)
        {
            CMTLog(@"输入的不是数字,请输入字符");
            [self.mTfField shake];
            [self toastAnimation:@"您输入的职业医师号不合法"];
            return NO;
        }
    }
    else if([self.mTfField.placeholder isEqualToString:@"请输入真实姓名"])
    {
        CMTLog(@"输入中文");
    }
    return YES;
}

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
//    self.mTfField.text = @"";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
