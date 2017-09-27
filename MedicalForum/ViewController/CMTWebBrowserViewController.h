//
//  CMTWebBrowserViewController.h
//  MedicalForum
//
//  Created by fenglei on 15/2/4.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTReadCodeBlindViewController.h"

/// 网页浏览器
@interface CMTWebBrowserViewController : CMTBaseViewController
@property (nonatomic, strong)UIViewController *lastViewController;

//普通构造函数
- (instancetype)initWithURL:(NSString *)URL;
//针对活动的构造函数
-(instancetype)initWithActivities : (CMTActivities *)activities;
//针对多重跳转的活动
- (instancetype)initWithURL:(NSString *)URL activities:(CMTActivities *)activities;
@end
