//
//  CMTClient+SyncTheme.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+SyncTheme.h"
#import "CMTTheme.h"

@implementation CMTClient (SyncTheme)

- (RACSignal *)syncTheme:(NSDictionary *)parameters
{
    return [self POST:@"app/user/sync_concern_theme.json" parameters:parameters resultClass:[CMTTheme class] withStore:NO];
}

@end
