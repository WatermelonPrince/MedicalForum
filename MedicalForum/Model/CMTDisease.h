//
//  CMTDisease.h
//  MedicalForum
//
//  Created by CMT on 15/6/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTDisease : CMTObject
@property(nonatomic,strong)NSString *diseaseId;
@property(nonatomic,strong)NSString *disease;
@property(nonatomic,strong)NSString *opTime;
@property(nonatomic,strong)NSString *count;
@property(nonatomic,strong)NSString *postCount;
@property(nonatomic,strong)NSString *caseCout;
@property(nonatomic,strong)NSString *readTime;
@property(nonatomic,strong)NSString *postReadtime;
@property(nonatomic,strong)NSString *caseReadtime;
@end
