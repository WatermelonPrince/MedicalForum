//
//  CMTClient+GetScoreList.m
//  MedicalForum
//
//  Created by jiahongfei on 15/7/29.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetScoreList.h"
#import "CMTScore.h"

@implementation CMTClient (GetScoreList)

/// . 积分列表接口
- (RACSignal *)getScoreList:(NSDictionary *)parameters {
    
    return [self POST:@"app/score/list.json" parameters:parameters resultClass:[CMTScore class] withStore:NO];
}

@end
