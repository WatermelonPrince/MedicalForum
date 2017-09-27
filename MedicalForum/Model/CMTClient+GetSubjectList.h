//
//  CMTClient+GetSubjectList.h
//  MedicalForum
//
//  Created by Bo Shen on 15/3/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
// 修改订阅模式后，获取关注列表接口

#import "CMTClient.h"

@interface CMTClient (GetSubjectList)
-(RACSignal *) getSubjectList:(NSDictionary *)parameters;
@end
