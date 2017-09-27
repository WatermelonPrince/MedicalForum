//
//  CMTClient+GetScoreList.h
//  MedicalForum
//
//  Created by jiahongfei on 15/7/29.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (GetScoreList)

/// . 积分列表接口
- (RACSignal *)getScoreList:(NSDictionary *)parameters;

@end
