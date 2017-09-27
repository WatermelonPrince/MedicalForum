//
//  CMTClient+GetThemeUnreadNotice.m
//  MedicalForum
//
//  Created by fenglei on 15/4/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetThemeUnreadNotice.h"

@implementation CMTClient (GetThemeUnreadNotice)

- (RACSignal *)getThemeUnreadNotice:(NSDictionary *)parameters {
    
    return [self POST:@"app/theme/unread_notice.json" parameters:parameters resultClass:[CMTTheme class] withStore:NO];
}

@end
