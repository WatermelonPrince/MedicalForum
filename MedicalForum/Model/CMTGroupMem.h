//
//  CMTGroupMem.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTGroupMem : CMTObject
//用户ID
@property(nonatomic,strong)NSString *userId;
//用户头像路径
@property(nonatomic,strong)NSString *picture;
//用户名称
@property(nonatomic,strong)NSString *nickname;
//用户类型
@property(nonatomic,strong)NSString *userType;
//自增ID
@property(nonatomic,strong)NSString *incrId;
@end
