//
//  CMTRecordedViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTRecordedViewController.h"
#import "BBFlashCtntLabel.h"
#import "LDZAVPlayerHelper.h"
#import "SSIndicatorLabel.h"
#import "CMTLiveShareView.h"
#import "CMTBindingViewController.h"
#import "CMTDownLoadAndStoreView.h"
#import "CMTDownloadManagerView.h"
#import "CMTDownCenterViewController.h"
@interface CMTRecordedViewController ()<UIWebViewDelegate,UIAlertViewDelegate>{
    CGRect RecordRect;//初始大小
    AVPlayerItem *playItem;
    float progressSlider;
    BOOL isPlay;
    
}
@property(nonatomic,strong)UIView *toolbarView;//上工具条
@property(nonatomic,strong)UIButton *backButton;//返回按钮
@property(nonatomic,strong)UIWebView *liveteilWebdetails;//直播详情
@property(nonatomic,strong)CMTLivesRecord *myparam;
@property(nonatomic,strong)UIView *buttomView;//控制视频播放
@property (nonatomic,strong) UIImageView *playView;//直播间默认图片
@property(nonatomic,strong)UIButton *playbutton;//报名
@property (nonatomic, strong) LDZAVPlayerHelper *playerHelper;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic,retain) SSIndicatorLabel *indicatorLabel;
// 公共的
@property(nonatomic,strong)UIView *bottomView;//播放控制工具条
@property (strong, nonatomic) UILabel *PastTimeLabel;//播放时间
@property (strong, nonatomic) UISlider *ProgressSlider;//播放时间控制
@property (strong, nonatomic) UILabel *RemainderLabel;//剩余时间
@property(strong,nonatomic)UIButton *fullModeButton;//全屏按钮
@property(nonatomic,strong)UIButton*playButton;//播放按钮;
@property (nonatomic, assign)CGFloat initTime;//初始进度时间（秒）
@property(assign,nonatomic)BOOL isfullScreen;//是否全屏;
@property(nonatomic,strong)UIView *videoView;//视频界面
@property (nonatomic, assign) NSInteger totalMovieDuration;//  保存该视频资源的总时长，快进或快退的时候要用
@property (nonatomic, strong)UIAlertView *alertView;//监听网络
@property(nonatomic,strong)CMTLiveShareView *ShareView;//分享视图
@property(nonatomic,strong)UIButton *fristplaybutton;//初次播放按钮
@property(nonatomic,assign)BOOL firstplay;//是否第一次播放;
@property(nonatomic,strong)UIView *imageplayBack;//播放视图
@property(nonatomic,assign)BOOL isplayFinish;//播放完成
@property (nonatomic, strong)UIButton *shareItem;  // 分享按钮
@property(nonatomic,strong)NSTimer *HideToolbarTimer;
@property(nonatomic,assign)BOOL isTimeStatistics;
@property (nonatomic, strong)CMTDownLoadAndStoreView *loadAndStoreView;
@property (nonatomic,assign)BOOL isDelete;//防止下线重复请求，回调删除列表数据重复发生；
@property (nonatomic, strong)CMTDownloadManagerView *Download;

@property(nonatomic,assign)BOOL isneedUpdateState;
@end
@implementation CMTRecordedViewController
- (CMTDownLoadAndStoreView *)loadAndStoreView{
    if (!_loadAndStoreView) {
        _loadAndStoreView = [[CMTDownLoadAndStoreView alloc]initWithFrame:CGRectMake(-5, SCREEN_HEIGHT - 44, SCREEN_WIDTH + 10, 44)];
        _loadAndStoreView.backgroundColor = ColorWithHexStringIndex(c_ffffff);
        _loadAndStoreView.layer.shadowOffset = CGSizeMake(0, -1);
        _loadAndStoreView.layer.shadowColor = ColorWithHexStringIndex(c_32c7c2).CGColor;
        _loadAndStoreView.layer.shadowOpacity = 0.5;
        [_loadAndStoreView.storeContorl addTarget:self action:@selector(storeAction:) forControlEvents:UIControlEventTouchUpInside];
         [_loadAndStoreView.storeBtn addTarget:self action:@selector(storeAction:) forControlEvents:UIControlEventTouchUpInside];
        [[RACObserve(self.myparam, isStore)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString * x) {
            _loadAndStoreView.storeBtn.selected = x.integerValue;
        }];
        [_loadAndStoreView.downContorl addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
         [_loadAndStoreView.downLoadBtn addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loadAndStoreView;
}
-(void)downloadAction{
    //判断网络和登陆
    if(!CMTUSER.login){
        CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
        bing.nextvc=kComment;
        self.nextVC = @"blindVC";
        [self.navigationController pushViewController:bing animated:YES];
        return;
    }
    if([CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.haveDownloadedList classID:self.myparam.classRoomId]||[CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.downloadList classID:self.myparam.classRoomId]){
        CMTNavigationController * navigation=[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
        BOOL flag=[CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.haveDownloadedList classID:self.myparam.classRoomId];
        CMTDownCenterViewController *center=[[CMTDownCenterViewController alloc]initWith:flag];
        [navigation pushViewController:center animated:YES];
    }else{
        if([self getNetworkReachabilityStatus].integerValue!=2){
            [self toastAnimation:@"请切换至wifi网络" top:0];
            return;
        }
        if([self.contentBaseView viewWithTag:10000]!=nil){
            return;
        }
     self.Download=[[CMTDownloadManagerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.liveteilWebdetails.height+44)];
         [self.contentBaseView addSubview:self.Download];
        self.Download.parent=self;
        self.Download.tag=10000;
      [self.Download reloadData:self.myparam];
        @weakify(self);
        self.Download.updateDemanDownstate=^(NSString* str){
            @strongify(self);
            self.loadAndStoreView.downlabel.text=@"下载中";
        };

     [UIView animateWithDuration:0.3 animations:^{
        self.Download.top=self.liveteilWebdetails.top;
     } completion:^(BOOL finished) {
         [self.contentBaseView bringSubviewToFront:self.Download];
      }];
    }
}

#pragma 收藏
#pragma __收藏
- (void)storeAction:(UIButton *)sender{
    
    if (!CMTUSER.login) {
        self.isneedUpdateState=YES;
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
        return ;
        
    }
    if (_loadAndStoreView.storeBtn.selected) {
        UIAlertView *cancleStoreAlert=[[UIAlertView alloc]initWithTitle:@"确定不再收藏该课程吗？" message:nil delegate:nil
                                                      cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [cancleStoreAlert show];
        @weakify(self)
        [[[cancleStoreAlert rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if ([index integerValue] == 1) {
                NSMutableArray *dleteArr = [NSMutableArray array];
                if (self.myparam.dataId !=nil) {
                    [dleteArr addObject:self.myparam.dataId];
                }
                NSData *pData = [NSJSONSerialization dataWithJSONObject:dleteArr options:NSJSONWritingPrettyPrinted error:nil];
                NSString *pStr = [[NSString alloc]initWithData:pData encoding:NSUTF8StringEncoding];
                NSDictionary *pDic = @{
                                       @"userId":CMTUSER.userInfo.userId?:@"0",
                                       @"items":pStr?:@"",
                                       @"delType":@"0",
                                       };
                @weakify(self);
                [[[CMTCLIENT CMTDeleteStoreVideoAction:pDic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
                    CMTLog(@"课程删除收藏成功");
                    [self toastAnimation:@"取消收藏成功" top:0];
                    [self.loadAndStoreView.storeBtn changeScaleWithAnimate];
                    self.loadAndStoreView.storeBtn.selected = NO;
                    self.myparam.isStore = @"0";
                    self.myparam.isrefresh = YES;
                    if (self.updateReadNumber) {
                        self.updateReadNumber(self.myparam);
                    }
                    
                } error:^(NSError *error) {
                    if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
                        @strongify(self);
                        [self toastAnimation:@"你的网络不给力" top:0];
                    }else{
                        [self toastAnimation:[error.userInfo objectForKey:@"errmsg"] top:0];
                    }
                }];
                
            }else{
                self.loadAndStoreView.storeBtn.selected = YES;
            }
        }];
        return;
    }
    NSDictionary *pDic = @{
                           @"userId":CMTUSER.userInfo.userId?:@"0",
                           @"classRoomId":self.myparam.classRoomId?:@"",
                           @"coursewareId":self.myparam.coursewareId?:@"",
                           };
    @weakify(self);
    [[[CMTCLIENT CMTStoreVideoAction:pDic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord * x) {
        CMTLog(@"课程收藏成功");
        [self toastAnimation:@"收藏成功" top:0];
        [self.loadAndStoreView.storeBtn changeScaleWithAnimate];
        self.loadAndStoreView.storeBtn.selected = YES;
        self.myparam.isStore = @"1";
        self.myparam.dataId = x.dataId;
        
    } error:^(NSError *error) {
        if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
            @strongify(self);
            [self toastAnimation:@"你的网络不给力" top:0];
        }else{
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"] top:0];
        }
    }];
}
-(UIImageView*)playView{
    if (_playView==nil) {
        _playView=[[UIImageView alloc]initWithFrame:RecordRect];
        [_playView setImageURL:self.myparam.roomPic placeholderImage:IMAGE(@"recordedDefaultimage") contentSize:CGSizeMake(RecordRect.size.width, RecordRect.size.height)];
        _playView.contentMode=UIViewContentModeScaleAspectFill;
        _playView.clipsToBounds=YES;
        _playView.userInteractionEnabled=YES;
        self.imageplayBack=[[UIView alloc]initWithFrame:CGRectMake(0, 0, RecordRect.size.width, RecordRect.size.height)];
        self.imageplayBack.backgroundColor=[UIColor blackColor];
        self.imageplayBack.alpha=0.20;
        [_playView addSubview:self.imageplayBack];
       [_playView addSubview:self.fristplaybutton];
    }
    return _playView;
}

-(UIView*)toolbarView{
    if(_toolbarView==nil){
        _toolbarView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,40)];
        [_toolbarView setBackgroundColor:[UIColor clearColor]];
        self.backButton=[[UIButton alloc]initWithFrame:CGRectMake(10,10,110/3, 110/3)];
        [self.backButton setImage:IMAGE(@"livebackImage") forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(gotoback) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView addSubview:self.backButton];
        
        self.shareItem=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-110/3-10,10, 110/3, 110/3)];
        [self.shareItem setImage:IMAGE(@"liveShareImage") forState:UIControlStateNormal];
        @weakify(self);
        self.shareItem.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if(self.isfullScreen){
                [self FulScreenRotation:nil];
            }
            [self.ShareView showSharaAction];
            return [RACSignal empty];
            
        }];

        [_toolbarView addSubview:self.shareItem];
    }
    return _toolbarView;
    
}
- (UIView *)buttomView{
    if (_bottomView==nil) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0,RecordRect.size.height - 40,RecordRect.size.width, 40)];
        _bottomView.backgroundColor = [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.7];
        _bottomView.hidden=YES;
    }
    return _bottomView;
}
- (UIButton *)fristplaybutton{
    if (_fristplaybutton==nil) {
        _fristplaybutton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fristplaybutton.frame = CGRectMake((SCREEN_WIDTH-78)/2,(RecordRect.size.height-78)/2, 78, 78);
        [_fristplaybutton setBackgroundImage:IMAGE(@"firstPlayimage") forState:UIControlStateNormal];
        [_fristplaybutton setBackgroundImage:IMAGE(@"firstPlayimage") forState:UIControlStateHighlighted];
        @weakify(self);
        _fristplaybutton.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            return [self ClickPlayButton];
        }];
    }
    return _fristplaybutton;
    
}
//播放事件点击
-(RACSignal*)ClickPlayButton{
    if ([self getNetworkReachabilityStatus].integerValue==0) {
        [self toastAnimation:@"无法连接到网络，请检查网络设置" top:0];
        return [RACSignal empty];
    }
    if (!CMTUSER.login) {
        self.isneedUpdateState=YES;
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
        return [RACSignal empty];
        
    }
    if([self getNetworkReachabilityStatus].integerValue==1){
        [self ProcessingMobileNetwork];
        return [RACSignal empty];
    }
    if (self.myparam.status.integerValue==2) {
        [self toastAnimation:@"视频已经下线" top:0];
       
        return [RACSignal empty];
    }
    self.playView.hidden=YES;
    [_fristplaybutton setBackgroundImage:IMAGE(@"secondplayimage") forState:UIControlStateNormal];
    [_fristplaybutton setBackgroundImage:IMAGE(@"secondplayimage") forState:UIControlStateHighlighted];
    if (self.firstplay) {
        //添录播画面
        [self addAVPlayer];
        self.firstplay=NO;
    }
    self.bottomView.hidden=NO;
    //传递阅读数
    [self getUserNumber];
    [self setVideoPlay];
    [self addHideToolbarTimer];
    return [RACSignal empty];
}
- (UIButton *)playButton{
    if (_playButton==nil) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(7, 17/2, 23, 23);
        [_playButton setImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
        [_playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        @weakify(self);
        _playButton.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if (isPlay) {
                [self setVideoStop];
            }else{
                 [self setVideoPlay];
            }
            
            return [RACSignal empty];
        }];
    }
    return _playButton;
    
}
- (UISlider *)ProgressSlider{
    if (!_ProgressSlider) {
        _ProgressSlider = [[UISlider alloc]initWithFrame:CGRectMake(92, 0, self.buttomView.width - 182, 40)];
        _ProgressSlider.userInteractionEnabled=NO;
        [_ProgressSlider setMinimumTrackImage:IMAGE(@"progressImage") forState:UIControlStateNormal];
        [_ProgressSlider setMaximumTrackImage:IMAGE(@"progressRightImage") forState:UIControlStateNormal];
        //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
        [_ProgressSlider setThumbImage:IMAGE(@"progressControlImage") forState:UIControlStateNormal];
        [_ProgressSlider addTarget:self action:@selector(topSliderValueChangedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ProgressSlider;
}

- (UIButton *)fullModeButton{
    if (!_fullModeButton) {
        _fullModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullModeButton.frame = CGRectMake(self.buttomView.size.width - 30, 17/2, 23, 23);
        [_fullModeButton setBackgroundImage:IMAGE(@"fullModeImage") forState:UIControlStateNormal];
        [_fullModeButton addTarget:self action:@selector(FulScreenRotation:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullModeButton;
}
- (UILabel *)RemainderLabel{
    if (_RemainderLabel ==nil) {
        _RemainderLabel = [[UILabel alloc]init];
        _RemainderLabel.frame =CGRectMake(self.buttomView.size.width - 88 , 10, 48, 20);
        _RemainderLabel.text = @"00:00:00";
        _RemainderLabel.font = FONT(10);
        _RemainderLabel.textColor = [UIColor whiteColor];
    }
    return _RemainderLabel;
}

- (UILabel *)PastTimeLabel{
    if (_PastTimeLabel == nil) {
        _PastTimeLabel = [[UILabel alloc]init];
        _PastTimeLabel.frame = CGRectMake(42, 10, 48, 20);
        _PastTimeLabel.text = @"00:00:00";
        _PastTimeLabel.font = FONT(10);
        _PastTimeLabel.textAlignment = NSTextAlignmentRight;
        _PastTimeLabel.textColor = [UIColor whiteColor];
    }
    return _PastTimeLabel;
}


-(UIView*)videoView{
    if (_videoView==nil) {
        _videoView=[[UIView alloc]initWithFrame:RecordRect];
        [_videoView setBackgroundColor:[UIColor blackColor]];
        [_videoView addSubview:self.buttomView];
        [self.buttomView addSubview:self.playButton];
        [self.buttomView addSubview:self.PastTimeLabel];
        [self.buttomView addSubview:self.ProgressSlider];
        [self.buttomView addSubview:self.RemainderLabel];
        [self.buttomView addSubview:self.fullModeButton];
        UITapGestureRecognizer *gest=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTopbar:)];
        [_videoView addGestureRecognizer:gest];
        
    }
    return _videoView;
}
-(CMTLiveShareView*)ShareView{
    if (_ShareView==nil) {
        _ShareView=[[CMTLiveShareView alloc]init];
        _ShareView.parentView=self;
        @weakify(self);
        _ShareView.updateUsersnumber=^(CMTLivesRecord*rect){
            @strongify(self);
            self.myparam.users=rect.users;
            if (self.updateReadNumber!=nil) {
                self.updateReadNumber(self.myparam);
            }
        };
        _ShareView.LivesRecord=[self.myparam copy];
         _ShareView.LivesRecord.classRoomType=@"3";
    }
    return _ShareView;
}
-(UIWebView*)liveteilWebdetails{
    if(_liveteilWebdetails==nil){
        _liveteilWebdetails=[[UIWebView alloc]initWithFrame:CGRectMake(0,RecordRect.size.height, SCREEN_WIDTH,SCREEN_HEIGHT-RecordRect.size.height - 44)];
        _liveteilWebdetails.delegate=self;
        _liveteilWebdetails.backgroundColor = ColorWithHexStringIndex(c_ffffff);
        _liveteilWebdetails.scrollView.backgroundColor=ColorWithHexStringIndex(c_ffffff);
    }
    return _liveteilWebdetails;
}
//添加定时隐藏
-(void)addHideToolbarTimer{
    if(self.HideToolbarTimer==nil){
        self.HideToolbarTimer=[NSTimer timerWithTimeInterval:5 target:self selector:@selector(CMTHideRectToolbar) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.HideToolbarTimer forMode:NSRunLoopCommonModes];
    }else{
            [self.HideToolbarTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }

}
-(void)CMTHideRectToolbar{
          if(self.isfullScreen){
           self.toolbarView.hidden=YES;
            self.buttomView.hidden=YES;
          }else{
              self.toolbarView.hidden=NO;
              self.shareItem.hidden=YES;
              self.bottomView.hidden=YES;
          }
    self.HideToolbarTimer.fireDate=[NSDate distantFuture];
}
#pragma 显示工具条
-(void)showTopbar:(UITapGestureRecognizer*)tap{
    CGPoint point=[tap locationInView:tap.view];
    if (point.y<tap.view.height-self.buttomView.height) {
        if(self.isfullScreen){
            if (self.toolbarView.hidden) {
                self.toolbarView.hidden=NO;
                self.buttomView.hidden=NO;
                [self.HideToolbarTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
            }else{
                self.toolbarView.hidden=YES;
                self.buttomView.hidden=YES;
                self.HideToolbarTimer.fireDate=[NSDate distantFuture];
            }
        }else{
            if(!self.buttomView.hidden){
                self.shareItem.hidden=YES;
                self.bottomView.hidden=YES;
                self.HideToolbarTimer.fireDate=[NSDate distantFuture];

            }else{
                self.shareItem.hidden=NO;
                self.bottomView.hidden=NO;
                [self.HideToolbarTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];

            }
        }
    }
}
#pragma mark 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark 全屏
-(void)FulScreenRotation:(UIButton*)btn{
    [self.view endEditing:YES];//收起键盘
    //强制旋转
    if (!self.isfullScreen) {
        [UIView animateWithDuration:0.5 animations:^{
            self.contentBaseView.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.contentBaseView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.videoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            self.playerLayer.frame=self.videoView.frame;
            self.playView.frame=self.videoView.frame;
            self.fristplaybutton.center=CGPointMake(self.videoView.width/2, self.videoView.height/2);
            self.imageplayBack.frame=CGRectMake(0, 0, self.playView.size.width, self.playView.size.height);
            self.isfullScreen = YES;
            self.liveteilWebdetails.hidden=YES;
             self.Download.hidden=YES;
            [self.contentBaseView bringSubviewToFront:self.toolbarView];
            [self changeTooBarView];
             self.indicatorLabel.frame=CGRectMake((self.videoView.width- self.indicatorLabel.width)/2, (self.videoView.height-20)/2,self.indicatorLabel.width, 20);
            [self.fullModeButton setBackgroundImage:IMAGE(@"zoombutton") forState:UIControlStateNormal];
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.contentBaseView.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(0));
            self.contentBaseView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.videoView.frame=RecordRect;
            self.playView.frame=RecordRect;
            self.fristplaybutton.center=CGPointMake(self.videoView.width/2, self.videoView.height/2);
            self.imageplayBack.frame=CGRectMake(0, 0, RecordRect.size.width, RecordRect.size.height);
            self.isfullScreen = NO;
            self.liveteilWebdetails.hidden=NO;
            [self changeTooBarView];
             self.indicatorLabel.center=self.videoView.center;
             self.playerLayer.frame=CGRectMake(0, 0, self.videoView.width, self.videoView.height);
             self.indicatorLabel.frame=CGRectMake((self.videoView.width- self.indicatorLabel.width)/2, (self.videoView.height-20)/2,self.indicatorLabel.width, 20);
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self.fullModeButton setBackgroundImage:IMAGE(@"fullModeImage") forState:UIControlStateNormal];
        }];
    }
     self.shareItem.hidden=self.isfullScreen;
}
#pragma mark 旋屏自适应
-(void)changeTooBarView{
    if (self.isfullScreen) {
        self.toolbarView.frame=CGRectMake(0, 0,self.view.height, self.toolbarView.height);
        self.backButton.frame=CGRectMake(10, 10, self.backButton.width, self.backButton.height);
        self.buttomView.frame=CGRectMake(0, self.view.width- self.buttomView.height,self.view.height, self.buttomView.height);
       

      }else{
        self.toolbarView.frame=CGRectMake(0, 0,self.view.width, self.toolbarView.height);
        self.backButton.frame=CGRectMake(10, 10, self.backButton.width, self.backButton.height);
          
        self.buttomView.frame=CGRectMake(0,RecordRect.size.height-self.buttomView.height,RecordRect.size.width,self.buttomView.height);
        
    }
    self.shareItem.right=self.toolbarView.width-10;
    self.fullModeButton.frame = CGRectMake(self.buttomView.size.width - 30, self.fullModeButton.top,  self.fullModeButton.width, self.fullModeButton.height);
    self.ProgressSlider.frame=CGRectMake(92, self.ProgressSlider.top, self.buttomView.width - 182, self.ProgressSlider.height);
    self.RemainderLabel.frame =CGRectMake(self.buttomView.size.width - 88 , self.RemainderLabel.top, self.RemainderLabel.width, self.RemainderLabel.height);
}

#pragma mark - 播放进度
- (void)topSliderValueChangedAction:(id)sender {
    [_playerHelper.getAVPlayer pause];
    
    UISlider *senderSlider = sender;
    NSLog(@"进度条进度 + %f", senderSlider.value);
    Float64 totalSeconds = CMTimeGetSeconds(_playerHelper.getAVPlayer.currentItem.duration);
    CMTime duration=_playerHelper.getAVPlayer.currentItem.duration;
    CMTime time = CMTimeMakeWithSeconds(totalSeconds * senderSlider.value,duration.timescale);
    
    @weakify(self);
    [_playerHelper.getAVPlayer seekToTime:time completionHandler:^(BOOL finished) {
        @strongify(self);
        if (isPlay) {
            [self setVideoPlay];
        }
        
    }];
}
//播放
-(void)setVideoPlay{
    //设置阻止锁屏代码
    if (![UIApplication sharedApplication].idleTimerDisabled) {
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    [self.playerHelper.getAVPlayer play];
    self.myparam.playstatus=@"0";
    self.isplayFinish=NO;
    isPlay = YES;
    //  因为用的是xib,不设置的话图片会重合
    [self.playButton setImage:[UIImage imageNamed:@"pauseImage"] forState: UIControlStateNormal];

}
-(void)setVideoStop{
    [_playerHelper.getAVPlayer pause];
    isPlay = NO;
    //  因为用的是xib,不设置的话图片会重合
    [self.playButton setImage:[UIImage imageNamed:@"replayImage"] forState: UIControlStateNormal];

}
#pragma mark 返回函数
-(void)gotoback{
    if (self.isfullScreen) {
        [self FulScreenRotation:self.fullModeButton];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        [self playerdealloc];
    }

    
   }
//#pragma mark - 观察者 观察播放完毕 观察屏幕旋转
- (void)addNotificationCenters {
    //  注册观察者用来观察，是否播放完毕
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(VideoPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
#pragma mark 添加播放视图
- (void)addAVPlayer{
    NSURL *url=[NSURL URLWithString:self.myparam.studentJoinUrl];
    playItem = [AVPlayerItem playerItemWithURL:url];
    self.playerHelper = [[LDZAVPlayerHelper alloc] init];
    [_playerHelper initAVPlayerWithAVPlayerItem:playItem];
    //  创建显示层
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer: _playerHelper.getAVPlayer];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //  插入到view层上面, 没有用addSubLayer
    _playerLayer.frame =CGRectMake(0, 0, self.videoView.width, self.videoView.height);
    [self.videoView.layer insertSublayer:_playerLayer atIndex:0];
    //  添加进度观察
    [self addProgressObserver];
    [self addObserverToPlayerItem: playItem];
}
#pragma mark -  添加进度观察 - addProgressObserver
- (void)addProgressObserver {
    //  设置每秒执行一次
    @weakify(self);
    [_playerHelper.getAVPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue: NULL usingBlock:^(CMTime time) {
        @strongify(self);
        //      NSLog(@"进度观察 + %f", _topProgressSlider.value);
        //  获取当前时间
        CMTime currentTime = _playerHelper.getAVPlayer.currentItem.currentTime;
        //  转化成秒数
        CGFloat currentPlayTime = (CGFloat)currentTime.value / currentTime.timescale;
        CMTime totalTime = playItem.duration;
        //  转化成秒
        _totalMovieDuration = (CGFloat)totalTime.value / totalTime.timescale;
        //  相减后
        self.ProgressSlider.value = CMTimeGetSeconds(currentTime) / _totalMovieDuration;
        progressSlider = CMTimeGetSeconds(currentTime) / _totalMovieDuration;
        //        NSLog(@"%f", _topProgressSlider.value);
        NSDate *pastDate = [NSDate dateWithTimeIntervalSince1970: currentPlayTime];
        if (currentPlayTime<=(CGFloat)0.0) {
            currentPlayTime=0.0;
            _PastTimeLabel.text=@"00:00:00";
        }else{
            _PastTimeLabel.text = [@"time" getTimeByDate:pastDate byProgress: currentPlayTime];
        }
        CGFloat remainderTime = _totalMovieDuration - currentPlayTime;
        NSDate *remainderDate = [NSDate dateWithTimeIntervalSince1970: remainderTime];
        if (remainderTime<=(CGFloat)0.0) {
            remainderTime=0.0;
            _RemainderLabel.text=@"00:00:00";
        }else{
            self.RemainderLabel.text = [@"time" getTimeByDate:remainderDate byProgress: remainderTime];
        }
    }];
  }
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
}
- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

//  观察者的方法, 会在加载好后触发, 可以在这个方法中, 保存总文件的大小, 用于后面的进度的实现
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        self.ProgressSlider.userInteractionEnabled=YES;
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            self.indicatorLabel.hidden=YES;
            NSLog(@"正在播放...,视频总长度: %.2f",CMTimeGetSeconds(playerItem.duration));
            if (((CGFloat)playerItem.duration.value)==(CGFloat)0.0) {
                if (self.isfullScreen) {
                    [self FulScreenRotation:self.fullModeButton];
                }
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"视频播放失败" message:nil delegate:nil
                                                   cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
                [alert show];
                @weakify(self)
                [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                    // 确定 跳转App Store
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
                
            }else{
                CMTime totalTime = playerItem.duration;
                self.totalMovieDuration = (CGFloat)totalTime.value / totalTime.timescale;
                if(self.myparam.isvideoFristLoad.integerValue==0){
                    if(self.myparam.islearn.integerValue==1){
                        CMTime time = CMTimeMakeWithSeconds(self.initTime,playerItem.duration.timescale);
                        [_playerHelper.getAVPlayer seekToTime:time completionHandler:^(BOOL finished) {
                            self.myparam.isvideoFristLoad=@"1";
                            [_playerHelper.getAVPlayer play];
                        }];
                    }
                }else{
                    if (!isPlay) {
                        [self setVideoStop];
                    }
                }
               
            }
            
        }else if(status == AVPlayerStatusFailed){
            self.indicatorLabel.hidden=YES;
            if (self.isfullScreen) {
                 [self FulScreenRotation:self.fullModeButton];
            }
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"视频播放失败" message:nil delegate:nil
                                               cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            [alert show];
            @weakify(self)
            [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                // 确定 跳转App Store
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"您的网络不稳定" message:nil delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = playerItem.loadedTimeRanges;
        //  本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //  缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        NSLog(@"共缓冲%.2f", totalBuffer);
        NSLog(@"进度 + %f", progressSlider);
        self.ProgressSlider.value = progressSlider;
        
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (playerItem.playbackBufferEmpty) {
            NSLog(@"缓存为空");
        }
    }
    
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (!playerItem.playbackLikelyToKeepUp){
            self.indicatorLabel.hidden=NO;
        }else{
            self.indicatorLabel.hidden=YES;
        }
    }
}
#pragma mark 播放结束后的代理回调
- (void)VideoPlayDidEnd:(NSNotification *)notify
{
    self.HideToolbarTimer.fireDate=[NSDate distantFuture];
    self.playView.hidden=NO;
    self.toolbarView.hidden=NO;
    self.buttomView.hidden=YES;
    self.shareItem.hidden=NO;
    self.isplayFinish=YES;
     self.myparam.playstatus=@"1";
    CMTime dragedCMTime = CMTimeMake(0, 1);
    @weakify(self)
    [_playerHelper.getAVPlayer seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
        @strongify(self);
        if (isPlay) {
            [self setVideoStop];
        }
    }];
   
}
#pragma mark 页面参数初始化
-(instancetype)initWithRecordedParam:(CMTLivesRecord*)Param{
    self=[super init];
    if (self) {
        self.myparam=Param;
        self.isfullScreen=NO;
        self.firstplay=YES;
        RecordRect=CGRectMake(0, 0,SCREEN_WIDTH,ceil((SCREEN_WIDTH/16.0*9.0)));
    }
    return self;
}
#pragma mark 页面加载函数
- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTRecordedViewController willDeallocSignal");
    }];
    [self setNeedsStatusBarAppearanceUpdate];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    //初始时间进度设为0秒
    self.initTime = 0;
    self.titleText=self.myparam.title;
    [self setContentState:CMTContentStateLoading moldel:@"1" height:self.toolbarView.height];
    float with=[CMTGetStringWith_Height CMTGetLableTitleWith:@"视频正在加载中,请耐心等待" fontSize:17];
    self.indicatorLabel=[[SSIndicatorLabel alloc]initWithFrame:CGRectMake((self.videoView.width-with-30)/2, (self.videoView.height-20)/2, with+30, 20)];
    self.indicatorLabel.backgroundColor = self.videoView.backgroundColor;
    self.indicatorLabel.textLabel.textColor = [UIColor whiteColor];
    [self.indicatorLabel startWithText:@"视频正在加载中,请耐心等待"];
    self.indicatorLabel.backgroundColor=[UIColor clearColor];
    [self.videoView addSubview:self.indicatorLabel];
    [self.contentBaseView addSubview:self.videoView];
    [self.contentBaseView addSubview:self.playView];
    [self.contentBaseView addSubview:self.toolbarView];
    [self.contentBaseView addSubview:self.liveteilWebdetails];
    
    [self loadLiveDeilWebView];
    [self addNotificationCenters];
    [self getRoomState];
    [self.contentBaseView addSubview:self.loadAndStoreView];

#pragma mark 网络监听处理
    [[[RACObserve([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus)distinctUntilChanged]
       deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        CMTNavigationController *nav=[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
        if ([nav.topViewController isKindOfClass:[self class]]) {
            if (self.isfullScreen) {
                [self FulScreenRotation:self.fullModeButton];
            }
            if (self.isplayFinish||self.firstplay) {
                
            }else{
                
                if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable) {
                [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
                self.alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"你的网络已断开" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [self.alertView show];
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                
                
                }else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWiFi) {
                    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
                    self.alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"已连接至wifi" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                    [self.alertView show];
                    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                    CMTLogError(@"APPCONFIG Reachability Error Value: %@", CMTAPPCONFIG.reachability);
                } else if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWWAN){
                   [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
                    if (self.alertView==nil) {
                        self.alertView=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看课程" message:nil delegate:self
                                                       cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
                        [self.alertView show];
                        if (isPlay) {
                            [self setVideoStop];
                        }
                        @weakify(self)
                        [[[self.alertView rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
                            @strongify(self);
                            if(index.integerValue==0){
                                [self gotoback];
                            }else{
                                [self setVideoPlay];
                            }
                        }];

                        
                    }
                }
                
            }
        }
    } error:^(NSError *error) {;
        
    }];

}
#pragma mark 处理4g网络
-(void)ProcessingMobileNetwork{
    
    if (self.alertView==nil) {
        self.alertView=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看课程" message:nil delegate:self
                                       cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
        [self.alertView show];
        if (isPlay) {
            [self setVideoStop];
        }
        @weakify(self)
        [[[self.alertView rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if(index.integerValue==0){
                [self gotoback];
            }else{
                self.playView.hidden=YES;
                [_fristplaybutton setBackgroundImage:IMAGE(@"secondplayimage") forState:UIControlStateNormal];
                [_fristplaybutton setBackgroundImage:IMAGE(@"secondplayimage") forState:UIControlStateHighlighted];
                if (self.firstplay) {
                    //添加直播画面
                    [self addAVPlayer];
                    self.firstplay=NO;
                }
                //传递阅读数
                [self getUserNumber];
                [self setVideoPlay];
                

            }
        }];
    }
}

//关闭弹出框
-(void) performDismiss:(NSTimer *)timer
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    self.alertView=nil;
}
#pragma mark 获取直播间状态
-(void)getRoomState{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"0",
                             @"coursewareId":self.myparam.coursewareId?:@"0",
                             @"roomId":self.myparam.classRoomId?:@"0",
                             @"actionType":@"1",
                             };
    
    @weakify(self);
    [[[CMTCLIENT CMTGetVideoPlayStatus:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *x) {
        @strongify(self);
        self.myparam.status=x.status;
        self.myparam.islearn=x.islearn;
        self.myparam.playDuration=x.playDuration;
        self.myparam.playstatus=x.playstatus;
        self.myparam.isStore = x.isStore;
        self.myparam.dataId = x.dataId.length==0?self.myparam.dataId:x.dataId;
        if (x.status.integerValue == 1) {
           [self.toolbarView removeFromSuperview];
           self.contentEmptyView.frame=self.contentBaseView.frame;
          [self.contentEmptyView addSubview:self.toolbarView];
            [self setContentState:CMTContentStateEmpty];
            self.contentEmptyView.contentEmptyPrompt=@"该课程已下线";
              if(self.updateReadNumber!=nil){
                 self.updateReadNumber(nil);
               }

        }else{
              [self.contentBaseView addSubview:self.toolbarView];
              [self setContentState:CMTContentStateNormal];
             if(self.myparam.islearn.integerValue==1&&CMTUSER.login){
                 self.initTime=self.myparam.playstatus.integerValue==0?self.myparam.playDuration.floatValue/1000:0;
                 [self ClickPlayButton];
             }
        }
    } error:^(NSError *error) {
         @strongify(self);
        self.mReloadBaseView.frame=self.contentBaseView.frame;
        [self.mReloadBaseView addSubview:self.toolbarView];
          [self setContentState:CMTContentStateReload];
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力" top:0];
        }else{
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"] top:0];
        }
    }];

}
#pragma mark 获取阅读数
-(void)getUserNumber{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"0",
                             @"videoId":self.myparam.coursewareId?:@"0",
                             @"classRoomId":self.myparam.classRoomId?:@"0",
                             @"videoUrl":self.myparam.studentJoinUrl,
                             };
    
    @weakify(self);
    [[[CMTCLIENT CMTGetvideoplaynumber:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *x) {
        @strongify(self);
        self.myparam.users=x.users;
        if (self.updateReadNumber!=nil) {
            self.updateReadNumber(self.myparam);
        }
        } error:^(NSError *error) {
        
    }];
    
}
#pragma mark 重新加载
-(void)animationFlash{
    [super animationFlash];
    [self.toolbarView removeFromSuperview];
    [self.view addSubview:self.toolbarView];
    [self setContentState:CMTContentStateLoading];
    [self getRoomState];
    [self loadLiveDeilWebView]
;}
#pragma mark 加载webView
-(void)loadLiveDeilWebView{
    NSURL *URL=[[NSURL alloc]initWithString:[[CMTClient defaultClient].baseURL.absoluteString stringByAppendingString:self.myparam.desUrl]];
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:URL];
    if (CMTUSER.login) {
        [request addValue: USER_AGENT forHTTPHeaderField:@"User-Agent"];
        NSString *userId = CMTUSER.userInfo.userId;
        [request setValue:userId forHTTPHeaderField:@"userId"];
        [request setValue:CMTUSERINFO.userUuid forHTTPHeaderField:@"userUuid"];
        [request setValue:USER_AGENT forHTTPHeaderField:@"cmUserAgent"];
    }
    else {
        [request addValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"0" forHTTPHeaderField:@"userId"];
        [request setValue:@"0" forHTTPHeaderField:@"userUuid"];
        [request setValue:USER_AGENT forHTTPHeaderField:@"cmUserAgent"];
        
    }
    
    [self.liveteilWebdetails loadRequest:request];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *URLString = request.URL.absoluteString;
    NSString *URLScheme =request.URL.scheme;
    //处理空白页和系统标签
    return [self handleWithinLightVedio:URLString URLScheme:URLScheme viewController:self];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
     [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    if (self.playerHelper.getAVPlayer.currentItem==nil) {
       [self.playerHelper.getAVPlayer replaceCurrentItemWithPlayerItem:playItem];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    if(self.playView.hidden){
       [self.HideToolbarTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    if(self.isneedUpdateState&&CMTUSER.login){
        [self getRoomState];
       
    }
     self.isneedUpdateState=NO;
    if([CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.haveDownloadedList classID:self.myparam.classRoomId]){
        self.loadAndStoreView.downlabel.text=@"已下载";
    }else if([CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.downloadList classID:self.myparam.classRoomId]){
        self.loadAndStoreView.downlabel.text=@"下载中";
    }else{
         self.loadAndStoreView.downlabel.text=@"下载";
    }
}
/**
*  一旦输出改变则执行此方法
*
*  @param notification 输出改变通知对象
*/
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
               if (isPlay) {
                    [_playerHelper.getAVPlayer pause];
                    [_playerHelper.getAVPlayer play];
               }
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    self.alertView=nil;
    [self.playerHelper.getAVPlayer replaceCurrentItemWithPlayerItem:nil];
    [self setVideoStop];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
     [self setNeedsStatusBarAppearanceUpdate];
    self.HideToolbarTimer.fireDate=[NSDate distantFuture];
    self.toolbarView.hidden=NO;
    self.buttomView.hidden=NO;
}
#pragma mark 监听
-(void)ResignActiveNotification:(NSNotification *)aNotification{
    if (isPlay) {
        [self setVideoStop];
    }
     AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [self RecordTheViewingTime];
}
-(void)ApplicationDidBecomeActive:(NSNotification*)aNotification{
}
#pragma mark 记录播放时间;
-(void)RecordTheViewingTime{
    if(self.firstplay||!CMTUSER.login){
        return;
    }
    CMTime currentTime = _playerHelper.getAVPlayer.currentItem.currentTime;
    //  转化成秒数
    CGFloat currentPlayTime = (CGFloat)currentTime.value / currentTime.timescale;
    if(_totalMovieDuration==0.0){
        currentPlayTime=self.myparam.playDuration.integerValue/1000;
    }
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"0",
                             @"coursewareId":self.myparam.coursewareId?:@"0",
                             @"classRoomId":self.myparam.classRoomId?:@"0",
                             @"duration":[@"" stringByAppendingFormat:@"%f",currentPlayTime*1000],
                             @"playstatus":self.myparam.playstatus?:@"0",
                             @"type":self.myparam.type,
                             };
    
    @weakify(self);
    [[[CMTCLIENT CMTPersonalLearningRecord:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *x) {
        @strongify(self);
        if(self.updateReadTime!=nil){
            self.updateReadTime(self.myparam);
        }
    } error:^(NSError *error) {
        
    }];

}
#pragma mark 释放播放器
- (void)playerdealloc {
    [self RecordTheViewingTime];
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
     self.alertView=nil;
     self.isplayFinish=NO;
     self.firstplay=YES;
    //  移除观察者,使用观察者模式的时候,记得在不使用的时候,进行移除
    [self removeObserverFromPlayerItem: _playerHelper.getAVPlayer.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    //  返回前一个页面的时候释放内存
    [self.playerHelper.getAVPlayer replaceCurrentItemWithPlayerItem:nil];
     self.HideToolbarTimer.fireDate=[NSDate distantFuture];
    if (self.HideToolbarTimer.isValid) {
        [self.HideToolbarTimer invalidate];
    }
    self.HideToolbarTimer=nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end
