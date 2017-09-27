//
//  CMTProvince.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTHospitalInformation.h"
@implementation CMTCity
+ (NSValueTransformer *)hospital_listJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTDetailHosptial class]];
}
+ (NSValueTransformer *)areasJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTArea class]];
}

@end
@implementation CMTProvince

// `+<key>JSONTransformer` method
+ (NSValueTransformer *)citiesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTCity class]];
}

@end
@implementation CMTHospital

@end
@implementation CMTDetailHosptial

@end
@implementation CMTSubDepart

@end

@implementation CMTDepart

// `+<key>JSONTransformer` method
+ (NSValueTransformer *)subDepartsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTSubDepart class]];
}


@end

