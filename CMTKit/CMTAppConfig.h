//
//  CMTAppConfig.h
//  MedicalForum
//
//  Created by fenglei on 15/3/12.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMTAddPost.h"
#import "CMTSubject.h"
#import "CMTInitObject.h"
#import "CMTshakeobject.h"
#import "CMTLivesRecord.h"
FOUNDATION_EXPORT NSString * const NSUserDefaultsRecordedVersion;
FOUNDATION_EXPORT NSString * const NSUserDefaultsSubscriptionRecordedVersion;
FOUNDATION_EXPORT NSString * const NSUserDefaultsThemeFocusedRecordedVersion;
FOUNDATION_EXPORT NSString * const NSUserDefaultsCustomFontSize;
FOUNDATION_EXPORT NSString * const NSUserDefaultsAddPostSubject;

typedef NS_ENUM(NSInteger, CMTAppState) {
    CMTAppStateUnDefined = 0,
    CMTAppStateWillResignActive,
    CMTAppStateDidEnterBackground,
    CMTAppStateWillEnterForeground,
    CMTAppStateDidBecomeActive,
    CMTAppStateWillTerminate,
};

/// 配置信息
@interface CMTAppConfig : NSObject

/* constructor */

/// Returns the share instance.
+ (instancetype)defaultConfig;

/* control */

/// 每次启动更新配置信息
- (void)updateConfig;

/* output */

#pragma mark 版本
@property (nonatomic,strong)NSString *areaUpdateTime;
//启动页是否消失
@property(nonatomic,strong)NSString *IsStartWebDisappear;
@property(nonatomic,assign)BOOL IsStartedGuidePage;
//联系我们
@property(nonatomic,strong)CMTContact *contact;
//音乐播放名称
@property(nonatomic,strong)NSString *AudioName;
//有赞商城地址
@property(nonatomic,strong)NSString *epaperStoreUrl;
//判断侧边栏是否划出
@property(nonatomic,assign)BOOL isALLowShowSlide;
//记录
@property(nonatomic,strong)NSString *isAllowPlaymusic;
/// 当前记录版本
@property (nonatomic, strong) NSString *recordedVersion;
/// 当前版本是否第一次启动
@property (nonatomic, assign, readonly) BOOL currentVersionFirstLaunch;

/// 完成强制订阅记录的版本
@property (nonatomic, strong) NSString *subscriptionRecordedVersion;
/// 当前版本是否完成了强制订阅
@property (nonatomic, assign, readonly) BOOL currentVersionSubscribed;
/// 是否有缓存的订阅信息
@property (nonatomic, assign, readonly) BOOL subscriptionCached;

/// 完成专题订阅记录的版本
@property (nonatomic, strong) NSString *themeFocusedRecordedVersion;
/// 完成系列课程订阅记录的版本
@property (nonatomic, strong) NSString *seriesFocusedRecordedVersion;/// 当前版本是否完成了专题订阅
@property (nonatomic, assign, readonly) BOOL currentVersionThemeFocused;

#pragma mark 设置

/// 自定义字体大小
@property (nonatomic, strong) NSString *customFontSize;
//判断是否弹出视频非wifi下播放选择
@property(nonatomic,strong)NSString *IsWWANplaybackVideo;
//判断是否中断音频播放
@property(nonatomic,assign)BOOL IsInterruptAudioPlayback;
@property(nonatomic,strong)NSString *ISGesturesSlidingEnd;
@property(nonatomic,strong)NSString *isrefreshLivelist;

#pragma mark 状态
/// 网络状态
/// 0: 断网 1: 连网
@property (nonatomic, copy, readonly) NSString *reachability;

/// 更新程序状态
- (void)updateAppState:(CMTAppState)appState;
/// 当前程序状态
@property (nonatomic, assign, readonly) CMTAppState appState;

#pragma mark 通知

/// 上一次获取通知时间
@property (nonatomic, copy, readonly) NSDate *lastNotificationTime;
/// 获取通知
@property (nonatomic, assign, readonly) BOOL getNotification;
/// 未读专题文章数
@property (nonatomic, copy, readonly) NSString *themeUnreadNumber;
//未读系列课程消息数
@property (nonatomic, copy)NSString *seriesDtlUnreadNumber;
//首页气泡显示数目
@property (nonatomic, copy, readwrite) NSString *HomeNoticeUnreadNumber;
//未读个推文章数目
@property(nonatomic,copy,readwrite)NSString *HomePushUnreadNumber;
//未读个推直播数目
@property(nonatomic,copy,readwrite)NSString *collagePushUnreadNumber;
//app 启动数据更新
-(void)MandatoryUpdateNotificationAndSubscription;
/// 更新未读专题文章数
- (void)updateThemeUnreadNumber;
/// 清空未读专题文章数
- (void)clearThemeUnreadNumber;

/// 未读指南文章数
@property (nonatomic, copy,readwrite) NSString *GuideUnreadNumber;
/// 更新未读指南文章数
-(void)updateGuideUnreadNumber;
//更新创建按钮
@property (nonatomic, copy,readwrite) NSString *updateCreatebutton;
/// 清空未读指南数
- (void)cleareGuideUnreadNumber;
#pragma mark 更新论吧系统通知数目
/**
 *  更新组内未读通知总数
 */
-(void)updateCaseNoticeUnreadNumber;
/**
 *  更新论吧系统通知数目
 */
-(void)updateCaseSysNoticeUnreadNumber;
/// 未读病例数目
@property(nonatomic,copy,readwrite) NSString *UnreadCaseNumber_Slide;
/// 清空未读病例文章
- (void)clearCaseUnreadNumber;

/// 未读文章数目
@property(nonatomic,copy,readwrite) NSString *UnreadPostNumber_Slide;
/// 清空未读首页文章
- (void)clearPostUnreadNumber;

@property(nonatomic,copy,readwrite) NSMutableArray *cacheFouceDiseaseList;

/// 2首页强制刷新  1是病例强制刷新 0 不做任意页面都不做刷新
@property(nonatomic,copy,readwrite) NSString *refreshmodel;
/// 是否刷新指南标签视图
@property(nonatomic,strong) NSString *isReloadGuadeTagView;
/// 是否强制刷新病例
@property(nonatomic,strong) NSString *isrefreahCase;
/// 是否强制刷新论吧小组列表
@property(nonatomic,assign) BOOL isrefreahGroupList;
//刷新直播列表
@property (nonatomic, assign)BOOL isrefreshPlayAndRecord;
@property (nonatomic, assign)BOOL isrefreshCollegedata;

/// 首页未读通知数目
@property (nonatomic, copy,readwrite) NSString *HomeNoticeNumber;

- (void)clearHomeNoticeUnreadNumber;
/// 病例未读通知数目
@property (nonatomic, copy,readwrite) NSString *CaseNoticeNumber;
//论吧组内未读通知数目
@property (nonatomic, copy,readwrite) NSString *CaseGroupNoticeNumber;


/// 论吧系统未读通知数目
@property (nonatomic, copy,readwrite) NSString *CaseSystemNoticeNumber;
///首页摇一摇数据
@property (nonatomic,strong)CMTshakeobject *shakeobject;


- (void)clearCaseNoticeNumber;

#pragma mark 发帖

/// 广场发帖学科
@property (nonatomic, strong) CMTSubject *addPostSubject;
/// 广场发帖数据
@property (nonatomic, strong, readonly) CMTAddPost *addPostData;
/// 缓存广场发帖数据
- (void)saveAddPostData;
/// 清空广场发帖数据
- (void)clearAddPostData;
/// 广场发帖
- (void)addPostWithCompleteBlock:(void (^)(CMTAddPost *))completeBlock;

/// 小组发帖数据
@property (nonatomic, strong, readonly) CMTAddPost *addGroupPostData;
/// 缓存小组发帖数据
- (void)saveAddGroupPostData;
/// 清空小组发帖数据
- (void)clearAddGroupPostData;
/// 小组发帖
- (void)addGroupPostWithCompleteBlock:(void (^)(CMTAddPost *))completeBlock;

/// 帖子追加数据
@property (nonatomic, strong, readonly) CMTAddPost *addPostAdditionalData;
/// 缓存帖子追加数据
- (void)saveAddPostAdditionalData;
/// 清空帖子追加数据
- (void)clearAddPostAdditionalData;
/// 帖子追加
- (void)addPostAdditionalWithCompleteBlock:(void (^)(CMTAddPost *))completeBlock;
//发帖错误信息
@property (nonatomic, copy,readwrite) NSString *addPosterror;

//直播发帖
@property (nonatomic, strong, readonly) CMTAddPost *addLivemessageData;
/// 缓存直播帖子
- (void)saveaddLivemessageData;
/// 清空直播帖子追加数据
- (void)clearaddLivemessageData;
/// 直播帖子追加完成
- (void)addLivemessageDataWithCompleteBlock:(void (^)(CMTAddPost *))completeBlock;
/**
 *  字典存储摇一摇功能的结果
 */

@property(nonatomic,strong)NSMutableDictionary *shakeDictionary;
/**
 *  获取当前控制器
 *
 *  @return <#return value description#>
 */
- (UIViewController *)getCurrentVC;
@property(nonatomic,strong)CMTInitObject *InitObject;//启动对象
@property(nonatomic,strong)CMTInitObject *readCodeObject;//阅读码
@property(nonatomic,strong)CMTInitObject *AppVersionObject;//版本信息
//获取随机UUID
-(NSString *)uuidString;

- (void)updateSeriesDtlUnreadNumber;
//处理学院和首页push 未读通知数
-(void)ProcessingInformBage:(NSInteger)type;
//获取大约空间
-(NSString *)freeDiskSpaceInBytesStr;
//获取系统剩余空间
-(long long)freeDiskSpaceInBytes;
@property(nonatomic,strong)NSMutableArray *downloadList;
@property(nonatomic,strong)NSMutableArray *haveDownloadedList;
@property(nonatomic,strong)CMTLivesRecord *downloadingLive;
@property(nonatomic,strong)NSString *DownnetState;//0 无网络 1 4g 2 wifi
-(void)savedownloadList;
-(void)saveHavedownLoadList;
-(void)savedownloadingLive;
-(void)getUserInfo;
@end
