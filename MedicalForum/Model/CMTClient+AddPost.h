//
//  CMTClient+AddPost.h
//  MedicalForum
//
//  Created by fenglei on 15/8/4.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (AddPost)

/// 63. 追加描述/添加结论接口
- (RACSignal *)addPostAdditional:(NSDictionary *)parameters;

/// 65. 发表病例接口
- (RACSignal *)addPost:(NSDictionary *)parameters;

///// 81 发布直播消息接口
- (RACSignal *)addLivemessage:(NSDictionary *)parameters;
@end
