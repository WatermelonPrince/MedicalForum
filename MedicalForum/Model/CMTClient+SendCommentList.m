//
//  CMTClient+SendCommentList.m
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+SendCommentList.h"
#import "CMTSendComment.h"

@implementation CMTClient(SendCommentList)

- (RACSignal *)getSendCommentList:(NSDictionary *)parameters {
    
    return [self GET:@"app/comment/sent_list.json" parameters:parameters resultClass:[CMTSendComment class] withStore:NO];
}

@end
