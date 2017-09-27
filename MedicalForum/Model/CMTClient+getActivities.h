//
//  CMTClient+getActivities.h
//  MedicalForum
//
//  Created by jiahongfei on 15/8/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (getActivities)

///获取活动列表
- (RACSignal *)getActivities:(NSDictionary *)parameters;

@end
