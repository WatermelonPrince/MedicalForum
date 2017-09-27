//
//  CMTAppConfig.m
//  MedicalForum
//
//  Created by fenglei on 15/3/12.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTAppConfig.h"
#import "CMTDigitalWebViewController.h"
#include <sys/param.h>
#include <sys/mount.h>
NSString * const NSUserDefaultsRecordedAreaUpdateTime = @"NSUserDefaultsRecordedAreaUpdateTime";
NSString * const NSUserDefaultsRecordedVersion = @"NSUserDefaultsRecordedVersion";

NSString * const NSUserDefaultsSubscriptionRecordedVersion = @"NSUserDefaultsSubscriptionRecordedVersion";
NSString * const NSUserDefaultsThemeFocusedRecordedVersion = @"NSUserDefaultsThemeFocusedRecordedVersion";
NSString * const NSUserDefaultsSeriesFocusedRecordedVersion = @"NSUserDefaultsSeriesFocusedRecordedVersion";
NSString * const NSUserDefaultsCustomFontSize = @"NSUserDefaultsCustomFontSize";
NSString * const NSUserDefaultsAddPostSubject = @"NSUserDefaultsAddPostSubject";

#if DEBUG
static const NSTimeInterval CMTAppConfigNotificationTimeInterval = 1;
#else
static const NSTimeInterval CMTAppConfigNotificationTimeInterval =20*60;
#endif

@interface CMTAppConfig ()

@property (nonatomic, assign, readwrite) BOOL currentVersionFirstLaunch;
@property (nonatomic, assign, readwrite) BOOL currentVersionSubscribed;
@property (nonatomic, assign, readwrite) BOOL currentVersionThemeFocused;
@property (nonatomic, copy, readwrite) NSString *reachability;
@property (nonatomic, copy, readwrite) NSString *themeUnreadNumber;
@property (nonatomic, assign, readwrite) CMTAppState appState;
@property (nonatomic, copy, readwrite) NSDate *lastNotificationTime;
@property (nonatomic, assign, readwrite) BOOL getNotification;
@property (nonatomic, strong, readwrite) CMTAddPost *addPostData;
@property (nonatomic, strong, readwrite) CMTAddPost *addGroupPostData;
@property (nonatomic, strong, readwrite) CMTAddPost *addPostAdditionalData;
@property (nonatomic, strong, readwrite) CMTAddPost *addLivemessageData;


@end

@implementation CMTAppConfig

+ (instancetype)defaultConfig {
    static CMTAppConfig *defaultConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultConfig = [[CMTAppConfig alloc] init];
    });
    
    return defaultConfig;
}

#pragma mark - 更新配置信息

- (void)updateConfig {
    // 设置默认值
    self.refreshmodel = @"0";
    self.isrefreahCase = @"0";
    self.isrefreshLivelist=@"0";
    self.IsStartWebDisappear=@"0";
    self.IsStartedGuidePage=NO;
    self.DownnetState=@"3";
    // 检查版本信息
    [self updateRecordedVersionConfig];
    // 检查强制订阅版本信息
    [self updateSubscriptionRecordedVersionConfig];
    
    // 检查专题订阅版本信息
    [self updateThemeFocusedRecordedVersionConfig];
//#pragma mark 检测网络状态
    
    [self updateNetWorkStatus];
    CMTAPPCONFIG.HomePushUnreadNumber=[[NSUserDefaults standardUserDefaults]objectForKey:@"CMTHomePushNumber"];
    CMTAPPCONFIG.collagePushUnreadNumber=[[NSUserDefaults standardUserDefaults]objectForKey:@"CMTCollagePushNumber"];
    //获取正在下载列表
    [self loadDownloadList];
    //获取正在下载的课程
    [self loadDownloadingLive];
    //获取已经下载的列表
    [self loadHavedownLoadList];
}
#pragma mark 启动更新数据
-(void)MandatoryUpdateNotificationAndSubscription{
    //获取app版本号
     [self CMTGetAPPVersion];
    // 读取用户信息
    CMTUSER;
    
    // 激活数统计
    // loginType 1 初次激活设备; 2 打开应用;
    NSString *userId = CMTUSERINFO.userId;
    NSString *loginType = self.currentVersionFirstLaunch == YES ? @"1" : @"2";
    [[[CMTCLIENT postStatisticsLogin:@{
                                       @"userId": userId ?: @"",
                                       @"loginType": loginType ?: @"",
                                       }]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        CMTLog(@"AppConfig Statistics Login Success With userId: %@, loginType: %@", userId, loginType);
    } error:^(NSError *error) {
        CMTLogError(@"AppConfig Statistics Login Failure With Error: %@", error);
    }];
    [self getShakeData];
    //启动
    [self CMTAPPInit];
    //统计启动次数
    [self AppInitCountStartTimes];
#pragma mark 更新未读评论数/未读专题文章数
    [self updateThemeUnreadNumber];
    
    //#pragma mark 更新未读指南文章数
    
    [self updateGuideUnreadNumber];
    [self updatePostUnreadNumber];
    [self updateCasetUnreadNumber];
    //更新系列课程未读消息数
    [self updateSeriesDtlUnreadNumber];
    // 更新通知数目
    [self updateHomeNoticeUnreadNumber];
    [self updateCaseNoticeUnreadNumber];
    [self updateCaseSysNoticeUnreadNumber];
    //更新解密key
    [self updateDigitaNewspaperdecryptionKey];
    
#pragma mark 更新发帖信息
    
    [self updateAddPostInfo];
    
#pragma mark 更新病例模块下文章类型信息
    [CMTFOCUSMANAGER getPostTypesByModule:@"1"];
    



}
#pragma mark - 检查版本信息

- (void)updateRecordedVersionConfig {
    
    if ([self.recordedVersion isEqualToString:APP_VERSION]) {
        self.currentVersionFirstLaunch = NO;
        self.isAllowPlaymusic=@"1";
    }
    else {
        self.currentVersionFirstLaunch = YES;
         self.isAllowPlaymusic=@"0";
    }
}

- (NSString *)recordedVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsRecordedVersion];
}

- (void)setRecordedVersion:(NSString *)recordedVersion {
    [[NSUserDefaults standardUserDefaults] setObject:recordedVersion forKey:NSUserDefaultsRecordedVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)areaUpdateTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsRecordedAreaUpdateTime];
}

- (void)setAreaUpdateTime:(NSString *)areaUpdateTime{
    [[NSUserDefaults standardUserDefaults] setObject:areaUpdateTime forKey:NSUserDefaultsRecordedAreaUpdateTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




#pragma mark - 检查强制订阅注版本信息

- (void)updateSubscriptionRecordedVersionConfig {
    
    if ([self.subscriptionRecordedVersion isEqualToString:APP_VERSION]) {
        self.currentVersionSubscribed = YES;
    }
    else {
        self.currentVersionSubscribed = NO;
    }
}

- (NSString *)subscriptionRecordedVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsSubscriptionRecordedVersion];
}

- (void)setSubscriptionRecordedVersion:(NSString *)subscriptionRecordedVersion {
    [[NSUserDefaults standardUserDefaults] setObject:subscriptionRecordedVersion forKey:NSUserDefaultsSubscriptionRecordedVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)subscriptionCached {
    NSArray *subscriptions = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
    if ([subscriptions respondsToSelector:@selector(count)]) {
        if ([subscriptions count] > 0) {
            return YES;
        }
    }
    return NO;
}
//获取摇一摇数据
-(void)getShakeData{
    self.shakeobject=nil;
     NSString *shakesting=@"";
    if ([CMTAPPCONFIG.shakeDictionary.allKeys count]>0) {
        for (NSString *str in CMTAPPCONFIG.shakeDictionary.allKeys) {
            shakesting=[shakesting stringByAppendingFormat:@"%@:%@,",str,[CMTAPPCONFIG.shakeDictionary objectForKey:str] ] ;
        }
    }
    NSDictionary *param = @{
                            @"shakeInfo":shakesting,
                            @"userId":CMTUSERINFO.userId? :@"0",
                            };
    @weakify(self)
    [[[CMTCLIENT getShakeData:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTshakeobject *shakeObject) {
        @strongify(self);
        self.shakeobject=shakeObject;
    }error:^(NSError *error) {
        
    } completed:^{
        
    }];

}
/**
 *  APP 启动函数
 */
-(void)CMTAPPInit{
    @weakify(self);
    [[[CMTCLIENT CMTAPPinit:@{@"isFirstBoot":[NSString stringWithFormat:@"%ld",(long)0]}]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTInitObject *init) {
        NSLog(@"启动成功%@",init);
        @strongify(self);
        if (init!=nil) {
            if(init.adver.startType.integerValue!=1){
               NSString *sys=[[NSUserDefaults standardUserDefaults] objectForKey:@"initTime"];
                if(sys.length==0||![sys isEqualToString:DATE(init.sysDate)]){
                  self.InitObject=init;
                [[NSUserDefaults standardUserDefaults] setObject:DATE(self.InitObject.sysDate) forKey:@"initTime"];
               }else{
                self.InitObject=nil;
               }
                self.readCodeObject=init;
            }else{
                self.InitObject=init;
                self.readCodeObject=init;
            }
         
        }
#pragma mark请求全国收货区域列表zz
        [CMTAPPCONFIG getAllAreas];
    } error:^(NSError *error) {
        NSLog(@"feguywrfgeywgeygfyegfye%@",[error.userInfo objectForKey:@"errmsg"]);
    }];
    
}
//获取版本号
-(void)CMTGetAPPVersion{
    @weakify(self);
    [[[CMTCLIENT GetAppVersion:@{@"userId":CMTUSERINFO.userId?:@"0"}]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTInitObject *init) {
        NSLog(@"获取版本号成功%@",init);
        @strongify(self);
        if (init!=nil) {
            if(init.updateStatus.integerValue!=1){
               NSString *time=[[NSUserDefaults standardUserDefaults]objectForKey:@"getVersionTime"];
                 if (time.length==0||![time isEqualToString:DATE(init.sysDate)]) {
                        self.AppVersionObject=init;
                        [[NSUserDefaults standardUserDefaults] setObject:DATE(init.sysDate) forKey:@"getVersionTime"];
                 }else{
                     self.AppVersionObject=nil;
                 }
            }else{
                 self.AppVersionObject=init;
            }
        }
    } error:^(NSError *error) {
        NSLog(@"feguywrfgeywgeygfyegfye%@",[error.userInfo objectForKey:@"errmsg"]);
    }];
    
}

#pragma mark -统计启动次数
-(void)AppInitCountStartTimes{
    [[[CMTCLIENT CMTAPPinitFor_stat:@{@"userId":CMTUSER.userInfo.userId?:@"0"}]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTContact *init) {
        NSLog(@"启动次数统计");
        self.contact=init;
        
     } error:^(NSError *error) {
        NSLog(@"feguywrfgeywgeygfyegfye%@",[error.userInfo objectForKey:@"errmsg"]);
    }];

}
#pragma mark - 检查专题订阅版本信息
- (void)updateThemeFocusedRecordedVersionConfig {
    
    // 只要有版本记录 不考虑哪个版本
    if (self.themeFocusedRecordedVersion != nil) {
        self.currentVersionThemeFocused = YES;
    }
    else {
        self.currentVersionThemeFocused = NO;
    }
}

- (NSString *)themeFocusedRecordedVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsThemeFocusedRecordedVersion];
}

- (void)setThemeFocusedRecordedVersion:(NSString *)themeFocusedRecordedVersion {
    [[NSUserDefaults standardUserDefaults] setObject:themeFocusedRecordedVersion forKey:NSUserDefaultsThemeFocusedRecordedVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 检查专题订阅版本信息
    [self updateThemeFocusedRecordedVersionConfig];
}
//系列课程订阅版本号
- (NSString *)seriesFocusedRecordedVersion{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsSeriesFocusedRecordedVersion];
}

- (void)setSeriesFocusedRecordedVersion:(NSString *)seriesFocusedRecordedVersion{
    [[NSUserDefaults standardUserDefaults] setObject:seriesFocusedRecordedVersion forKey:NSUserDefaultsSeriesFocusedRecordedVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 自定义字体大小

- (NSString *)customFontSize {
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsCustomFontSize] ?: @"100";
}

- (void)setCustomFontSize:(NSString *)customFontSize {
    [[NSUserDefaults standardUserDefaults] setObject:customFontSize forKey:NSUserDefaultsCustomFontSize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - 摇一摇存储字典
- (NSMutableDictionary *)shakeDictionary{
    if (_shakeDictionary == nil) {
        _shakeDictionary = [[NSMutableDictionary alloc]init];
    }
    return _shakeDictionary;
}

#pragma mark - 网络状态

- (void)updateNetWorkStatus {
    @weakify(self);
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        if (![AFNetworkReachabilityManager sharedManager].isReachable && !NET_CELL && !NET_WIFI) {
            self.reachability = @"0";
        }
        else {
            
            if ([AFNetworkReachabilityManager sharedManager].isReachable && !NET_CELL) {
                self.reachability = @"2";
            }else{
                self.reachability = @"1";
            }
        }
    }];
}

#pragma mark - 程序状态

/// 更新程序状态
- (void)updateAppState:(CMTAppState)appState {
    NSString *appStateString = nil;
    
    // 更新前处理
    switch (appState) {
        case CMTAppStateUnDefined: {
            appStateString = @"UnDefined";
        }
            break;
        case CMTAppStateWillResignActive: {
            appStateString = @"WillResignActive";
        }
            break;
        case CMTAppStateDidEnterBackground: {
            appStateString = @"DidEnterBackground";
            
            // 记录首次进入后台时间
            // 以此时间作为上次获取通知时间的初始值
            if (self.lastNotificationTime == nil) {
                self.lastNotificationTime = [NSDate date];
            }
        }
            break;
        case CMTAppStateWillEnterForeground: {
            appStateString = @"WillEnterForeground";
            //app启动次数统计
            [self AppInitCountStartTimes];
            // 上次获取通知时间到现在的间隔大于刷新时间间隔
            if (-[self.lastNotificationTime timeIntervalSinceNow] > CMTAppConfigNotificationTimeInterval) {

#pragma mark 获取通知
                [self getShakeData];
                // 更新未读评论数/未读专题文章数
                [self updateThemeUnreadNumber];
                //更新未读指南文章数
                [self updateGuideUnreadNumber];
                [self updatePostUnreadNumber];
                [self updateCasetUnreadNumber];
                //更新系列课程未读消息数
                [self updateSeriesDtlUnreadNumber];
                //更新通知数目
                [self updateHomeNoticeUnreadNumber];
                [self updateCaseNoticeUnreadNumber];
                [self updateCaseSysNoticeUnreadNumber];
                [self updateDigitaNewspaperdecryptionKey];

                // 目前获取通知涉及到:
                // 1. 首页焦点图/列表强制刷新
                self.getNotification = YES;
                //论吧小组列表强制刷新
                self.isrefreahGroupList=YES;
                //壹生大学列表强制刷新
                self.isrefreshPlayAndRecord = YES;
                self.isrefreshCollegedata = YES;
                
                // 重设上次获取通知时间
                self.lastNotificationTime = [NSDate date];
            }
        }
            break;
        case CMTAppStateDidBecomeActive: {
            appStateString = @"DidBecomeActive";
        }
            break;
        case CMTAppStateWillTerminate: {
            appStateString = @"WillTerminate";
            
            // 保存用户信息
            [CMTUSER save];
        }
            break;
            
        default:
            break;
    }
    
    CMTLog(@"\n::::[App State]: %@", appStateString);
    
    self.appState = appState;
}

#pragma mark - 未读通知数
//更新未读系列课程数
- (void)updateSeriesDtlUnreadNumber{
    @weakify(self);
        //缓存系列课程列表
        NSArray *cachArr=[[NSArray alloc]init];
        if([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]]){
            cachArr= [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
        }
        //缓存items 的optime themuuid 组成的js串
        NSMutableArray *rditems = [NSMutableArray array];
        for (CMTSeriesDetails *seriesDtl in cachArr) {
            if (!BEMPTY(seriesDtl.themeUuid) && !BEMPTY(seriesDtl.viewTime)) {
                
                [rditems addObject:@{
                                     @"themeUuid": seriesDtl.themeUuid ?: @"",
                                     @"opTime": seriesDtl.viewTime ?: TIMESTAMP,
                                     }];
            }
        }
        
        NSError *JSError = nil;
        NSData *rdItemsJSData = [NSJSONSerialization dataWithJSONObject:rditems options:NSJSONWritingPrettyPrinted error:&JSError];
       
        if (JSError !=nil) {
            CMTLogError(@"请求系列课程未读消息列表json串转化error");
        }
        NSString *readItemsStr = [[NSString alloc]initWithData:rdItemsJSData encoding:NSUTF8StringEncoding];
       
        NSDictionary *params = @{
                                 @"userId": CMTUSERINFO.userId ?: @"0",
                                 @"readItems":readItemsStr?:@"",
                                 };
        [[[CMTCLIENT cmtgetSubscribeSeriesDetailList:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSMutableArray * x) {
            @strongify(self);
            self.seriesDtlUnreadNumber = @"0";
            if (x.count > 0) {
                for (CMTSeriesDetails *seriesDtl in x) {
                    self.seriesDtlUnreadNumber = [NSString stringWithFormat:@"%ld",(long)(self.seriesDtlUnreadNumber.integerValue + seriesDtl.newrecordCount.integerValue)];
                }
                //更新缓存中的消息数
                for (int i = 0; i < cachArr.count ; i ++) {
                    CMTSeriesDetails *seriesDtl = cachArr[i];
                    for (int j = 0; j < x.count; j ++) {
                        CMTSeriesDetails *seriesDtlj = x[j];
                        if ([seriesDtl.themeUuid isEqual:seriesDtlj.themeUuid]) {
                            seriesDtlj.viewTime = seriesDtl.viewTime;
                        }
                    }
                }
                [NSKeyedArchiver archiveRootObject:x toFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
            }
            
        } error:^(NSError *error) {
            CMTLogError(@"请求订阅系列课程未读消息数错误%@",error);
        }];
}

/// 更新未读专题文章数
- (void)updateThemeUnreadNumber {
    @weakify(self);
        // 缓存专题列表
        NSArray *cacheThemeList =[[NSArray alloc]init];
        if([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"focusList"]]){
            cacheThemeList= [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
        }
        // 缓存专题列表map 以themeId为key
        NSMutableDictionary *itemsWithKeys = [NSMutableDictionary dictionary];
        
        // 缓存专题列表themeId, opTime字段 组成参数json
        NSMutableArray *items = [NSMutableArray array];
        
        for (CMTTheme *cacheTheme in cacheThemeList) {
            if (!BEMPTY(cacheTheme.themeId) && !BEMPTY(cacheTheme.viewTime)) {
                [items addObject:@{
                                   @"themeId": cacheTheme.themeId ?: @"",
                                   @"opTime": cacheTheme.viewTime ?: TIMESTAMP,
                                   }];
                
                itemsWithKeys[cacheTheme.themeId] = cacheTheme;
            }
        }
        NSError *JSONSerializationError = nil;
        NSData *itemsJSONData = [NSJSONSerialization dataWithJSONObject:items options:NSJSONWritingPrettyPrinted error:&JSONSerializationError];
        if (JSONSerializationError != nil) {
            CMTLogError(@"AppConfig Cached Theme Info JSONSerialization Error: %@", JSONSerializationError);
        }
        NSString *itemsJSONString = [[NSString alloc] initWithData:itemsJSONData encoding:NSUTF8StringEncoding];
        
        // 获取未读专题列表
        [[[CMTCLIENT getThemeUnreadNotice:@{
                                            @"userId": CMTUSERINFO.userId ?: @"0",
                                            @"items": itemsJSONString ?: @"",
                                            }]
          deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *unreadThemeList) {
            // 未读专题列表为空
            if (unreadThemeList == nil || unreadThemeList.count == 0) {
                CMTLog(@"AppConfig Get Theme Unread Number: 0");
                [[RACScheduler mainThreadScheduler] schedule:^{
                    @strongify(self);
                    
                    self.themeUnreadNumber = @"0";
                }];
            }
            // 未读专题列表不为空
            else {
                // 更新订阅专题浏览时间
                NSInteger themeUnreadNumber = 0;
                for (CMTTheme *unreadTheme in unreadThemeList) {
                    if (unreadTheme.themeId != nil) {
                        CMTTheme *cacheTheme = itemsWithKeys[unreadTheme.themeId];
                        CMTLog(@"cacheTheme ViewTime: %@\nunreadTheme opTime: %@", cacheTheme.viewTime, unreadTheme.opTime);
                        cacheTheme.opTime = unreadTheme.opTime;
                        themeUnreadNumber++;
                    }
                }
                
                CMTLog(@"AppConfig Get Theme Unread Number: %ld", (long)themeUnreadNumber);
                [[RACScheduler mainThreadScheduler] schedule:^{
                    @strongify(self);
                    
                    self.themeUnreadNumber = [NSString stringWithFormat:@"%ld", (long)themeUnreadNumber];
                }];
                
                // 保存更新后的订阅专题列表
                if (![NSKeyedArchiver archiveRootObject:cacheThemeList toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]]) {
                    CMTLogError(@"AppConfig Archive Updated Theme List Failed");
                }
            }
        }
         error:^(NSError *error) {
             CMTLogError(@"AppConfig Get Theme Unread Notice Error: %@", error);
             [[RACScheduler mainThreadScheduler] schedule:^{
                 @strongify(self);
                 
                 self.themeUnreadNumber = @"0";
             }];
         }];
}

/// 清空未读专题文章数
- (void)clearThemeUnreadNumber {
    
    self.themeUnreadNumber = @"0";
}

- (NSMutableArray*)cacheFouceDiseaseList{
    if (_cacheFouceDiseaseList==nil) {
        _cacheFouceDiseaseList=[[NSMutableArray alloc]init];
    }
    return _cacheFouceDiseaseList;
}

//更新指南未读文文章数 add by guoyuanchao
-(void)updateGuideUnreadNumber{
    if([[NSFileManager defaultManager]fileExistsAtPath:PATH_FOUSTAG]){
           self.cacheFouceDiseaseList = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG];
        }
    NSMutableArray *itemsArray=[NSMutableArray new];
    for (CMTDisease *dis in self.cacheFouceDiseaseList) {
        if (!BEMPTY(dis.diseaseId)) {
            [itemsArray addObject:@{
                               @"diseaseId": dis.diseaseId ?: @"",
                               @"opTime": dis.readTime==nil?(dis.opTime.length==0?TIMESTAMP:dis.opTime):dis.readTime,
                               }];
            if (dis.readTime==nil) {
                dis.readTime=dis.opTime;
            }
        }
    }
    NSError *JSONSerializationError = nil;
    NSData *itemsJSONData = [NSJSONSerialization dataWithJSONObject:itemsArray options:NSJSONWritingPrettyPrinted error:&JSONSerializationError];
    if (JSONSerializationError != nil) {
        CMTLogError(@"AppConfig Cached Theme Info JSONSerialization Error: %@", JSONSerializationError);
    }
    NSString *itemsJSONString = [[NSString alloc] initWithData:itemsJSONData encoding:NSUTF8StringEncoding];

    NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"module":@"2",@"items":itemsJSONString};
     @weakify(self);
    [[[CMTCLIENT GetGuideunReadNotice:dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
        @strongify(self);
         NSInteger UnreadNumber=0;
        for (CMTDisease *dis in self.cacheFouceDiseaseList) {
            for (CMTDisease *unreaddic in array) {
                if ([unreaddic.diseaseId isEqualToString:dis.diseaseId]) {
                    dis.count=unreaddic.count;
                    UnreadNumber+=[dis.count integerValue];
                    break;
                }
            }
        }
        //判断是否刷新指南tag视图
        if ((isEmptyString(self.GuideUnreadNumber)||[self.GuideUnreadNumber integerValue]!=UnreadNumber)&&UnreadNumber!=0) {
            self.isReloadGuadeTagView=@"true";
        }else{
            self.isReloadGuadeTagView=@"false";

        }
        self.GuideUnreadNumber=[@""stringByAppendingFormat:@"%ld",(long)UnreadNumber];
        [NSKeyedArchiver archiveRootObject:[self.cacheFouceDiseaseList mutableCopy] toFile:PATH_FOUSTAG];
        
    } error:^(NSError *error) {
        CMTLog(@"错误信息%@",error);
    } completed:^{
        CMTLog(@"完成");
    }];
    
 }

- (void)cleareGuideUnreadNumber {
    
    self.GuideUnreadNumber = @"0";
}

//更新文章未读文文章数 add by guoyuanchao
-(void)updatePostUnreadNumber{
      if(self.cacheFouceDiseaseList.count==0){
            if([[NSFileManager defaultManager]fileExistsAtPath:PATH_FOUSTAG]){
                self.cacheFouceDiseaseList = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG];
            }
      }
    NSMutableArray *itemsArray=[NSMutableArray new];
    for (CMTDisease *dis in self.cacheFouceDiseaseList) {
        if (!BEMPTY(dis.diseaseId) && !BEMPTY(dis.opTime)) {
            [itemsArray addObject:@{
                                    @"diseaseId": dis.diseaseId ?: @"",
                                    @"opTime": dis.postReadtime==nil?(dis.opTime.length==0?TIMESTAMP:dis.opTime): dis.postReadtime,
                                    }];
            
        }
        if (dis.postReadtime==nil) {
            dis.postReadtime=dis.opTime;
        }

    }
    NSError *JSONSerializationError = nil;
    NSData *itemsJSONData = [NSJSONSerialization dataWithJSONObject:itemsArray options:NSJSONWritingPrettyPrinted error:&JSONSerializationError];
    if (JSONSerializationError != nil) {
        CMTLogError(@"AppConfig Cached Theme Info JSONSerialization Error: %@", JSONSerializationError);
    }
    NSString *itemsJSONString = [[NSString alloc] initWithData:itemsJSONData encoding:NSUTF8StringEncoding];
    
    NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"module":@"0",@"items":itemsJSONString};
     @weakify(self);
    [[[CMTCLIENT GetGuideunReadNotice:dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
        @strongify(self);
        NSInteger UnreadNumber=0;
        for (CMTDisease *dis in self.cacheFouceDiseaseList) {
            for (CMTDisease *unreaddic in array) {
                if ([unreaddic.diseaseId isEqualToString:dis.diseaseId]) {
                    dis.postCount=unreaddic.count;
                    UnreadNumber+=[dis.postCount integerValue];
                    break;
                }
            }
        }

        self.UnreadPostNumber_Slide=[@""stringByAppendingFormat:@"%ld",(long)UnreadNumber];
        [NSKeyedArchiver archiveRootObject:[self.cacheFouceDiseaseList mutableCopy] toFile:PATH_FOUSTAG];
        
    } error:^(NSError *error) {
        CMTLog(@"错误信息%@",error);
    } completed:^{
        CMTLog(@"完成");
    }];
    
}
//更新病例未读文文章数 add by guoyuanchao
-(void)updateCasetUnreadNumber{
    if(self.cacheFouceDiseaseList.count==0){
        if([[NSFileManager defaultManager]fileExistsAtPath:PATH_FOUSTAG]){
            self.cacheFouceDiseaseList = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG];
        }
    }
    NSMutableArray *itemsArray=[NSMutableArray new];
    for (CMTDisease *dis in self.cacheFouceDiseaseList) {
        if (!BEMPTY(dis.diseaseId)) {
            [itemsArray addObject:@{
                                    @"diseaseId": dis.diseaseId ?: @"",
                                    @"opTime": dis.caseReadtime==nil?(dis.opTime.length==0?TIMESTAMP:dis.opTime): dis.caseReadtime,
                                    }];
            
        }
        if (dis.caseReadtime==nil) {
            dis.caseReadtime=dis.opTime;
        }
    }
    NSError *JSONSerializationError = nil;
    NSData *itemsJSONData = [NSJSONSerialization dataWithJSONObject:itemsArray options:NSJSONWritingPrettyPrinted error:&JSONSerializationError];
    if (JSONSerializationError != nil) {
        CMTLogError(@"AppConfig Cached Theme Info JSONSerialization Error: %@", JSONSerializationError);
    }
    NSString *itemsJSONString = [[NSString alloc] initWithData:itemsJSONData encoding:NSUTF8StringEncoding];
    
    NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"module":@"1",@"items":itemsJSONString};
    @weakify(self);
    [[[CMTCLIENT GetGuideunReadNotice:dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
        @strongify(self);
        NSInteger UnreadNumber=0;
        for (CMTDisease *dis in self.cacheFouceDiseaseList) {
            for (CMTDisease *unreaddic in array) {
                if ([unreaddic.diseaseId isEqualToString:dis.diseaseId]) {
                    dis.caseCout=unreaddic.count;
                    UnreadNumber+=[dis.caseCout integerValue];
                    break;
                }
                
            }
        }
        self.UnreadCaseNumber_Slide=[@""stringByAppendingFormat:@"%ld",(long)UnreadNumber];
        [NSKeyedArchiver archiveRootObject:[self.cacheFouceDiseaseList mutableCopy] toFile:PATH_FOUSTAG];
        
    } error:^(NSError *error) {
        CMTLog(@"错误信息%@",error);
    } completed:^{
        CMTLog(@"完成");
    }];
    
}
- (void)clearCaseUnreadNumber {
    
    self.UnreadCaseNumber_Slide = @"0";
}

- (void)clearPostUnreadNumber {
    
    self.UnreadPostNumber_Slide = @"0";
}
//更新通知未读数目
-(void)updateHomeNoticeUnreadNumber{
    if (CMTUSER.login) {
        NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"module":@"0"};
        @weakify(self);
        [[[CMTCLIENT getnoticeCount:dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNotice *notice) {
            @strongify(self);
            self.HomeNoticeNumber=notice.count;
            
        } error:^(NSError *error) {
            CMTLog(@"错误信息%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];

        
    }
  
}
- (void)clearHomeNoticeUnreadNumber {
    
    self.HomeNoticeNumber = @"0";
}


//更新群组通知未读总数
-(void)updateCaseNoticeUnreadNumber{
    if (CMTUSER.login) {
        NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"userType":@"0"};
        @weakify(self);
        [[[CMTCLIENT getGroupNoticeCount:dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNotice *notice) {
            @strongify(self);
            self.CaseGroupNoticeNumber=notice.count;
            if(notice.count.integerValue>0){
                self.isrefreahCase=@"1";
            }
            if(isEmptyString(self.CaseSystemNoticeNumber)){
                self.CaseSystemNoticeNumber=@"0";
            }
            self.CaseNoticeNumber=[@"" stringByAppendingFormat:@"%ld",(long)self.CaseSystemNoticeNumber.integerValue+self.CaseGroupNoticeNumber.integerValue];
        } error:^(NSError *error) {
            CMTLog(@"错误信息%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];

        
    }
    
}
//更新论吧系统通知
-(void)updateCaseSysNoticeUnreadNumber{
    if (CMTUSER.login) {
        NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"userType":@"0", @"noticeRange":@"9"};
        @weakify(self);
        [[[CMTCLIENT getGroup_diseaseCount:dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNotice *notice) {
            @strongify(self);
            self.CaseSystemNoticeNumber=notice.noticeCount;
            if(![CMTUSERINFO.authStatus isEqualToString:notice.authStatus]){
                 CMTUSERINFO.authStatus=notice.authStatus;
                self.updateCreatebutton=@"1";
            }
            if (isEmptyObject(self.CaseGroupNoticeNumber)) {
                self.CaseGroupNoticeNumber=@"0";
            }
           self.CaseNoticeNumber=[@"" stringByAppendingFormat:@"%ld",(long)self.CaseSystemNoticeNumber.integerValue+self.CaseGroupNoticeNumber.integerValue];
        } error:^(NSError *error) {
            CMTLog(@"错误信息%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];
        
        
    }
    
}

- (void)clearCaseNoticeNumber {
    
    self.CaseNoticeNumber = @"0";
}
//更新数字报解密key
-(void)updateDigitaNewspaperdecryptionKey{
    if (CMTUSER.login) {
        NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"onlyDecryptKey":@"1"};
        [[[CMTCLIENT GetDigitalSubject:dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTDigitalObject *Digital) {
            CMTUSERINFO.decryptKey=Digital.decryptKey;
            CMTUSERINFO.canRead=Digital.canRead;
            CMTUSERINFO.rcodeState = Digital.rcodeState;
        } error:^(NSError *error) {
            CMTLog(@"错误信息%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];
        
        
    }
    
}


#pragma mark - 发帖

- (CMTSubject *)addPostSubject {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsAddPostSubject]];
}

- (void)setAddPostSubject:(CMTSubject *)addPostSubject {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:addPostSubject]
                                              forKey:NSUserDefaultsAddPostSubject];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CMTAddPost *)addPostData {
    if (_addPostData == nil) {
        if([[NSFileManager defaultManager]fileExistsAtPath:PATH_ADDPOST_ADDPOST]){
           _addPostData = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_ADDPOST_ADDPOST];
        }else{
            _addPostData = [[CMTAddPost alloc] init];
        }
    }
    
    return _addPostData;
}



- (CMTAddPost *)addGroupPostData {
    if (_addGroupPostData == nil) {
        if([[NSFileManager defaultManager]fileExistsAtPath:PATH_ADDPOST_ADDGROUPPOST]){
          _addGroupPostData = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_ADDPOST_ADDGROUPPOST];
        }else{
            _addGroupPostData = [[CMTAddPost alloc] init];
        }
    }
    
    return _addGroupPostData;
}

- (CMTAddPost *)addPostAdditionalData {
    if (_addPostAdditionalData == nil) {
        if([[NSFileManager defaultManager]fileExistsAtPath:PATH_ADDPOST_ADDPOSTADDITIONAL]){
           _addPostAdditionalData = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_ADDPOST_ADDPOSTADDITIONAL];
        }else{
            _addPostAdditionalData = [[CMTAddPost alloc] init];
        }
    }
    
    return _addPostAdditionalData;
}
- (CMTAddPost *)addLivemessageData {
    if (_addLivemessageData == nil) {
        if([[NSFileManager defaultManager]fileExistsAtPath:PATH_ADDPOST_ADDLIVEMESSAGE]){
             _addLivemessageData = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_ADDPOST_ADDLIVEMESSAGE];
        }else{
              _addLivemessageData = [[CMTAddPost alloc] init];
        }
    }
    
    return _addLivemessageData;
}

#pragma mark--请求收货全国区域
- (void)getAllAreas{
    if (![[NSFileManager defaultManager]fileExistsAtPath:[PATH_ALLAREAS stringByAppendingPathComponent:@"areas_list"]] || ![CMTAPPCONFIG.areaUpdateTime isEqualToString:CMTAPPCONFIG.readCodeObject.areaUpdateTime])
    {
        
        NSLog(@"appdle+++++%d------%d",![[NSFileManager defaultManager]fileExistsAtPath:[PATH_ALLAREAS stringByAppendingPathComponent:@"areas_list"]],![CMTAPPCONFIG.areaUpdateTime isEqualToString:CMTAPPCONFIG.readCodeObject.areaUpdateTime] );
        [CMTFOCUSMANAGER getAllAreas];
        
    }
    
}
/// 更新发帖信息
- (void)updateAddPostInfo {
    // 广场发帖数据为空
    if (BEMPTY(self.addPostData.addPostStatus)) {
        // 初始化广场发帖数据
        self.addPostData.addPostStatus = @"0";
    }
    // 上次发送中 再次启动设置为发送失败
    else if ([self.addPostData.addPostStatus isEqual:@"1"]) {
        self.addPostData.addPostStatus = @"3";
    }
    
    // 小组发帖数据为空
    if (BEMPTY(self.addGroupPostData.addPostStatus)) {
        // 初始化小组发帖数据
        self.addGroupPostData.addPostStatus = @"0";
    }
    // 上次发送中 再次启动设置为发送失败
    else if ([self.addGroupPostData.addPostStatus isEqual:@"1"]) {
        self.addGroupPostData.addPostStatus = @"3";
    }
    
    // 帖子追加数据为空
    if (BEMPTY(self.addPostAdditionalData.addPostStatus)) {
        // 初始化帖子追加数据
        self.addPostAdditionalData.addPostStatus = @"0";
    }
    // 上次发送中 再次启动设置为发送失败
    else if ([self.addPostAdditionalData.addPostStatus isEqual:@"1"]) {
        self.addPostAdditionalData.addPostStatus = @"3";
    }
#pragma 直播
    // 帖子追加数据为空
    if (BEMPTY(self.addLivemessageData.addPostStatus)) {
        // 初始化帖子追加数据
        self.addLivemessageData.addPostStatus = @"0";
    }
    // 上次发送中 再次启动设置为发送失败
    else if ([self.addLivemessageData.addPostStatus isEqual:@"1"]) {
         self.addLivemessageData.addPostStatus = @"3";
    }

}

#pragma mark 广场发帖

/// 缓存广场发帖数据
- (void)saveAddPostData {
    if (![NSKeyedArchiver archiveRootObject:self.addPostData toFile:PATH_ADDPOST_ADDPOST]) {
        CMTLogError(@"\nArchive AddPostData Error\nAddPostData: %@\nPath: %@", self.addPostData, PATH_ADDPOST_ADDPOST);
    }
}

/// 清空广场发帖数据
- (void)clearAddPostData {
     self.addPostData = [[CMTAddPost alloc] init];
     self.addPostData.addPostStatus = @"0";
    if (![NSKeyedArchiver archiveRootObject:self.addPostData toFile:PATH_ADDPOST_ADDPOST]) {
        CMTLogError(@"Archive nil to AddPostData Error");
    }
}

/// 广场发帖
- (void)addPostWithCompleteBlock:(void (^)(CMTAddPost *))completeBlock {
    
    // 更新发帖状态
    self.addPostData.addPostStatus = @"1";
    
    // 缓存数据
    [self saveAddPostData];
    
    // 调用接口
    [self addPostWithData:self.addPostData completeBlock:completeBlock];
}

#pragma mark 小组发帖

/// 缓存小组发帖数据
- (void)saveAddGroupPostData {
    if (![NSKeyedArchiver archiveRootObject:self.addGroupPostData toFile:PATH_ADDPOST_ADDGROUPPOST]) {
        CMTLogError(@"\nArchive AddGroupPostData Error\nAddGroupPostData: %@\nPath: %@", self.addGroupPostData, PATH_ADDPOST_ADDGROUPPOST);
    }
}

/// 清空小组发帖数据
- (void)clearAddGroupPostData {
    self.addGroupPostData = [[CMTAddPost alloc] initWithDictionary:@{} error:nil];
    self.addGroupPostData.addPostStatus = @"0";
    if (![NSKeyedArchiver archiveRootObject:self.addGroupPostData toFile:PATH_ADDPOST_ADDGROUPPOST]) {
        CMTLogError(@"Archive nil to AddGroupPostData Error");
    }
}

/// 小组发帖
- (void)addGroupPostWithCompleteBlock:(void (^)(CMTAddPost *))completeBlock {
    
    // 更新发帖状态
    self.addGroupPostData.addPostStatus = @"1";
    
    // 缓存数据
    [self saveAddGroupPostData];
    
    // 调用接口
    [self addPostWithData:self.addGroupPostData completeBlock:completeBlock];
}

#pragma mark 帖子追加

/// 缓存帖子追加数据
- (void)saveAddPostAdditionalData {
    if (![NSKeyedArchiver archiveRootObject:self.addPostAdditionalData toFile:PATH_ADDPOST_ADDPOSTADDITIONAL]) {
        CMTLogError(@"\nArchive AddPostAdditionalData Error\nAddPostAdditionalData: %@\nPath: %@", self.addPostAdditionalData, PATH_ADDPOST_ADDPOSTADDITIONAL);
    }
}

/// 清空帖子追加数据
- (void)clearAddPostAdditionalData {
    self.addPostAdditionalData = [[CMTAddPost alloc] initWithDictionary:@{} error:nil];
    self.addPostAdditionalData.addPostStatus = @"0";
    if (![NSKeyedArchiver archiveRootObject:self.addPostAdditionalData toFile:PATH_ADDPOST_ADDPOSTADDITIONAL]) {
        CMTLogError(@"Archive nil to AddPostAdditionalData Error");
    }
    
}

/// 帖子追加
- (void)addPostAdditionalWithCompleteBlock:(void (^)(CMTAddPost *))completeBlock {
    
    // 更新发帖状态
    self.addPostAdditionalData.addPostStatus = @"1";
    
    // 缓存数据
    [self saveAddPostAdditionalData];
    
    // 调用接口
    [self addPostAdditionalWithData:self.addPostAdditionalData completeBlock:completeBlock];
}

#pragma mark 调用发帖接口

- (void)addPostWithData:(CMTAddPost *)addPostData completeBlock:(void (^)(CMTAddPost *))completeBlock {
    @weakify(self);
    
    NSString *diseaseTagIds = [[addPostData.diseaseTagArray componentsOfValueForKey:@"diseaseId"] componentsJoinedByString:@","];
    NSString *atUserIds=[[addPostData.userinfoArray componentsOfValueForKey:@"userId"] componentsJoinedByString:@","];
    NSDictionary *param=@{
                          @"userId": CMTUSERINFO.userId ?: @"",
                          @"postType": addPostData.postTypeId ?: @"",
                          @"content": addPostData.addPostContent ?: @"",
                          @"title": addPostData.title ?: @"",
                          @"groupId": addPostData.groupId ?: @"",
                          @"diseaseTag": diseaseTagIds ?: @"",
                          @"subjectId": self.addPostSubject.subjectId ?: @"",
                          @"pictureFilePaths": addPostData.pictureFilePaths ?: @[],
                          @"atUserIds":atUserIds?:@"",
                          };
    if (addPostData.voteArray.count>0) {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:param];
        [dic setObject:addPostData.voteTilte forKey:@"voteTitle"];
        for (NSInteger i=0;i<(addPostData.voteArray.count==26?addPostData.voteArray.count:addPostData.voteArray.count-1);i++) {
            CMTVoteObject *object=[addPostData.voteArray objectAtIndex:i];
            [dic setObject:object.text forKey:[@"voteItems["  stringByAppendingFormat:@"%ld]",(long)i]];
        }
        param=[dic copy];
    }
    
    [[[CMTCLIENT addPost:param]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTAddPost * addPostCompleteData) {
        @strongify(self);
        
        // 发帖完成回调
        if (completeBlock != nil) {
            completeBlock(addPostCompleteData);
        }
        
        // 清空广场发帖数据
        if (BEMPTY(addPostData.groupId)) {
            [self clearAddPostData];
        }
        // 清空小组发帖数据
        else {
            [self clearAddGroupPostData];
        }
    }
     error:^(NSError *error) {
         @strongify(self);
         if (error.code==1001) {
             self.addPosterror=error.userInfo[@"errmsg"];
         }else{
             self.addPosterror=nil;
         }
         
         if (BEMPTY(addPostData.groupId)) {
             // 刷新广场发帖状态
             self.addPostData.addPostStatus = @"3";
             // 缓存广场发帖数据
             [self saveAddPostData];
         }
         else {
             // 刷新小组发帖状态
             self.addGroupPostData.addPostStatus = @"3";
             // 缓存小组发帖数据
             [self saveAddGroupPostData];
         }
     }];
}

- (void)addPostAdditionalWithData:(CMTAddPost *)addPostAdditionalData completeBlock:(void (^)(CMTAddPost *))completeBlock {
    @weakify(self);
    
    [[[CMTCLIENT addPostAdditional:@{
                                     @"postId": addPostAdditionalData.postId ?: @"",
                                     @"contentType": addPostAdditionalData.contentType ?: @"",
                                     @"content": addPostAdditionalData.addPostContent ?: @"",
                                     @"pictureFilePaths": addPostAdditionalData.pictureFilePaths ?: @[],
                                     }]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTAddPost * addPostAdditionalCompleteData) {
        @strongify(self);
        
        // 设置追加类型
        addPostAdditionalCompleteData.contentType = addPostAdditionalData.contentType;
        // 设置图片URL
        for (CMTPicture *picture in addPostAdditionalCompleteData.picList) {
            if (BEMPTY(picture.picFilepath)) {
                picture.picFilepath = picture.picUrl;
            }
        }
        
        // 追加完成回调
        if (completeBlock != nil) {
            completeBlock(addPostAdditionalCompleteData);
        }
        
        // 清空帖子追加数据
        [self clearAddPostAdditionalData];
    }
     error:^(NSError *error) {
         @strongify(self);
         
         // 刷新帖子追加状态
         self.addPostAdditionalData.addPostStatus = @"3";
         // 缓存帖子追加数据
         [self saveAddPostAdditionalData];
     }];
}
/// 缓存直播帖子
- (void)saveaddLivemessageData{
    if (![NSKeyedArchiver archiveRootObject:self.addLivemessageData toFile:PATH_ADDPOST_ADDLIVEMESSAGE]) {
        CMTLogError(@"\nArchive AddPostAdditionalData Error\nAddPostAdditionalData: %@\nPath: %@", self.addLivemessageData, PATH_ADDPOST_ADDPOSTADDITIONAL);
    }

}
/// 清空直播帖子追加数据
- (void)clearaddLivemessageData{
    self.addLivemessageData = [[CMTAddPost alloc] initWithDictionary:@{} error:nil];
    self.addLivemessageData.addPostStatus = @"0";
    if (![NSKeyedArchiver archiveRootObject:self.addLivemessageData toFile:PATH_ADDPOST_ADDLIVEMESSAGE]) {
        CMTLogError(@"Archive nil to AddPostAdditionalData Error");
    }

}

//直播发帖函数
- (void)addLivemessage:(CMTAddPost *)addPostData completeBlock:(void (^)(CMTAddPost *))completeBlock{
     @weakify(self);
    [[[CMTCLIENT addLivemessage:@{
                                  @"liveBroadcastId":addPostData.liveBroadcastId ?: @"",
                                  @"liveBroadcastTagId": addPostData.livetag.liveBroadcastTagId ?: @"",
                                  @"content": addPostData.addPostContent ?: @"",
                                  @"pictureFilePaths": addPostData.pictureFilePaths ?: @[],
                                  @"userId":CMTUSER.userInfo.userId?:@"0",
                                  }]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTAddPost * addPostAdditionalCompleteData) {
        @strongify(self);
        
        // 设置图片URL
        for (CMTPicture *picture in addPostAdditionalCompleteData.picList) {
            if (BEMPTY(picture.picFilepath)) {
                picture.picFilepath = picture.picUrl;
            }
        }
        
        // 追加完成回调
        if (completeBlock != nil) {
            completeBlock(addPostAdditionalCompleteData);
        }
        
        // 清空帖子追加数据
        [self clearaddLivemessageData];
    }
     error:^(NSError *error) {
         @strongify(self);
         self.addLivemessageData.addPostStatus = @"3";
         // 缓存帖子追加数据
         [self saveaddLivemessageData];
         if(error.code==103){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"你已被限制在该直播室发言" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
             [alert show];
         }         // 刷新帖子追加状态
        
     }];

}
///直播发帖
- (void)addLivemessageDataWithCompleteBlock:(void (^)(CMTAddPost *))completeBlock{
    // 更新发帖状态
    self.addLivemessageData.addPostStatus = @"1";
    
    // 缓存数据
    [self saveaddLivemessageData];
    
    // 调用接口
    [self addLivemessage:self.addLivemessageData completeBlock:completeBlock];

}

//获取当前视图
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
-(NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}
-(void)ProcessingInformBage:(NSInteger)type{
    if (type==0) {
        NSInteger number=[UIApplication sharedApplication].applicationIconBadgeNumber;
        if (CMTAPPCONFIG.collagePushUnreadNumber.integerValue==0) {
            CMTAPPCONFIG.HomePushUnreadNumber=@"0";
            [UIApplication sharedApplication].applicationIconBadgeNumber=0;
            [GeTuiSdk setBadge:0];
            [[NSUserDefaults standardUserDefaults] setObject:CMTAPPCONFIG.HomePushUnreadNumber forKey:@"CMTHomePushNumber"];
        }else{
            if (CMTAPPCONFIG.HomePushUnreadNumber.integerValue>=number) {
                CMTAPPCONFIG.HomePushUnreadNumber=@"0";
                [[NSUserDefaults standardUserDefaults] setObject:CMTAPPCONFIG.HomePushUnreadNumber forKey:@"CMTHomePushNumber"];
            }else{
                [UIApplication sharedApplication].applicationIconBadgeNumber=number- CMTAPPCONFIG.HomePushUnreadNumber.integerValue;
                [GeTuiSdk setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
                CMTAPPCONFIG.HomePushUnreadNumber=@"0";
                [[NSUserDefaults standardUserDefaults] setObject:CMTAPPCONFIG.HomePushUnreadNumber forKey:@"CMTHomePushNumber"];
            }
            
        }

    }else if(type==2){
        NSInteger number=[UIApplication sharedApplication].applicationIconBadgeNumber;
        if (CMTAPPCONFIG.HomePushUnreadNumber.integerValue==0) {
            CMTAPPCONFIG.collagePushUnreadNumber=@"0";
            [UIApplication sharedApplication].applicationIconBadgeNumber=0;
            [GeTuiSdk setBadge:0];
            [[NSUserDefaults standardUserDefaults] setObject:CMTAPPCONFIG.collagePushUnreadNumber forKey:@"CMTCollagePushNumber"];
        }else{
            if (CMTAPPCONFIG.collagePushUnreadNumber.integerValue>=number) {
                CMTAPPCONFIG.collagePushUnreadNumber=@"0";
                [[NSUserDefaults standardUserDefaults] setObject:CMTAPPCONFIG.collagePushUnreadNumber forKey:@"CMTCollagePushNumber"];
            }else{
                [UIApplication sharedApplication].applicationIconBadgeNumber=number- CMTAPPCONFIG.collagePushUnreadNumber.integerValue;
                [GeTuiSdk setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
                CMTAPPCONFIG.collagePushUnreadNumber=@"0";
                [[NSUserDefaults standardUserDefaults] setObject:CMTAPPCONFIG.collagePushUnreadNumber forKey:@"CMTCollagePushNumber"];
            }
        }

    }
}
//获取剩余空间
-(NSString *)freeDiskSpaceInBytesStr{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return [@"" stringByAppendingFormat:@"%ld%@",(long)(ceil((freespace/1024/1024>1024?freespace/1024/1024/1024:freespace/1024/1024))),freespace/1024/1024>1024?@"G":@"M"];
}
-(long long)freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}
-(NSMutableArray*)downloadList{
    if(_downloadList==nil){
        _downloadList=[[NSMutableArray alloc]init];
    }
    return _downloadList;
}
-(NSMutableArray*)haveDownloadedList{
    if(_haveDownloadedList==nil){
        _haveDownloadedList=[[NSMutableArray alloc]init];
    }
    return _haveDownloadedList;
}
-(void)loadDownloadingLive{
    self.downloadingLive=[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_downLoad stringByAppendingPathComponent:@"downloadingLive"]];
    if(self.downloadingLive!=nil){
        self.downloadingLive.Downstate=2;
    }
    CMTLog(@"jdjdjjddjdjdj%@",self.downloadingLive);
}
-(void)loadDownloadList{
    NSArray *array=[[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_downLoad stringByAppendingPathComponent:@"downloadList"]]mutableCopy];
    if(array!=nil){
        self.downloadList=[array mutableCopy];
        for (CMTLivesRecord * live in self.downloadList) {
            live.Downstate=0;
        }
    }

}
-(void)loadHavedownLoadList{
     NSArray *array=[[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_downLoad stringByAppendingPathComponent:@"haveDownloadedList"]]mutableCopy];
    if(array!=nil){
        self.haveDownloadedList=[array mutableCopy];
    }
}
//存储正在下载列表
-(void)savedownloadList{
    if([NSKeyedArchiver archiveRootObject:self.downloadList toFile:[PATH_downLoad stringByAppendingPathComponent:@"downloadList"]]){
        NSLog(@"正在下载列表存储成功");
        
    }
}
//存储已经下载列表
-(void)saveHavedownLoadList{
    if([NSKeyedArchiver archiveRootObject:self.haveDownloadedList toFile:[PATH_downLoad stringByAppendingPathComponent:@"haveDownloadedList"]]){
        NSLog(@"已经下载列表存储成功");
        
    }
}
//存储正在下载的课程
-(void)savedownloadingLive{
    if([NSKeyedArchiver archiveRootObject:self.downloadingLive toFile:[PATH_downLoad stringByAppendingPathComponent:@"downloadingLive"]]){
        NSLog(@"正在下载的课程存储成功");
    }
}
//获取用户信息
-(void)getUserInfo{
    NSString *userId = CMTUSER.userInfo.userId;
    NSDictionary *pDic = @{@"userId":userId ?: @""};
    [[CMTCLIENT getUserInfo:pDic]subscribeNext:^(CMTUserInfo * info)
     {
         if (info)
         {
             CMTLog(@"info = %@",info);
             CMTUSER.userInfo = info;
             [CMTUSER save];
         }
     } error:^(NSError *error) {
         CMTLog(@"error=%@",error);
         
     } ];
}
@end
