//
//  CMTGroup.m
//  MedicalForum
//
//  Created by CMT on 15/7/13.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTGroup.h"
@implementation CMTGroup
+(NSValueTransformer*)topMemListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTParticiPators class]];
}
+(NSValueTransformer*)groupLogoJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTGroupLogo class]];
}
+(NSValueTransformer*)advertisementJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}
@end
