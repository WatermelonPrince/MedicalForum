//
//  CMTSeriesDetails.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSeriesDetails.h"

@implementation CMTSeriesDetails

+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{ @"newrecordCount":@"newRecordCount",
              };
}
+(NSValueTransformer*)navigationsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTSeriesNavigation class]];
}
+ (NSValueTransformer *)sharePicJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}


@end
