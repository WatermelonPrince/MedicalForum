//
//  CMTSocial.m
//  MedicalForum
//
//  Created by fenglei on 14/11/27.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
// UMeng
static NSString * const CMTSocialUMengAppKey = @"54d1e3effd98c5422c000121";

// Wechat
static NSString * const CMTSocialWechatAppID = @"wx756ed2fb5c6c5bc0";
static NSString * const CMTSocialWechatAppSecret = @"712015eed3ca4b3b50735896d45ad0d8";
static NSString * const CMTSocialWechatURL = @"http://www.umeng.com/social";

// Sina
static NSString * const CMTSocialSinaOpenSSORedirectURL = @"http://sns.whalecloud.com/sina2/callback";

// data
static NSString * const CMTSocialSNSDataDefaultIconName = @"AppIcon60x60";
static NSString * const CMTSocialSNSDataDefaultTitle = @"壹生";
static NSString * const CMTSocialSNSDataDefaultContent = nil;       // 不分享正文
static NSString * const CMTSocialSNSDataDefaultImageURL = nil;      // 正文有图时才分享图片, 且只分享到新浪微博
static NSString * const CMTSocialSNSDataDefaultLink = @"http://123.57.46.32:8088/login.do";

static NSString *const CMTPushKAppId=@"TCgmn0UjYs9Qnp0OFKRnX4";
static NSString *const CMTPushKAppKey=@"d78CMdG13p740pGEu9wgxA";
static NSString *const CMTPushkAppSecret=@"9Qdehz8EzF8EyWkkw8kuN7";

@interface CMTSocial ()
@end

@implementation CMTSocial

+ (instancetype)shareInstance {
    static CMTSocial *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[CMTSocial alloc] init];
    });
    
    return shareInstance;
}

- (void)setupDefaultSocialConfig {
   #ifdef Release
    [[UMSocialManager defaultManager] setUmSocialAppkey:CMTSocialUMengAppKey];
    // 分享 设置微信AppId, AppSecret, URL
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:CMTSocialWechatAppID appSecret:CMTSocialWechatAppSecret redirectURL:CMTSocialWechatURL];
    // 分享 打开新浪微博的SSO开关, 设置新浪微博回调地址
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"1293481685"  appSecret:@"ba4d5eb8c4db1197dfdf7b99158cbcfb" redirectURL:CMTSocialSinaOpenSSORedirectURL];
    // 统计 设置友盟Appkey, 发送统计报告方式(目前为启动发送BATCH), 渠道ID
    UMAnalyticsConfig *Analytics=[[UMAnalyticsConfig alloc]init];
    Analytics.appKey=CMTSocialUMengAppKey;
    Analytics.ePolicy=BATCH;
    Analytics.channelId=DISTRIBUTION_CHANNEL;
    [MobClick startWithConfigure:Analytics];
    // 统计 设置App版本号
    [MobClick setAppVersion:APP_VERSION];
  #endif
}
//注册通知
- (void)registerRemoteNotification
{
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

//解绑apns
-(void)unregisterForRemoteNotifications{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];

}
//创建个推对象
- (void)startSdkWith{
        [GeTuiSdk startSdkWithAppId:CMTPushKAppId appKey:CMTPushKAppKey appSecret:CMTPushkAppSecret delegate:self];
}
//关闭个推SDK
- (void)stopGexinSdk
{
    if([GeTuiSdk status] == SdkStatusStarted) {
        [GeTuiSdk destroy];
    }
}
//关闭壹生服务器推送
-(void)StopCMTPush{
       NSDictionary *Dic=@{
                        @"clientId":CMTSOCIAL.clientId ?: @"0",
                        @"userId":CMTUSER.userInfo.userId ?: @"0",
                        @"pushSwitch":@"2"};
    [[[CMTCLIENT getPushInit:Dic]deliverOn:[RACScheduler scheduler]]subscribeNext:^(CMTObject *state) {
          [[NSUserDefaults standardUserDefaults] setObject:@"fasle" forKey:@"CMTnoticeState"];
    }error:^(NSError *error) {
        CMTLog(@"关闭失败");
    } completed:^{
        CMTLog(@"完成");
    }];
}
//开始壹生推送服务
-(void)startCMTPush{
    
    NSDictionary *Dic=@{@"clientId":CMTSOCIAL.clientId ?: @"0",@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"pushSwitch":@"1"};
    [[[CMTCLIENT getPushInit:Dic]deliverOn:[RACScheduler scheduler]]subscribeNext:^(CMTObject *state) {
        CMTLog(@"推送打开成功");
         [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"CMTnoticeState"];
            [[NSUserDefaults standardUserDefaults] setObject:DATE([NSDate UNIXTimeStampFromNow]) forKey:@"CMTintPushIsFrist"];
    }error:^(NSError *error) {
              CMTLog(@"推送打开失败");
        
    } completed:^{
        CMTLog(@"完成");
    }];

}
//检查是否启动个推SDK
- (BOOL)checkSdkInstance
{
    if ([GeTuiSdk status] == SdkStatusStoped) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"SDK未启动" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return NO;
    }
    return YES;
}
//注册设备token
- (void)setDeviceToken:(NSString *)aToken
{
    if (![self checkSdkInstance]) {
        return;
    }
    
    [GeTuiSdk registerDeviceToken:aToken];
}

//设置标签
- (BOOL)setTags:(NSArray *)aTags error:(NSError **)error
{
    if (![self checkSdkInstance]) {
        return NO;
    }
    
    return [GeTuiSdk setTags:aTags];
}

//发送消息
- (NSString *)sendMessage:(NSData *)body error:(NSError **)error {
    if (![self checkSdkInstance]) {
        return nil;
    }
    
    return [GeTuiSdk sendMessage:body error:error];
}
//绑定别名
- (void)bindAlias:(NSString *)aAlias {
    if (![self checkSdkInstance]) {
        return;
    }
    
    return [GeTuiSdk bindAlias:aAlias andSequenceNum:nil];
}

//解除别名绑定
- (void)unbindAlias:(NSString *)aAlias {
    if (![self checkSdkInstance]) {
        return;
    }
    
    return [GeTuiSdk unbindAlias:aAlias andSequenceNum:nil];
}

#pragma mark - GexinSdkDelegate
/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    CMTLog(@"hdhhdhdhhdhdhdhd&&&&&&------%@",clientId);
    [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:@"clientId"];
    
    // [4-EXT-1]: 个推SDK已注册
    
    _sdkStatus = SdkStatusStarted;
    _clientId = clientId;
    CMTSOCIAL.clientId=clientId;
    //返回个推ID进行推送注册处理
    if (clientId.length>0) {
        //向服务器注册推送
        NSString *time=[[NSUserDefaults standardUserDefaults]objectForKey:@"CMTintPushIsFrist"];
        if ((time.length==0||![time isEqualToString:DATE([NSDate UNIXTimeStampFromNow])])) {
            if(![[[NSUserDefaults standardUserDefaults]objectForKey:@"CMTnoticeState"]isEqualToString:@"false"]){
                [CMTSOCIAL startCMTPush];
            }
            [CMTFOCUSMANAGER uploadFollows:NO];
        }
        
    }

}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>[GTSdk error]:%@\n\n", [error localizedDescription]);
}


/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    // [ GTSdk ]：汇报个推自定义事件(反馈透传消息)
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
    
    // 数据转换
    NSString *payloadMsg = nil;
    NSDictionary *payDic=nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
            NSData *data=[payloadMsg dataUsingEncoding:NSUTF8StringEncoding];
          payDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         NSLog(@"kskksskskskskksks%@",payDic);
        if (((NSNumber*)[payDic objectForKey:@"postId"]).stringValue.length>0) {
            CMTAPPCONFIG.HomePushUnreadNumber=[@""stringByAppendingFormat:@"%ld",(long)CMTAPPCONFIG.HomePushUnreadNumber.integerValue+1];
             [[NSUserDefaults standardUserDefaults] setObject:CMTAPPCONFIG.HomePushUnreadNumber forKey:@"CMTHomePushNumber"];
        }else if(((NSString*)[payDic objectForKey:@"liveUuid"]).length>0){
            CMTAPPCONFIG.collagePushUnreadNumber=[@""stringByAppendingFormat:@"%ld",(long)CMTAPPCONFIG.collagePushUnreadNumber.integerValue+1];
            [[NSUserDefaults standardUserDefaults] setObject:CMTAPPCONFIG.collagePushUnreadNumber forKey:@"CMTCollagePushNumber"];
        }
        [CMTAPPCONFIG ProcessingInformBage:APPDELEGATE.tabBarController.selectedIndex];
     }
    
    // 控制台打印日志
    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@%@", taskId, msgId, payloadMsg, offLine ? @"<离线消息>" : @""];
    NSLog(@"\n>>[GTSdk ReceivePayload]:%@\n\n", msg);
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // 发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    NSLog(@"\n>>[GTSdk DidSendMessage]:%@\n\n", msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // 通知SDK运行状态
    NSLog(@"\n>>[GTSdk SdkState]:%u\n\n", aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>[GTSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    
    NSLog(@"\n>>[GTSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}


@end
