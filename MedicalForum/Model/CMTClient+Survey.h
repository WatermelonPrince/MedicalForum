//
//  CMTClient+Survey.h
//  MedicalForum
//
//  Created by zhaohuan on 16/4/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (Survey)
//115 调研
- (RACSignal *)GetSurvey:(NSDictionary *)parameters;

@end
