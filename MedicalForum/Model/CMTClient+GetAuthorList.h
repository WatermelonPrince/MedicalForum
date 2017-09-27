//
//  CMTClient+GetAuthorList.h
//  MedicalForum
//
//  Created by Bo Shen on 15/3/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (GetAuthorList)
-(RACSignal *) getAuthorList:(NSDictionary *)parameters;

@end
