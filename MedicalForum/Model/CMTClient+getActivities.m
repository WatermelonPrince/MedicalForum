//
//  CMTClient+getActivities.m
//  MedicalForum
//
//  Created by jiahongfei on 15/8/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getActivities.h"

@implementation CMTClient (getActivities)

///获取活动列表
- (RACSignal *)getActivities:(NSDictionary *)parameters {
    
    return [self POST:@"/app/activity/list.json" parameters:parameters resultClass:[CMTActivities class] withStore:NO];
}

@end
