//
//  CMTLogFormatter.m
//  MedicalForum
//
//  Created by fenglei on 14/11/27.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTLogFormatter.h"

@interface CMTLogFormatter ()

@property (nonatomic, strong) NSDateFormatter *threadUnsafeDateFormatter;

@end

@implementation CMTLogFormatter

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    self.threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
    self.threadUnsafeDateFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
    self.threadUnsafeDateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss.SSS";
    
    return self;
}

+ (instancetype)formatter {
    return [[self alloc] init];
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *dateAndTime = [self.threadUnsafeDateFormatter stringFromDate:(logMessage.timestamp)];
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    NSString *logLevel = nil;
    switch (logMessage.flag) {
        case DDLogFlagError     : logLevel = @" ❌[ERROR] "; break;
        case DDLogFlagWarning   : logLevel = @" ❗️[WARNING] "; break;
        case DDLogFlagInfo      : logLevel = @" 💡[INFO] "; break;
        case DDLogFlagDebug     : logLevel = @" 👔[DEBUG] "; break;
        case DDLogFlagVerbose   : logLevel = @" ✅"; break;
        default                 : logLevel = @" ❓ "; break;
    }
    
    NSString *formattedLog = [NSString stringWithFormat:@"\n%@ %@[%@](%@)\n-->%@[%@ %@] #%lu:\n%@",
                              dateAndTime,
                              bundleName,
                              logMessage.threadID,
                              logMessage.queueLabel,
                              logLevel,
                              logMessage.fileName,
                              logMessage.function,
                              (unsigned long)logMessage.line,
                              logMessage.message];
    
    return formattedLog;
}

@end
