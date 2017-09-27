//
//  CMTClient+ScoreCount.m
//  MedicalForum
//
//  Created by jiahongfei on 15/7/29.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+ScoreCount.h"
#import "ScoreCount.h"

@implementation CMTClient (ScoreCount)

/// .获取积分总数接口
- (RACSignal *)getScoreCount:(NSDictionary *)parameters {
    
    return [self POST:@"app/score/count.json" parameters:parameters resultClass:[ScoreCount class] withStore:NO];
}


@end
