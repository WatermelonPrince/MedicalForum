//
//  CMTLiveListData.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLiveListData.h"

@implementation CMTLiveListData
+(NSValueTransformer*)liveListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTLive class]];
}
+(NSValueTransformer*)focusPicListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTFocus class]];
}
+(NSValueTransformer*)topMessageJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLive class]];
}
+(NSValueTransformer*)liveMessageListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTLive class]];
}
+(NSValueTransformer*)liveInfoJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLive class]];
}
+(NSValueTransformer*)topArticlesJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPost class]];
}






@end
