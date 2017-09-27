//
//  CMTClient.h
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@class CMTServer;

/// 请求状态信息
typedef NSString * CMTClientRequestStatusInfo;
FOUNDATION_EXPORT NSString * const CMTClientRequestStatusInfoSent;                      // CMTClientRequestStatusInfoSent
FOUNDATION_EXPORT NSString * const CMTClientRequestStatusInfoFinish;                    // CMTClientRequestStatusInfoFinish
FOUNDATION_EXPORT NSString * const CMTClientRequestStatusInfoEmpty;                     // CMTClientRequestStatusInfoEmpty
FOUNDATION_EXPORT NSString * const CMTClientRequestStatusInfoEmptyLatest;               // CMTClientRequestStatusInfoEmptyLatest
FOUNDATION_EXPORT NSString * const CMTClientRequestStatusInfoEmptyNoMore;               // CMTClientRequestStatusInfoEmptyNoMore
FOUNDATION_EXPORT NSString * const CMTClientRequestStatusInfoNetError;                  // CMTClientRequestStatusInfoNetError
FOUNDATION_EXPORT NSString * const CMTClientRequestStatusInfoServerError;               // @"CMTClientRequestStatusInfoServerError: "
FOUNDATION_EXPORT NSString * const CMTClientRequestStatusInfoSystemError;               // @"CMTClientRequestStatusInfoSystemError: "

@interface NSString (CMTClient)
/// 解析请求状态信息中服务器错误信息
/// 如果没有服务器错误信息 返回nil
- (NSString *)serverErrorMessage;
/// 解析请求状态信息中系统错误信息
/// 如果没有系统错误信息 返回nil
- (NSString *)systemErrorMessage;
@end

/// 服务器错误域
FOUNDATION_EXPORT NSString * const CMTClientServerErrorDomain;                  // CMTClientServerErrorDomain
FOUNDATION_EXPORT NSString * const CMTClientServerErrorCodeKey;                 // errcode
FOUNDATION_EXPORT NSString * const CMTClientServerErrorUserInfoMessageKey;      // errmsg
FOUNDATION_EXPORT NSString * const CMTClientErrorDomain;                        // CMTClientErrorDomain

/// 刷新形式
typedef NS_ENUM(NSUInteger, CMTClientRequestMode) {
    CMTClientRequestModeUndefined = 0,      // 默认未定义
    CMTClientRequestModeReset,              // 重置 强制请求最新30条并覆盖旧缓存
    CMTClientRequestModeRefresh,            // 刷新 请求最新
    CMTClientRequestModeLoadMore,           // 翻页 加载更多
};

@interface CMTClient : AFHTTPSessionManager

/// Creates and Initializes the receiver to make requests to the given server.
/// This is the designated constructors for this class.
+ (instancetype)clientWithServer:(CMTServer *)server;

/// Returns the default client instance
+ (instancetype)defaultClient;

/// Change Client Server between debugServer and releaseServer
+ (instancetype)changeClientServer;

@end

@interface CMTClient (Requests)

/// Creates and Enqueues a mutable URL request to be sent to the server.

/// Returns a signal which will send an instance or an array of `CMTObject class cluster` for each parsed
/// JSON object, then complete. If an error occurs at any point, the returned
/// signal will send it immediately, then terminate.

/// Request with GET method
- (RACSignal *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters resultClass:(Class)resultClass withStore:(BOOL)withStore;

/// Request with POST method
- (RACSignal *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters resultClass:(Class)resultClass withStore:(BOOL)withStore;

/// Request with POST method with MultipartFormData
- (RACSignal *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters resultClass:(Class)resultClass
          dataBlock:(void (^)(id <AFMultipartFormData> formData))dataBlock;

@end
