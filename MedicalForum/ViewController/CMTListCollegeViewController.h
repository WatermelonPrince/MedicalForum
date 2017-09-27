//
//  CMTListCollegeViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//


#import "CMTBaseViewController.h"//学院


#import "CMTBaseViewController.h"
#import "CMTColledgeVedioViewController.h"

@interface CMTListCollegeViewController : CMTBaseViewController
@property (nonatomic, strong)CMTColledgeVedioViewController *parentVC;
@property (nonatomic, strong)NSTimer *focusPageShuffling;//焦点图滚动计时器
@end
