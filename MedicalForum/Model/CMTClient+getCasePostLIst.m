//
//  CMTClient+getCasePostLIst.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getCasePostLIst.h"

@implementation CMTClient(getCasePostLIst)
// 63.病例筛选接口
- (RACSignal *)getCasePostLIst:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/screen_disease_list.json" parameters:parameters resultClass:[CMTCaseLIstData class] withStore:NO];
}

@end
