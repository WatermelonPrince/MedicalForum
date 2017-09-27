//
//  CMTClient+Statistics.h
//  MedicalForum
//
//  Created by fenglei on 15/2/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (Statistics)

- (RACSignal *)getPostStatistics:(NSDictionary *)parameters;

@end
