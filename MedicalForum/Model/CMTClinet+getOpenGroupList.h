//
//  CMTCline+getOpen_list.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClinet+getOpenGroupList.h"

@interface CMTClient(getOpenGroupList)
- (RACSignal *)getOpenGroupList:(NSDictionary *)parameters;
- (RACSignal *)searchTeam:(NSDictionary *)parameters;
- (RACSignal *)groupCheckName:(NSDictionary *)parameters;
//创建小组
- (RACSignal *) modifyCreatGroup:(NSDictionary *) parameters;
//修改小组
- (RACSignal *)modifUpdateGroup:(NSDictionary *) parameters;
@end
