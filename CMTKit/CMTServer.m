//
//  CMTServer.m
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTServer.h"
#import "CMTServer+Private.h"

NSString * const CMTServerMedicalForumDebugServerBaseURL =  @"https://apps.medtrib.cn/";//@"https://admins.medtrib.cn/";
NSString * const CMTServerMedicalForumReleaseServerBaseURL = @"https://apps.medtrib.cn/";
//// 发布版本要使用域名 不能使用IP地址
//NSString * const CMTServerMedicalForumReleaseServerBaseURL = @"http://topdr.test.medtrib.cn/";

@interface CMTServer ()

@property (nonatomic, copy, readwrite) NSURL *baseURL;

@end

@implementation CMTServer

#pragma mark Lifecycle

+ (instancetype)debugServer {
    static CMTServer *debugServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        debugServer = [[self alloc] initWithBaseURL:[NSURL URLWithString:CMTServerMedicalForumDebugServerBaseURL]];
    });
    
    return debugServer;
}

+ (instancetype)releaseServer {
    static CMTServer *releaseServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        releaseServer = [[self alloc] initWithBaseURL:[NSURL URLWithString:CMTServerMedicalForumReleaseServerBaseURL]];
    });
    
    return releaseServer;
}

+ (instancetype)serverWithBaseURL:(NSURL *)baseURL {
    if (baseURL == nil) return [self releaseServer];
    
    return [[CMTServer alloc] initWithBaseURL:baseURL];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    self = [super init];
    if (self == nil) return nil;
    
    _baseURL = baseURL;
    
    return self;
}

@end
