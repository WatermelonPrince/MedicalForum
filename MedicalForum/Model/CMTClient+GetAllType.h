//
//  CMTClient+GetAllType.h
//  MedicalForum
//
//  Created by Bo Shen on 15/1/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"


@interface CMTClient (GetAllType)

- (RACSignal *)getallTypes:(NSDictionary *)parameters;

@end
