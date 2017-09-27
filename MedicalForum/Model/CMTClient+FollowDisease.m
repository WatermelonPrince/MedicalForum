//
//  CMTClient+.m
//  MedicalForum
//
//  Created by CMT on 15/6/12.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+FollowDisease.h"

@implementation CMTClient(FollowDisease)
//同步订阅疾病标签接口
- (RACSignal *)FollowDisease:(NSDictionary *)parameters{
    return [self POST:@"app/disease/follow.json" parameters:parameters resultClass:[CMTDisease class] withStore:NO];
}

@end
