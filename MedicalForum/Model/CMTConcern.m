//
//  CMTOpTime.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTConcern.h"
#import "CMTAuthor.h"

@implementation CMTConcern

// `+<key>JSONTransformer` method
+ (NSValueTransformer *)authorsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTAuthor class]];
}

@end
