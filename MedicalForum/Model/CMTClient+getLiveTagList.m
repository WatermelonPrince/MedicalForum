//
//  CMTClient+getLiveTag.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getLiveTagList.h"

@implementation CMTClient(getLiveTagList)
///直播标签列表
- (RACSignal *)getLiveTagList:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/tag_list.json" parameters:parameters resultClass:[CMTLiveTag class] withStore:NO];
}

@end
