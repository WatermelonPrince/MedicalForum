//
//  NSArray+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 15/8/7.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CMTExtension)

/// 遍历数组元素 调用-valueForKey:
/// 返回所有value构成的数组
/// 出错则返回nil
- (NSArray *)componentsOfValueForKey:(NSString *)key;

@end
