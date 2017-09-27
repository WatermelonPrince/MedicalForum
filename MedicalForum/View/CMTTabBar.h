//
//  CMTTabBar.h
//  MedicalForum
//
//  Created by fenglei on 15/5/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTTabBarItem.h" 
#import "CMTGuideViewController.h"
#import "CMTCaseCircleViewController.h"
// 导航栏条目

/// 底部导航栏
@interface CMTTabBar : UIView

/* output */

/// 当前选中的条目
@property (nonatomic, weak, readonly) CMTTabBarItem *selectedItem;

/* control */

/// 选择条目
@property (nonatomic, assign) NSInteger selectedIndex;

@end
