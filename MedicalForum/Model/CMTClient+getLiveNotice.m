//
//  CMTClient+getLiveNoticie.m
//  MedicalForum
//
//  Created by jiahongfei on 15/8/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getLiveNotice.h"

@implementation CMTClient (getLiveNotice)

///直播点赞或评论通知
- (RACSignal *)getLiveNotice:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/notice_list.json" parameters:parameters resultClass:[CMTLiveNotice class] withStore:NO];
}


@end
