//
//  CMTClient+GetFocusList.h
//  MedicalForum
//
//  Created by fenglei on 15/4/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (GetFocusList)

// 首页焦点图列表接口
- (RACSignal *)getFocusList:(NSDictionary *)parameters;

@end
