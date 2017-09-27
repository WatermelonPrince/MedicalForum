//
//  NSDictionary+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 14/12/9.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CMTExtension)

// 过滤value为空的键值对
- (instancetype)filtEmptyValue;

@end
