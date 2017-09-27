//
//  CMTMacros.h
//  MedicalForum
//
//  Created by fenglei on 14/11/27.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

// log
#ifdef DD_LEGACY_MACROS
    #undef LOG_LEVEL_DEF
    #define LOG_LEVEL_DEF CMTLibLogLevel
    #ifdef DEBUG
        static const DDLogLevel CMTLibLogLevel = DDLogLevelVerbose;
    #else
        static const DDLogLevel CMTLibLogLevel = DDLogLevelInfo;
    #endif
    #define CMTLog(...)                     DDLogVerbose(__VA_ARGS__)
    #define CMTLogDebug(...)                DDLogDebug(__VA_ARGS__)
    #define CMTLogInfo(...)                 DDLogInfo(__VA_ARGS__)
    #define CMTLogWarn(...)                 DDLogWarn(__VA_ARGS__)
    #define CMTLogError(...)                DDLogError(__VA_ARGS__)
#else
    #define CMTLog(...)                     NSLog(@"%s %@: %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
    #define CMTLogDebug(...)                ((void)0)
    #define CMTLogInfo(...)                 ((void)0)
    #define CMTLogWarn(...)                 ((void)0)
    #define CMTLogError(...)                ((void)0)
#endif

// device (CMTSystemServices)
#define SYSTEM_VERSION                              [[CMTSystemServices sharedServices] systemsVersion]
#define SYSTEM_VERSION_GREATER_THAN(version)        [[CMTSystemServices sharedServices] systemVersionGreaterThan:version]
#define SYSTEM_VERSION_NOT_LESS_THAN(version)       [[CMTSystemServices sharedServices] systemVersionNotLessThan:version]
#define SYSTEM_VERSION_EQUAL_TO(version)            [[CMTSystemServices sharedServices] systemVersionEqualTo:version]
#define SYSTEM_VERSION_NOT_GREATER_THAN(version)    [[CMTSystemServices sharedServices] systemVersionNotGreaterThan:version]
#define SYSTEM_VERSION_LESS_THAN(version)           [[CMTSystemServices sharedServices] systemVersionLessThan:version]
#define SCREEN_WIDTH                                [[CMTSystemServices sharedServices] screenWidth]
#define SCREEN_HEIGHT                               [[CMTSystemServices sharedServices] screenHeight]
#define SCREEN_SCALE                                [[CMTSystemServices sharedServices] screenScale]
#define SCREEN_MODEL                                [[CMTSystemServices sharedServices] screenHeightSizeModel]
#define RATIO                                       [[CMTSystemServices sharedServices] screenWidthRatio]
#define XXXRATIO                                    [[CMTSystemServices sharedServices] xxxscreenWidthRatio]
#define PIXEL                                       [[CMTSystemServices sharedServices] onePixelLineHeight]
#define SCREEN_BRIGHTNESS                           [[CMTSystemServices sharedServices] screenBrightness]
#define APP_VERSION                                 [[CMTSystemServices sharedServices] applicationVersion]
#define APP_BUILD                                   [[CMTSystemServices sharedServices] applicationBuild]
#define APP_VERSION_BUILD                           [[CMTSystemServices sharedServices] applicationVersionBuild]
#define APP_BUNDLE_ID                               [[CMTSystemServices sharedServices] applicationIdentifier]
#define APP_BUNDLE_NAME                             [[CMTSystemServices sharedServices] applicationName]
#define APP_BUNDLE_DISPLAY                          [[CMTSystemServices sharedServices] applicationDisplayName]
#define DISTRIBUTION_CHANNEL                        [[CMTSystemServices sharedServices] distribution]
#define UDID                                        [[CMTSystemServices sharedServices] CMTUDID]
#define USER_AGENT                                  [[CMTSystemServices sharedServices] UserAgent]
#define NET_WIFI                                    [[CMTSystemServices sharedServices] connectedToWiFi]
#define NET_CELL                                    [[CMTSystemServices sharedServices] connectedToCellNetwork]
#define DISK_FREE                                   [[CMTSystemServices sharedServices] longFreeDiskSpace]
#define PATH_SDWEBIMAGE                             [[CMTSystemServices sharedServices] SDWebImageCacheDirectoryPath]
#define PATH_USERS                                  [[CMTSystemServices sharedServices] userDirectoryPath]
#define PATH_downLoad                               [[CMTSystemServices sharedServices] downLoadDiectoryPath]
#define PATH_DEFAULTUSER                            [[CMTSystemServices sharedServices] userFilePath]
#define PATH_COLLECTIONLIST                         [[CMTSystemServices sharedServices] collectionListFilePath]
#define PATH_ADDPOSTS                               [[CMTSystemServices sharedServices] addPostDiectoryPath]
#define PATH_ADDPOST_ADDPOST                        [[CMTSystemServices sharedServices] addPostFilePath]
#define PATH_ADDPOST_ADDGROUPPOST                   [[CMTSystemServices sharedServices] addGroupPostFilePath]
#define PATH_ADDPOST_ADDPOSTADDITIONAL              [[CMTSystemServices sharedServices] addPostAdditionalFilePath]
#define PATH_ADDPOST_ADDLIVEMESSAGE                 [[CMTSystemServices sharedServices] addLiveMeaasgeFilePath]
#define PATH_SUBSCRIPTIONS                          [[CMTSystemServices sharedServices] subscriptionDiectoryPath]
#define PATH_TOTALSUBSCRIPTION                      [[CMTSystemServices sharedServices] totalSubscriptionPath]
#define PATH_ALLHOSPTIALS                           [[CMTSystemServices sharedServices] allHosptialsDiectory]
#define PATH_ALLAREAS                               [[CMTSystemServices sharedServices] allareasDiectory]

#define PATH_PDF                                    [[CMTSystemServices sharedServices] PDFDirectoryPath]
#define PATH_CACHES                                 [[CMTSystemServices sharedServices] cacheDirectoryPath]
#define PATH_CACHE_IMAGES                           [[CMTSystemServices sharedServices] imageCacheDirectoryPath]
#define PATH_CACHE_SEARCH                           [[CMTSystemServices sharedServices] searchCacheDirectoryPath]
#define PATH_CACHE_POSTS                            [[CMTSystemServices sharedServices] postCacheDirectoryPath]
#define PATH_CACHE_FOCUSLIST                        [[CMTSystemServices sharedServices] focusListFilePath]
#define PATH_CACHE_LIVELIST                        [[CMTSystemServices sharedServices] LiveListFilePath]

#define PATH_CACHE_POSTLIST                         [[CMTSystemServices sharedServices] postListFilePath]
#define PATH_CACHE_CASELIST                         [[CMTSystemServices sharedServices] caseListFilePath]
#define PATH_CACHE_DRSEAAELIST                      [[CMTSystemServices sharedServices] diseaseListCacheFilePath ]
#define PATH_CACHE_THEMES                           [[CMTSystemServices sharedServices] themeCacheDirectoryPath]
#define PATH_CACHE_HOSPTIAL                         [[CMTSystemServices sharedServices] hosptialCacheDirectoryPath]
#define PATH_CACHE_ALL_TEAM                         [[CMTSystemServices sharedServices] caseAllTeamFilePath]
#define PATH_CACHE_GROUPTYPECHOICE                  [[CMTSystemServices sharedServices] groupTypeChoicePath]
#define PATH_CACHE_CASE_MYTEAMS                     [[CMTSystemServices sharedServices] caseMyTeamFilePath]


#define PATH_CACHE_CASE_TEAM                         [[CMTSystemServices sharedServices] caseTeamFilePath]


#define PATH_FOUSTAG                                 [PATH_USERS stringByAppendingString:@"/FocusTag"]
// color
#define COLOR(ColorHexStringIndex)          ColorWithHexStringIndex(ColorHexStringIndex)

// font
#define FONT(fontSize)                      [UIFont systemFontOfSize:fontSize]
//#define FONTSIZEFROMPS(fontpx)          pxToSize(fontpx)

// image
#define IMAGE(imageName)                    [UIImage imageNamed:imageName]
#define IMAGE_COLOR(ColorHexStringIndex)    [COLOR(ColorHexStringIndex) pixelImage]

// date
#define TIMESTAMP                           [NSDate UNIXTimeStampFromNow]
#define DATE(TIME_STAMP)                    [NSDate dateFormatPattern:TIME_STAMP]
#define DATE_BRIEF(TIME_STAMP)              [NSDate briefFormattedStringFromDateWithUNIXTimeStamp:TIME_STAMP]
#define PASSED_DATE(TIME_STAMP)             [NSDate formattedPassedTimeFromDateWithUNIXTimeStamp:TIME_STAMP]

// empty
#define BEMPTY(NSObject)                    isEmptyObject(NSObject)

// dealloc
#define DEALLOC_HANDLE_SUCCESS              if (self == nil) {CMTLogError(@"Request Status Success(Request Success) and Call Back, but Subscriber Dealloc");return;}
#define DEALLOC_HANDLE_FAILURE              if (self == nil) {CMTLogError(@"Request Failure(Status Failure/Request Failure) and Sent Error, but Subscriber Dealloc");return;}

// navigationItem leftItem
/*直接创建一个barButton,关联方法实现弹栈*/
#define LEFT_ITEM  [[UIBarButtonItem alloc]initWithImage:IMAGE(@"naviBar_back") style:UIBarButtonItemStyleDone target:self action:@selector(popViewController)];

#define LOGIN_STATE [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginState"]boolValue]

