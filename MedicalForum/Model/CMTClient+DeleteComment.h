//
//  CMTClient+DeleteComment.h
//  MedicalForum
//
//  Created by fenglei on 15/1/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//
//  删除文章评论接口
//

#import "CMTClient.h"

@interface CMTClient (DeleteComment)

- (RACSignal *)deleteComment:(NSDictionary *)parameters;

@end
