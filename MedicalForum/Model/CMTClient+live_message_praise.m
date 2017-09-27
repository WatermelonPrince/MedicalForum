//
//  CMTClient+live_message_praise.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+live_message_praise.h"

@implementation CMTClient(live_message_praise)
///直播消息点赞
- (RACSignal *)live_message_praise:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/message_praise.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

@end
