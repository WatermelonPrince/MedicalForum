//
//  CMTClient+ReplyComment.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+ReplyComment.h"
#import "CMTReply.h"

@implementation CMTClient(ReplyComment)

- (RACSignal *)replyComment:(NSDictionary *)parameters {
    
    return [self POST:@"app/comment/reply.json" parameters:parameters resultClass:[CMTReply class] withStore:NO];
}

@end
