//
//  CMTProvince.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTCity : CMTObject

// 城市ID
@property(nonatomic, copy, readwrite) NSString *cityCode;
@property(nonatomic, copy, readwrite) NSString *cityid;

// 城市名称
@property(nonatomic, copy, readwrite) NSString *cityName;
@property(nonatomic, copy, readwrite) NSString *city;

@property (strong, nonatomic)NSArray *hospital_list;
@property (strong, nonatomic)NSArray *areas;

@end

@interface CMTProvince : CMTObject

// 省ID
@property(nonatomic, copy, readwrite) NSString *provCode;
@property(nonatomic, copy, readwrite) NSString *provinceid;
// 省名称
@property(nonatomic, copy, readwrite) NSString *provName;
@property(nonatomic, copy, readwrite) NSString *province;

// 城市列表
@property(nonatomic, copy, readwrite) NSArray *cities;

@end
@interface CMTHospital : CMTObject

// 医院ID
@property(nonatomic, copy, readwrite) NSString *hospitalId;
// 医院名称
@property(nonatomic, copy, readwrite) NSString *hospital;

@end
@interface CMTDetailHosptial : CMTObject

@property (copy, nonatomic) NSString *provCode;
@property (copy, nonatomic) NSString *provName;
@property (copy, nonatomic) NSString *cityCode;
@property (copy, nonatomic) NSString *cityName;
@property (copy, nonatomic) NSString *hosptialId;
@property (copy, nonatomic) NSString *hosptialName;

@end
@interface CMTSubDepart : CMTObject

//一级学科ID
@property(nonatomic,strong) NSString *departId;
// 二级学科ID
@property(nonatomic, copy, readonly) NSString *subDepartId;
// 二级学科名称
@property(nonatomic, copy, readonly) NSString *subDepartment;

@end
@interface CMTDepart : CMTObject

// 学科ID
@property(nonatomic,strong) NSString *departId;
// 学科名称
@property(nonatomic, copy, readonly) NSString *department;
// 二级学科
@property(nonatomic, copy, readonly) NSArray *subDeparts;

@end


