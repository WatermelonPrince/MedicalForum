//
//  CMTClient+getLiveNoticeCount.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getLiveNoticeCount.h"

@implementation CMTClient(getLiveNoticeCount)
///直播通知数
- (RACSignal *)getLiveNoticeCount:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/notice_count.json" parameters:parameters resultClass:[CMTNoticeData class] withStore:NO];
}


@end
