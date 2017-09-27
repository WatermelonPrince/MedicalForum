//
//  CMTClient+DeleteReply.m
//  MedicalForum
//
//  Created by fenglei on 15/1/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+DeleteReply.h"

@implementation CMTClient (DeleteReply)

- (RACSignal *)deleteReply:(NSDictionary *)parameters {
    
    return [self POST:@"app/comment/del_reply.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

@end
