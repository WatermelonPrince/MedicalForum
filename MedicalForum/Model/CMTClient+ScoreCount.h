//
//  CMTClient+ScoreCount.h
//  MedicalForum
//
//  Created by jiahongfei on 15/7/29.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (ScoreCount)

- (RACSignal *)getScoreCount:(NSDictionary *)parameters;

@end
