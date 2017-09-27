//
//  CMTClient+GetCity.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+HospitalInterface.h"

@implementation CMTClient(HospitalInterface)

- (RACSignal *) getCity {
    
    return [self GET:@"app/common/get_city.json" parameters:nil resultClass:[CMTProvince class] withStore:YES];

}
-(RACSignal *) getAllHospital:(NSDictionary *)parameters {
    
    return [self GET:@"app/common/get_all_hospital.json" parameters:parameters resultClass:[CMTProvince class] withStore:YES];
}
-(RACSignal *) getHospital:(NSDictionary *)parameters {
    
    return [self GET:@"app/common/get_hospital.json" parameters:parameters resultClass:[CMTHospital class] withStore:YES];
    
}
-(RACSignal *) getDepart {
    
    return [self GET:@"app/common/get_depart.json" parameters:nil resultClass:[CMTDepart class] withStore:YES];
    
}
-(RACSignal *) getAllAreas:(NSDictionary *) parameters{
    return [self GET:@"app/common/get_all_areas.json" parameters:parameters resultClass:[CMTProvince class] withStore:NO];
}

@end
