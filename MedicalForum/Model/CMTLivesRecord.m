//
//  CMTLivesRecord.m
//  MedicalForum
//
//  Created by zhaohuan on 16/6/2.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTLivesRecord.h"
@implementation CMTCollegeInfo

@end
@implementation CMTThemeInfo

@end
@implementation CMTLivesRecord
+ (NSValueTransformer *)userInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTUserInfo class]];
}
+ (NSValueTransformer *)themeInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTThemeInfo class]];
}
+ (NSValueTransformer *)collegeInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTCollegeInfo class]];
}

+ (NSValueTransformer *)sharePicJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}
+ (NSValueTransformer *)videoPicJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTPicture class]];
}



- (NSString *)startDateAndEndDateformattNSString{
    NSString *monthDayTime = [NSDate briefFormattedStringFromDateWithUNIXTimeStamp:self.startDate];
    NSArray *monthAndDayArr = [monthDayTime componentsSeparatedByString:@"-"];
    NSString *month = monthAndDayArr[0];
    NSString *day = monthAndDayArr[1];
    month = [NSString stringWithFormat:@"%lld",month.longLongValue];
    day = [NSString stringWithFormat:@"%lld",day.longLongValue];
    NSString *startTime = [NSDate timeFormattedStringFromDateWithUNIXTimeStamp:self.startDate];
    NSString *endTime = [NSDate timeFormattedStringFromDateWithUNIXTimeStamp:self.endDate];
    NSString *dateString = [NSString stringWithFormat:@"时间：%@月%@日 %@-%@",month,day,startTime,endTime];
    return dateString;
}


- (NSString *)toStartTimeformattNSStringWithCurrentTime:(NSString *)time{
    NSString *countDownTimeString;
    long long countDownTime =self.startDate.longLongValue - time.longLongValue;
    long long day = countDownTime/1000/60/60/24;
    long long hour = countDownTime/1000/60/60;
    long long min =  countDownTime/1000/60;
    if (countDownTime < 0) {
        countDownTimeString = @"";
    }else if (day>0){
        countDownTimeString = [NSString stringWithFormat:@"%lld天",day];
    }else if (hour < 1){
        if (min < 1) {
            countDownTimeString = @"1分钟";
        }else{
            countDownTimeString = [NSString stringWithFormat:@"%lld分钟",countDownTime/1000/60];
 
        }
    }else{
        countDownTimeString = [NSString stringWithFormat:@"%lld小时",countDownTime/1000/60/60];
    }
    return countDownTimeString;
}
@end
@implementation CmtLiveOrOnDemand
+ (NSValueTransformer *)roominfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLivesRecord class]];
}

+ (NSValueTransformer *)videoinfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTLivesRecord class]];
}
@end


