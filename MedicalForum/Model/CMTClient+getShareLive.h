//
//  CMTClient+getShareLive.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(getShareLive)
- (RACSignal *)getShareLive:(NSDictionary *)parameters;
@end
