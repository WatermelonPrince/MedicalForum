//
//  CMTClient+getGroupNotice.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/10/9.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(getGroupNotice)
- (RACSignal *)getGroupNotice:(NSDictionary *)parameters;
//收到小组系统通知
- (RACSignal *)getCaseSystemNotice:(NSDictionary *)parameters;
//同意/拒绝小组申请
- (RACSignal *)allowOrRefuseEnterGroup:(NSDictionary *)parameters;




@end
