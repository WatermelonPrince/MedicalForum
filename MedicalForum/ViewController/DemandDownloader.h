//
//  DownLoadViewController.h
//  VodSDKDemo
//
//  Created by gs_mac_wjj on 15/9/21.
//  Copyright © 2015年 Gensee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemandDownloader :NSObject
//初始化方法
+ (instancetype)defaultDemandDownloader;
//开始下载
- (void)doDownloader;
//暂停下载
- (void)doPauseDownload;
- (void)PauseDownload;
//删除下载
- (void)doDeleteDownload:(NSString*)vodid;
@property(nonatomic,copy)void(^updateDemanDownProgress)(float downprogress,long filesize);
@property(nonatomic,copy)void(^updateDemanDownpause)();
@property(nonatomic,copy)void(^updateDemanDownstart)();
@property(nonatomic,copy)NSIndexPath *indexPath;
@property(nonatomic,assign)BOOL downfinish;
@end
