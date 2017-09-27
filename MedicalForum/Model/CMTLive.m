//
//  CMTLive.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLive.h"

@implementation CMTLive

+(NSValueTransformer*)liveBroadcastTagJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLiveTag class]];
}
+(NSValueTransformer*)sharePicJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}
+(NSValueTransformer*)headPicJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}
+(NSValueTransformer*)pictureListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPicture class]];
}
+(NSValueTransformer*)praiseUserListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTParticiPators class]];
}


@end
