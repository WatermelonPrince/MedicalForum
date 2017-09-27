//
//  CMTClient+get_post_types.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+get_post_types_by_module.h"

@interface CMTClient(get_post_types_by_module)
- (RACSignal *)get_post_types_by_module:(NSDictionary *)parameters;
@end
