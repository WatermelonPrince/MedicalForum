//
//  CMTClient+PushInit.m
//  MedicalForum
//
//  Created by CMT on 15/6/18.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+PushInit.h"

@implementation CMTClient(PushInit)
//通知初始化接口
- (RACSignal *)getPushInit:(NSDictionary *)parameters {
    return [self POST:@"app/push/getui_init.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

@end
