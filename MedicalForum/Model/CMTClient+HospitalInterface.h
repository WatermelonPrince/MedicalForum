//
//  CMTClient+GetCity.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//
//  获取医院城市接口
//

#import "CMTClient.h"

@interface CMTClient(HospitalInterface)
//8 获取医院城市
- (RACSignal *) getCity;
//获取全部医院列表接口
-(RACSignal *) getAllHospital:(NSDictionary *) parameters;
//9 根据城市获取医院列表接口
-(RACSignal *) getHospital:(NSDictionary *) parameters;
//10 获取科室列表接口
-(RACSignal *) getDepart;
//150获取全部省市县接口
-(RACSignal *) getAllAreas:(NSDictionary *) parameters;


@end
