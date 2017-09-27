//
//  CMTClient+shareTheme.h
//  MedicalForum
//
//  Created by Bo Shen on 15/4/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (shareTheme)

- (RACSignal *)shareTheme:(NSDictionary *)parameters;

@end
