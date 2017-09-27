//
//  CMTClient+getLive_info.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/24.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(getLive_info)
- (RACSignal *)getLive_info:(NSDictionary *)parameters;
@end
