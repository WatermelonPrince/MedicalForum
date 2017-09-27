//
//  CMTClient+SyncStore.m
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+SyncStore.h"
#import "CMTStore.h"

@implementation CMTClient(SyncStore)

- (RACSignal *)syncStore:(NSDictionary *)parameters {
    
    return [self GET:@"app/user/sync_store.json" parameters:parameters resultClass:[CMTStore class] withStore:NO];
}

@end
