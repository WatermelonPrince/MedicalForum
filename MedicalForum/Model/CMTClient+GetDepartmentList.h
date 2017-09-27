//
//  CMTClient+GetDepartmentList.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//
//  订阅列表接口
//

#import "CMTObject.h"

@interface CMTClient(GetDepartmentList)

-(RACSignal *) getDepartmentList:(NSDictionary *)parameters;

@end
