//
//  CMTInitObject.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/14.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTInitObject.h"

@implementation CMTInitObject
+(NSValueTransformer*)itemsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTInitObject class]];
}
+(NSValueTransformer*)adverJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTAdverObject class]];
}
+ (NSValueTransformer *)readcodeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTTouchme class]];
}
+ (NSValueTransformer *)touchmeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTTouchme class]];
}
+ (NSValueTransformer *)recommendJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTRecommend class]];
}
@end
@implementation CMTAdverObject
@end
@implementation CMTRecommend

@end
@implementation CMTTouchme
@end
@implementation CMTContact
+ (NSValueTransformer *)touchmeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTTouchme class]];
}
+ (NSValueTransformer *)recommendJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTRecommend class]];
}


@end
@implementation CMTAuthCode
@end
