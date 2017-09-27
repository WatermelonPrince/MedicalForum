//
//  CMTComment.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTComment.h"

@implementation CMTComment

// `+<key>JSONTransformer` method
+ (NSValueTransformer *)replyListJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTReply class]];
}
+ (NSValueTransformer *)commentPicJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}

@end
