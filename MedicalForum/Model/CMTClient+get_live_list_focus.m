//
//  CMTClient+get_live_list_focus.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+get_live_list_focus.h"

@implementation CMTClient(get_live_list_focus)
///获取直播列表 
- (RACSignal *)get_live_list_focus:(NSDictionary *)parameters {
    
    return [self POST:@"/app/live/live_list_focus_pic.json" parameters:parameters resultClass:[CMTLiveListData class] withStore:NO];
}

@end
