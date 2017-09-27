//
//  CMTClient+GetDisease.h
//  MedicalForum
//
//  Created by CMT on 15/6/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetDiseaseList.h"

@interface CMTClient(GetDiseaseList)
- (RACSignal *)GetDiseaseList:(NSDictionary *)parameters;
@end
