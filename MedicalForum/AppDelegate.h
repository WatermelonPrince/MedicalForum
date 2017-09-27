//
//  AppDelegate.h
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTCollectionDelegate.h"
#import "GeTuiSdk.h"
#import "CMTPostDetailCenter.h"
#import "CMTPostStatistics.h"
#import "CMTLivesRecord.h"
#import <PlayerSDK/PlayerSDK.h>
#import <PlayerSDK/VodPlayer.h>
#import "LiveVideoPlayViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIWindow *subscriptionGuideWindow;
@property (nonatomic, strong) UIWindow *introWindow;
@property (nonatomic, strong) UIWindow *launchWindow;

@property (nonatomic, strong) UINavigationController *centerNavigationController;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic,strong)  CMTPostDetailCenter *postDetailCenter;
@property (nonatomic,assign)  BOOL allowRotation;
@property (nonatomic, strong) VodPlayer *vodplayer;
@property(nonatomic,strong)void (^backgroundSessionCompletionHandler)();

@property(nonatomic,strong)NSDictionary *songInfo;

@end

