//
//  CMTClient+getMyTeam.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getMyTeams.h"

@implementation CMTClient(getMyTeams)
// 70 我加入的小组
- (RACSignal *)getMyTeams:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/my_joined_groups.json" parameters:parameters resultClass:[CMTGroup class] withStore:NO];
}
@end
