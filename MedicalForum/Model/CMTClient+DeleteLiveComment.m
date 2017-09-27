//
//  CMTClient+DeleteLiveComment.m
//  MedicalForum
//
//  Created by fenglei on 15/9/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+DeleteLiveComment.h"

@implementation CMTClient (DeleteLiveComment)

- (RACSignal *)deleteLiveComment:(NSDictionary *)parameters {
    
    return [self POST:@"app/live/message_comment_del.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

@end
