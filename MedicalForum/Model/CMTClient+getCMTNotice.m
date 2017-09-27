//
//  CMTClient+getCMTNotice.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getCMTNotice.h"

@implementation CMTClient(getCMTNotice)
// 67 收到点赞和评论通知接口
- (RACSignal *)getCMTNotice:(NSDictionary *)parameters {
    
    return [self GET:@"app/notice/list.json" parameters:parameters resultClass:[CMTNoticeData class] withStore:NO];
}

@end
