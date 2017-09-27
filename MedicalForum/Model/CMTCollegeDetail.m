//
//  CMTCollegeDetail.m
//  MedicalForum
//
//  Created by zhaohuan on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTCollegeDetail.h"

@implementation CMTCollegeDetail

+ (NSValueTransformer *)assortmentArrayJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTAssortments class]];
}
+ (NSValueTransformer *)sharePicJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}
@end
