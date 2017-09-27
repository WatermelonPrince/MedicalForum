//
//  CMTClient+Praise.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+Praise.h"

@implementation CMTClient(Praise)
// 67 对文章，评论，子评论点赞
- (RACSignal *)Praise:(NSDictionary *)parameters {
    
    return [self GET:@"app/praise/post_and_comment.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}


@end
