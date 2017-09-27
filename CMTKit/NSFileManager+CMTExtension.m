//
//  NSFileManager+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 15/4/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSFileManager+CMTExtension.h"

@implementation NSFileManager (CMTExtension)

- (long long)fileSizeOfItemAtPath:(NSString *)path {
    long long fileSize = 0;
    
    NSError *getAttributesError = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&getAttributesError];
    if (getAttributesError != nil) {
        // 260: 文件不存在 256: 未能完成操作
        if (getAttributesError.code == 260 || getAttributesError.code == 256) {
            fileSize = 0;
        }
        else {
            CMTLogError(@"NSFileManager Get Attributes of File Error: %@", getAttributesError);
        }
    }
    else {
        NSNumber *fileSizeNumber = attributes[NSFileSize];
        if ([fileSizeNumber respondsToSelector:@selector(longLongValue)]) {
            fileSize = fileSizeNumber.longLongValue;
        }
    }
    
    return fileSize;
}

@end
