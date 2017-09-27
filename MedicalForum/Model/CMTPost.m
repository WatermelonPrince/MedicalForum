//
//  CMTPost.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTPost.h"
#import "CMTPdf.h"
#import "CMTDiseaseTag.h"
#import "CMTParticiPators.h"
#import "CMTPicture.h"
#import "CMTAddPost.h"

@implementation CMTPost

// `+<key>JSONTransformer` method
+ (NSValueTransformer *)pdfFilesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPdf class]];
}

+ (NSValueTransformer *)diseaseTagArrJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTDiseaseTag class]];
}

+ (NSValueTransformer*)participatorsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTParticiPators class]];
}

+ (NSValueTransformer*)imageListJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTPicture class]];
}

+ (NSValueTransformer *)postDiseaseExtListJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTAddPost class]];
}
+(NSValueTransformer*)sharePicJSONTransformer{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}
@end
