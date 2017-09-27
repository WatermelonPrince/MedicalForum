//
//  CMTClient+getGroupNotice.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/10/9.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTClient+getGroupNotice.h"
@implementation CMTClient(getGroupNotice)
//92 收到小组文章点赞和通知
- (RACSignal *)getGroupNotice:(NSDictionary *)parameters {
    
    return [self GET:@"/app/notice/listByGroup.json" parameters:parameters resultClass:[CMTNoticeData class] withStore:NO];
}

//收到小组系统通知
- (RACSignal *)getCaseSystemNotice:(NSDictionary *)parameters {
    return [self GET:@"/app/notice/group_disease/list.json" parameters:parameters resultClass:[CMTCaseSystemNoticeModel class] withStore:NO];
}
//同意或拒绝小组申请
- (RACSignal *)allowOrRefuseEnterGroup:(NSDictionary *)parameters{
    return [self GET:@"/app/group/apply_deal.json" parameters:parameters resultClass:[CMTCaseSystemNoticeModel class] withStore:NO];
}



@end
