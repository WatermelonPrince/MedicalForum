//
//  CMTOpTime.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTConcern : CMTObject


// subjectId	学科ID
@property(nonatomic, copy, readwrite) NSString *subjectId;
// subject	学科名称		string
@property(nonatomic, copy, readwrite) NSString *subject;
// 服务端保存时间
@property(nonatomic, copy) NSString *opTime;

// concernFlag	是否订阅	0 未订阅；1 已订阅	int
@property(nonatomic, copy, readwrite) NSString *concernFlag;
// authors	作者列表
@property(nonatomic, copy, readwrite) NSArray *authors;

@property(nonatomic, copy, readwrite) NSString *CMT_selected;


@end
