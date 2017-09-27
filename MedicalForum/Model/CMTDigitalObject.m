//
//  CMTDigitalObject.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTDigitalObject.h"

@implementation CMTDigitalObject
+(NSValueTransformer*)subjectListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTSubject class]];
}

@end
