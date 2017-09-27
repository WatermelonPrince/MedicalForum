//
//  CMTSystemServices.h
//  MedicalForum
//
//  Created by fenglei on 14/12/2.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMTSystemServices : NSObject

/* Hardware Information */

/// Model of Device (iPhone)
@property (nonatomic, readonly) NSString *deviceModel;

/// Device Name (Your's iPhone)
@property (nonatomic, readonly) NSString *deviceName;

/// System Name (iPhone OS)
@property (nonatomic, readonly) NSString *systemName;

/// System Version (8.0.0)
@property (nonatomic, readonly) NSString *systemsVersion;

/// System Version > version ?
- (BOOL)systemVersionGreaterThan:(NSString *)version;

/// System Version >= version ?
- (BOOL)systemVersionNotLessThan:(NSString *)version;

/// System Version = version ?
- (BOOL)systemVersionEqualTo:(NSString *)version;

/// System Version <= version ?
- (BOOL)systemVersionNotGreaterThan:(NSString *)version;

/// System Version < version ?
- (BOOL)systemVersionLessThan:(NSString *)version;

/// System Device Type (Not Formatted = iPhone5,1)
@property (nonatomic, readonly) NSString *systemDeviceTypeNotFormatted;

/// System Device Type (Formatted = iPhone 5(GSM))
@property (nonatomic, readonly) NSString *systemDeviceTypeFormatted;

/// Get the Screen Width (320), error return -1
@property (nonatomic, readonly) NSInteger screenWidth;

/// Get the Screen Height (568), error return -1
@property (nonatomic, readonly) NSInteger screenHeight;

/// Get the Screen Brightness (53.8401), error return -1
@property (nonatomic, readonly) float screenBrightness;

/// Get the Screen Width Ratio base 320 point, screenWidth / 320 (320 or 375 or 414 / 320), 1 or 1.17188 or 1.29375, error return -1
@property (nonatomic, readonly) CGFloat screenWidthRatio;

@property (nonatomic, readonly) CGFloat xxxscreenWidthRatio;


/// Get the Screen Height Size Model, 1 (3.5 inch screen) or 0 (larger screen), error return -1
@property (nonatomic, readonly) NSInteger screenHeightSizeModel;

/// Get the natural scale factor associated with the screen, 1.0 or 2.0 or 3.0, error return -1
@property (nonatomic, readonly) CGFloat screenScale;

/// Get the height in point for 1px line, 1.0 or 1.0/2.0 or 1.0/3.0, error return -1
@property (nonatomic, readonly) CGFloat onePixelLineHeight;

/* Application Information */

/// Application Bundle Identifier (com.CMT.MedicalForum)
@property (nonatomic, readonly) NSString *applicationIdentifier;

/// Application Bundle Name (MedicalForum)
@property (nonatomic, readonly) NSString *applicationName;

/// Application Display Name (壹生)
@property (nonatomic, readonly) NSString *applicationDisplayName;

/// Application Version (1.0.0)
@property (nonatomic, readonly) NSString *applicationVersion;

/// Application Build (1)
@property (nonatomic, readonly) NSString *applicationBuild;

/// Application Version with Build (1.0.0.1)
@property (nonatomic, readonly) NSString *applicationVersionBuild;

/// Clipboard Content 剪切版内容
@property (nonatomic, readonly) NSString *clipboardContent;

/* Distribution Channel */

/// Distribution Name (App Store)
@property (nonatomic, readonly) NSString *distribution;

/* Universal Unique Identifiers */

/// UDID always the same
@property (nonatomic, readonly) NSString *CMTUDID;

/// User-Agent with format
/// applicationName_applicationVersionBuild_systemDeviceTypeFormatted systemName_systemsVersion_distribution_CMTUDID_cityCode
/// (产品名称_版本_平台_平台版本_渠道名_IMEI_城市区划码)
@property (nonatomic, readonly) NSString *UserAgent;

/* Network Information */

/// Get Cell IP Address
@property (nonatomic, readonly) NSString *cellIPAddress;

/// Get Cell MAC Address
@property (nonatomic, readonly) NSString *cellMACAddress;

/// Get Cell Netmask Address
@property (nonatomic, readonly) NSString *cellNetmaskAddress;

/// Get Cell Broadcast Address
@property (nonatomic, readonly) NSString *cellBroadcastAddress;

/// Get WiFi IP Address
@property (nonatomic, readonly) NSString *wiFiIPAddress;

/// Get WiFi MAC Address
@property (nonatomic, readonly) NSString *wiFiMACAddress;

/// Get WiFi Netmask Address
@property (nonatomic, readonly) NSString *wiFiNetmaskAddress;

/// Get WiFi Broadcast Address
@property (nonatomic, readonly) NSString *wiFiBroadcastAddress;

/// Connected to WiFi?
@property (nonatomic, readonly) BOOL connectedToWiFi;

/// Connected to Cellular Network?
@property (nonatomic, readonly) BOOL connectedToCellNetwork;

/* Carrier Information */

/// Carrier Name (中国移动)
@property (nonatomic, readonly) NSString *carrierName;

/// Carrier Country (CN)
@property (nonatomic, readonly) NSString *carrierCountry;

/// Carrier Mobile Country Code (460)
@property (nonatomic, readonly) NSString *carrierMobileCountryCode;

/// Carrier ISO Country Code (cn)
@property (nonatomic, readonly) NSString *carrierISOCountryCode;

/// Carrier Mobile Network Code (02)
@property (nonatomic, readonly) NSString *carrierMobileNetworkCode;

/// Carrier Allows VOIP
@property (nonatomic, readonly) BOOL carrierAllowsVOIP;

/* Disk Information */

/// Total Disk Space (930.71 GB/MB)
@property (nonatomic, readonly) NSString *diskSpace;

/// Total Free Disk Space (877.48 GB/MB)
@property (nonatomic, readonly) NSString *freeDiskSpaceinRaw;

/// Total Free Disk Space (94%)
@property (nonatomic, readonly) NSString *freeDiskSpaceinPercent;

/// Total Used Disk Space (53.23 GB/MB)
@property (nonatomic, readonly) NSString *usedDiskSpaceinRaw;

/// Total Used Disk Space (5%)
@property (nonatomic, readonly) NSString *usedDiskSpaceinPercent;

/// Get the total disk space in long format unit byte (999345127424), error return -1
@property (nonatomic, readonly) long long longDiskSpace;

/// Get the total free disk space in long format unit byte (942187859968), error return -1
@property (nonatomic, readonly) long long longFreeDiskSpace;

/* File Information  */

/// SDWebImageCacheDirectory Path
@property (nonatomic, readonly) NSString *SDWebImageCacheDirectoryPath;

/// System DocumentDirectory Path
@property (nonatomic, readonly) NSString *documentDirectoryPath;

/// UserDirectory Path Created in DocumentDirectory
@property (nonatomic, readonly) NSString *userDirectoryPath;

/// User File Path Created in UserDirectory
@property (nonatomic, readonly) NSString *userFilePath;

/// CollectionList File Path Created in UserDirectory
@property (nonatomic, readonly) NSString *collectionListFilePath;

/// AddPostDiectory Path Created in UserDirectory
@property (nonatomic, readonly) NSString *addPostDiectoryPath;

/// AddPost File Path Created in AddPostDiectory
@property (nonatomic, readonly) NSString *addPostFilePath;

/// addGroupPost File Path Created in AddPostDiectory
@property (nonatomic, readonly) NSString *addGroupPostFilePath;

/// addPostAdditional File Path Created in AddPostDiectory
@property (nonatomic, readonly) NSString *addPostAdditionalFilePath;
/// addLiveMeaasgeFilePath File Path Created in AddPostDiectory
@property (nonatomic, readonly) NSString *addLiveMeaasgeFilePath;


/// SubscriptionDiectory Path Created in DocumentDirectory
@property (nonatomic, readonly) NSString *subscriptionDiectoryPath;

/// TotalSubscription File Path Created in SubscriptionDiectory
@property (nonatomic, readonly) NSString *totalSubscriptionPath;

/// allHosptialsDiectory Created in DocumentDirectory
@property (nonatomic, readonly) NSString *allHosptialsDiectory;

/// allarea Created in DocumentDirectory
@property (nonatomic, readonly) NSString *allareasDiectory;

/// PDFDirectory Path Created in DocumentDirectory
@property (nonatomic, readonly) NSString *PDFDirectoryPath;

/// CacheDirectory Path Created in DocumentDirectory
@property (nonatomic, readonly) NSString *cacheDirectoryPath;

/// ImageDirectory Path Created in CacheDirectory
@property (nonatomic, readonly) NSString *imageCacheDirectoryPath;

/// SearchPost Path Created in CacheDirectory
@property (nonatomic, readonly) NSString *searchCacheDirectoryPath;

/// PostDirectory Path Created in CacheDirectory
@property (nonatomic, readonly) NSString *postCacheDirectoryPath;

/// FocusList File Path Created in PostDirectory
@property (nonatomic, readonly) NSString *focusListFilePath;
///  LiveList File Path Created in PostDirectory
@property(nonatomic,readonly)NSString * LiveListFilePath;

/// PostList File Path Created in PostDirectory
@property (nonatomic, readonly) NSString *postListFilePath;

/// CaseList File Path Created in CaseDirectory
@property(nonatomic,readonly) NSString *caseListFilePath;
//病例小组列表缓存地址
@property(readonly,nonatomic)NSString *caseAllTeamFilePath;
//疾病小组详情缓存地址
@property(readonly,nonatomic)NSString *caseTeamFilePath;
//我加入的病例小组
@property(readonly,nonatomic)NSString *caseMyTeamFilePath;
//创建小组 选择小组类型缓存类型
@property (nonatomic,readonly)NSString *groupTypeChoicePath;


/// ThemeDirectory Path Created in CacheDirectory
@property (nonatomic, readonly) NSString *themeCacheDirectoryPath;

/// HosptialDirectory Path Created in CacheDirectory
@property (readonly, nonatomic) NSString *hosptialCacheDirectoryPath;

//疾病列表缓存地址
@property(readonly,nonatomic)NSString *diseaseListCacheFilePath;
//下载地址
@property(readonly,nonatomic)NSString *downLoadDiectoryPath;

/* Localization Information */

/// City (110000)
@property (nonatomic, readonly) NSString *cityCode;

/// Country (zh_CN)
@property (nonatomic, readonly) NSString *country;

/// Language (zh-Hans)
@property (nonatomic, readonly) NSString *language;

/// TimeZone (Asia/Shanghai)
@property (nonatomic, readonly) NSString *timeZoneSS;

/// Currency Symbol (¥) 货币符号
@property (nonatomic, readonly) NSString *currency;

/// Shared Manager
+ (instancetype)sharedServices;

@end
