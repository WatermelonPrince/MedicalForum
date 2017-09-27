//
//  CMTClient+Concern.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//
//  
//

#import "CMTClient.h"

@interface CMTClient(Concern)
-(RACSignal *) fetchConcern:(NSDictionary *) parameters;
@end
