//
//  CMTClient+GetPostByDepart.h
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(GetPostByDepart)

- (RACSignal *)getPostByDepart:(NSDictionary *)parameters;

@end
