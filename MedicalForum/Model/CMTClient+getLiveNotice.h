//
//  CMTClient+getLiveNoticie.h
//  MedicalForum
//
//  Created by jiahongfei on 15/8/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (getLiveNoticie)

///直播点赞或评论通知
- (RACSignal *)getLiveNotice:(NSDictionary *)parameters;

@end
