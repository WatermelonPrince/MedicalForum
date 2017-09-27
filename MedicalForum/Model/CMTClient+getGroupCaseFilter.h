//
//  CMTClient+groupCaseFilter.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/10/9.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(getGroupCaseFilter)
- (RACSignal *)getGroupCaseFilter:(NSDictionary *)parameters;
- (RACSignal *)search_post:(NSDictionary *)parameters;
@end
