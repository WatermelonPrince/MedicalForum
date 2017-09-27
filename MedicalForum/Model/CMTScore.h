//
//  CMTScore.h
//  MedicalForum
//
//  Created by jiahongfei on 15/7/29.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTScore : CMTObject

//积分文案 	积分文案 	string
@property(nonatomic,copy,readwrite)NSString *content;
//	积分数 	可能为负数 	int
@property(nonatomic,copy,readwrite)NSString *score ;
/// 	创建时间 	创建时间 	long
@property(nonatomic,copy,readwrite)NSString *createTime;
// 	翻页ID 	翻页ID 	long
@property(nonatomic,copy,readwrite)NSString *incrId;
// 认证状态
@property(nonatomic,copy,readwrite)NSString *authStatus;



@end
