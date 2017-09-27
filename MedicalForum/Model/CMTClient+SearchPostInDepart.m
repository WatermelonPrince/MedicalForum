//
//  CMTClient+SearchPostInDepart.m
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+SearchPostInDepart.h"
#import "CMTPost.h"

@implementation CMTClient(SearchPostInDepart)

-(RACSignal *) searchPostInDepart: (NSDictionary *) parameters {
    
    return [self POST:@"app/search/post/the_subject.json" parameters:parameters resultClass:[CMTPost class] withStore:NO];
    
}

@end
