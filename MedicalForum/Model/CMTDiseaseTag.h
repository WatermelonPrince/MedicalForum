//
//  CMTDiseaseTag.h
//  MedicalForum
//
//  Created by fenglei on 15/6/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

/// 疾病标签
@interface CMTDiseaseTag : CMTObject

/// diseaseId   疾病id    int
@property (nonatomic, copy, readonly) NSString *diseaseId;
/// disease 疾病名称    string
@property (nonatomic, copy, readonly) NSString *disease;
/// level   级别  int
/// 指南区分主次，0为主标签 1.次标签
@property (nonatomic, copy, readonly) NSString *level;

@end
