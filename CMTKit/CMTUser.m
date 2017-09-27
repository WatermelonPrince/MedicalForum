//
//  CMTUser.m
//  MedicalForum
//
//  Created by fenglei on 14/12/17.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTUser.h"
#import <objc/runtime.h>

@implementation CMTUser

static CMTUser *defaultUser = nil;

+ (instancetype)defaultUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_DEFAULTUSER]) {
            // to do unarchiveObjectWithFile 存在crash
            id cachedUser = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_DEFAULTUSER];
            if ([cachedUser isKindOfClass:[CMTUser class]]) {
                defaultUser = cachedUser;
            } else {
                CMTLogError(@"Cached User object is not an CMTUser: %@ at Path: %@", cachedUser, PATH_DEFAULTUSER);
            }
        }
        
        if (defaultUser == nil) {
            defaultUser = [self defaultInitUser];
        }
    });
    
    return defaultUser;
}

+ (instancetype)defaultInitUser {
    CMTUser *initUser = nil;
    @try {
        NSError *initUserError, *initUserInfoError;
        // 保证CMTUSER初始化时login及userInfo属性会初始化赋值
        initUser = [[self alloc] initWithDictionary:@{
                                                      @"login": @NO,
                                                      @"userInfo": [[CMTUserInfo alloc] init],
                                                      }
                                              error:&initUserError];
        if (initUserInfoError != nil) {
            initUser = nil;
            CMTLogError(@"USER Init UserInfo Error: %@", initUserInfoError);
        }
        if (initUserError != nil) {
            initUser = nil;
            CMTLogError(@"USER Init User Error: %@", initUserError);
        }
    }
    @catch (NSException *exception) {
        initUser = nil;
        CMTLogError(@"USER Init Exception: %@", exception);
    }
    
    return initUser;
}

+ (BOOL)clearDefaultUser {
    defaultUser = [self defaultInitUser];
    if (defaultUser == nil) {
        return NO;
    }
    
    return YES;
}

- (BOOL)save {
    if (self != nil) {
        @try {
            // 创建用户文件夹成功
            if (!BEMPTY(PATH_DEFAULTUSER)) {
                BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:PATH_DEFAULTUSER];
                if (success == NO) {
                    CMTLogError(@"Archiving User to Store Error");
                }
                
                return success;
            }
            // 创建用户文件夹失败
            else {
                CMTLogError(@"Archiving User Error: Create DEFAULTUSER FilePath Failed");
            }
        }
        @catch (NSException *exception) {
            CMTLogError(@"Archiving User Exception: %@", exception);
        }
    }
    
    return NO;
}

static void *CMTUSERUserInfoInitHandleKey = &CMTUSERUserInfoInitHandleKey;

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    
    // 初始化时 重设userInfo属性的初始化赋值标记
    @try {
        objc_setAssociatedObject(self, CMTUSERUserInfoInitHandleKey, @NO, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    @catch (NSException *exception) {
        CMTLogError(@"USER CLEAR LOGIN INIT HANDLE EXCEPTION: %@", exception);
    }
    
    return self;
}

- (void)setLogin:(BOOL)login {
    if (_login == login) return;
    
    // 退出登录时 先清空userInfo存储信息
    if (login == NO) {
        self.userInfo = [[CMTUserInfo alloc] initWithDictionary:@{} error:nil];
    }
    
    _login = login;
}

- (void)setUserInfo:(CMTUserInfo *)userInfo {
    if (_userInfo == userInfo) return;
    
    // 退出登录之后 userInfo 禁止赋值
    if (_login == NO) {
        // 排除login属性的初始化赋值
        @try {
            NSNumber *InitHandle = objc_getAssociatedObject(self, CMTUSERUserInfoInitHandleKey);
            if ([InitHandle boolValue] == YES) {
                return;
            }
        }
        @catch (NSException *exception) {
            CMTLogError(@"USER GET LOGIN INIT HANDLE EXCEPTION: %@", exception);
        }
    }
    
    // to do 验证这种判断是否存在bug
    if ([userInfo isKindOfClass:[CMTUserInfo class]]) {
        _userInfo = userInfo;
    }
    else {
        _userInfo = [[CMTUserInfo alloc] initWithDictionary:@{} error:nil];
    }
    
    // 设置初始化赋值标记
    @try {
        NSNumber *InitHandle = objc_getAssociatedObject(self, CMTUSERUserInfoInitHandleKey);
        if ([InitHandle boolValue] == NO) {
            objc_setAssociatedObject(self, CMTUSERUserInfoInitHandleKey, @YES, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"USER SET LOGIN INIT HANDLE EXCEPTION: %@", exception);
    }
}

- (RACSignal *)loginSignal {
    static RACSignal *loginSignal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @weakify(self);
        loginSignal = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            
            __block BOOL previousLogin = self.login;
            [RACObserve(self, login) subscribeNext:^(NSNumber *value) {
                BOOL login = [value boolValue];
                
                // login
                if (previousLogin == NO && login == YES) {
                    [subscriber sendNext:[NSNumber numberWithBool:login]];
                }
                
                previousLogin = login;
            }];
            
            return nil;
        }] combineLatestWith:[RACObserve(self, userInfo) distinctUntilChanged]] filter:^BOOL(RACTuple *tuple) {
            @strongify(self);
            
            BOOL login = self.login;
            CMTUserInfo *userInfo = tuple.second;
            
            // login With userInfo
            return (login == YES && userInfo.userId != nil);
        }];
    });
    
    return loginSignal;
}

- (RACSignal *)logoutSignal {
    static RACSignal *logoutSignal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @weakify(self);
        logoutSignal = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            
            __block BOOL previousLogin = self.login;
            [RACObserve(self, login) subscribeNext:^(NSNumber *value) {
                BOOL login = [value boolValue];
                
                // logout
                if (previousLogin == YES && login == NO) {
                    [subscriber sendNext:[NSNumber numberWithBool:login]];
                }
                
                previousLogin = login;
            }];
            
            return nil;
        }] combineLatestWith:[RACObserve(self, userInfo) distinctUntilChanged]] filter:^BOOL(RACTuple *tuple) {
            @strongify(self);
            
            BOOL login = self.login;
            CMTUserInfo *userInfo = tuple.second;
            
            // logout and clear userInfo
            return (login == NO && userInfo.userId == nil);
        }];
    });
    
    return logoutSignal;
}

// to do 潜在bug 有时取消订阅 但首页列表未刷新
- (RACSignal *)subscriptionChangeSignal {
    static RACSignal *subscriptionChangeSignal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @weakify(self);
        subscriptionChangeSignal = [[RACObserve(self, userInfo) ignore:nil] flattenMap:^RACStream *(id value) {
            @strongify(self);
            
            __block NSArray *previousFollows = [self.userInfo.follows copy];
            return [[[RACObserve(self.userInfo, follows) ignore:nil] distinctUntilChanged]
                    filter:^BOOL(NSArray *follows) {
                        
                        // change
                        BOOL change = NO;
                        @try {
                            change = ![previousFollows isEqualToArray:follows];
                            previousFollows = [follows copy];
                        }
                        @catch (NSException *exception) {
                            change = NO;
                            CMTLogError(@"USER -SubscriptionChange Compare Array Exception: %@", exception);
                        }
                        
                        return change;
                    }];
        }];
    });
    
    return subscriptionChangeSignal;
}

// to do bug: 状态改变无信号
- (RACSignal *)authStatusChangeSignal {
    static RACSignal *authStatusChangeSignal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @weakify(self);
        authStatusChangeSignal = [[RACObserve(self, userInfo) ignore:nil] flattenMap:^RACStream *(id value) {
            @strongify(self);
            
            __block NSString *previousAuthStatus = [self.userInfo.authStatus copy];
            return [[[RACObserve(self.userInfo, authStatus) ignore:nil] distinctUntilChanged]
                    filter:^BOOL(NSString *authStatus) {
                        
                        // change
                        BOOL change = NO;
                        @try {
                            change = ![previousAuthStatus isEqual:authStatus];
                            previousAuthStatus = [authStatus copy];
                        }
                        @catch (NSException *exception) {
                            change = NO;
                            CMTLogError(@"USER -AuthStatusChangeSignal Compare String Exception: %@", exception);
                        }
                        
                        return change;
                    }];
        }];
    });
    
    return authStatusChangeSignal;
}

@end
