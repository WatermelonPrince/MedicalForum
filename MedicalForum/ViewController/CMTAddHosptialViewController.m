//
//  CMTAddHosptialViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 15/3/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTAddHosptialViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTSettingViewController.h"
@interface CMTAddHosptialViewController ()

@property (strong, nonatomic) CMTUpgradeViewController *mUpgradeVC;

@end

@implementation CMTAddHosptialViewController

- (UITextField *)mTfField
{
    if (!_mTfField)
    {
        _mTfField = [[UITextField alloc]initWithFrame:CGRectMake(0, 83, SCREEN_WIDTH, 45)];
        _mTfField.borderStyle = UITextBorderStyleNone;
        _mTfField.layer.borderWidth = 0.5;
        _mTfField.clearsOnBeginEditing = YES;
        _mTfField.clearButtonMode = UITextBorderStyleLine;
        _mTfField.layer.borderColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0].CGColor;
        _mTfField.delegate = self;
        _mTfField.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        UIImageView *pImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10*RATIO, 45)];
        _mTfField.leftView = pImageView;
        _mTfField.leftViewMode = UITextFieldViewModeAlways;
        //[_mTfField setAutocorrectionType:UITextAutocorrectionTypeNo];
        _mTfField.placeholder = @"填写医院全称";
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
- (UILabel *)mLbHosptial
{
   
    if (!_mLbHosptial)
    {
        _mLbHosptial = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200*RATIO, 30)];
        _mLbHosptial.textColor = [UIColor colorWithRed:130.0/255 green:130.0/255 blue:130.0/255 alpha:1.0];
        _mLbHosptial.textAlignment = NSTextAlignmentRight;
    }
    return _mLbHosptial;
    
}

#pragma mark 生命周期方法
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];
    self.titleText = @"新增医院";
    [self.view addSubview:self.mTfField];
    self.navigationItem.leftBarButtonItem = self.mLeftItem;
    self.navigationItem.rightBarButtonItem = self.mRightItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//取消按钮关联方法
- (void)buttonCancel:(UIBarButtonItem *)item
{
    CMTLog(@"%s",__func__);
    [self.navigationController popViewControllerAnimated:YES];
}
//保存按钮关联方法
- (void)buttonSave:(UIBarButtonItem *)item
{
    CMTHospital *hospital=[[CMTHospital alloc]init];
    hospital.hospital=self.mTfField.text;
    hospital.hospitalId=@"0";
    @weakify(self);
    if (self.updateHostpital!=nil) {
        @strongify(self);
        self.updateHostpital(hospital);
    }
    CMTLog(@"%s",__func__);
    NSArray *pArr = self.navigationController.childViewControllers;
    for (int i = 0; i < pArr.count; i++)
    {
        UIViewController *pVC = [pArr objectAtIndex:i];
        if ([pVC isKindOfClass:[CMTUpgradeViewController class]])
        {
            self.mUpgradeVC = [pArr objectAtIndex:i];
            self.mLbHosptial.text = self.mTfField.text;
            self.mUpgradeVC.mHosptioal.hospital = self.mTfField.text;
            self.mUpgradeVC.mHosptioal.hospitalId = @"0";
            self.mUpgradeVC.mStrHospital = self.mLbHosptial.text;
            break;
        }
    }
    if (self.mTfField.text > 0)
    {
        if(self.mUpgradeVC==nil){
            NSArray *pArr = self.navigationController.childViewControllers;
            for (int i = 0; i < pArr.count; i++){
                UIViewController *pVC = [pArr objectAtIndex:i];
                if ([pVC isKindOfClass:[CMTSettingViewController class]]){
                    [self.navigationController popToViewController:pVC animated:YES];

                }
            }
        }else{
           [self.navigationController popToViewController:self.mUpgradeVC animated:YES];
        }
    }
    else
    {
        [self toastAnimation:@"请添加医院信息"];
    }
   
    
}


@end
