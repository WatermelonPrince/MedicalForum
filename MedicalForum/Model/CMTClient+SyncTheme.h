//
//  CMTClient+SyncTheme.h
//  MedicalForum
//
//  Created by Bo Shen on 15/4/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (SyncTheme)

- (RACSignal *)syncTheme:(NSDictionary *)parameters;

@end
