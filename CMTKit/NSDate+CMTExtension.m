//
//  NSDate+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 14/12/5.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "NSDate+CMTExtension.h"

@implementation NSDate (CMTExtension)

+ (NSString *)UNIXTimeStampFromNow {
    return [NSString stringWithFormat:@"%lld", (long long)([[NSDate date] timeIntervalSince1970]*1000)];
}

+ (instancetype)dateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp {
    NSDate *date = nil;
    @try {
        if ([UNIXTimeStamp respondsToSelector:@selector(longLongValue)]) {
            date = [NSDate dateWithTimeIntervalSince1970:[UNIXTimeStamp longLongValue]/1000];
        }
    }
    @catch (NSException *exception) {
        date = nil;
        CMTLogError(@"Convert UNIXTimeStamp Error: %@", exception);
    }
    
    return date;
}

+ (NSString *)formattedStringFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp {
    
    return [[NSDateFormatter defaultFormatter] stringFromDate:[self dateWithUNIXTimeStamp:UNIXTimeStamp]];
}

+ (NSString *)briefFormattedStringFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp {
    
    return [[NSDateFormatter briefFormatter] stringFromDate:[self dateWithUNIXTimeStamp:UNIXTimeStamp]];
}

+ (NSString *)timeFormattedStringFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp {
    
    return [[NSDateFormatter timeFormatter] stringFromDate:[self dateWithUNIXTimeStamp:UNIXTimeStamp]];
}


+ (NSString *)secondstimeFormattedStringFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp{
    return [[NSDateFormatter secondtimeFormatter] stringFromDate:[self dateWithUNIXTimeStamp:UNIXTimeStamp]];
}

//根据时间戳获取星期几
+ (NSString *)getWeekDayFordate:(TIME_STAMP)UNIXTimeStamp
{
    NSArray *weekday = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSDate *newDate = [NSDate dateWithUNIXTimeStamp:UNIXTimeStamp];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:newDate];
    
    NSString *weekStr = [weekday objectAtIndex:components.weekday];
    return weekStr;
}
+ (NSString *)formattedPassedTimeFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp {
    NSString *formattedPassedTime = nil;
    long long UNIXTimeStampLongValue = [UNIXTimeStamp longLongValue];
    long long nowTimeLongValue = [[self UNIXTimeStampFromNow] longLongValue];
    long long passedTime = nowTimeLongValue - UNIXTimeStampLongValue;
    
    long long day = passedTime / (24 * 60 * 60 * 1000);
    long long hour = (passedTime / (60 * 60 * 1000) - day * 24);
    long long min = ((passedTime / (60 * 1000)) - day * 24 * 60 - hour * 60);
//    long long s = (passedTime/1000-day*24*60*60-hour*60*60-min*60);
    
//    if (day > 0) {
//        formattedPassedTime = [NSString stringWithFormat:@"%lld天前", day];
//    } else if (hour > 0) {
//        formattedPassedTime = [NSString stringWithFormat:@"%lld小时前", hour];
//    } else if (min > 0) {
//        formattedPassedTime = [NSString stringWithFormat:@"%lld分钟前", min];
//    } else {
//        formattedPassedTime = @"刚刚";
//    }
    
    if (day > 0 || hour > 0) {
        formattedPassedTime = [self timeFormattedStringFromDateWithUNIXTimeStamp:UNIXTimeStamp];
    } else if (min >= 5) {
        formattedPassedTime = [NSString stringWithFormat:@"%lld分钟前", min];
    } else {
        formattedPassedTime = @"刚刚";
    }

    return formattedPassedTime;
}

+ (NSInteger)dateStampFromDateWithUNIXTimeStamp:(TIME_STAMP)UNIXTimeStamp {
    NSInteger dateStamp = 0;
    @try {
        dateStamp = [[[NSDateFormatter dateStampFormatter] stringFromDate:[self dateWithUNIXTimeStamp:UNIXTimeStamp]] integerValue];
    }
    @catch (NSException *exception) {
        dateStamp = 0;
        CMTLogError(@"Convert DateStamp Error: %@", exception);
    }
    
    return dateStamp;
}

+ (NSInteger)dateStampFromNow {
    NSInteger dateStamp = 0;
    @try {
        dateStamp = [[[NSDateFormatter dateStampFormatter] stringFromDate:[NSDate date]] integerValue];
    }
    @catch (NSException *exception) {
        dateStamp = 0;
        CMTLogError(@"Generate DateStamp Error: %@", exception);
    }
    
    return dateStamp;
}

//根据pattern格式化时间
//@param pattern @"yyyy-MM-dd HH:mm:ss"
+ (NSString *)dateFormatPattern : (NSString *) pattern TimeStamp  : (TIME_STAMP)UNIXTimeStamp{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:pattern];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[self dateWithUNIXTimeStamp:UNIXTimeStamp]];
    //输出格式为：2010-10-27 10:22:13
    CMTLog(@"%@",currentDateStr);
    return  currentDateStr;
}
/**
 *  转换成年月日
 *
 *  @param UNIXTimeStamp UNIXTimeStamp description
 *
 *  @return <#return value description#>
 */
+ (NSString *)dateFormatPattern:(TIME_STAMP)UNIXTimeStamp{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[self dateWithUNIXTimeStamp:UNIXTimeStamp]];
    //输出格式为：2010-10-27 10:22:13
    CMTLog(@"%@",currentDateStr);
    return  currentDateStr;
}

@end
