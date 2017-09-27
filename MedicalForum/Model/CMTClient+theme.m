//
//  CMTClient+theme.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+theme.h"
#import "CMTTheme.h"
@implementation CMTClient(theme)
-(RACSignal *)fetchTheme:(NSDictionary *)parameters
{
    return [self POST:@"app/user/concern_theme.json" parameters:parameters resultClass:[CMTTheme class] withStore:NO];
}
-(RACSignal *)getSubjectThemelist:(NSDictionary *)parameters
{
    return [self GET:@"app/subject/theme_list.json" parameters:parameters resultClass:[CMTTheme class] withStore:NO];
}

@end
