//
//  CMTParticiPators.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTParticiPators : CMTObject
//用户id
@property(nonatomic,strong)NSString *userId;
//名称
@property(nonatomic,strong)NSString *nickname;
//头像
@property(nonatomic,strong)NSString *picture;
//操作时间
@property(nonatomic,strong)NSString *opTime;
//id
@property(nonatomic,strong)NSString *incrId;
//操作类型
@property(nonatomic,strong)NSString *opType;
//用户类型
@property(nonatomic,strong)NSString *userType;
//截取后的名字
@property (nonatomic,strong)NSString *subNickName;
@property (nonatomic,strong)NSString *memberGrade;//身份 0：群主，1:组长，2:组员



@end
