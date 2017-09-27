//
//  CMTClient+getSeriesFollows.h
//  MedicalForum
//
//  Created by zhaohuan on 16/9/13.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (getSeriesFollows)

//137 已订阅系列课程接口
- (RACSignal *)cmtgetSubscribeSeriesDetailList:(NSDictionary *)parameters;

@end
