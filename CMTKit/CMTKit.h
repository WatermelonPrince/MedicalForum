//
//  CMTKit.h
//  MedicalForum
//
//  Created by fenglei on 14/11/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

// Utilities
#import "CMTMacros.h"
#import "CMTFunctions.h"
#import "CMTSwizzle.h"
#import "CMTSystemServices.h"
#import "CMTSubscriptingAssignmentTrampoline.h"
#import "CMTAppConfig.h"
#import "CMTVideoDownloader.h"
#import "DemandDownloader.h"
#import "CMTSocial.h"

// Extensions
#import "NSDate+CMTExtension.h"
#import "NSDateFormatter+CMTExtension.h"
#import "NSNumber+CMTExtension.h"
#import "NSString+CMTExtension_DigitString.h"
#import "NSString+CMTExtension_URLString.h"
#import "NSString+CMTExtension_HTMLString.h"
#import "NSArray+CMTExtension.h"
#import "NSDictionary+CMTExtension.h"
#import "NSError+CMTExtension.h"
#import "NSData+CMTExtension.h"
#import "NSFileManager+CMTExtension.h"
#import "UIColor+CMTExtension.h"
#import "UIImage+CMTExtension.h"
#import "UIView+CMTExtension.h"
#import "UIImageView+CMTExtension.h"
#import "UITextField+CMTExtension.h"
#import "UIViewController+CMTExtension.h"
#import "UINavigationController+CMTExtension.h"
#import "CMTNavigationController.h"
//add by guoyuanchao 获取自定义lable宽度
#import "CMTGetStringWith_Height.h"
#import "GTMBase64.h"
#import "NSString+ThreeDES.h"
#import "CMTMD5.h"
#import "CMTImageCompression.h"

// CMTObject
#import "CMTObject.h"
#import "CMTUser.h"
#import "CMTServer.h"
#import "CMTStore.h"

// CMTClient
#import "CMTClient.h"

// AppDelegate.h
#import "AppDelegate.h"
#import "CMTFocusManager.h"
#import <Masonry/Masonry.h>
#import <UMMobClick/MobClick.h>
#import <UMMobClick/MobClickSocialAnalytics.h>
#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialSinaHandler.h"
#import "CMTBaseViewController+CMTExtension.h"
#define CMTCLIENT           [CMTClient defaultClient]
#define CMTUSER             [CMTUser defaultUser]
#define CMTUSERINFO         CMTUSER.userInfo
#define CMTAPPCONFIG        [CMTAppConfig defaultConfig]
#define CMTDownLoad         [CMTVideoDownloader  defaultDownloader]
#define CMTDemandDownLoad   [DemandDownloader defaultDemandDownloader]
#define CMTFOCUSMANAGER     [CMTFocusManager sharedManager]
#define CMTSOCIAL           [CMTSocial shareInstance]
#define APPDELEGATE         ((AppDelegate *)[UIApplication sharedApplication].delegate)
