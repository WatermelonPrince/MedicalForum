//
//  CMTClient+GetSubjectList.m
//  MedicalForum
//
//  Created by Bo Shen on 15/3/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetSubjectList.h"
#import "CMTSubject.h"

@implementation CMTClient (GetSubjectList)
-(RACSignal *) getSubjectList:(NSDictionary *)parameters
{
    return [self GET:@"app/subject/follows.json" parameters:parameters resultClass:[CMTSubject class] withStore:NO];
}

@end
