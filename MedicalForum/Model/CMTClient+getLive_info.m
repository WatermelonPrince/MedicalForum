//
//  CMTClient+getLive_info.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/24.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getLive_info.h"

@implementation CMTClient(getLive_info)
///获取直播内容
- (RACSignal *)getLive_info:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/live_info.json" parameters:parameters resultClass:[CMTLiveListData class] withStore:NO];
}

@end
