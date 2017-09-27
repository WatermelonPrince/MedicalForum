//
//  CMTClient+Private.h
//  MedicalForum
//
//  Created by fenglei on 14/11/19.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient ()

// Opens the specified URL in its preferred application.
//
// Returns whether the URL was opened successfully.
+ (BOOL)openURL:(NSURL *)URL;

// Enqueues a request that will not automatically parse results.

// Returns a signal which will send tuples for each response, containing the
// `NSHTTPURLResponse` and response object (the type of which will be determined
// by AFNetworking), then complete. If an error occurs at any point, the
// returned signal will send it immediately, then terminate.
- (RACSignal *)enqueueRequest:(NSURLRequest *)request;

// Enqueues a request to be sent to the server.

// Returns a signal which will send an instance of `CMTResponse` for each parsed
// JSON object, then complete. If an error occurs at any point, the returned
// signal will send it immediately, then terminate.
- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass;

// Create a NSMutableURLRequest to enqueues, and store the parsedResult if 'witStore' is YES

// Returns the signal returned from -enqueueRequest:resultClass:
- (RACSignal *)enqueueRequestWithMethod:(NSString *)method
                              URLString:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                            resultClass:(Class)resultClass
                              withStore:(BOOL)withStore
                               filePath:(NSString *)filePath;

// Fetch the parsedResult from store if 'witStore' is YES, otherwise Create a NSMutableURLRequest to enqueues

// Returns the signal with stored parsedResult or return the signal returned from -enqueueRequestWithMethod:URLString:parameters:resultClass:withStore:
- (RACSignal *)fetchRequestWithMethod:(NSString *)method
                            URLString:(NSString *)URLString
                           parameters:(NSDictionary *)parameters
                          resultClass:(Class)resultClass
                            withStore:(BOOL)withStore;

@end

