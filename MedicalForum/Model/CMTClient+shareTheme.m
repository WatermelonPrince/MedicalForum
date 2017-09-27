//
//  CMTClient+shareTheme.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+shareTheme.h"

@implementation CMTClient (shareTheme)

- (RACSignal *)shareTheme:(NSDictionary *)parameters
{
    return [self GET:@"app/theme/share.json" parameters:parameters resultClass:[CMTTheme class] withStore:NO];
}

@end
