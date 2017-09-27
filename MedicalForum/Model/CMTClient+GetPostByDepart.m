//
//  CMTClient+GetPostByDepart.m
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+GetPostByDepart.h"
#import "CMTPostByDepart.h"

@implementation CMTClient(GetPostByDepart)

- (RACSignal *)getPostByDepart:(NSDictionary *)parameters {
    
    return [self POST:@"app/search/post/subjects.json" parameters:parameters resultClass:[CMTPostByDepart class] withStore:NO];
    
}

@end
