//
//  CMTClient+GetPostByType.m
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+GetPostByType.h"
#import "CMTPostByType.h"

@implementation CMTClient(GetPostByType)

- (RACSignal *)getPostByType:(NSDictionary *)parameters {
    
    return [self POST:@"app/search/post/types.json" parameters:parameters resultClass:[CMTPostByType class] withStore:NO];
    
}

@end
