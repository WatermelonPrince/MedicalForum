//
//  CMTClient+deleteLive_message.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(deleteLive_message)
- (RACSignal *)deleteLive_message:(NSDictionary *)parameters;
@end
