//
//  CMTClient+getGroupDetails.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/22.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getGroupDetails.h"
#import "CMTPost.h"

@implementation CMTClient(getGroupDetails)
// 60小组详情接口
- (RACSignal *)getGroupDetails:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/detail_with_top.json" parameters:parameters resultClass:[CMTCaseLIstData class] withStore:NO];
}
//组内屏蔽文章
- (RACSignal *)deleteCase:(NSDictionary *)parameters{
    return [self POST:@"app/group/post/del.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}


//自己删除自己文章
- (RACSignal *)deleteCaseOfMyself:(NSDictionary *)parameters{
    
    return [self POST:@"/app/group/del_post.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];

}


@end
