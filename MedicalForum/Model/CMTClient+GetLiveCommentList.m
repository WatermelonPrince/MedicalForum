//
//  CMTClient+GetLiveCommentList.m
//  MedicalForum
//
//  Created by fenglei on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetLiveCommentList.h"
#import "CMTLiveComment.h"

@implementation CMTClient (GetLiveCommentList)

- (RACSignal *)getLiveCommentList:(NSDictionary *)parameters {
    
    return [self GET:@"app/live/message_comment_list.json" parameters:parameters resultClass:[CMTLiveComment class] withStore:NO];
}

@end
