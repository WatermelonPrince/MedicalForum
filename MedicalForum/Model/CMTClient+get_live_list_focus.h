//
//  CMTClient+get_live_list_focus.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(get_live_list_focus)
//75 首页直播列表和焦点图列表接口
- (RACSignal *)get_live_list_focus:(NSDictionary *)parameters;
@end
