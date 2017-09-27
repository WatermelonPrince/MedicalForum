//
//  CMTClient+GuideRequire.m
//  MedicalForum
//
//  Created by CMT on 15/6/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GuideRequire.h"

@implementation CMTClient(GuideRequire)
//指南我需要接口
- (RACSignal *)SentGuideRequire:(NSDictionary *)parameters{
    return [self POST:@"app/disease/guide_require.json" parameters:parameters resultClass:[CMTDisease class] withStore:NO];
}
@end
