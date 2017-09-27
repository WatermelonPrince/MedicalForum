//
//  CMTClient+SyncConcern.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+SyncConcern.h"
#import "CMTConcern.h"

@implementation CMTClient(SyncConcern)

-(RACSignal *) syncConcern:(NSDictionary *)parameters {
    
    //return [self GET:@"app/user/sync_concern.json" parameters:parameters resultClass:[CMTConcern class] withStore:NO];
    return [self POST:@"app/user/sync_concern.json" parameters:parameters resultClass:[CMTConcern class] withStore:NO];
    
}
@end
