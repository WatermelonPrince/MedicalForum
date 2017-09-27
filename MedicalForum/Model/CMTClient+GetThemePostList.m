//
//  CMTClient+GetThemePostList.m
//  MedicalForum
//
//  Created by fenglei on 15/4/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetThemePostList.h"
#import "CMTThemePostList.h"

@implementation CMTClient (GetThemePostList)

// 42. 专题文章列表接口
- (RACSignal *)getThemePostList:(NSDictionary *)parameters {
    
    return [self GET:@"app/theme/post_list.json" parameters:parameters resultClass:[CMTThemePostList class] withStore:NO];
}

@end
