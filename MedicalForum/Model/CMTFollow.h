//
//  CMTFollow.h
//  MedicalForum
//
//  Created by guanyx on 14/12/12.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"
@interface CMTFollow : CMTObject

//departId	科室ID
@property (nonatomic, copy, readwrite) NSString *subjectId;
//department	科室名称
@property (nonatomic, copy, readonly) NSString *subject;
//opTime	操作时间	unix时间戳
@property (nonatomic, copy, readonly) NSString *opTime;

@end

@interface CMTReceiverAddress : CMTObject

//收货地址ID
@property (nonatomic, copy) NSString *addressId;

@property (nonatomic, copy) NSString *receiveUser;//收货人
@property (nonatomic, copy) NSString *email;//邮箱
@property (nonatomic, copy) NSString *cellphone;//收货人手机号

@property (nonatomic, copy) NSString *provinceid;//省ID

@property (nonatomic, copy) NSString *province;//省

@property (nonatomic, copy) NSString *cityid;//市ID

@property (nonatomic, copy) NSString *city;//市

@property (nonatomic, copy) NSString *areaid;//区ID
@property (nonatomic, copy) NSString *area;//区
@property (nonatomic, copy) NSString *address;//详细地址




@end
