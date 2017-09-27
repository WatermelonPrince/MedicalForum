//
//  CMTClient+Concern.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+Concern.h"
#import "CMTConcern.h"

@implementation CMTClient(Concern)

- (RACSignal *)fetchConcern:(NSDictionary *)parameters {
    
    return [self POST:@"app/user/concern.json" parameters:parameters resultClass:[CMTConcern class] withStore:NO];
}

@end
