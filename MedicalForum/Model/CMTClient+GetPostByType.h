//
//  CMTClient+GetPostByType.h
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(GetPostByType)

- (RACSignal *)getPostByType:(NSDictionary *)parameters;

@end
