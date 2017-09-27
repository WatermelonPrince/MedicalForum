//
//  CMTSubject.h
//  MedicalForum
//
//  Created by Bo Shen on 15/3/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTSubject : CMTObject

@property (strong, nonatomic) NSString *subjectId;
@property (strong, nonatomic) NSString *subject;

// 服务端保存时间
@property(nonatomic, copy) NSString *opTime;

// concernFlag	是否订阅	0 未订阅；1 已订阅	int
@property(nonatomic, copy, readwrite) NSString *concernFlag;
//图片
@property(nonatomic,copy,readwrite)NSString *headPic;
//地址
@property(nonatomic,copy,readwrite)NSString *url;
//期号
@property (nonatomic, copy)NSString *issueNo;

@end
