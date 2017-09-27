//
//  CMTClient+ReceivedList.h
//  MedicalForum
//
//  Created by guanyx on 14/12/12.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(ReceivedList)

- (RACSignal *)receivedList:(NSDictionary *)parameters;

@end
