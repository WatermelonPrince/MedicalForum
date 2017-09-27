//
//  CMTClient+Praise.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(Praise)
- (RACSignal *)Praise:(NSDictionary *)parameters;
@end
