//
//  CMTCommitrPhotoViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//



#import "CMTCommitrPhotoViewController.h"

@interface CMTCommitrPhotoViewController ()<UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet *mActionSheet;

@end

@implementation CMTCommitrPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setResult:@"添加工作证照片"];
    [self.view addSubview:self.mLbResult];
    [self setImage:IMAGE(@"photo")];
    [self.mBtnTackPhoto addTarget:self action:@selector(choicImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mBtnTackPhoto];
    
    self.titleText = @"验证信息";
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (UILabel *)mLbResult
{
    if (!_mLbResult)
    {
        _mLbResult = [[UILabel alloc]initWithFrame:CGRectMake(0, 275, SCREEN_WIDTH, 16)];
       _mLbResult.textColor =  [UIColor colorWithRed:172.0/255 green:172.0/255 blue:172.0/255 alpha:1.0];
        _mLbResult.textAlignment = NSTextAlignmentCenter;
        _mLbResult.font = [UIFont systemFontOfSize:15.0];
    }
    return _mLbResult;
}
- (void)setResult:(NSString *)result
{
    self.mLbResult.text = result;
}

- (UIButton *)mBtnTackPhoto
{
    if (!_mBtnTackPhoto)
    {
        _mBtnTackPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mBtnTackPhoto setFrame:CGRectMake(114*RATIO, 137, 103, 103)];
    }
    return _mBtnTackPhoto;
}

- (void)setImage:(UIImage *)image
{
    [self.mBtnTackPhoto setImage:image forState:UIControlStateNormal];
}

#pragma mark choice  image

- (void)choicImage:(id)sender
{
    self.mActionSheet = [[UIActionSheet alloc]initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    [self.mActionSheet showInView:self.view];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
