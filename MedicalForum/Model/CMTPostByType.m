//
//  CMTPostByType.m
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTPostByType.h"
#import "CMTPost.h"

@implementation CMTPostByType

// `+<key>JSONTransformer` method
+ (NSValueTransformer *)itemsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPost class]];
}

@end
