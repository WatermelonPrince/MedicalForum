//
//  CMTAPPinit.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/4.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTAPPinit.h"

@implementation CMTClient(CMTAPPinit)
///获取活动列表
- (RACSignal *)CMTAPPinit:(NSDictionary *)parameters {
    
    return [self GET:@"/app/common/init.json" parameters:parameters resultClass:[CMTInitObject class] withStore:NO];
}
///1. 统计启动次数
- (RACSignal *)CMTAPPinitFor_stat:(NSDictionary *)parameters {
    
    return [self GET:@"app/common/init/for_stat.json" parameters:parameters resultClass:[CMTContact class] withStore:NO];
}

//117. 统计视频播放时长接口
- (RACSignal *)CMTVideo_stat:(NSDictionary *)parameters{
    return [self POST:@"/app/media/video/statistics.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}
//116. 获取app最新版本号接口
- (RACSignal *)GetAppVersion:(NSDictionary *)parameters{
    return [self POST:@"app/common/get_version.json" parameters:parameters resultClass:[CMTInitObject class] withStore:NO];
}
//147 广告点击量统计
- (RACSignal *)GetAdClickStatistics:(NSDictionary *)parameters{
    return [self POST:@"app/live/adverpv.json" parameters:parameters resultClass:[CMTInitObject class] withStore:NO];
}
//35 用户激活数与日活数统计接口
- (RACSignal *)postStatisticsLogin:(NSDictionary *)parameters {
    
    return [self POST:@"app/user/statistics/login.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

@end
