//
//  CMTThemePostList.m
//  MedicalForum
//
//  Created by fenglei on 15/4/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTThemePostList.h"
#import "CMTTheme.h"
#import "CMTPost.h"

@implementation CMTThemePostList

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
    if (BEMPTY(JSONDictionary[@"theme"]) ) {
        
        return [CMTThemePostOnlyList class];
    }
    else {
        
        return [CMTThemePostList class];
    }
}

+ (NSValueTransformer *)themeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTTheme class]];
}
+ (NSValueTransformer *)liveInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLive class]];
}


+ (NSValueTransformer *)itemsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPost class]];
}

@end

@implementation CMTThemePostOnlyList

+ (NSValueTransformer *)itemsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPost class]];
}
+ (NSValueTransformer *)liveInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLive class]];
}

@end
