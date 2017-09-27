//
//  CMTServer.h
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMTServer : NSObject

/// The base URL to the instance associated with this server
@property (nonatomic, copy, readonly) NSURL *baseURL;

/// Returns the debug server instance
+ (instancetype)debugServer;

/// Returns the release server instance
+ (instancetype)releaseServer;

/// Returns either the server instance for a given base URL,
/// or +releaseServer if `baseURL` is nil.
+ (instancetype)serverWithBaseURL:(NSURL *)baseURL;

@end
