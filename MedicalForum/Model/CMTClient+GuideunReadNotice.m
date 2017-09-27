//
//  CMTClient+GuideunReadNotice.m
//  MedicalForum
//
//  Created by CMT on 15/6/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GuideunReadNotice.h"

@implementation CMTClient(GuideunReadNotice)
//未读文章接口
- (RACSignal *)GetGuideunReadNotice:(NSDictionary *)parameters{
    return [self POST:@"app/disease/unread_notice.json" parameters:parameters resultClass:[CMTDisease class] withStore:NO];
}

@end
