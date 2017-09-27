//
//  NSData+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 15/4/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CMTExtension)

/// 在指定文件夹 指定文件路径(包括文件名及后缀) 写入二进制文件
/// 如果写入成功 返回YES, 否则 返回NO
- (BOOL)writeToFileAtPath:(NSString *)path withDirectoryPath:(NSString *)directoryPath overWriting:(BOOL)overWriting;

@end
