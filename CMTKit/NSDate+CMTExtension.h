//
//  NSDate+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 14/12/5.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * TIME_STAMP;

@interface NSDate (CMTExtension)

+ (NSString *)UNIXTimeStampFromNow;
+ (instancetype)dateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp;
+ (NSString *)formattedStringFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp;
+ (NSString *)briefFormattedStringFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp;
+ (NSString *)timeFormattedStringFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp;
+ (NSString *)secondstimeFormattedStringFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp;
+ (NSString *)formattedPassedTimeFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp;
+ (NSString *)dateFormatPattern : (NSString *) pattern TimeStamp  : (TIME_STAMP)UNIXTimeStamp;
+ (NSString *)dateFormatPattern:(TIME_STAMP)UNIXTimeStamp;
//根据时间戳获取星期几
+ (NSString *)getWeekDayFordate:(TIME_STAMP)UNIXTimeStamp;
@end
