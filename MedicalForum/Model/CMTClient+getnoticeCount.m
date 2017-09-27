//
//  CMTClient+getnoticeCount.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getnoticeCount.h"

@implementation CMTClient(getnoticeCount)
//68 收到通知数目
- (RACSignal *)getnoticeCount:(NSDictionary *)parameters {
    
    return [self GET:@"app/notice/count.json" parameters:parameters resultClass:[CMTNotice class] withStore:NO];
}
//93 圈子通知总数接口
- (RACSignal *)getGroupNoticeCount:(NSDictionary *)parameters {
    
    return [self GET:@"app/notice/countByGroup.json" parameters:parameters resultClass:[CMTNotice class] withStore:NO];
}

// 95 论吧收到系统通知数目
- (RACSignal *)getGroup_diseaseCount:(NSDictionary *)parameters {
    
    return [self GET:@"app/notice/group_disease/count.json" parameters:parameters resultClass:[CMTNotice class] withStore:NO];
}

@end
