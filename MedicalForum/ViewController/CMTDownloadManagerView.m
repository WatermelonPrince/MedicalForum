//
//  CMTDownloadManagerView.m
//  MedicalForum
//
//  Created by guoyuanchao on 2017/3/15.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTDownloadManagerView.h"
#import "CMTDownCenterViewController.h"
@implementation CMTDownloadManagerView
-(UILabel*)title{
    if(_title==nil){
       _title=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.width-50, 40)];
       _title.text=@"请选择下载文件";
        _title.textColor=COLOR(c_b9b9b9);
       _title.font=FONT(15);

    }
    return _title;
}
-(UIButton*)closebutton{
    if(_closebutton==nil){
        _closebutton=[[UIButton alloc]initWithFrame:CGRectMake(self.width-40, 0,40, 40)];
        [_closebutton setImage:IMAGE(@"closeDownMange") forState:UIControlStateNormal];
        [_closebutton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closebutton;
}
-(UILabel *)equipmentStorage{
    if(_equipmentStorage==nil){
        _equipmentStorage=[[UILabel alloc]initWithFrame:CGRectMake(0, self.height-44, self.width, 44)];
        _equipmentStorage.backgroundColor=COLOR(c_f5f5f5);
        _equipmentStorage.textColor=COLOR(c_b9b9b9);
        _equipmentStorage.font=FONT(13);
        _equipmentStorage.numberOfLines=0;
        _equipmentStorage.lineBreakMode=NSLineBreakByCharWrapping;
        _equipmentStorage.textAlignment=NSTextAlignmentCenter;
    }
    return _equipmentStorage;
}
-(UIControl*)contentCell{
    if(_contentCell==nil){
        _contentCell=[[UIControl alloc]initWithFrame:CGRectMake(0, 40, self.width,42)];
        [_contentCell addTarget:self action:@selector(addToDownList) forControlEvents:UIControlEventTouchUpInside];
        _downimage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
        _downimage.image=IMAGE(@"CMT_undown");
        
        _namelable=[[UILabel alloc]initWithFrame:CGRectMake(40, 1, self.width-80, 40)];
        _namelable.font=FONT(15);
        _namelable.textColor=[UIColor colorWithHexString:@"#5c5c5c"];
        
        _sizelable=[[UILabel alloc]initWithFrame:CGRectMake(self.width-40, 1, 40, 40)];
        _sizelable.textColor=COLOR(c_b9b9b9);
        _sizelable.font=FONT(13);
        [_contentCell addSubview:_downimage];
        [_contentCell addSubview:_namelable];
        [_contentCell addSubview:_sizelable];
        UIView *line1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 1)];
        line1.backgroundColor=COLOR(c_f5f5f5);
        [_contentCell addSubview:line1];
        UIView *line2=[[UIView alloc]initWithFrame:CGRectMake(0,41, self.width, 1)];
        line2.backgroundColor=COLOR(c_f5f5f5);
        [_contentCell addSubview:line2];

        
    }
    return _contentCell;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        self.backgroundColor=COLOR(c_ffffff);
        [self addSubview:self.title];
        [self addSubview:self.closebutton];
        [self addSubview:self.contentCell];
        [self addSubview:self.equipmentStorage];
        self.downNumber=[@"已经下载了(" stringByAppendingFormat:@"%ld%@",CMTAPPCONFIG.haveDownloadedList.count,@")\r\n"];
    }
    return self;
}
-(void)reloadData:(CMTLivesRecord*)live{
    self.mylive=live;
    self.namelable.text=live.title;
    if(live.fileSize>0){
        float with=[CMTGetStringWith_Height CMTGetLableTitleWith:[CMTDownLoad AccessFileSize:live.fileSize] fontSize:13];
        self.mylive.fileSize=live.fileSize;
        with=with+20;
        self.sizelable.text=[CMTDownLoad AccessFileSize:live.fileSize];
        self.sizelable.left=self.width-with;
        self.namelable.width= self.sizelable.left-self.namelable.left;
        self.equipmentStorage.text=[self.downNumber stringByAppendingFormat:@"%@%@%@%@",@"预计新增", [CMTDownLoad AccessFileSize:live.fileSize],@",剩余",live.fileSize>[CMTAPPCONFIG freeDiskSpaceInBytes]?[CMTDownLoad AccessFileSize:[CMTAPPCONFIG freeDiskSpaceInBytes]-live.fileSize]:@"空间不足"];
    }else{
        self.equipmentStorage.text=[ self.downNumber stringByAppendingFormat:@"%@%@",@"剩余",[CMTAPPCONFIG freeDiskSpaceInBytesStr]];
        if(live.type.integerValue==2&&live.fileSize==0)
            [self getUrlFileLength:live.studentJoinUrl];
    }
}
- (void)getUrlFileLength:(NSString *)url
{
    NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [mURLRequest setHTTPMethod:@"HEAD"];
    mURLRequest.timeoutInterval = 5.0;
    NSURLConnection *URLConnection = [NSURLConnection connectionWithRequest:mURLRequest delegate:self];
    [URLConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSDictionary *dict = [(NSHTTPURLResponse *)response allHeaderFields];
    NSString *length = [dict objectForKey:@"Content-Length"];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    //异步返回主线程，根据获取的数据，更新UI
    dispatch_async(mainQueue, ^{
        NSLog(@"根据更新UI界面");
        float with=[CMTGetStringWith_Height CMTGetLableTitleWith:[CMTDownLoad AccessFileSize:length.integerValue] fontSize:13];
        self.mylive.fileSize=length.integerValue;
        with=with+20;
        self.sizelable.text=[CMTDownLoad AccessFileSize:length.integerValue];
        self.sizelable.left=self.width-with;
        self.namelable.right=self.sizelable.left;
        self.equipmentStorage.text=[self.downNumber stringByAppendingFormat:@"%@%@%@%@",@"预计新增", [CMTDownLoad AccessFileSize:length.integerValue],@",剩余",[CMTAPPCONFIG freeDiskSpaceInBytes]>length.integerValue?[CMTDownLoad AccessFileSize:[CMTAPPCONFIG freeDiskSpaceInBytes]-length.integerValue]:@"空间不足"];

    });
    [connection cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"获取文件大小失败：%@",error);
    [connection cancel];
}
//关闭下载管理页面
-(void)closeAction{
    @weakify(self);
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        self.top=SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        @strongify(self);
         [self removeFromSuperview];
    }];

   
}
//添加到下载队列
-(void)addToDownList{
    if([self.parent getNetworkReachabilityStatus].integerValue!=2){
        [self.parent toastAnimation:@"请切换至Wifi网络" top:0];
         return;
    }
     [MobClick event:@"CMTdownloadStatistics"];
    self.downimage.image=IMAGE(@"CMT_downing");
    if(CMTAPPCONFIG.downloadList.count==0){
        CMTAPPCONFIG.downloadingLive=[self.mylive copy];
        [CMTAPPCONFIG savedownloadingLive];
        [CMTAPPCONFIG.downloadList addObject:[self.mylive copy]];
        [CMTAPPCONFIG savedownloadList];
        if(self.mylive.type.integerValue==2){
             [CMTDownLoad  resumeDownLoad];
        }else{
            [CMTDemandDownLoad doDownloader];
        }
        

    }else if(![CMTAPPCONFIG.downloadingLive.classRoomId isEqualToString:self.mylive.classRoomId]){
       [CMTAPPCONFIG.downloadList addObject:[self.mylive copy]];
       [CMTAPPCONFIG savedownloadList];
    }
    self.contentCell.userInteractionEnabled=NO;
    if(self.updateDemanDownstate!=nil){
        self.updateDemanDownstate(@"正在下载");
    }
    [self closeAction];
    [self.parent toastAnimation:@"已加入下载队列，请到下载中心查看！" top:0];
    
}
@end
