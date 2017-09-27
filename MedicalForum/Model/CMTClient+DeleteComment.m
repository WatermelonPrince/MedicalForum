//
//  CMTClient+DeleteComment.m
//  MedicalForum
//
//  Created by fenglei on 15/1/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+DeleteComment.h"

@implementation CMTClient (DeleteComment)

- (RACSignal *)deleteComment:(NSDictionary *)parameters {
    
    return [self POST:@"app/comment/del.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

@end
