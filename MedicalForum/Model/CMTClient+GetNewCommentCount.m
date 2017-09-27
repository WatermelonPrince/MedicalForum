//
//  CMTClient+GetNewCommentCount.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+GetNewCommentCount.h"
#import "CMTCommentCount.h"

@implementation CMTClient(GetNewCommentCount)

- (RACSignal *)getNewCommentCount:(NSDictionary *)parameters {
    
    return [self GET:@"app/comment/new_received_count.json" parameters:parameters resultClass:[CMTCommentCount class] withStore:NO];
}

@end
