//
//  NSArray+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 15/8/7.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSArray+CMTExtension.h"

@implementation NSArray (CMTExtension)

- (NSArray *)componentsOfValueForKey:(NSString *)key {
    NSMutableArray *componentsArray = [NSMutableArray array];
    SEL selectorOfKey = NSSelectorFromString(key);
    
    @try {
        for (id component in self) {
            if ([component respondsToSelector:selectorOfKey]) {
                id value = [component valueForKey:key];
                if (value != nil) {
                    [componentsArray addObject:value];
                }
            }
        }
    }
    @catch (NSException *exception) {
        componentsArray = nil;
        CMTLogError(@"NSArray Map ValueForKey Exception: %@", exception);
    }
    
    return componentsArray;
}


@end
