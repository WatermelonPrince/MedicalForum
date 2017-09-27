//
//  CMTClient+theme.h
//  MedicalForum
//
//  Created by Bo Shen on 15/4/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (theme)
//订阅专题
-(RACSignal *)fetchTheme:(NSDictionary *)parameters;
//获取学科下专题列表
-(RACSignal *)getSubjectThemelist:(NSDictionary *)parameters;

@end
