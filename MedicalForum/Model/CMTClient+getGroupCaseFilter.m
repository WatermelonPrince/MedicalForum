//
//  CMTClient+groupCaseFilter.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/10/9.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTClient+getGroupCaseFilter.h"

@implementation CMTClient(getGroupCaseFilter)
// 105小组筛选
- (RACSignal *)getGroupCaseFilter:(NSDictionary *)parameters {
    
    return [self GET:@"/app/group/screen_disease_list_with_top.json" parameters:parameters resultClass:[CMTCaseLIstData class] withStore:NO];
}
//109论吧搜索帖子接口
- (RACSignal *)search_post:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/search_post.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}

@end
