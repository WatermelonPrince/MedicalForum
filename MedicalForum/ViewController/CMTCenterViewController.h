//
//  CMTCenterViewController.h
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CMTTabBar.h"                           // 底部导航栏

/// 首页(文章列表)
@interface CMTCenterViewController : CMTBaseViewController{
    SystemSoundID                 soundID;
}
@property (nonatomic, strong) CMTTabBar *bottomTabBar;                          // 底部导航栏
/// 启动时刷新文章列表
- (void)refreshPostListFromLaunch;

/// 刷新侧边栏
- (void)refreshSideBar;

@end

