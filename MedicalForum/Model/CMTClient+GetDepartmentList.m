//
//  CMTClient+GetDepartmentList.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+GetDepartmentList.h"
#import "CMTConcern.h"

@implementation CMTClient(GetDepartmentList)

-(RACSignal *) getDepartmentList:(NSDictionary *)parameters {
    
    return [self GET:@"app/subject/list.json" parameters:parameters resultClass:[CMTConcern class] withStore:NO];
}

@end
