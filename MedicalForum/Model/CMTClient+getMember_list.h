//
//  CMTClient+getMember_list.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getMember_list.h"

@interface CMTClient(getMember_list)
- (RACSignal *)getMember_list:(NSDictionary *)parameters;

//组内设为组长/组员接口
- (RACSignal *)sendChangeMemberGrade:(NSDictionary *)parameters;

//移除用户接口
- (RACSignal *)sendDeleteMember:(NSDictionary *)parameters;
//撤销组长
- (RACSignal *)revokeGradeManager:(NSDictionary *)parameters;
//拉黑
- (RACSignal *)sendBlackListMember:(NSDictionary *)parameters;
//取消拉黑
- (RACSignal *)cancleBlackListMember:(NSDictionary *)parameters;
//59 搜索小组成员接口
- (RACSignal *)searchGroupMember:(NSDictionary *)parameters;
@end
