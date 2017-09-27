//
//  CMTJoinAuthorGroupViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTJoinAuthorGroupViewController.h"

@interface CMTJoinAuthorGroupViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *mTapGesture;

@end

@implementation CMTJoinAuthorGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleText = @"加入作者群体";
    
    self.mTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToUrl)];
    
    [self.view addSubview:self.mImageView];
    [self.view addSubview:self.mLbLogoIn];
    [self.view addSubview:self.mLbLink];
    [self.view addSubview:self.mLbCommit];
    
}
- (UIImageView *)mImageView
{
    if (!_mImageView) {
        _mImageView = [[UIImageView alloc]initWithImage:IMAGE(@"computer")];
        [_mImageView setFrame:CGRectMake(138, 202, 45, 45)];
        _mImageView.centerX = SCREEN_WIDTH/2;
    }
    return _mImageView;
}

- (UILabel *)mLbLogoIn
{
    if (!_mLbLogoIn)
    {
        //_mLbLogoIn = [[UILabel alloc]initWithFrame:CGRectMake(0, 283, 162*RATIO, 12)];
        _mLbLogoIn = [[UILabel alloc]initWithFrame:CGRectMake(0, 283, 142*RATIO, 12)];
        _mLbLogoIn.textAlignment = NSTextAlignmentRight;
        _mLbLogoIn.textColor = [UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1.0];
        _mLbLogoIn.font = [UIFont systemFontOfSize:13];
        _mLbLogoIn.text = @"请在电脑上登录:";
    }
    return _mLbLogoIn;
}

- (UILabel *)mLbLink
{
    if (!_mLbLink)
    {
        //_mLbLink = [[UILabel alloc]initWithFrame:CGRectMake(172*RATIO, 281, SCREEN_WIDTH - 162*RATIO-10, 15)];
         _mLbLink = [[UILabel alloc]initWithFrame:CGRectMake(145*RATIO, 281, SCREEN_WIDTH - 162*RATIO-10, 15)];
        _mLbLink.textColor = [UIColor colorWithRed:55.0/255 green:81.0/255 blue:151.0/255 alpha:1.0];
        _mLbLink.textAlignment = NSTextAlignmentLeft;
        _mLbLink.userInteractionEnabled = YES;
        _mLbLink.font = [UIFont systemFontOfSize:13.0];
        _mLbLink.text = @"http://admin.medtrib.cn";
        //[_mLbLink addGestureRecognizer:self.mTapGesture];
    }
    return _mLbLink;
}

- (UILabel *)mLbCommit
{
    if (!_mLbCommit)
    {
        _mLbCommit = [[UILabel alloc]initWithFrame:CGRectMake(0, 303, SCREEN_WIDTH, 14)];
        _mLbCommit.textAlignment = NSTextAlignmentCenter;
        _mLbCommit.textColor = [UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1.0];
        _mLbCommit.text = @"提交作者个人信息需要的资料";
        _mLbCommit.font = [UIFont systemFontOfSize:13];
    }
    return _mLbCommit;
}

#pragma mark   gesture  method

- (void)jumpToUrl
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.mLbLink.text]];
}


- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
