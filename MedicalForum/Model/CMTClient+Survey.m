//
//  CMTClient+Survey.m
//  MedicalForum
//
//  Created by zhaohuan on 16/4/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTClient+Survey.h"

@implementation CMTClient (Survey)

- (RACSignal *)GetSurvey:(NSDictionary *)parameters{
    return [self POST:@"/app/common/survey/is_show.json" parameters:parameters resultClass:[CMTSurvey class] withStore:NO];
    
}

@end
