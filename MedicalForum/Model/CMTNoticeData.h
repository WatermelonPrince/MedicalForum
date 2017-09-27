//
//  CMTNoticeData.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTNoticeData : CMTObject
//消息列表
@property(nonatomic,copy,readwrite)NSArray *items;
//消息数目
@property(nonatomic,copy,readwrite)NSString *noticeCount;
@end
