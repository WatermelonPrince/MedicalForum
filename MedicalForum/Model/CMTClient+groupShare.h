//
//  CMTClient+groupShare.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/29.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+groupShare.h"

@interface CMTClient(groupShare)
- (RACSignal *)groupShare:(NSDictionary *)parameters;
@end
