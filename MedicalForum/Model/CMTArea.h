//
//  CMTArea.h
//  MedicalForum
//
//  Created by zhaohuan on 2017/4/13.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTArea : CMTObject

// 区域ID
@property(nonatomic, copy, readwrite) NSString *areaid;

// 区域名称
@property(nonatomic, copy, readwrite) NSString *area;


@end
