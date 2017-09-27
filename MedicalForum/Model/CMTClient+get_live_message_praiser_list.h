//
//  CMTClient+get_live_message_praiser_list.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/9/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(get_live_message_praiser_list)
- (RACSignal *)get_live_message_praiser_list:(NSDictionary *)parameters;
@end
