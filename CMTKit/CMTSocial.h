//
//  CMTSocial.h
//  MedicalForum
//
//  Created by fenglei on 14/11/27.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeTuiSdk.h"
/// 社会化组件 (分享 反馈 统计 自动检查更新)
@interface CMTSocial : NSObject <GeTuiSdkDelegate>
//文章ID
@property (nonatomic, copy) NSString *postId;
//网络通道ID
@property(nonatomic,strong)NSString *clientId;
//SdK 状态
@property (assign, nonatomic) SdkStatus sdkStatus;
//设备ID
@property(nonatomic,strong) NSString *deviceToken;
//消息存储节点
@property (strong, nonatomic) NSString *payloadId;
+ (instancetype)shareInstance;

/// 启动配置
- (void)setupDefaultSocialConfig;

//注册通知
- (void)registerRemoteNotification;
//解绑通知
-(void)unregisterForRemoteNotifications;
//启动个推
- (void)startSdkWith;
//关闭个推SDK
- (void)stopGexinSdk;
//检查个腿SDK是否启动
-(BOOL)checkSdkInstance;
//绑定设备ID
- (void)setDeviceToken:(NSString *)aToken;
//设置个推推送标签
-(BOOL)setTags:(NSArray *)aTags error:(NSError **)error;
//上传消息
- (NSString *)sendMessage:(NSData *)body error:(NSError **)error;
//绑定别名
- (void)bindAlias:(NSString *)aAlias;
//解绑别名
- (void)unbindAlias:(NSString *)aAlias;
//打开关闭推送服务
-(void)StopCMTPush;
//打开壹生推送服务
-(void)startCMTPush;

@end
