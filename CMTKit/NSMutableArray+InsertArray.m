//
//  NSMutableArray+InsertArray.m
//  MedicalForum
//
//  Created by jiahongfei on 15/8/24.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSMutableArray+InsertArray.h"

@implementation NSMutableArray (InsertArray)

- (void)insertArray:(NSArray *)newAdditions atIndex:(NSUInteger)index{
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for(NSUInteger i = index;i < newAdditions.count+index;i++){
        [indexes addIndex:i];
    }
    [self insertObjects:newAdditions atIndexes:indexes];
}

@end
