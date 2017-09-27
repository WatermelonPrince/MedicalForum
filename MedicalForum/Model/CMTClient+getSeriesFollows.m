//
//  CMTClient+getSeriesFollows.m
//  MedicalForum
//
//  Created by zhaohuan on 16/9/13.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTClient+getSeriesFollows.h"
#import "CMTSeriesFollowed.h"

@implementation CMTClient (getSeriesFollows)


//137 已订阅系列课程接口
- (RACSignal *)cmtgetSubscribeSeriesDetailList:(NSDictionary *)parameters{
    return [self GET:@"app/series/list/followed.json" parameters:parameters resultClass:[CMTSeriesDetails class] withStore:NO];
}

@end
