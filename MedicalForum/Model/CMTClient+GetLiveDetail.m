//
//  CMTClient+GetLiveDetail.m
//  MedicalForum
//
//  Created by fenglei on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetLiveDetail.h"
#import "CMTLive.h"

@implementation CMTClient (GetLiveDetail)

- (RACSignal *)getLiveDetail:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/message_info.json" parameters:parameters resultClass:[CMTLive class] withStore:NO];
}

@end
