//
//  CMTClient+VerifyAuthCode.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//
//  验证码登录接口
//

#import "CMTClient.h"

@interface CMTClient(LoginInterface)
// 3 获取登录验证码接口
- (RACSignal *)getAuthCode:(NSDictionary *) parameters;
//4  登陆接口
- (RACSignal *)verifyAuthCode:(NSDictionary *) parameters;
//138退出登录
- (RACSignal *)logout:(NSDictionary *) parameters;
//5 修改用户信息
- (RACSignal *) modifyPicture:(NSDictionary *) parameters;
//6 获取用户信息
- (RACSignal *) getUserInfo:(NSDictionary *) parameters;
//7 升级认证用户接口
-(RACSignal *) promoteVip:(NSDictionary *) parameters;
//149 保存用户收货地址
-(RACSignal *)saveShippingaddress:(NSDictionary *) parameters;


@end
