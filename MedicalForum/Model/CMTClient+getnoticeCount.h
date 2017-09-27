//
//  CMTClient+getnoticeCount.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(getnoticeCount)
- (RACSignal *)getnoticeCount:(NSDictionary *)parameters;
- (RACSignal *)getGroupNoticeCount:(NSDictionary *)parameters;
/**
 *  获取论吧系统通知
 *
 *  @param parameters <#parameters description#>
 *
 *  @return <#return value description#>
 */
- (RACSignal *)getGroup_diseaseCount:(NSDictionary *)parameters;
@end
