//
//  NSDateFormatter+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 15/1/6.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (CMTExtension)

+ (instancetype)defaultFormatter;
+ (instancetype)briefFormatter;
+ (instancetype)timeFormatter;
+ (instancetype)secondtimeFormatter;
+ (instancetype)dateStampFormatter;

@end
