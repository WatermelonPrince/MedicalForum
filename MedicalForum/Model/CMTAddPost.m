//
//  CMTAddPost.m
//  MedicalForum
//
//  Created by fenglei on 15/8/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTAddPost.h"
#import "CMTDiseaseTag.h"
#import "CMTPicture.h"

@implementation CMTAddPost

// `+<key>JSONTransformer` method
+ (NSValueTransformer *)diseaseTagArrayJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTDiseaseTag class]];
}
+ (NSValueTransformer *)userinfoArrayJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTUserInfo class]];
}

+ (NSValueTransformer *)pictureFilePathsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPicture class]];
}

+ (NSValueTransformer *)postBriefJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPost class]];
}
+ (NSValueTransformer *)liveBroadcastMessageJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLive class]];
}
+ (NSValueTransformer *)livetagJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLiveTag class]];
}



+ (NSValueTransformer *)picListJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPicture class]];
}

@end
