//
//  CMTFunctions.m
//  MedicalForum
//
//  Created by fenglei on 14/12/29.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTFunctions.h"

// Empty Handle
BOOL isEmptyObject(id object) {
    BOOL empty = NO;
    @try {
        empty = isEmptyString(object)
            || isEmptyArray(object)
            || isEmptyDictionary(object);
    }
    @catch (NSException *exception) {
        empty = YES;
    }
    
    return empty;
}

BOOL isEmptyString(NSString *string) {
    BOOL empty = NO;
    @try {
        empty = !string
            || [string isKindOfClass:[NSNull class]]
            || ([string respondsToSelector:@selector(length)] && [string length] == 0);
    }
    @catch (NSException *exception) {
        empty = YES;
    }
    
    return empty;
}

BOOL isEmptyArray(NSArray *array) {
    BOOL empty = NO;
    @try {
        empty = !array
            || [array isKindOfClass:[NSNull class]]
            || ([array respondsToSelector:@selector(count)] && [array count] == 0);
    }
    @catch (NSException *exception) {
        empty = YES;
    }
    
    return empty;
}

BOOL isEmptyDictionary(NSDictionary *dictionary) {
    BOOL empty = NO;
    @try {
        empty = !dictionary
            || [dictionary isKindOfClass:[NSNull class]]
            || ([dictionary respondsToSelector:@selector(count)] && [dictionary count] == 0);
    }
    @catch (NSException *exception) {
        empty = YES;
    }
    
    return empty;
}

