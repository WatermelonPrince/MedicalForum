//
//  CMTClient+GetAuthorList.m
//  MedicalForum
//
//  Created by Bo Shen on 15/3/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GetAuthorList.h"
#import "CMTAuthor.h"

@implementation CMTClient (GetAuthorList)

-(RACSignal *) getAuthorList:(NSDictionary *)parameters
{
    return [self GET:@"app/subject/author_list.json" parameters:parameters resultClass:[CMTAuthor class] withStore:NO];
}

@end
