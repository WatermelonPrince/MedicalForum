//
//  CMTClient+ReceivedList.m
//  MedicalForum
//
//  Created by guanyx on 14/12/12.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+ReceivedList.h"
#import "CMTReceivedComment.h"

@implementation CMTClient(ReceivedList)

- (RACSignal *)receivedList:(NSDictionary *)parameters {
    
    return [self GET:@"app/comment/received_list.json" parameters:parameters resultClass:[CMTReceivedComment class] withStore:NO];
}

@end
