//
//  CMTClient+.h
//  MedicalForum
//
//  Created by CMT on 15/6/12.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+FollowDisease.h"

@interface CMTClient(FollowDisease)
- (RACSignal *)FollowDisease:(NSDictionary *)parameters;
@end
