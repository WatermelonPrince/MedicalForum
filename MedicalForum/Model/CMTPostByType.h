//
//  CMTPostByType.h
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTPostByType : CMTObject

//postTypeId	类型ID
@property(nonatomic, copy, readwrite) NSString *postTypeId;
//postType	类型名称
@property(nonatomic, copy, readwrite) NSString *postType;
//items	文章		list
@property(nonatomic, copy, readwrite) NSArray *items;

@end
