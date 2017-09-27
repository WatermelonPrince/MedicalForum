//
//  CMTVideoDownloader.h
//  MedicalForum
//
//  Created by guoyuanchao on 2017/3/16.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "AFURLSessionManager.h"
@interface CMTVideoDownloader :NSObject<NSURLSessionDelegate>
//初始化下载器
+ (instancetype)defaultDownloader;
@property(nonatomic,strong)NSURLSession *downloadermanager;
@property(nonatomic,strong)NSURLSessionDownloadTask *downloadtask;
@property(nonatomic,assign)BOOL isenterbackGround;
@property(nonatomic,strong)NSIndexPath *indexPath;
@property(nonatomic,assign)BOOL downfinish;
//开始下载
-(void)startDownLoad;
//断点续传下载
-(void)resumeDownLoad;
-(void)suspendedDownLoad;
-(void)cancelDownLoad;
-(void)CancelsuspendedDownLoad;
-(void)cancel;
//文件是否已经下载
-(BOOL)whetherFileExists:(NSString*)filepath;
//更新下载进度
@property(nonatomic,copy)void(^updateDownProgress)(float downprogress,long filesize);
@property(nonatomic,copy)void(^updateDownpause)();
@property(nonatomic,copy)void(^updateDownstart)();
-(BOOL)checkClassRoomIsDown:(NSArray*)arry classID:(NSString*)classID;
-(NSInteger)findIndex:(NSMutableArray*)arry dic:(CMTLivesRecord*)classRoom;
//删除视频文件
-(void)deleteDownFile:(NSString*)url;
//获取文件大小
-(NSString*)AccessFileSize:(long)filesize;
@end
