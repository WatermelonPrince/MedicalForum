//
//  CMTClient+getLiveTag.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(getLiveTagList)
 - (RACSignal *)getLiveTagList:(NSDictionary *)parameters;
@end
