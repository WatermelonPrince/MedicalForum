//
//  CMTAPPinit.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/4.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(CMTAPPinit)
- (RACSignal *)CMTAPPinit:(NSDictionary *)parameters;
//1，app启动调用接口
- (RACSignal *)CMTAPPinitFor_stat:(NSDictionary *)parameters;
//107,视频统计
- (RACSignal *)CMTVideo_stat:(NSDictionary *)parameters;
//获取系统版本号
- (RACSignal *)GetAppVersion:(NSDictionary *)parameters;
//147 广告点击量统计
- (RACSignal *)GetAdClickStatistics:(NSDictionary *)parameters;
//35 用户激活数与日活数统计接口
- (RACSignal *)postStatisticsLogin:(NSDictionary *)parameters;

@end
