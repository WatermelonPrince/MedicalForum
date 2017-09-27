//
//  CMTClient+SharePost.m
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+SharePost.h"

@implementation CMTClient(SharePost)
//分享文章接口 编号:26
- (RACSignal *)sharePost:(NSDictionary *)parameters {
    
    return [self GET:@"app/post/share.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

@end
