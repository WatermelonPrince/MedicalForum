//
//  NSNumber+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 15/6/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (CMTExtension)

/// 是否为真 非零
- (BOOL)isTrue;
/// 是否为假 零
- (BOOL)isFalse;

@end
