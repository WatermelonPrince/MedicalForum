//
//  CMTClient+CommonShare.h
//  MedicalForum
//
//  Created by jiahongfei on 15/9/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (CommonShare)

///78业务分享接口
- (RACSignal *)commonShare:(NSDictionary *)parameters;


//阅读码绑定

- (RACSignal *)readCodeBlind:(NSDictionary *)parameters;



@end
