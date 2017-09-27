//
//  CMTPlayAndRecordList.m
//  MedicalForum
//
//  Created by zhaohuan on 16/6/2.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTPlayAndRecordList.h"
#import "CMTCollegeDetail.h"
#import "CMTSeriesDetails.h"

@implementation CMTPlayAndRecordList

+(NSValueTransformer*)storeDataJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTLivesRecord class]];
}
+(NSValueTransformer*)livesJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTLivesRecord class]];
}



+(NSValueTransformer*)recordsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTLivesRecord class]];
}

+(NSValueTransformer*)focuslistJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTSeriesDetails class]];
}
+(NSValueTransformer*)collegesJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTCollegeDetail class]];
}
+(NSValueTransformer*)revideosJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTLivesRecord class]];
}
+(NSValueTransformer*)seriesesJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTSeriesDetails class]];
}

+(NSValueTransformer*)videosJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTLivesRecord class]];
}

+(NSValueTransformer*)adversJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTAdvert class]];
}



@end
