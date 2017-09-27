//
//  CMTClient+GetFocusList.m
//  MedicalForum
//
//  Created by fenglei on 15/4/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetFocusList.h"
#import "CMTFocus.h"

@implementation CMTClient (GetFocusList)

- (RACSignal *)getFocusList:(NSDictionary *)parameters {
    
    return [self GET:@"app/focus/list.json" parameters:parameters resultClass:[CMTFocus class] withStore:NO];
}

@end
