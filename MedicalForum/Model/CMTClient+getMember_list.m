//
//  CMTClient+getMember_list.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getMember_list.h"

@implementation CMTClient(getMember_list)
// 59小组成员列表
- (RACSignal *)getMember_list:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/member_list.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}

//98组内设为组长

- (RACSignal *)sendChangeMemberGrade:(NSDictionary *)parameters{
    return [self POST:@"/app/group/user/set_level.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}
//98撤销组长
- (RACSignal *)revokeGradeManager:(NSDictionary *)parameters{
    return [self POST:@"/app/group/user/set_level.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}

//99移除用户接口
- (RACSignal *)sendDeleteMember:(NSDictionary *)parameters{
    return [self POST:@"/app/group/user/del.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}

//111拉黑接口
- (RACSignal *)sendBlackListMember:(NSDictionary *)parameters{
    return [self POST:@"/app/group/user/set_black.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}

//111取消拉黑

- (RACSignal *)cancleBlackListMember:(NSDictionary *)parameters{
    return [self POST:@"/app/group/user/set_black.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}

//59 搜索小组成员接口
- (RACSignal *)searchGroupMember:(NSDictionary *)parameters{
    return [self POST:@"/app/group/member_list.json" parameters:parameters resultClass:[CMTParticiPators class] withStore:NO];
}

@end
