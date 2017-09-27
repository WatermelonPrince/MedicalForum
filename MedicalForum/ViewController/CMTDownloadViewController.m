//
//  CMTDownloadViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/27.
//  Copyright (c) 2014年 CMT. All rights reserved.
//



#import "CMTDownloadViewController.h"

@interface CMTDownloadViewController ()

@end

@implementation CMTDownloadViewController
int value = 0;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.mHidItem;
    self.navigationItem.rightBarButtonItem = self.mCancelItem;
    self.titleText = @"下载订阅内容";
    /**
     
     这一块义务有点模糊,等待与下载两种情况的交互是如何设计的
     
     **/
    /*先判断用户是下载还是等待缓冲来设置lbWaiting的内容*/
    [self.mLbwaitting setText:@"等待缓冲"];
    /*时间从系统获取*/
    [self.mLbDate setText:[NSDate UNIXTimeStampFromNow]];
    /*固定设置*/
    [self.mLbUpdatContent setText:@"更新内容"];
    
    /*背景图如何设置*/
    /*注意背景图片的设置，不能阻塞主线程*/
    NSData *pData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://pic16.nipic.com/20110918/8389870_175318599000_2.jpg"]];
    UIImage *pImage = [[UIImage alloc]initWithData:pData];
    self.mBackGroundImageView.image = pImage;
    [self.view addSubview:self.mBackGroundImageView];
    [self.view addSubview:self.mLbwaitting];
    [self.view addSubview:self.mLbDate];
    [self.view addSubview:self.mLbUpdatContent];
    [self.view addSubview:self.mAnimationView];
    [self.view addSubview:self.mLbProgress];
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    self.mTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [self.mAnimationView startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mTimer invalidate];
}

- (UIImageView *)mBackGroundImageView
{
    if (!_mBackGroundImageView)
    {
        _mBackGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-53)];
        _mBackGroundImageView.backgroundColor = [UIColor yellowColor];
        _mBackGroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _mBackGroundImageView;
}

- (UILabel *)mLbwaitting
{
    if (!_mLbwaitting)
    {
        _mLbwaitting = [[UILabel alloc]initWithFrame:CGRectMake(12*RATIO, SCREEN_HEIGHT-35, 60*RATIO, 15)];
        _mLbwaitting.font = [UIFont systemFontOfSize:14.0];
        
    }
    return _mLbwaitting;
}
- (UILabel *)mLbDate
{
    if (!_mLbDate)
    {
        _mLbDate = [[UILabel alloc]initWithFrame:CGRectMake(74*RATIO, SCREEN_HEIGHT-35, 80*RATIO, 15)];
        _mLbDate.textColor = COLOR(c_32c7c2);
        _mLbDate.font = [UIFont systemFontOfSize:14.0];
    }
    return _mLbDate;
}
- (UILabel *)mLbUpdatContent
{
    if (!_mLbUpdatContent)
    {
        _mLbUpdatContent = [[UILabel alloc]initWithFrame:CGRectMake(158*RATIO, SCREEN_HEIGHT-35, 60*RATIO, 15)];
         _mLbUpdatContent.font = [UIFont systemFontOfSize:14.0];
    }
    return _mLbUpdatContent;
}

- (UIBarButtonItem *)mHidItem
{
    if (!_mHidItem)
    {
        NSString*pTitleStr = [self string:@"隐藏" WithColor:COLOR(c_32c7c2)];
        _mHidItem = [[UIBarButtonItem alloc]initWithTitle:pTitleStr style:UIBarButtonItemStyleDone target:self action:@selector(methodHide:)];
    }
    return _mHidItem;
}
- (UIBarButtonItem *)mCancelItem
{
    if (!_mCancelItem)
    {
        NSString *pTitle = [self string:@"取消" WithColor:COLOR(c_32c7c2)];
        
        _mCancelItem = [[UIBarButtonItem alloc]initWithTitle:pTitle style:UIBarButtonItemStyleDone target:self action:@selector(methodCancel:)];
    }
    return _mCancelItem;
}

- (LLARingSpinnerView *)mAnimationView
{
    if (!_mAnimationView)
    {
        _mAnimationView = [[LLARingSpinnerView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-43, SCREEN_HEIGHT-43, 34, 34)];
        _mAnimationView.tintColor = COLOR(c_32c7c2);
    }
    return _mAnimationView;
}
- (UILabel *)mLbProgress
{
    if (!_mLbProgress)
    {
        _mLbProgress = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-43, SCREEN_HEIGHT-34, 33, 15)];
        _mLbProgress.font = [UIFont systemFontOfSize:12.0];
        _mLbProgress.textAlignment = NSTextAlignmentCenter;
    }
    return _mLbProgress;
}

///**
// *@brief 字符串上色
// *@param str: 需要修改颜色的字符串
// *@param color: 修改颜色
// */
//- (NSString *)string:(NSString *)str WithColor:(UIColor *)color
//{
//    NSMutableAttributedString *pAttStr = [[NSMutableAttributedString alloc]initWithString:str];
//    [pAttStr addAttribute:NSForegroundColorAttributeName value:color range:NSRangeFromString(str)];
//    return [pAttStr string];
//}
/**
 *@brief 弹栈操作，下载任务继续
 */
- (void)methodHide:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *@brief 取消下载任务,弹栈操作
 */
- (void)methodCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *@brief 更新进度指示标签
 */
- (void)updateProgress
{
    value++;
    NSString *pProgress = [NSString stringWithFormat:@"%3d%%",value];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mLbProgress.text = pProgress;
    });
    if (value == 100)
    {
        [self.mTimer invalidate];
        [self.mAnimationView stopAnimating];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
