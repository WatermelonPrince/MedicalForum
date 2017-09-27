//
//  CMTPlayAndRecordList.h
//  MedicalForum
//
//  Created by zhaohuan on 16/6/2.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTPlayAndRecordList : CMTObject
@property (nonatomic, strong)NSArray *lives;
@property (nonatomic, copy)NSString *sysDate;

@property (nonatomic, strong)NSArray *focuslist;
@property (nonatomic, strong)NSArray *colleges;
@property (nonatomic, strong)NSArray *revideos;
@property (nonatomic, strong)NSArray *serieses;
@property (nonatomic, strong)NSArray *videos;//2.6.0新增节点

@property (nonatomic, strong)NSArray *storeData;//2.6.3 课程存储
@property (nonatomic, strong)NSString *totalNum;//收藏总数;

@property (nonatomic, strong)NSArray *advers;//2.6.3 广告数组



@end
