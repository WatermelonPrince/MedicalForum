//
//  CMTClient+getParticipators.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getParticipators.h"

@implementation CMTClient(getParticipators)
// 62.病例参与互动的用户列表接口
- (RACSignal *)getParticipatorsList:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/participators_list.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}

@end
