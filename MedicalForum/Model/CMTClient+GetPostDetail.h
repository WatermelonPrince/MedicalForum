//
//  CMTClient+GetPostDetail.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (GetPostDetail)

- (RACSignal *)getPostDetail:(NSDictionary *)parameters;
- (RACSignal *)set_Post_top:(NSDictionary *)parameters;
- (RACSignal *)Details_update:(NSDictionary *)parameters;
@end
