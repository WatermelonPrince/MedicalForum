//
//  NSDateFormatter+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 15/1/6.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSDateFormatter+CMTExtension.h"

@implementation NSDateFormatter (CMTExtension)

+ (instancetype)defaultFormatter {
    static NSDateFormatter *defaultFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultFormatter = [[NSDateFormatter alloc] init];
        [defaultFormatter setDateFormat:@"YYYY-MM-dd"];
    });
    
    return defaultFormatter;
}

+ (instancetype)briefFormatter {
    static NSDateFormatter *briefFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        briefFormatter = [[NSDateFormatter alloc] init];
        [briefFormatter setDateFormat:@"MM-dd"];
    });
    
    return briefFormatter;
}

+ (instancetype)timeFormatter {
    static NSDateFormatter *timeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
    });
    
    return timeFormatter;
}

+ (instancetype)secondtimeFormatter {
    static NSDateFormatter *timeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
    });
    
    return timeFormatter;
}

+ (instancetype)dateStampFormatter {
    static NSDateFormatter *dateStampFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateStampFormatter = [[NSDateFormatter alloc] init];
        [dateStampFormatter setDateFormat:@"YYYYMMdd"];
    });
    
    return dateStampFormatter;
}

@end
