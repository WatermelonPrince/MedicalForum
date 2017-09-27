//
//  CMTSeriesNavigation.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSeriesNavigation.h"

@implementation CMTSeriesNavigation
+(NSValueTransformer*)videoJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTLivesRecord class]];
}


@end
