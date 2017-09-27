//
//  NSError+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 15/9/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSError+CMTExtension.h"

@implementation NSError (CMTExtension)

- (NSString *)CMTUserInfo {
    // 网络错误
    if ([self.domain isEqual:NSURLErrorDomain]) {
        return CMTClientRequestStatusInfoNetError;
    }
    // 服务器返回错误
    else if ([self.domain isEqual:CMTClientServerErrorDomain]) {
        // 业务参数错误
        if ([self.userInfo[CMTClientServerErrorCodeKey] integerValue] > 100) {
            return [CMTClientRequestStatusInfoServerError
                    stringByAppendingString:
                    self.userInfo[CMTClientServerErrorUserInfoMessageKey]];
        }
        // 系统错误/错误代码格式错误
        else {
            return [CMTClientRequestStatusInfoSystemError
                    stringByAppendingString:
                    self.userInfo[CMTClientServerErrorUserInfoMessageKey]];
        }
    }
    
    return nil;
}

@end
