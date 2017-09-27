//
//  CMTCaseLIstData.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTGroup.h"
@interface CMTCaseLIstData : CMTObject
//所有病历列表
@property(nonatomic, strong)NSArray *groupCaselistArray;
//普通疾病列表
@property(nonatomic,strong)NSArray *diseaseList;
//置顶病例列表
@property (nonatomic, strong)NSArray *topDiseaseList;
//推荐小组
@property(nonatomic,strong)CMTGroup *groupInfo;

@end
