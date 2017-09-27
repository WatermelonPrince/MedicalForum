//
//  CMTClient+GetDisease.m
//  MedicalForum
//
//  Created by CMT on 15/6/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//
#import "CMTClient+GetDiseaseList.h"

@implementation CMTClient(GetDisease)
//获取学科下疾病列表接口
- (RACSignal *)GetDiseaseList:(NSDictionary *)parameters{
    return [self POST:@"app/disease/diseaseList.json" parameters:parameters resultClass:[CMTDisease class] withStore:NO];
}
@end
