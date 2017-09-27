//
//  CMTPostByDepart.h
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTPostByDepart : CMTObject

//subjectId	科室ID
@property(nonatomic, copy, readwrite) NSString *subjectId;
//subject	科室名称
@property(nonatomic, copy, readonly) NSString *subject;
//items	文章		list
@property(nonatomic, copy, readonly) NSArray *items;

@end
