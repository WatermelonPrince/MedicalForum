//
//  CMTClient+SendLiveComment.h
//  MedicalForum
//
//  Created by fenglei on 15/9/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (SendLiveComment)

- (RACSignal *)sendLiveComment:(NSDictionary *)parameters;

@end
