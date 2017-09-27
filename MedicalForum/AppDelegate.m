//
//  AppDelegate.m
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "AppDelegate.h"
#import "CMTLogFormatter.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "CMTCenterViewController.h"
#import "CMTNavigationController.h"
#import "CMTSubscriptionGuideViewController.h"
#import "CMTIntroViewController.h"
#import "CMTLaunchViewController.h"
#import "CMTCollectionViewController.h"
#import "MineViewController.h"
#import "CMTCaseCircleViewController.h"
#import"CMTSystemSettingViewController.h"
#import "CMTFoundViewController.h"
#import "CMTCaseDetailViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CMTColledgeVedioViewController.h"
#import "CMTLightVideoViewController.h"
#import "MBProgressHUD.h"
#ifdef DEBUG
//#import "BugshotKit.h"
#endif

@interface AppDelegate () <UITabBarControllerDelegate, GeTuiSdkDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[DDASLLogger sharedInstance] setLogFormatter:[CMTLogFormatter formatter]];
    [[DDTTYLogger sharedInstance] setLogFormatter:[CMTLogFormatter formatter]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [CMTSOCIAL setupDefaultSocialConfig];
    //同步订阅系列课程
    [CMTFOCUSMANAGER asyneSeriesListForUser:CMTUSERINFO];
    [[CMTAppConfig defaultConfig] updateConfig];
    
    //判断是否第一次初始化推送
    NSString *PushIsFrist=[[NSUserDefaults standardUserDefaults]objectForKey:@"CMTintPushIsFrist"];
    if (isEmptyString(PushIsFrist)) {
        [CMTFOCUSMANAGER subcriptions:nil];
    }
    //是否清空通知数目
     NSString *ISClearPushnumber=[[NSUserDefaults standardUserDefaults]objectForKey:@"CmtISClearPushnumber"];
     if(isEmptyString(ISClearPushnumber)){
         [UIApplication sharedApplication].applicationIconBadgeNumber=0;
         [GeTuiSdk setBadge:0];
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"CmtISClearPushnumber"];
     }
       //启动注册个推
     [CMTSOCIAL startSdkWith];
       //注册APNS
     [CMTSOCIAL registerRemoteNotification];
      //同步学科
      [CMTFOCUSMANAGER allCollectionsWithFollows:CMTUSER.userInfo.follows userId:CMTUSER.userInfo.userId?:@"0"];
    
#pragma mark RootViewController
    
    UIViewController *centerViewController = [[CMTCenterViewController alloc] initWithNibName:nil bundle:nil];
    self.centerNavigationController = [[CMTNavigationController alloc] initWithRootViewController:centerViewController];
    CMTCaseCircleViewController *caseViewController = [[CMTCaseCircleViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *casehNavigationController = [[CMTNavigationController alloc] initWithRootViewController:caseViewController];
    
    CMTFoundViewController *guideViewController=[[CMTFoundViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *GuideNavigationController=[[CMTNavigationController  alloc]initWithRootViewController:guideViewController];
    
    CMTColledgeVedioViewController *university=[[CMTColledgeVedioViewController alloc]initWithNibName:nil bundle:nil];
    
    CMTNavigationController *universityNav=[[CMTNavigationController alloc]initWithRootViewController:university];
    
    UIViewController *mineViewController = [[MineViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *mineNavigationController = [[CMTNavigationController alloc] initWithRootViewController:mineViewController];
    
    self.tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    self.tabBarController.viewControllers = @[self.centerNavigationController,casehNavigationController,universityNav,GuideNavigationController, mineNavigationController];
    self.tabBarController.tabBar.hidden = YES;
    self.tabBarController.delegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
    
#pragma mark 强制订阅页
    
    // 强制订阅页面出现条件: 1.没有订阅缓存 2.没有点击过强制关注的确定按钮
    // 第一次启动 点击立即体验按钮时 之前版本有订阅缓存的用户此版本标记为点击过强制订阅的确定按钮 以此作为强制订阅的第一次启动记录
    if (CMTAPPCONFIG.subscriptionCached == NO && CMTAPPCONFIG.currentVersionSubscribed == NO) {
        self.subscriptionGuideWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UINavigationController *subscriptionGuideNavi = [[CMTNavigationController alloc] initWithRootViewController:[[CMTSubscriptionGuideViewController alloc] initWithNibName:nil bundle:nil]];
        [self.subscriptionGuideWindow setRootViewController:subscriptionGuideNavi];
        [self.subscriptionGuideWindow makeKeyAndVisible];
    }else{
        self.tabBarController.selectedIndex=2;
    }

#pragma mark 引导页
    
    if (CMTAPPCONFIG.currentVersionFirstLaunch == YES) {
        self.introWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.introWindow setRootViewController:[[CMTIntroViewController alloc] initWithNibName:nil bundle:nil]];
        [self.introWindow makeKeyAndVisible];
    }
    
#pragma mark 启动页动画
    
    self.launchWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.launchWindow setRootViewController:[[CMTLaunchViewController alloc] initWithNibName:nil bundle:nil]];
    [self.launchWindow makeKeyAndVisible];

#pragma mark 用户相关信息
    
    if (CMTUSER.login)
    {
        [CMTAPPCONFIG getUserInfo];
    }
    CMTLog(@"%@",PATH_CACHES);
    CMTLog(@"realName::::%@",[CMTUSERINFO.realName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    
    /*登陆成功后就在后台请求订阅列表，同时缓存到本地*/
    if ([[NSFileManager defaultManager]fileExistsAtPath:PATH_TOTALSUBSCRIPTION])
    {
        CMTLog(@"已经有请求列表缓存数据");
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CMTFOCUSMANAGER subcriptions:nil];
        });
    }
    
#pragma mark  请求医院列表
    if (![[NSFileManager defaultManager]fileExistsAtPath:[PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"hosptial_list"]]) {
        [CMTFOCUSMANAGER getAllHosptials:nil];
    }

    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [CMTAPPCONFIG updateAppState:CMTAppStateWillResignActive];
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    if (self.songInfo!=nil) {
         center.nowPlayingInfo=self.songInfo;
    }
   

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [CMTAPPCONFIG updateAppState:CMTAppStateDidEnterBackground];
    
    // [EXT] 切后台关闭SDK，让SDK第一时间断线，让个推先用APN推送
    NSInteger bagenumber=[UIApplication sharedApplication].applicationIconBadgeNumber;
    [GeTuiSdk setBadge:bagenumber];

    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [CMTAPPCONFIG updateAppState:CMTAppStateWillEnterForeground];
   UINavigationController *navigation=[[self.tabBarController viewControllers]objectAtIndex:self.tabBarController.selectedIndex];
    if ([navigation.topViewController isKindOfClass:[CMTSystemSettingViewController class]]) {
        [((CMTSystemSettingViewController*)navigation.topViewController) changeSwitchState];
    }
    NSInteger bagenumber=[UIApplication sharedApplication].applicationIconBadgeNumber;
    [GeTuiSdk setBadge:bagenumber];
    //启动个推
    [CMTSOCIAL startSdkWith];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [CMTAPPCONFIG updateAppState:CMTAppStateDidBecomeActive];

 }

//ios 8 注册成功
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    CMTLog(@"推送注册成功%@",notificationSettings);
}
//注册DeviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    token =[token stringByReplacingOccurrencesOfString:@" " withString:@""];
    CMTLog(@"deviceToken:%@", token);
       // [3]:向个推服务器注册deviceToken
   
       [GeTuiSdk registerDeviceToken:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userinfo
{
     CMTLog(@"APNS推送消息内容%@",userinfo);
      [self dealWithPushInformation:userinfo];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
      [self dealWithPushInformation:userInfo];
   
       completionHandler(UIBackgroundFetchResultNewData);
}
//处理APNs 信息
-(void)dealWithPushInformation:(NSDictionary *)userInfo{
    [MobClick event:@"B_Detail_Notice"];
    CMTLog(@"APDS接受值%@",userInfo);
    NSString *postid=[((NSNumber*)[userInfo objectForKey:@"postId"])stringValue];
    NSString *ishtml=[((NSNumber*)[userInfo objectForKey:@"isHTML"])stringValue];
    NSString *url=[userInfo objectForKey:@"url"];
    NSString *module = [userInfo objectForKey:@"module"];
    NSString *liveUuid=[userInfo objectForKey:@"liveUuid"];
    NSString *target=[userInfo objectForKey:@"target"];
    UINavigationController *navigation =[[self.tabBarController viewControllers]objectAtIndex:self.tabBarController.selectedIndex];
    [navigation popToRootViewControllerAnimated:NO];
    @weakify(self);
    if(postid.length>0){
        if(self.tabBarController.selectedIndex!=0){
               self.tabBarController.selectedIndex=0;
        }
        navigation=[[self.tabBarController viewControllers]objectAtIndex:self.tabBarController.selectedIndex];
        [[RACScheduler mainThreadScheduler] afterDelay:0.2 schedule:^{
            @strongify(self);
            [MobClick event:@"B_Detail_Notice"];
            ((CMTCenterViewController*)navigation.topViewController).bottomTabBar.selectedIndex=0;
            if ([((CMTPostDetailCenter*)navigation.topViewController) isEqual:self.postDetailCenter]) {
                
                [navigation popViewControllerAnimated:NO];
            }else if(![navigation.topViewController isKindOfClass:[CMTCenterViewController class]]){
                 [navigation popViewControllerAnimated:NO];
            }else{
                [CMTAPPCONFIG ProcessingInformBage:self.tabBarController.selectedIndex];
            }
            self.postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:postid isHTML:ishtml postURL:url postModule:module postDetailType:CMTPostDetailTypeUnDefind];
            [navigation pushViewController:self.postDetailCenter animated:NO];
        }];
    }else if(liveUuid.length>0){
        if(self.tabBarController.selectedIndex!=2){
            self.tabBarController.selectedIndex=2;
        }
        navigation=[[self.tabBarController viewControllers]objectAtIndex:self.tabBarController.selectedIndex];
        ((CMTColledgeVedioViewController*)navigation.topViewController).bottomTabBar.selectedIndex=0;
        if ([navigation.topViewController isKindOfClass:[LiveVideoPlayViewController class]]) {
            LiveVideoPlayViewController *live=(LiveVideoPlayViewController*)navigation.topViewController;
            [live.playerManager leave];
            [navigation popToRootViewControllerAnimated:NO];
        }else if([navigation.topViewController isKindOfClass:[CMTLightVideoViewController class]]){
            CMTLightVideoViewController *light=(CMTLightVideoViewController*)navigation.topViewController;
            [light.vodplayer stop];
            [navigation popToRootViewControllerAnimated:NO];
        }else if(![navigation.topViewController isKindOfClass:[CMTColledgeVedioViewController class]]){
                [navigation popToRootViewControllerAnimated:NO];
        }else{
            [CMTAPPCONFIG ProcessingInformBage:self.tabBarController.selectedIndex];
        }
        if (target.integerValue==0) {
            [MobClick event:@"B_LiveList_Notice"];
            [[RACScheduler mainThreadScheduler] afterDelay:0.2 schedule:^{
                [((CMTColledgeVedioViewController*)navigation.topViewController).switchCustomScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
            }];
            
        }else{
            [MobClick event:@"B_Live_video_details_Notice"];
                        [MBProgressHUD showHUDAddedTo:((CMTBaseViewController*)navigation.topViewController).contentBaseView animated:YES];
            NSDictionary *param = @{
                                    @"userId":CMTUSERINFO.userId?:@"0",
                                    @"liveUuid":liveUuid?:@"",
                                    @"targetType":@"1",
                                    };
            [[[CMTCLIENT CMTGetIfLiveJumpOnDemand:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CmtLiveOrOnDemand *param) {
                 [MBProgressHUD hideHUDForView:((CMTBaseViewController*)navigation.topViewController).contentBaseView animated:YES];
                if (param.roominfo!=nil) {
                     [((CMTColledgeVedioViewController*)navigation.topViewController).switchCustomScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
                    LiveVideoPlayViewController *LiveVideoPlay=[[LiveVideoPlayViewController alloc]initWithParam:param.roominfo];
                    LiveVideoPlay.networkReachabilityStatus=@"2";
                    [navigation pushViewController:LiveVideoPlay animated:YES];
                }else{
                    CMTLightVideoViewController *light=[[CMTLightVideoViewController alloc]init];
                    light.myliveParam=param.videoinfo;
                    [navigation pushViewController:light animated:YES];
                }
            }error:^(NSError *error) {
                if (error.code>=-1009&&error.code<=-1001) {
                    [(CMTBaseViewController*)navigation.topViewController toastAnimation:@"你的网络不给力"];
                }else{
                    NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
                    [(CMTBaseViewController*)navigation.topViewController toastAnimation:errcode];
                }
                [MBProgressHUD hideHUDForView:((CMTBaseViewController*)navigation.topViewController).contentBaseView animated:YES];
            } completed:^{
                NSLog(@"完成");
            }];
            
        }
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [CMTAPPCONFIG updateAppState:CMTAppStateWillTerminate];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
     CMTLog(@"远程通知注册失败");
      if([GeTuiSdk status] == SdkStatusStarted){
        [CMTSOCIAL setDeviceToken:@""];
        }

   }

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // 调用cmtopdr://
    if ([url.absoluteString rangeOfString:CMTNSStringHTMLTagHeader].length > 0) {
        return YES;
    }
    // 其他OpenURL
    else {
        return [[UMSocialManager defaultManager] handleOpenURL:url];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // 调用cmtopdr://
    if ([url.absoluteString rangeOfString:CMTNSStringHTMLTagHeader].length > 0) {
        
        CMTLog(@"openURL: %@\nsourceApplication: %@\nannotation: %@", url, sourceApplication, annotation);
        
        return YES;
    }
    // 其他OpenURL
    else {
        return [[UMSocialManager defaultManager] handleOpenURL:url];
    }
}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webpageURL = userActivity.webpageURL;
        NSString *url=webpageURL.absoluteString;
        if ([webpageURL.absoluteString hasPrefix:@"https://apps.medtrib.cn/media/deeplink/"]) {
            //进行我们需要的处理
            [MobClick event:@"UniversalLinksStartApp"];
                NSDictionary *param=[webpageURL.absoluteString CMT_HTMLTag_parseDictionary:@"https"];
               [url handleWithinArticleShare:param[@"parameters"][@"pageValue"] type:param[@"parameters"][@"pageType"]];
        }else{
              NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly : @YES};
              [[UIApplication sharedApplication]openURL:webpageURL options:options completionHandler:^(BOOL success) {
              }];
            
         }
     }
     return YES;
}
#pragma mark UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}


//打开或者禁止第三方键盘
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    return YES;
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appdelgate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appdelgate.backgroundSessionCompletionHandler) {
        void (^completionHandle)() = appdelgate.backgroundSessionCompletionHandler;
        appdelgate.backgroundSessionCompletionHandler = nil;
        completionHandle();
    }
}
@end
