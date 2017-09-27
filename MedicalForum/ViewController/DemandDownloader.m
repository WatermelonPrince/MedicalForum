//
//  DownLoadViewController.m
//  VodSDKDemo
//
//  Created by gs_mac_wjj on 15/9/21.
//  Copyright © 2015年 Gensee. All rights reserved.
//

#import "DemandDownloader.h"
#import <PlayerSDK/VodDownLoader.h>
@interface DemandDownloader ()<VodDownLoadDelegate>
{
    downItem *downloadItem;
}
@property (nonatomic,strong) VodDownLoader *voddownloader;
@property (nonatomic ,strong) NSString *vodId;

@end

@implementation DemandDownloader
+ (instancetype)defaultDemandDownloader {
    static DemandDownloader *defaultDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDownloader = [[DemandDownloader alloc] init];
    });
    return defaultDownloader;
}

-(VodDownLoader*)voddownloader{
 if (!_voddownloader) {
        _voddownloader = [[VodDownLoader alloc]init];
       _voddownloader.delegate = self;
    }
    AFNetworkReachabilityManager*manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                 CMTAPPCONFIG.DownnetState=@"2";
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                  CMTAPPCONFIG.DownnetState=@"1";
                  [self PauseDownload];
                break;

            default:
                 NSLog(@"无网络bfbbffbff");
                 CMTAPPCONFIG.DownnetState=@"0";
                [self PauseDownload];
                break;
        }
    } ];

    return _voddownloader;
}
//添加到下载( 开始下载 )
- (void)doDownloader
{
    self.voddownloader.vodTimeFlag = YES; //获取下载件大小
    [self.voddownloader addItem:CMTAPPCONFIG.downloadingLive.studentJoinUrl number:CMTAPPCONFIG.downloadingLive.number loginName:nil vodPassword:CMTAPPCONFIG.downloadingLive.studentClientToken?:@"" loginPassword:nil downFlag:0 serType:CMTAPPCONFIG.downloadingLive.serviceType oldVersion:NO
                         kToken:nil customUserID:0];
     CMTAPPCONFIG.downloadingLive.Downstate=3;
    if(self.updateDemanDownstart!=nil){
        self.updateDemanDownstart();
    }

}

//暂停下载
- (void)doPauseDownload
{
    if(CMTAPPCONFIG.downloadingLive.Downstate==1){
        CMTAPPCONFIG.downloadingLive.Downstate=2;
    }else{
         CMTAPPCONFIG.downloadingLive.Downstate=5;
    }
    [CMTAPPCONFIG savedownloadingLive];
    if(_vodId.length>0){
        [_voddownloader stop:_vodId];
    }
    if(self.updateDemanDownpause!=nil){
        self.updateDemanDownpause();
    }
}
//暂停下载
- (void)PauseDownload
{
    if(_vodId.length>0&&downloadItem.state!=REDAY){
        [_voddownloader stop:_vodId];
    }
}

//删除下载
- (void)doDeleteDownload:(NSString*)vodid
{
    [self.voddownloader delete:vodid];
}

#pragma mark - VodDownLoadDelegate
//下载进度代理
- (void)onDLPosition:(NSString *)downLoadId percent:(float)percent
{
    CMTLog(@"ufheufheufheuhfuehfeufh%f",percent);
    CMTAPPCONFIG.downloadingLive.downloadProgress=percent/100;
    if(self.updateDemanDownProgress!=nil){
        self.updateDemanDownProgress(percent/100, CMTAPPCONFIG.downloadingLive.fileSize);
    }
    if( CMTAPPCONFIG.downloadingLive.Downstate==4){
         [_voddownloader stop:_vodId];
    }
}

//下载开始代理
- (void)onDLStart:(NSString *)downLoadId{
    NSLog(@"APP:下载开始");
    self.downfinish=NO;
    CMTAPPCONFIG.downloadingLive.Downstate=1;
    [CMTAPPCONFIG savedownloadingLive];
    if(self.updateDemanDownstart!=nil){
        self.updateDemanDownstart();
    }


}

//下载完成代理
- (void) onDLFinish:(NSString*) downLoadId
{
    NSLog(@"下载结束");
    [MobClick event:@"CMTdownloadCompleteStatistics"];
    CMTAPPCONFIG.downloadingLive.downData=nil;
    CMTAPPCONFIG.downloadingLive.Downstate=0;
    CMTAPPCONFIG.downloadingLive.downloadProgress=0.0;
    NSMutableArray *array=[[NSMutableArray alloc]init];
    [array addObject:[CMTAPPCONFIG.downloadingLive copy]];
    [array addObjectsFromArray:[CMTAPPCONFIG.haveDownloadedList copy]];
    CMTAPPCONFIG.haveDownloadedList=[array mutableCopy];;
     CMTAPPCONFIG.downloadingLive.fileSize=0;
    [CMTAPPCONFIG saveHavedownLoadList];
    [CMTAPPCONFIG.downloadList removeObjectAtIndex:[CMTDownLoad findIndex:CMTAPPCONFIG.downloadList dic:[CMTAPPCONFIG.downloadingLive copy]]];
    [CMTAPPCONFIG savedownloadList];
     _vodId=nil;
     self.indexPath=nil;
     self.downfinish=YES;
     CMTAPPCONFIG.downloadingLive=nil;
     [CMTAPPCONFIG savedownloadingLive];
    if(CMTAPPCONFIG.downloadList.count>0){
        CMTAPPCONFIG.downloadingLive=[CMTAPPCONFIG.downloadList[0] copy];
        CMTAPPCONFIG.downloadingLive.Downstate=3;
        self.indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [CMTAPPCONFIG savedownloadingLive];
        if(CMTAPPCONFIG.downloadingLive.type.integerValue==2){
            CMTDownLoad.indexPath=self.indexPath;
            [CMTDownLoad resumeDownLoad];
        }else{
            [CMTDemandDownLoad doDownloader];
        }
    }
 }

//下载出错代理
- (void)onDLError:(NSString *)downloadID Status:(VodDownLoadStatus)errorCode
{
    CMTAPPCONFIG.downloadingLive.Downstate=4;
    self.downfinish=YES;
    NSLog(@"APP:下载出错");
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"下载出错" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
    [alertView show];
}

//添加到下载代理
- (void)onAddItemResult:(RESULT_TYPE)resultType voditem:(downItem *)item{
    NSLog(@"APP: onAddItemResult:(RESULT_TYPE)resultType voditem:(downItem*)item");
    if (resultType == RESULT_SUCCESS) {
        _vodId = item.strDownloadID;
        CMTAPPCONFIG.downloadingLive.strDownloadID=item.strDownloadID;
        CMTAPPCONFIG.downloadingLive.fileSize=item.fileSize.integerValue;
        if(CMTAPPCONFIG.freeDiskSpaceInBytes<=item.fileSize.integerValue){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"没有足够的空间缓存视频" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            CMTAPPCONFIG.downloadingLive.Downstate=4;
            self.downfinish=YES;
        }else{
              downloadItem = [[VodManage shareManage]findDownItem:_vodId];
             [self.voddownloader download:downloadItem chatPost:NO];
        }
       
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString([self errorString:resultType] ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
        CMTAPPCONFIG.downloadingLive.Downstate=4;
        self.downfinish=YES;
    }
}
-(NSString*)errorString:(RESULT_TYPE)resultType{
    NSString *errorString=@"课程服务器连接失败";
    if(resultType==RESULT_FAILED_NET_REQUIRED){
        errorString=@"您的网络不给力,课程下载失败";
    }else if(resultType==RESULT_INIT_DOWNLOAD_FAILED){
        errorString=@"下载初始化失败";
    }else if(resultType==RESULT_ROOM_NUMBER_UNEXIST){
        errorString=@"无法连接到视频源，请稍后再次下载";
    }else if(resultType==RESULT_NOT_EXSITE){
        errorString=@"正在下载的课程不存在";
    }else if(resultType==RESULT_FAIL_WEBCAST){
        errorString=@"正在下载课程的id不正确";
    }else if(resultType==RESULT_FAIL_TOKEN){
        errorString=@"正在下载课程的口令错误";
    }else if(resultType==RESULT_FAIL_LOGIN){
        errorString=@"正在下载课程的用户名或密码错误";
    }else if(resultType==RESULT_ISONLY_WEB){
        errorString=@"正在下载的课程只支持web";
    }else if(resultType==RESULT_ROOM_UNEABLE){
        errorString=@"正在下载的课程不可用";
    }else if(resultType==RESULT_OWNER_ERROR){
        errorString=@"内部问题";
    }else if(resultType==RESULT_INVALID_ADDRESS){
        errorString=@"正在下载的课程地址无效";
    }else if(resultType==RESULT_ROOM_OVERDUE){
        errorString=@"正在下载的课程已经过期";
    }else if(resultType==RESULT_AUTHORIZATION_NOT_ENOUGH){
        errorString=@"正在下载的课程授权不足";
    }else if(resultType==RESULT_UNSURPORT_MOBILE){
        errorString=@"正在下载的课程不支持移动设备";
    }

    return errorString;
}
@end
