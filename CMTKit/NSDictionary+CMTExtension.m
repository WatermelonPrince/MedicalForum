//
//  NSDictionary+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 14/12/9.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "NSDictionary+CMTExtension.h"

@implementation NSDictionary (CMTExtension)

- (instancetype)filtEmptyValue {
    NSMutableDictionary *handleDictionary = [NSMutableDictionary dictionary];
    @try {
        for (id key in self.allKeys) {
            if (!BEMPTY(self[key])) {
                handleDictionary[key] = self[key];
            }
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"Dictionary: %@ －Filt Empty Value Error: %@", self, exception);
        handleDictionary = nil;
    }
    
    if (handleDictionary != nil) {
        if (![self isKindOfClass:[NSMutableDictionary class]]) {
            return [NSDictionary dictionaryWithDictionary:handleDictionary];
        }
    }
    
    return handleDictionary;
}

@end
