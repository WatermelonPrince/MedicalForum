//
//  CMTUser.h
//  MedicalForum
//
//  Created by fenglei on 14/12/17.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTUserInfo.h"

@interface CMTUser : CMTObject

/// 登陆时赋值YES, 退出时赋值NO.
@property (nonatomic, assign) BOOL login;
/// 登陆时赋值, 退出时可以不赋值为nil,
/// login被赋值为NO时userInfo会被赋值为nil,
/// login值为NO时userInfo赋值被禁止.
@property (nonatomic, copy) CMTUserInfo *userInfo;

/// 点击首页的"添加订阅"按钮时设置,
/// 不跟随用户切换而改变.
@property (nonatomic, assign) BOOL subscription;
//上传学科成功
@property (nonatomic, assign) BOOL SysSubjectSuccess;

/// Returns the default user instance.
+ (instancetype)defaultUser;

/// ReInit the default user instance,
/// if success, return YES (defaultUser and userInfo are not nil),
/// or return NO (defaultUser is nil),
+ (BOOL)clearDefaultUser;

/// Archiving User object to Store.
- (BOOL)save;

/// Returns a signal that sends RACTuple of the User's login state and userInfo,
/// whenever login happened. i.e. 'login' property change value from NO to YES,
/// and 'userInfo' property setted to non-null value.
- (RACSignal *)loginSignal;

/// Returns a signal that sends RACTuple of the User's login state and userInfo,
/// whenever logout happened. i.e. 'login' property change value from YES to NO.
- (RACSignal *)logoutSignal;

/// Returns a signal that sends the User's subscription List,
/// whenever UserInfo's 'follows' property changes.
- (RACSignal *)subscriptionChangeSignal;

/// Returns a signal that sends the User's authentication status,
/// whenever UserInfo's 'authStatus' property changes.
- (RACSignal *)authStatusChangeSignal;

@end
