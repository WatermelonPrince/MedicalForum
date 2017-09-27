//
//  CMTClient+get_live_message_praiser_list.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/9/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+get_live_message_praiser_list.h"

@implementation CMTClient(get_live_message_praiser_list)
///直播消息点赞参与列表
- (RACSignal *)get_live_message_praiser_list:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/message_praiser_list.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}


@end
