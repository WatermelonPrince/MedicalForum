//
//  CMTClient+addTeam.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+addTeam.h"

@implementation CMTClient(addTeam)
//加入或者退出小组
- (RACSignal *)addTeam:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/join_or_quit.json" parameters:parameters resultClass:[CMTGroup class] withStore:NO];
}



@end
