//
//  CMTClient+GetPostByAuthor.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+GetPostList.h"
#import "CMTPost.h"

@implementation CMTClient (GetPostList)

// 16. 查看作者文章列表接口
- (RACSignal *)getPostListByAuthor:(NSDictionary *)parameters {
    
    return [self GET:@"app/post/author.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}

// 17. 首页/病例文章列表接口
- (RACSignal *)getPostList:(NSDictionary *)parameters {
    
    return [self GET:@"app/post/home.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}

// 28. 指定类型搜索接口
- (RACSignal *)searchPostInType:(NSDictionary *)parameters {
    
    return [self POST:@"app/search/post/the_type.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}

// 45. 某学科文章列表接口
- (RACSignal *)getPostListInSubject:(NSDictionary *)parameters {
    
    return [self GET:@"app/subject/post_list.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}

// 48. 按普通二级标签搜索接口
- (RACSignal *)getPostListBySearchKeyword:(NSDictionary *)parameters {
    
    return [self GET:@"app/search/post/tag.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}

// 50. 根据疾病获取文章列表接口
- (RACSignal *)getPostListByDisease:(NSDictionary *)parameters {
    
    return [self GET:@"app/disease/pageList.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
}

/// 摇一摇请求数据接口
- (RACSignal *)getShakeData:(NSDictionary *)parameters{
    return [self GET:@"app/common/shake.json" parameters:parameters resultClass:[CMTshakeobject class] withStore:NO];
}


@end
