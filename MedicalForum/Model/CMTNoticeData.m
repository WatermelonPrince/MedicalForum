//
//  CMTNoticeData.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTNoticeData.h"

@implementation CMTNoticeData
+(NSValueTransformer*)itemsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTNotice class]];
}

@end
