//
//  CMTClient+SendComment.h
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//
//  评论文章接口
//

#import "CMTClient.h"

@interface CMTClient(SendComment)

- (RACSignal *)sendComment:(NSDictionary *)parameters;

@end
