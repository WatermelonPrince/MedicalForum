//
//  CMTClient+GetThemeUnreadNotice.h
//  MedicalForum
//
//  Created by fenglei on 15/4/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (GetThemeUnreadNotice)

// 获取未读专题列表接口
- (RACSignal *)getThemeUnreadNotice:(NSDictionary *)parameters;

@end
