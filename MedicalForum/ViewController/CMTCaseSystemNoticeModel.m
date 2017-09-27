//
//  CMTCaseSystemNoticeModel.m
//  MedicalForum
//
//  Created by zhaohuan on 15/11/26.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTCaseSystemNoticeModel.h"

@implementation CMTCaseSystemNoticeModel
+ (NSValueTransformer *)userAuthInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTUserInfo class]];
}

@end
