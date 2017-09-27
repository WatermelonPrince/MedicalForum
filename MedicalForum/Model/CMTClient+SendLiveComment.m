//
//  CMTClient+SendLiveComment.m
//  MedicalForum
//
//  Created by fenglei on 15/9/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+SendLiveComment.h"
#import "CMTLiveComment.h"

@implementation CMTClient (SendLiveComment)

- (RACSignal *)sendLiveComment:(NSDictionary *)parameters {
    
    return [self POST:@"app/live/message_comment.json" parameters:parameters resultClass:[CMTLiveComment class] withStore:NO];
}

@end
