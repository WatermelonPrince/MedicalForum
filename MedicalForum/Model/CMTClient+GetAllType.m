//
//  CMTClient+GetAllType.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetAllType.h"
#import "CMTType.h"

@implementation CMTClient (GetAllType)

- (RACSignal *)getallTypes:(NSDictionary *)parameters
{
    return [self GET:@"app/common/get_post_types.json" parameters:parameters resultClass:[CMTType class] withStore:NO];
}

@end
