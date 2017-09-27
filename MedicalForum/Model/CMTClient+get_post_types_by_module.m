//
//  CMTClient+get_post_types.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+get_post_types_by_module.h"

@implementation CMTClient(get_post_types_by_module)
// 74.病例类型
- (RACSignal *)get_post_types_by_module:(NSDictionary *)parameters {
    
    return [self GET:@"app/common/get_post_types_by_module.json" parameters:parameters resultClass:[CMTType class] withStore:NO];
}


@end
