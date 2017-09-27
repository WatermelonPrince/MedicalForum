//
//  CMTPDFBrowserViewController.h
//  MedicalForum
//
//  Created by fenglei on 15/4/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

/// PDF文件状态
typedef NS_OPTIONS(NSUInteger, CMTPDFFileStatus) {
    CMTPDFFileStatusDownloading = 0,    // 下载中
    CMTPDFFileStatusCached,             // 已缓存
    CMTPDFFileStatusEmpty,              // 无缓存
};

/// PDF浏览器
@interface CMTPDFBrowserViewController : CMTBaseViewController <UIWebViewDelegate>

- (instancetype)initWithPDFURL:(NSString *)PDFURL
                       PDFSize:(NSString *)PDFSize
                         PDFID:(NSString *)PDFID
               updatePDFStatus:(void (^)(CMTPDFFileStatus))updatePDFStatus;

+ (CMTPDFFileStatus)checkPDFFileStatusWithPDFURL:(NSString *)PDFURL;

@end
