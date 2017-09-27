//
//  CMTClient+groupShare.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/29.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+groupShare.h"

@implementation CMTClient(groupShare)
// 72 分享小组接口
- (RACSignal *)groupShare:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/share.json" parameters:parameters resultClass:[CMTGroup class] withStore:NO];
}

@end
