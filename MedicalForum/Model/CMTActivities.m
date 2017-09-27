//
//  Activities.m
//  MedicalForum
//
//  Created by jiahongfei on 15/8/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTActivities.h"

@implementation CMTActivities

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"desc":@"description"
             };
}


+(NSValueTransformer*)pictureJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}


+(NSValueTransformer*)sharePicJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}

@end
