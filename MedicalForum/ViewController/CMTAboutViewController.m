//
//  CMTAboutViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/24.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTAboutViewController.h"

@implementation CMTAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setContentState:CMTContentStateNormal];
    self.titleText = @"关于我们";
    [self.contentBaseView addSubview:self.mLogoImageView];
    [self.contentBaseView addSubview:self.mLbVersion];
    self.contentBaseView.userInteractionEnabled=NO;
    self.mLbVersion.text = [NSString stringWithFormat:@"V %@", APP_VERSION_BUILD];
    [self.contentBaseView addSubview:self.mCharacterImageView];
    self.contentBaseView.backgroundColor = COLOR(c_424242);
    [self.contentBaseView addSubview:self.mLbCopyright];
    self.contentBaseView.userInteractionEnabled=NO;
    UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goBackAction)];
            Swipe.delegate=self;
          Swipe.direction=UISwipeGestureRecognizerDirectionRight;
            [self.view addGestureRecognizer:Swipe];

}

- (UIImageView *)mLogoImageView
{
    if (!_mLogoImageView)
    {
        _mLogoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90*RATIO, 90*RATIO)];
        _mLogoImageView.image = IMAGE(@"aboutLogo");
        _mLogoImageView.centerY = SCREEN_HEIGHT/4;
        _mLogoImageView.centerX = self.view.centerX;
    }
    return _mLogoImageView;
}

- (UILabel *)mLbVersion
{
    if (!_mLbVersion)
    {
        _mLbVersion = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55.0/2)];
        _mLbVersion.textAlignment = NSTextAlignmentCenter;
        _mLbVersion.centerX = self.view.centerX;
        _mLbVersion.centerY = self.mLogoImageView.centerY + 122*RATIO/2+10;
        _mLbVersion.font = [UIFont systemFontOfSize:16.0];
        
        _mLbVersion.textColor = COLOR(c_cfcfcf);
    }
    return _mLbVersion;
}

- (UIImageView *)mCharacterImageView                                                                                                                                                                                                                                            
{
    if (!_mCharacterImageView)
    {
        _mCharacterImageView = [[UIImageView alloc]initWithImage:IMAGE(@"characters")];
        _mCharacterImageView.frame = CGRectMake(0, 0, 340/3*2, 40);
        _mCharacterImageView.centerX = self.view.centerX;
        _mCharacterImageView.centerY = SCREEN_HEIGHT - 65;
        
    }
    return _mCharacterImageView;
}

- (UILabel *)mLbCopyright
{
    if (!_mLbCopyright)
    {
        _mLbCopyright = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
        _mLbCopyright.textAlignment = NSTextAlignmentCenter;
        _mLbCopyright.font = [UIFont systemFontOfSize:14.0];
        _mLbCopyright.text = @"中国医学论坛报社 版权所有";
        _mLbCopyright.centerY = SCREEN_HEIGHT - 20;
        _mLbCopyright.textColor = [UIColor whiteColor];
    }
    return _mLbCopyright;
}

#pragma mark   button Action
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)goBackAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
