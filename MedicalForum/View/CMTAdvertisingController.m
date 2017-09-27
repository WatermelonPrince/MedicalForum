//
//  CMTAdvertisingController.m
//  MedicalForum
//
//  Created by guoyuanchao on 2017/2/27.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTAdvertisingController.h"
@interface CMTAdvertisingController (){
    NSInteger timeint;
}
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIControl *Control;
@property(nonatomic,strong)UIControl *skipControl;
@property(nonatomic,strong)NSTimer *Timer;
@property(nonatomic,strong)UILabel *lable;
@end

@implementation CMTAdvertisingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    timeint=CMTAPPCONFIG.InitObject.adver.advertisingTime.length==0?3:CMTAPPCONFIG.InitObject.adver.advertisingTime.integerValue;
    self.imageView=[[UIImageView alloc]initWithFrame:self.contentBaseView.frame];
    [self.imageView setImageURL:CMTAPPCONFIG.InitObject.adver.picUrl placeholderImage:IMAGE(@"Placeholderdefault") contentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.imageView.userInteractionEnabled=YES;
    [self.contentBaseView addSubview:self.imageView];
    self.Control=[[UIControl alloc]initWithFrame:self.contentBaseView.frame];
    [self.contentBaseView addSubview:self.Control ];
    if(CMTAPPCONFIG.InitObject.adver.jumpLinks.length>0){
          [self.Control addTarget:self action:@selector(jumpPage) forControlEvents:UIControlEventTouchUpInside];
    }
    self.skipControl=[[UIControl alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-200/3-10,15,200/3,85/3)];
    self.skipControl.layer.cornerRadius=8;
    self.skipControl.backgroundColor=[UIColor colorWithRed:0.082 green:0.082 blue:0.082 alpha:0.7];
    self.lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.skipControl.width, self.skipControl.height)];
     self.lable.textColor=[UIColor colorWithHexString:@"#00b294"];
    [self.skipControl addSubview:self.lable];
    NSString *str=[@"" stringByAppendingFormat:@"跳过 %ld",(long)timeint];
    NSRange range = [str rangeOfString:@"跳过"];
    NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:str];
    [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_ffffff) range:range];
    self.lable.font=FONT(14);
    self.lable.attributedText=pStr;
    self.lable.textAlignment=NSTextAlignmentCenter;
    [self.Control addSubview:self.skipControl];
    @weakify(self);
    [[self.skipControl rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       @strongify(self);
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    //统计广告点击;
    [[[CMTCLIENT GetAdClickStatistics:@{@"adverId":CMTAPPCONFIG.InitObject.adver.adverId}]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        NSLog(@"统计失败");
    }];
}
-(void)jumpPage{
    [self.navigationController popToRootViewControllerAnimated:NO];
    if(self.jumpLinks!=nil){
        self.jumpLinks();
    }
   }
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.Timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scheduledTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.Timer forMode:NSRunLoopCommonModes];
}
-(void)scheduledTimer{
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        timeint-=1;
        NSString *str=[@"" stringByAppendingFormat:@"跳过 %ld",(long)timeint];
        NSRange range = [str rangeOfString:@"跳过"];
        NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:str];
        [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_ffffff) range:range];
        [self.lable setAttributedText:pStr];
        if(timeint==0){
            [self.navigationController popToRootViewControllerAnimated:YES];
            self.Timer.fireDate=[NSDate distantFuture];
        }
    });
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   [self.navigationController setNavigationBarHidden:NO animated:animated];
    if(self.Timer!=nil){
     self.Timer.fireDate=[NSDate distantFuture];
        [self.Timer invalidate];
    }

}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
