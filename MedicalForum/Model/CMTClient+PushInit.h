//
//  CMTClient+PushInit.h
//  MedicalForum
//
//  Created by CMT on 15/6/18.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+PushInit.h"
@interface CMTClient(PushInit)
- (RACSignal *)getPushInit:(NSDictionary *)parameters;
@end
