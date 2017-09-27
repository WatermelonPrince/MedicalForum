//
//  CMTClient+GetPostByAuthor.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (GetPostList)

/// 16. 查看作者文章列表接口
- (RACSignal *)getPostListByAuthor:(NSDictionary *)parameters;

/// 17. 首页/病例文章列表接口
- (RACSignal *)getPostList:(NSDictionary *)parameters;

/// 28. 指定类型搜索接口
- (RACSignal *)searchPostInType:(NSDictionary *)parameters;

/// 45. 某学科文章列表接口
- (RACSignal *)getPostListInSubject:(NSDictionary *)parameters;

/// 48. 按普通二级标签搜索接口
- (RACSignal *)getPostListBySearchKeyword:(NSDictionary *)parameters;

/// 50. 根据疾病获取文章列表接口
- (RACSignal *)getPostListByDisease:(NSDictionary *)parameters;

/// 摇一摇请求数据接口
- (RACSignal *)getShakeData:(NSDictionary *)parameters;

@end
