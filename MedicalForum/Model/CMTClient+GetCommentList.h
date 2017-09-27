//
//  CMTClient+GetCommentList.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient(GetCommentList)

-(RACSignal *) getCommentList: (NSDictionary *) parameters;
@end
