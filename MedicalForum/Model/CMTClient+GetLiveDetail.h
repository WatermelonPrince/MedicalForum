//
//  CMTClient+GetLiveDetail.h
//  MedicalForum
//
//  Created by fenglei on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (GetLiveDetail)

- (RACSignal *)getLiveDetail:(NSDictionary *)parameters;

@end
