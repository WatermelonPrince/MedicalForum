//
//  CMTAuthor.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTAuthor.h"

@implementation CMTAuthor

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"authorDescription": @"description",
             };
}

@end
