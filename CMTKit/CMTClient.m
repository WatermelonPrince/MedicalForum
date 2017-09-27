//
//  CMTClient.m
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient.h"
#import "CMTClient+Private.h"
#import "CMTObject.h"
#import "CMTServer.h"

/* Request Status Info */

NSString * const CMTClientRequestStatusInfoSent = @"CMTClientRequestStatusInfoSent";
NSString * const CMTClientRequestStatusInfoFinish = @"CMTClientRequestInfoFinish";
NSString * const CMTClientRequestStatusInfoEmpty = @"CMTClientRequestStatusInfoEmpty";
NSString * const CMTClientRequestStatusInfoEmptyLatest = @"CMTClientRequestStatusInfoEmptyLatest";
NSString * const CMTClientRequestStatusInfoEmptyNoMore = @"CMTClientRequestStatusInfoEmptyNoMore";
NSString * const CMTClientRequestStatusInfoNetError = @"CMTClientRequestStatusInfoNetError";
NSString * const CMTClientRequestStatusInfoServerError = @"CMTClientRequestStatusInfoServerError: ";
NSString * const CMTClientRequestStatusInfoSystemError = @"CMTClientRequestStatusInfoSystemError: ";

@implementation NSString (CMTClient)
- (NSString *)serverErrorMessage {
    if ([self rangeOfString:CMTClientRequestStatusInfoServerError].length > 0) {
        return [self stringByReplacingOccurrencesOfString:CMTClientRequestStatusInfoServerError withString:@""];
    }
    return nil;
}
- (NSString *)systemErrorMessage {
    if ([self rangeOfString:CMTClientRequestStatusInfoSystemError].length > 0) {
        return [self stringByReplacingOccurrencesOfString:CMTClientRequestStatusInfoSystemError withString:@""];
    }
    return nil;
}
@end

/* Request */

static NSString * const CMTClientRequestUserAgentKey = @"User-Agent";
static NSString * const CMTClientRequestCMUserAgentKey = @"cmUserAgent";
static NSString * const CMTClientRequestReqUserIdKey = @"reqUserId";
static NSString * const CMTClientRequestGetuiClientIdKey = @"getuiClientId";
static NSString * const CMTClientRequestSysDateKey = @"sysDate";
static NSString * const CMTClientRequestSysImeiKey = @"sysImei";
static NSString * const CMTClientRequestSysSignKey = @"sysSign";
static NSString * const CMTClientRequestSysPublickey = @"gG2GgksqJPcQLXVTmbx7sxxnhO3Jgs";

/* Response */

typedef NS_ENUM(NSUInteger, CMTClientResponseStatus) {
    CMTClientResponseStatusSuccess = 0,
    CMTClientResponseStatusFailure,
    CMTClientResponseStatusEmptyResult,
};

static NSString * const CMTClientResponseStatusKey = @"status";
static NSString * const CMTClientResponseResultKey = @"result";

/* Result */

static NSString * const CMTClientResultEmptyForStatusEmpty = @"CMTClientResultEmptyForStatusEmpty";

/* Server Error */

NSString * const CMTClientServerErrorDomain = @"CMTClientServerErrorDomain";
NSString * const CMTClientServerErrorCodeKey = @"errcode";
NSString * const CMTClientServerErrorUserInfoMessageKey = @"errmsg";

/* Client Error */

NSString * const CMTClientErrorDomain = @"CMTClientErrorDomain";
static const NSInteger CMTClientErrorJSONParsingFailed = 1001;
static const NSInteger CMTClientErrorObjectArchivingFailed = 2001;
static const NSInteger CMTClientErrorObjectUnarchivingFailed = 2002;
static NSString * const CMTClientErrorUserInfoResponseResultKey = @"responseResult";

/* Error UserInfo */

static NSString * const CMTClientErrorUserInfoURLKey = @"URL";
static NSString * const CMTClientErrorUserInfoHTTPStatusCodeKey = @"HTTPStatusCode";

@implementation CMTClient

#pragma mark Lifecycle

+ (instancetype)manager {
    NSAssert(NO, @"%@ must be initialized using +clientWithServer:", [self class]);
    return nil;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    NSAssert(NO, @"%@ must be initialized using +clientWithServer:", [self class]);
    return nil;
}

- (instancetype)initWithServer:(CMTServer *)server {
    NSParameterAssert(server != nil);
    
    self = [super initWithBaseURL:server.baseURL ];
    if (self == nil) return nil;
    // Encoding
    self.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    self.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    
    // Header
    [self.requestSerializer setValue:USER_AGENT forHTTPHeaderField:CMTClientRequestUserAgentKey];
    [self.requestSerializer setValue:USER_AGENT forHTTPHeaderField:CMTClientRequestCMUserAgentKey];
    
    return self;
}

+ (instancetype)clientWithServer:(CMTServer *)server {
    NSParameterAssert(server != nil);
    
    return [[self alloc] initWithServer:server];
}

static CMTClient *defaultClient = nil;

+ (instancetype)defaultClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef DEBUG
        defaultClient = [self clientWithServer:[CMTServer debugServer]];
#else
        defaultClient = [self clientWithServer:[CMTServer releaseServer]];
#endif
    });
    
    return defaultClient;
}

+ (instancetype)changeClientServer {
    @try {
        NSURL *clientBaseURL = [[self defaultClient] baseURL];
        CMTServer *debugServer = [CMTServer debugServer];
        CMTServer *releaseServer = [CMTServer releaseServer];
        
        if ([clientBaseURL isEqual:debugServer.baseURL]) {
            defaultClient = [self clientWithServer:releaseServer];
            CMTLogDebug(@"CLIENT Change to Release Server");
        }
        else if ([clientBaseURL isEqual:releaseServer.baseURL]) {
            defaultClient = [self clientWithServer:debugServer];
            CMTLogDebug(@"CLIENT Change to Debug Server");
        }
        else {
#ifdef DEBUG
            defaultClient = [self clientWithServer:[CMTServer debugServer]];
#else
            defaultClient = [self clientWithServer:[CMTServer releaseServer]];
#endif
            CMTLogError(@"CLIENT Default Client BaseURL Error: %@\nClIENT change Server to %@",
                        clientBaseURL.absoluteString,
                        defaultClient.baseURL.absoluteString);
        }
    }
    @catch (NSException *exception) {
#ifdef DEBUG
        defaultClient = [self clientWithServer:[CMTServer debugServer]];
#else
        defaultClient = [self clientWithServer:[CMTServer releaseServer]];
#endif
        CMTLogError(@"CLIENT Change Server Exception: %@\nClIENT change Server to %@",
                    exception,
                    defaultClient.baseURL.absoluteString);
    }
    
    return defaultClient;
}

#pragma mark Authentication

+ (BOOL)openURL:(NSURL *)URL {
    NSParameterAssert(URL != nil);
    
    if ([UIApplication.sharedApplication canOpenURL:URL]) {
        [UIApplication.sharedApplication openURL:URL];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Request Creation

// Request with GET method
- (RACSignal *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters resultClass:(Class)resultClass withStore:(BOOL)withStore {
    return [self fetchRequestWithMethod:@"GET" URLString:URLString parameters:[parameters filtEmptyValue] resultClass:resultClass withStore:withStore];
}

// Request with POST method
- (RACSignal *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters resultClass:(Class)resultClass withStore:(BOOL)withStore {
    return [self fetchRequestWithMethod:@"POST" URLString:URLString parameters:[parameters filtEmptyValue] resultClass:resultClass withStore:withStore];
}

// Request with POST method with MultipartFormData
- (RACSignal *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters resultClass:(Class)resultClass
          dataBlock:(void (^)(id <AFMultipartFormData> formData))dataBlock {
    // userId 随登陆登出改变 不能在初始化时指定
    [self.requestSerializer setValue:CMTUSERINFO.userId ?: @"0" forHTTPHeaderField:CMTClientRequestReqUserIdKey];
    [self.requestSerializer setValue:CMTSOCIAL.clientId ?: @"" forHTTPHeaderField:CMTClientRequestGetuiClientIdKey];
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]
                                                                               parameters:[self parametersWithSysSign:[parameters filtEmptyValue]]
                                                                constructingBodyWithBlock:dataBlock
                                                                                    error:nil];
    CMTLog(@">>>>[POST]:\n%@", request.allHTTPHeaderFields);
    
    return [self
            enqueueRequest:request resultClass:resultClass];
}

// Fetch parsedResult from Store
- (RACSignal *)fetchRequestWithMethod:(NSString *)method
                            URLString:(NSString *)URLString
                           parameters:(NSDictionary *)parameters
                          resultClass:(Class)resultClass
                            withStore:(BOOL)withStore {
    NSString *queryString, *filePath;
    
    //添加clineID
    [self.requestSerializer setValue:CMTUSERINFO.userId ?: @"0" forHTTPHeaderField:CMTClientRequestReqUserIdKey];
    [self.requestSerializer setValue:CMTSOCIAL.clientId ?: @"" forHTTPHeaderField:CMTClientRequestGetuiClientIdKey];
    
    
    if (withStore) {
        NSError *error;
        // queryString不能包括 "/", 否则会导致路径错误
        queryString = [[self.requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:parameters error:&error].URL.absoluteString
                       stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        if (queryString == nil) {
            CMTLogError(@"Serialize QueryString Error: %@", error);
            
            return [self enqueueRequestWithMethod:method URLString:URLString parameters:parameters resultClass:resultClass withStore:NO filePath:nil];
        }
        filePath = [PATH_CACHES stringByAppendingPathComponent:queryString];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            return [self enqueueRequestWithMethod:method URLString:URLString parameters:parameters resultClass:resultClass withStore:YES filePath:filePath];
        }
        id parsedResult = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (parsedResult == nil) {
            CMTLogError(@"Unarchiving ParsedResult From Store Error: %@", [self archivingErrorWithFilePath:filePath unarchiving:YES]);
            
            return [self enqueueRequestWithMethod:method URLString:URLString parameters:parameters resultClass:resultClass withStore:YES filePath:filePath];
        } else {
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:parsedResult];
                [subscriber sendCompleted];
                return nil;
            }];
            
            return [signal setNameWithFormat:@"-fetchRequestWithStore: %@",filePath];
        }
    } else {
        
        return [self enqueueRequestWithMethod:method URLString:URLString parameters:parameters resultClass:resultClass withStore:NO filePath:nil];
    }
}

// Create NSMutableURLRequest
- (RACSignal *)enqueueRequestWithMethod:(NSString *)method
                              URLString:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                            resultClass:(Class)resultClass
                              withStore:(BOOL)withStore
                               filePath:(NSString *)filePath {
    
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method
                                                                   URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]
                                                                  parameters:[self parametersWithSysSign:parameters]
                                                                       error:nil];
    
    return [[self
             enqueueRequest:request resultClass:resultClass]
            doNext:^(id parsedResult) {
                if (withStore) {
                    if (![NSKeyedArchiver archiveRootObject:parsedResult toFile:filePath]) {
                        CMTLogError(@"archiving ParsedResult to Store Error: %@", [self archivingErrorWithFilePath:filePath unarchiving:NO]);
                    }
                }
            }];
}

#pragma mark Request Enqueuing

- (RACSignal *)enqueueRequest:(NSURLRequest *)request{
    __weak typeof(self) weakSelf = self;
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // Encoding
        NSURLSessionDataTask *task=[weakSelf dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                               if (error==nil) {
                                                   if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                       switch ([responseObject[CMTClientResponseStatusKey] integerValue]) {
                                                           case CMTClientResponseStatusSuccess: {
                                                               RACTuple *tuple = RACTuplePack(response, responseObject[CMTClientResponseResultKey]);
                                                               
                                                               [subscriber sendNext:tuple];
                                                               if ([responseObject description].length <= 50000) {
                                                                   CMTLog(@">>>>[Status Success] of Operation:\n%@\n<<<<[ResponseObject]:\n%@",response.URL, responseObject);
                                                               }
                                                               else {
                                                                   CMTLog(@">>>>[Status Success] of Operation:\n%@\n<<<<[ResponseObject]:\n\nOverstep limitation of Description, length: %ld",
                                                                          self, (unsigned long)[responseObject description].length);
                                                               }
                                                               [subscriber sendCompleted];
                                                           }
                                                               break;
                                                           case CMTClientResponseStatusFailure: {
                                                               NSError *error = [[weakSelf class] errorFromRequestOperation:response object:responseObject];
                                                               
                                                               CMTLogError(@">>>>[Status Failure] of Operation:\n%@\n<<<<[Error]:\n%@",response, error);
                                                               [subscriber sendError:error];
                                                           }
                                                               break;
                                                           case CMTClientResponseStatusEmptyResult: {
                                                               RACTuple *tuple = RACTuplePack(response, CMTClientResultEmptyForStatusEmpty);
                                                               
                                                               [subscriber sendNext:tuple];
                                                               CMTLog(@">>>>[Status Empty] of Operation:\n%@", response);
                                                               [subscriber sendCompleted];
                                                           }
                                                               break;
                                                           default:
                                                               break;
                                                       }
                                                   } else {
                                                       NSError *error = [self parsingErrorWithFailureReason:NSLocalizedString(@"Non NSDictionary ResponseObject", @"") fromJSON:responseObject andResponse:response];
                                                       
                                                       CMTLogError(@">>>>[Status UnDefined] of Operation:\n%@\n<<<<[Error]:\n%@",response.URL, error);
                                                       [subscriber sendError:error];
                                                   }
                                                   
                                               }else{
                                                   NSLog(@"error:%@", error);
                                                   [subscriber sendError:error];
                                               }
                                           }];
        [task resume];
        return [RACDisposable disposableWithBlock:^{
            CMTLog(@">>>>[Operation Cancel]: %@", request.URL.absoluteString);
            [task cancel];
        }];
    }];
    
    return [[signal
             replayLazily]
            setNameWithFormat:@"-enqueueRequest: %@", request];
}

- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass{
    @weakify(self);
    return [[[self
              enqueueRequest:request]
             reduceEach:^id(NSURLResponse * response, id responseResult){
                 @strongify(self);
                 return [self
                         parsedResponseOfClass:resultClass fromJSON:responseResult andResponse:response];
             }]
            concat];
}

#pragma mark sysSign

- (NSDictionary *)parametersWithSysSign:(NSDictionary *)parameters {
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    NSMutableString *parametersString = [NSMutableString string];
    
    @try {
        [parametersHandle addEntriesFromDictionary:@{
                                                     CMTClientRequestSysDateKey: TIMESTAMP,
                                                     CMTClientRequestSysImeiKey: UDID,
                                                     }];
        NSArray *sortedKeys = [parametersHandle.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
        }];
        
        for (NSString *key in sortedKeys) {
            id value = parametersHandle[key];
            [parametersString appendFormat:@"%@%@", key, value];
        }
    }
    @catch (NSException *exception) {
        parametersString = nil;
        CMTLogError(@"CLIENT Handle Parameters Exception: %@", exception);
    }
    
    if (BEMPTY(parametersString)) {
        return parameters;
    }
    NSString *sysSign = [[parametersString stringByAppendingString:CMTClientRequestSysPublickey] MD5HexDigest];
    [parametersHandle addEntriesFromDictionary:@{CMTClientRequestSysSignKey: sysSign}];
    
    return parametersHandle;
}

#pragma mark Parsing

- (NSError *)parsingErrorWithFailureReason:(NSString *)localizedFailureReason fromJSON:(id)responseResult andResponse:( NSURLResponse*)Response {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not parse the response result", @"");
    if (localizedFailureReason != nil) userInfo[NSLocalizedFailureReasonErrorKey] = localizedFailureReason;
    
    if (Response.URL != nil) userInfo[CMTClientErrorUserInfoURLKey] =Response.URL;
    userInfo[CMTClientErrorUserInfoHTTPStatusCodeKey] = @(((NSHTTPURLResponse*)Response).statusCode);
    if (responseResult != nil) userInfo[CMTClientErrorUserInfoResponseResultKey] = responseResult;
    
    return [NSError errorWithDomain:CMTClientErrorDomain code:CMTClientErrorJSONParsingFailed userInfo:userInfo];
}

- (RACSignal *)parsedResponseOfClass:(Class)resultClass fromJSON:(id)responseResult andResponse:(NSURLResponse *)Response {
    NSParameterAssert(resultClass == nil || [resultClass isSubclassOfClass:[MTLModel class]]);
     @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CMTObject *(^parseJSONDictionary)(NSDictionary *) =  ^CMTObject *(NSDictionary *JSONDictionary) {
              @strongify(self);
            if (resultClass == nil) {
                NSError *error = [self parsingErrorWithFailureReason:NSLocalizedString(@"Unspecified ResultClass", @"")
                                                            fromJSON:responseResult
                                                         andResponse:Response];
                [subscriber sendError:error];
                return nil;
            }
            
            NSError *error = nil;
            CMTObject *parsedObject = [MTLJSONAdapter modelOfClass:resultClass fromJSONDictionary:JSONDictionary error:&error];
            if (parsedObject == nil) {
                [subscriber sendError:error];
                return nil;
            }
            
            NSAssert([parsedObject isKindOfClass:[CMTObject class]],  @"Parsed model object is not an CMTObject: %@", parsedObject);
            
            return parsedObject;
        };
        
        // 解析数组
        if ([responseResult isKindOfClass:[NSArray class]]) {
            NSMutableArray *parsedObjects = [NSMutableArray array];
            for (NSDictionary *JSONDictionary in responseResult) {
                if (![JSONDictionary isKindOfClass:[NSDictionary class]]) {
                    NSError *error = [self parsingErrorWithFailureReason:NSLocalizedString(@"Invalid JSON array element", @"")
                                                                fromJSON:responseResult
                                                             andResponse:Response];
                    [subscriber sendError:error];
                    return nil;
                }
                
                CMTObject *parsedObject = parseJSONDictionary(JSONDictionary);
                if (parsedObject == nil) {
                    return nil;
                } else {
                    [parsedObjects addObject:parsedObject];
                }
            }
            
            [subscriber sendNext:parsedObjects];
            [subscriber sendCompleted];
        }
        // 解析字典
        else if ([responseResult isKindOfClass:[NSDictionary class]]) {
            CMTObject *parsedObject = parseJSONDictionary(responseResult);
            if (parsedObject != nil) {
                
                [subscriber sendNext:parsedObject];
                [subscriber sendCompleted];
            }
        }
        // 解析Status2的空结果
        else if ([responseResult isEqual:CMTClientResultEmptyForStatusEmpty]) {
            
            // to do 此处返回 nil 所有的请求都需判断是否为nil
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }
        // responseObject错误
        else if (responseResult != nil) {
            NSError *error = [self parsingErrorWithFailureReason:NSLocalizedString(@"ResponseResult wasn't an array, dictionary or Empty Result of Status2", @"")
                                                        fromJSON:responseResult
                                                     andResponse:Response];
            [subscriber sendError:error];
        }
        // 解析Status0的空结果
        else {
            
            // to do 此处返回 nil 所有的请求都需判断是否为nil
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }
        
        return nil;
    }];
}


#pragma mark Error Handling

+ (NSError *)errorFromRequestOperation:(NSURLResponse *)Response object:(id)responseObject{
    NSParameterAssert(Response != nil);
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSDictionary *responseResult = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        responseResult = responseObject;
    }
    
    if (Response.URL != nil) userInfo[CMTClientErrorUserInfoURLKey] =Response.URL;
    userInfo[CMTClientErrorUserInfoHTTPStatusCodeKey] = @(((NSHTTPURLResponse*)Response).statusCode);
    
    NSInteger code = 0; // 默认0 表示无错误代码/错误信息
    NSString *message = @"";
    if (responseResult[CMTClientServerErrorCodeKey] != nil) {
        if ([responseResult[CMTClientServerErrorCodeKey] respondsToSelector:@selector(integerValue)]) {
            code = [responseResult[CMTClientServerErrorCodeKey] integerValue];
            message = responseResult[CMTClientServerErrorUserInfoMessageKey];
        } else {
            // code格式错误 无法获取数值
            code = -1;
            message = @"ErrorCode is not integer value";
        }
    }
    userInfo[CMTClientServerErrorCodeKey] = @(code);
    userInfo[CMTClientServerErrorUserInfoMessageKey] = message ?: @"";
    
    return [NSError errorWithDomain:CMTClientServerErrorDomain code:code userInfo:userInfo];
}

- (NSError *)archivingErrorWithFilePath:(NSString *)filePath unarchiving:(BOOL)unarchiving {
    NSInteger code = unarchiving ? CMTClientErrorObjectUnarchivingFailed : CMTClientErrorObjectArchivingFailed;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedFailureReasonErrorKey] = NSLocalizedString(@"Could not archiving the stored object", @"");
    if (unarchiving) {
        userInfo[NSLocalizedFailureReasonErrorKey] = NSLocalizedString(@"Could not unarchiving the stored object", @"");
    }
    
    if (filePath == nil) {
        userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Empty FilePath", @"");
    } else {
        userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Object Stored at FilePath", @""), filePath];
    }
    
    return [NSError errorWithDomain:CMTClientErrorDomain code:code userInfo:userInfo];
}


@end
