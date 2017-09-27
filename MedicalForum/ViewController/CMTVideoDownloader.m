    //
//  CMTVideoDownloader.m
//  MedicalForum
//
//  Created by guoyuanchao on 2017/3/16.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTVideoDownloader.h"

@implementation CMTVideoDownloader
+ (instancetype)defaultDownloader {
    static CMTVideoDownloader *defaultDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDownloader = [[CMTVideoDownloader alloc] init];
     });
    return defaultDownloader;
}
-(NSURLSession*)downloadermanager{
    if(_downloadermanager==nil){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"down"];
       _downloadermanager = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        AFNetworkReachabilityManager*manager = [AFNetworkReachabilityManager sharedManager];
        [manager startMonitoring];
        
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                       CMTAPPCONFIG.DownnetState=@"2";
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                        CMTAPPCONFIG.DownnetState=@"1";
                    if(self.downloadtask.state==NSURLSessionTaskStateRunning){
                        [self.downloadtask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                            CMTAPPCONFIG.downloadingLive.downData=resumeData;
                            self.downloadtask=nil;
                        }];
                    }else{
                        [self.downloadtask cancel];
                        self.downloadtask=nil;
                    }
                    break;
                    
                default:
                      CMTAPPCONFIG.DownnetState=@"0";
                    if(self.downloadtask.state==NSURLSessionTaskStateRunning){
                        [self.downloadtask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                            CMTAPPCONFIG.downloadingLive.downData=resumeData;
                            self.downloadtask=nil;
                        }];
                        NSLog(@"无网络555555555");
                    }else{
                        [self.downloadtask cancel];
                         self.downloadtask=nil;
                    }
                    break;
            }
         } ];

        
    }
    return _downloadermanager;
}
-(void)startDownLoad{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:CMTAPPCONFIG.downloadingLive.studentJoinUrl]];
    self.downloadtask = [self.downloadermanager downloadTaskWithRequest:request];
    [self.downloadtask resume];
}
//断点续传
-(void)resumeDownLoad{
    if(CMTAPPCONFIG.downloadingLive.downData!=nil){
        self.downloadtask = [self.downloadermanager downloadTaskWithResumeData:CMTAPPCONFIG.downloadingLive.downData];
        [self.downloadtask resume];
    }else{
         [self startDownLoad];
    }
    self.downfinish=NO;
    CMTAPPCONFIG.downloadingLive.Downstate=3;
    [CMTAPPCONFIG savedownloadingLive];
    if(self.updateDownstart!=nil){
        self.updateDownstart();
    }


}
#pragma mark 代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    //将下载好的文件从临时存放的地址转移到Cache文件夹中
    [MobClick event:@"CMTdownloadCompleteStatistics"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[PATH_downLoad stringByAppendingPathComponent:CMTAPPCONFIG.downloadingLive.studentJoinUrl.lastPathComponent]]) {
        [manager removeItemAtPath:[PATH_downLoad stringByAppendingPathComponent:CMTAPPCONFIG.downloadingLive.studentJoinUrl.lastPathComponent] error:nil];
    }
    
    [manager copyItemAtURL:location toURL:[NSURL fileURLWithPath:[PATH_downLoad stringByAppendingPathComponent:CMTAPPCONFIG.downloadingLive.studentJoinUrl.lastPathComponent]] error:nil];
                CMTAPPCONFIG.downloadingLive.downData=nil;
                CMTAPPCONFIG.downloadingLive.downloadProgress=0.0;
                CMTAPPCONFIG.downloadingLive.Downstate=0;
                NSMutableArray *array=[[NSMutableArray alloc]init];
                [array addObject:[CMTAPPCONFIG.downloadingLive copy]];
                [array addObjectsFromArray:[CMTAPPCONFIG.haveDownloadedList copy]];
                CMTAPPCONFIG.haveDownloadedList=[array mutableCopy];
                CMTAPPCONFIG.downloadingLive.fileSize=0;
                [CMTAPPCONFIG saveHavedownLoadList];
                [CMTAPPCONFIG.downloadList removeObjectAtIndex:[self findIndex:CMTAPPCONFIG.downloadList dic:[CMTAPPCONFIG.downloadingLive copy]]];
                [CMTAPPCONFIG savedownloadList];
                if(self.downloadtask.state !=3){
                    [self.downloadtask cancel];
                 };
                self.downloadtask=nil;
                self.indexPath=nil;
                self.downfinish=YES;
                CMTAPPCONFIG.downloadingLive=nil;
               [CMTAPPCONFIG savedownloadingLive];
                if(CMTAPPCONFIG.downloadList.count>0){
                    CMTAPPCONFIG.downloadingLive=[CMTAPPCONFIG.downloadList[0] copy];
                    CMTAPPCONFIG.downloadingLive.Downstate=3;
                    [CMTAPPCONFIG savedownloadingLive];
                     self.indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
                    if(CMTAPPCONFIG.downloadingLive.type.integerValue==2){
                         [self resumeDownLoad];
                    }else{
                        CMTDemandDownLoad.indexPath=self.indexPath;
                        [CMTDemandDownLoad doDownloader];
                       
                    }
                }else{
                    [self.downloadtask cancel];
                    self.downloadtask=nil;
                    [self.downloadermanager invalidateAndCancel];
                    self.downloadermanager=nil;
                }
}
-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    CMTAPPCONFIG.downloadingLive.Downstate=4;
    self.downfinish=YES;
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    __weak typeof (self)weakSelf = self;
     CMTLog(@"断点续传: %lld %lld %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    if(CMTAPPCONFIG.freeDiskSpaceInBytes<=totalBytesExpectedToWrite){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"没有足够的空间缓存视频" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        CMTAPPCONFIG.downloadingLive.Downstate=4;
        self.downfinish=YES;
        [self.downloadtask cancel];
    }else{
       CMTAPPCONFIG.downloadingLive.fileSize=totalBytesExpectedToWrite;
       CMTAPPCONFIG.downloadingLive.downloadProgress=(float)totalBytesWritten/totalBytesExpectedToWrite;
       if(self.updateDownProgress!=nil){
        self.updateDownProgress((float)totalBytesWritten/totalBytesExpectedToWrite,totalBytesExpectedToWrite);
      }
        if(CMTAPPCONFIG.downloadingLive.Downstate!=1){
               CMTAPPCONFIG.downloadingLive.Downstate=1;
            if(self.updateDownstart!=nil){
                self.updateDownstart();
            }
        }
     if (totalBytesWritten - CMTAPPCONFIG.downloadingLive.haveDownLength > totalBytesExpectedToWrite / 10) {
       CMTAPPCONFIG.downloadingLive.haveDownLength = totalBytesWritten;
        if(CMTAPPCONFIG.appState!=CMTAppStateDidEnterBackground ){
        [self.downloadtask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
            CMTAPPCONFIG.downloadingLive.downData=resumeData;
            CMTAPPCONFIG.downloadingLive.haveDownLength=totalBytesWritten;
            CMTAPPCONFIG.downloadingLive.downloadProgress=(float)totalBytesWritten/totalBytesExpectedToWrite;
            [CMTAPPCONFIG savedownloadingLive];
            //保存数据
            weakSelf.downloadtask = [weakSelf.downloadermanager downloadTaskWithResumeData:CMTAPPCONFIG.downloadingLive.downData];
            [weakSelf.downloadtask resume];
          }];
        }
      }
    }
}

//暂停下载
-(void)suspendedDownLoad{
    [self.downloadtask suspend];
    CMTAPPCONFIG.downloadingLive.Downstate=2;
    [CMTAPPCONFIG savedownloadingLive];
    if(self.updateDownpause!=nil){
        self.updateDownpause();
    }
}
-(void)CancelsuspendedDownLoad{
    [self.downloadtask resume];
    [CMTAPPCONFIG savedownloadingLive];
    if(self.updateDownstart!=nil){
        self.updateDownstart();
    }
}
//删除不带缓存
-(void)cancel{
    [self.downloadtask cancel];
    self.downloadtask=nil;
}
//取消下载
-(void)cancelDownLoad{
    if(CMTAPPCONFIG.downloadingLive.Downstate==3){
        CMTAPPCONFIG.downloadingLive.downData=nil;
        CMTAPPCONFIG.downloadingLive.Downstate=5;
        if(self.updateDownpause!=nil){
            self.updateDownpause();
        }
        [self.downloadtask cancel];
        self.downloadtask=nil;
    }else{
        [self.downloadtask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            CMTAPPCONFIG.downloadingLive.downData=resumeData;
            CMTAPPCONFIG.downloadingLive.Downstate=2;
            if(self.updateDownpause!=nil){
                self.updateDownpause();
            }
            self.downloadtask=nil;
        }];
    }
}
//判断是否下载
-(BOOL)whetherFileExists:(NSString*)filepath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filepath];
    return result;
}
-(BOOL)checkClassRoomIsDown:(NSArray*)arry classID:(NSString*)classID{
    BOOL flag=NO;
    for (CMTLivesRecord *live in arry) {
        if([live.classRoomId isEqualToString:classID]){
            flag=YES;
            break;
        }
    }
    return flag;
    
}
//删除下载的文件
-(void)deleteDownFile:(NSString*)url {
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString *path=[PATH_downLoad stringByAppendingPathComponent:url.lastPathComponent];
    //文件名
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!blHave) {
        NSLog(@"no  have");
        return ;
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:path error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
        
    }
}
//查找数据是不是存在
-(NSInteger)findIndex:(NSMutableArray*)arry dic:(CMTLivesRecord*)classRoom{
    NSInteger index=-1;
    for (NSInteger i=0;i<arry.count;i++) {
        CMTLivesRecord *live=arry[i];
        if([live.classRoomId isEqualToString:classRoom.classRoomId]){
            index=i;
            break;
        }
    }
    return index;
}
-(NSString*)AccessFileSize:(long)filesize{
    if(filesize==0){
        return @"";
    }
    long size=ceil((float)filesize/1024);
    NSString *sizeString= [@"" stringByAppendingFormat:@"%ld%@",size,@"K"];
    if(size>1024){
        size=ceil((float)filesize/1024/1024);
        sizeString=[@"" stringByAppendingFormat:@"%ld%@",size>1024?(long)ceil(size/1024):size,size>1024?@"G":@"M"];
    }
    return sizeString;
}
@end
