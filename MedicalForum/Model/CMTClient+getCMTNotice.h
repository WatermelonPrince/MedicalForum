//
//  CMTClient+getCMTNotice.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getCMTNotice.h"

@interface CMTClient(getCMTNotice)
- (RACSignal *)getCMTNotice:(NSDictionary *)parameters;
@end
