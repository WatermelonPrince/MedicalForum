//
//  CMTClient+getGroupDetails.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/22.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getGroupDetails.h"

@interface CMTClient(getGroupDetails)
- (RACSignal *)getGroupDetails:(NSDictionary *)parameters;
//组内屏蔽文章
- (RACSignal *)deleteCase:(NSDictionary *)parameters;

//自己删除自己文章
- (RACSignal *)deleteCaseOfMyself:(NSDictionary *)parameters;


@end
