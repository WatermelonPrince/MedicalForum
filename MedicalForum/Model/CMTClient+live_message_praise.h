//
//  CMTClient+live_message_praise.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(live_message_praise)
- (RACSignal *)live_message_praise:(NSDictionary *)parameters;
@end
