//
//  CMTClient+GetCommentList.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+GetCommentList.h"
#import "CMTComment.h"

@implementation CMTClient(GetCommentList)

- (RACSignal *)getCommentList:(NSDictionary *)parameters {
    
    return [self GET:@"app/comment/list.json" parameters:parameters resultClass:[CMTComment class] withStore:NO];
}
@end
