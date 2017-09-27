//
//  NSFileManager+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 15/4/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (CMTExtension)

/// 获取指定文件路径的文件大小(字节) 文件不存在或发生错误 返回0
- (long long)fileSizeOfItemAtPath:(NSString *)path;

@end
