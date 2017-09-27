//
//  CMTClient+DeleteReply.h
//  MedicalForum
//
//  Created by fenglei on 15/1/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//
//  删除评论回复接口
//

#import "CMTClient.h"

@interface CMTClient (DeleteReply)

- (RACSignal *)deleteReply:(NSDictionary *)parameters;

@end
