//
//  CMTAuthor.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTAuthor : CMTObject

// authorId	作者ID
@property(nonatomic, copy, readonly) NSString *authorId;
// picture	头像		string
@property(nonatomic, copy, readonly) NSString *picture;
// nickname	作者名称		string
@property(nonatomic, copy, readonly) NSString *nickname;
// description	描述
@property(nonatomic, copy, readonly) NSString *authorDescription;
/// 文章数
@property (assign) int postCount;

@end
