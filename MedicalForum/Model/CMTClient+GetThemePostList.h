//
//  CMTClient+GetThemePostList.h
//  MedicalForum
//
//  Created by fenglei on 15/4/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (GetThemePostList)

/// 42. 专题文章列表接口
- (RACSignal *)getThemePostList:(NSDictionary *)parameters;

@end
