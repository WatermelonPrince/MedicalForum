//
//  CMTClient+Store.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+Store.h"
#import "CMTStore.h"

@implementation CMTClient(Store)

- (RACSignal *)fetchStore:(NSDictionary *)parameters {
    
    return [self POST:@"app/user/store.json" parameters:parameters resultClass:[CMTStore class] withStore:NO];
}

@end
