//
//  CMTClient+getShareLive.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getShareLive.h"

@implementation CMTClient(getShareLive)
///直播间分享
- (RACSignal *)getShareLive:(NSDictionary *)parameters {
    
    return [self GET:@"app/common/share.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

@end
