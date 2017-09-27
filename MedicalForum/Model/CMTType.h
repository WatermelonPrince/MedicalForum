//
//  CMTType.h
//  MedicalForum
//  返回的文章类型
//  Created by Bo Shen on 15/1/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTType : CMTObject
//postTypeId	类型ID
@property(nonatomic, copy, readonly) NSString *postTypeId;
//postType	类型名称
@property(nonatomic, copy, readonly) NSString *postType;
//postUrl	图片网址
@property(nonatomic, copy, readonly) NSString *iconUrl;

@end
