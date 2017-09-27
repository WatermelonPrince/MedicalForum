//
//  CMTClient+getCasePostLIst.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+getCasePostLIst.h"

@interface CMTClient(getCasePostLIst)
- (RACSignal *)getCasePostLIst:(NSDictionary *)parameters;
@end
