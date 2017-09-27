//
//  CMTClient+GetPostDetail.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+GetPostDetail.h"
#import "CMTPost.h"

@implementation CMTClient (GetPostDetail)

- (RACSignal *)getPostDetail:(NSDictionary *)parameters {
    
    return [self GET:@"app/post/detail.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}
//110 设置和取消置顶
- (RACSignal *)set_Post_top:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/post/set_top.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}
//114 详情更新
- (RACSignal *)Details_update:(NSDictionary *)parameters {
    
    return [self GET:@"app/post/detail/is_new.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}

@end
