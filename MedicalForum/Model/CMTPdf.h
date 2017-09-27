//
//  CMTPdf.h
//  MedicalForum
//
//  Created by fenglei on 15/4/13.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTPdf : CMTObject

/// fileUrl 文件url   string
@property (nonatomic, copy, readonly) NSString *fileUrl;
/// contentLength   文件长度    单位字节    long
@property (nonatomic, copy, readonly) NSString *contentLength;
/// originalFilename 文件名称   string
@property (nonatomic, copy, readonly) NSString *originalFilename;

@end
