//
//  CMTClient+getParticipators.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(getParticipators)
- (RACSignal *)getParticipatorsList:(NSDictionary *)parameters;
@end
