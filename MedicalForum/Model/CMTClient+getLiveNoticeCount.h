//
//  CMTClient+getLiveNoticeCount.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(getLiveNoticeCount)
///直播通知数
- (RACSignal *)getLiveNoticeCount:(NSDictionary *)parameters;
@end
