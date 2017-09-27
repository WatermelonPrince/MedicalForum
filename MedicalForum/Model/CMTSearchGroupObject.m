//
//  CMTSearchObject.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/15.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSearchGroupObject.h"

@implementation CMTSearchGroupObject
+(NSValueTransformer*)inGroupsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTGroup class]];
}
+(NSValueTransformer*)unInGroupsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTGroup class]];
}

@end
