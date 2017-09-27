//
//  CMTshakeobject.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/13.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTshakeobject.h"

@implementation CMTshakeobject
+ (NSValueTransformer *)paramJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTshakeobject class]];
}


@end
