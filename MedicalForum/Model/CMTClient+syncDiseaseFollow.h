//
//  CMTClient+syncDiseaseFollow.h
//  MedicalForum
//
//  Created by CMT on 15/6/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+syncDiseaseFollow.h"

@interface CMTClient(syncDiseaseFollow)
- (RACSignal *)SynDiseasecFollowsList:(NSDictionary *)parameters;
@end
