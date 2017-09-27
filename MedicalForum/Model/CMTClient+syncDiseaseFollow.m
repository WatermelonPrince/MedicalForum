//
//  CMTClient+syncDiseaseFollow.m
//  MedicalForum
//
//  Created by CMT on 15/6/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+syncDiseaseFollow.h"

@implementation CMTClient(syncDiseaseFollow)
//同步订阅疾病标签接口
- (RACSignal *)SynDiseasecFollowsList:(NSDictionary *)parameters{
    return [self POST:@"app/disease/syncFollows.json" parameters:parameters resultClass:[CMTDisease class] withStore:NO];
}

@end
