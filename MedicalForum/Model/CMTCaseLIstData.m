//
//  CMTCaseLIstData.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCaseLIstData.h"

@implementation CMTCaseLIstData
+(NSValueTransformer*)groupInfoJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTGroup class]];
}
+(NSValueTransformer*)diseaseListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPost class]];
}

+(NSValueTransformer*)topDiseaseListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPost class]];
}

@end
