//
//  CMTClient+deleteLive_message.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+deleteLive_message.h"

@implementation CMTClient(deleteLive_message)
///删除直播消息
- (RACSignal *)deleteLive_message:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/del_message.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}
@end
