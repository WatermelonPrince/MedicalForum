//
//  CMTClient+SyncConcern.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//
//  同步订阅学科接口
//


#import "CMTClient.h"

@interface CMTClient(SyncConcern)
-(RACSignal *) syncConcern:(NSDictionary *) parameters;

@end
