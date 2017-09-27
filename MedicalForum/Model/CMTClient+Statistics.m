//
//  CMTClient+Statistics.m
//  MedicalForum
//
//  Created by fenglei on 15/2/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+Statistics.h"
#import "CMTPostStatistics.h"

@implementation CMTClient (Statistics)

- (RACSignal *)getPostStatistics:(NSDictionary *)parameters {
    
    return [self GET:@"app/post/simple_detail.json" parameters:parameters resultClass:[CMTPostStatistics class] withStore:NO];
}

@end
