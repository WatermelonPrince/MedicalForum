//
//  CMTTheme.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTTheme.h"

@implementation CMTTheme

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"descriptionString": @"description",
             };
}
+(NSValueTransformer*)sharePicJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}
@end
