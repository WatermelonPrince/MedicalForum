//
//  NSNumber+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 15/6/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSNumber+CMTExtension.h"

@implementation NSNumber (CMTExtension)

- (BOOL)isTrue {
    return self.boolValue == YES;
}

- (BOOL)isFalse {
    return self.boolValue == NO;
}

@end
