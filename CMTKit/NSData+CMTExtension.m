//
//  NSData+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 15/4/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSData+CMTExtension.h"

@implementation NSData (CMTExtension)

- (BOOL)writeToFileAtPath:(NSString *)path withDirectoryPath:(NSString *)directoryPath overWriting:(BOOL)overWriting {
    if (self == nil || BEMPTY(path) || BEMPTY(directoryPath)) {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 文件存在 且不重写
    if ([fileManager fileExistsAtPath:path] && overWriting == NO) {
        return YES;
    }
    
    // 创建文件夹
    if (![fileManager fileExistsAtPath:directoryPath]) {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    // 写入文件
    return [fileManager createFileAtPath:path contents:self attributes:nil];
}

@end
