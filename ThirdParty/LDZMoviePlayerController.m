//
//  LDZMoviePlayerController.m
//  LDZMoviewPlayer_Xib
//
//  Created by rongxun02 on 15/11/24.
//  Copyright © 2015年 DongZe. All rights reserved.
//

#import "LDZMoviePlayerController.h"
#import "LDZAVPlayerHelper.h"
#import "SSIndicatorLabel.h"
@interface LDZMoviePlayerController ()<UIGestureRecognizerDelegate>
{
     CGRect RecordRect;//初始大小
    AVPlayerItem *playItem;
    float progressSlider;
    BOOL isPlay;
    BOOL isfromDown;
}
@property (nonatomic, assign)CMTime currentTime;
@property(nonatomic,strong)UIView *toolbarView;//上工具条
@property(nonatomic,strong)UIButton *backButton;//返回按钮
@property(nonatomic,strong)UIView *buttomView;//控制视频播放
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
@property (nonatomic, assign) CGFloat initTime;//初始进度时间（秒）
@property(assign,nonatomic)BOOL isfullScreen;//是否全屏;
@property(nonatomic,strong)UIView *videoView;//视频界面
@property (nonatomic, assign) NSInteger totalMovieDuration;//  保存该视频资源的总时长，快进或快退的时候要用
@property (nonatomic, strong)UIAlertView *alertView;//监听网络
@property(nonatomic,assign)BOOL firstplay;
@property (nonatomic,strong)NSURL *movieURL;
@end

@implementation LDZMoviePlayerController
-(UIView*)toolbarView{
    if(_toolbarView==nil){
        _toolbarView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,CMTNavigationBarBottomGuide)];
        [_toolbarView setBackgroundColor:[UIColor colorWithHexString:@"#030303"]];
        _toolbarView.alpha = 0.7;
        self.backButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 26,40, 30)];
        [self.backButton setImage:IMAGE(@"collegeBackimage") forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(gotoback) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView addSubview:self.backButton];
        
    }
    return _toolbarView;
    
}
- (UIView *)buttomView{
    if (_bottomView==nil) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0,self.videoView.height- 40,self.videoView.width, 40)];
        _bottomView.backgroundColor = [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.7];
    }
    return _bottomView;
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
        _RemainderLabel.frame =CGRectMake(self.buttomView.size.width - 88 ,10, 48, 20);
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
#pragma 显示工具条
-(void)showTopbar:(UITapGestureRecognizer*)tap{
    CGPoint point=[tap locationInView:tap.view];
    if (point.y<tap.view.height-self.buttomView.height) {
        if (self.isfullScreen) {
            if (self.toolbarView.hidden) {
                self.toolbarView.hidden=NO;
                self.buttomView.hidden=NO;
            }else{
                self.toolbarView.hidden=YES;
                self.buttomView.hidden=YES;
            }
            
        }else{
            if (self.buttomView.hidden) {
                self.buttomView.hidden=NO;
            }else{
                self.buttomView.hidden=YES;
            }
            
        }
        
    }
}
-(BOOL)prefersStatusBarHidden{
    if(self.isfullScreen){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark 全屏
-(void)FulScreenRotation:(UIButton*)btn{
    [self.view endEditing:YES];//收起键盘
    //强制旋转
    if (!self.isfullScreen) {
         @weakify(self);
        [UIView animateWithDuration:isfromDown?0:0.5 animations:^{
             @strongify(self);
            self.contentBaseView.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.contentBaseView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.videoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            self.playerLayer.frame=self.videoView.frame;
            self.isfullScreen = YES;
            self.toolbarView.hidden=!isfromDown;
            self.buttomView.hidden=!isfromDown;
            [self.contentBaseView bringSubviewToFront:self.toolbarView];
            [self changeTooBarView];
            self.indicatorLabel.frame=CGRectMake((self.videoView.width- self.indicatorLabel.width)/2, (self.videoView.height-20)/2,self.indicatorLabel.width, 20);
            [self.fullModeButton setBackgroundImage:IMAGE(@"zoombutton") forState:UIControlStateNormal];
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    } else {
         @weakify(self);
        [UIView animateWithDuration:isfromDown?0:0.5 animations:^{
             @strongify(self);
            self.contentBaseView.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(0));
            self.contentBaseView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.videoView.frame=RecordRect;
            self.isfullScreen = NO;
            self.toolbarView.hidden=NO;
            [self changeTooBarView];
            self.indicatorLabel.center=self.videoView.center;
            self.playerLayer.frame=CGRectMake(0, 0, self.videoView.width, self.videoView.height);
            self.indicatorLabel.frame=CGRectMake((self.videoView.width- self.indicatorLabel.width)/2, (self.videoView.height-20)/2,self.indicatorLabel.width, 20);
            [self.fullModeButton setBackgroundImage:IMAGE(@"fullModeImage") forState:UIControlStateNormal];
            [self setNeedsStatusBarAppearanceUpdate];

        }];
       
    }
    
}
#pragma mark 旋屏自适应
-(void)changeTooBarView{
    if (self.isfullScreen) {
        self.toolbarView.frame=CGRectMake(0, 0,self.view.height, 44);
        self.backButton.frame=CGRectMake(0, 6, self.backButton.width, self.backButton.height);
        self.buttomView.frame=CGRectMake(0, self.view.width- self.buttomView.height,self.view.height, self.buttomView.height);
        
        
    }else{
        self.toolbarView.frame=CGRectMake(0, 0,self.view.width, CMTNavigationBarBottomGuide);
        self.backButton.frame=CGRectMake(0, 26, self.backButton.width, self.backButton.height);
        self.buttomView.frame=CGRectMake(0,RecordRect.size.height-40,RecordRect.size.width, self.buttomView.height);
        
    }
    self.fullModeButton.frame = CGRectMake(self.buttomView.size.width - 30, 17/2, 23, 23);
    self.ProgressSlider.frame=CGRectMake(92, 0, self.buttomView.width - 182, 40);
    self.RemainderLabel.frame =CGRectMake(self.buttomView.size.width - 88 , 10, 48, 20);
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
    self.firstplay=NO;
    //设置阻止锁屏代码
    if (![UIApplication sharedApplication].idleTimerDisabled) {
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    }
    if(self.playtime>0){
         CMTime time = CMTimeMakeWithSeconds(self.playtime,playItem.duration.timescale);
         @weakify(self);
        [_playerHelper.getAVPlayer seekToTime:time completionHandler:^(BOOL finished) {
              @strongify(self);
            [self.playerHelper.getAVPlayer play];
        }];
        self.playtime=0;

    }else{
         [_playerHelper.getAVPlayer play];
    }
    isPlay = YES;
    //  因为用的是xib,不设置的话图片会重合
    [self.playButton setImage:[UIImage imageNamed:@"pauseImage"] forState: UIControlStateNormal];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
     [audioSession setActive:YES error:nil];
}
-(void)setVideoStop{
    [_playerHelper.getAVPlayer pause];
    isPlay = NO;
    //  因为用的是xib,不设置的话图片会重合
    [self.playButton setImage:[UIImage imageNamed:@"replayImage"] forState: UIControlStateNormal];
    
}
#pragma mark 返回函数
-(void)gotoback{
    if (self.isfullScreen &&!isfromDown) {
        [self FulScreenRotation:self.fullModeButton];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
//#pragma mark - 观察者 观察播放完毕 观察屏幕旋转
- (void)addNotificationCenters {
    //  注册观察者用来观察，是否播放完毕
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(VideoPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
#pragma mark 添加播放视图
- (void)addAVPlayer{
    playItem = [AVPlayerItem playerItemWithURL:self.movieURL];
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
    if(isfromDown){
        [self FulScreenRotation:self.fullModeButton];
        self.fullModeButton.hidden=YES;
    }
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
        if (currentPlayTime > self.initTime) {
            self.initTime = currentPlayTime;
        }
        //  总时间
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
                if(!isPlay){
                   [self setVideoStop];
                }else{
                    [self setVideoPlay];
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
    self.toolbarView.hidden=NO;
    self.buttomView.hidden=NO;
    CMTime dragedCMTime = CMTimeMake(0, 1);
    self.initTime=0;
    @weakify(self)
    [_playerHelper.getAVPlayer seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
        @strongify(self);
        if (isPlay) {
            [self setVideoStop];
        }
    }];
}
#pragma mark 调用视频统计接口
- (void)videoStastics{
    //  转化成秒数
    NSInteger currentPlayTime = self.initTime;
    //  总时间
    CMTime totalTime = playItem.duration;
    //  转化成秒
    _totalMovieDuration = (CGFloat)totalTime.value / totalTime.timescale;
    NSString *totalMovieDurationstr = [NSString stringWithFormat:@"%ld", (long)_totalMovieDuration];
    NSString *currentPlayTimestr = [NSString stringWithFormat:@"%ld", (long)currentPlayTime];
    NSLog(@"+++____%ld%ld",(long)currentPlayTime,(long)_totalMovieDuration);
    NSString *urlstr = [self.movieURL.absoluteString componentsSeparatedByString:@"?"][0];
    NSString *str = [urlstr URLDecodedString:urlstr];
    NSDictionary *parameters = @{
                                 @"userId":CMTUSERINFO.userId?:@"0",
                                 @"videoUrl":str?:@"",
                                 @"maxSecond":totalMovieDurationstr?:@"",
                                 @"currentSecond":currentPlayTimestr?:@"",
                                 @"postId":self.postId?:@"",
                                 };
    if (self.initTime > 0) {
        @weakify(self);
        [[[CMTCLIENT CMTVideo_stat:parameters]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            @strongify(self);
            NSLog(@"视频统计接口成功调用__%@",parameters);
            self.initTime = 0;
        } error:^(NSError *error) {
            CMTLog(@"errormessage:%@",error.userInfo[@"errmsg"]);
        }];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
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
//        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
//        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
//        //原设备为耳机则暂停
//        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            if (isPlay) {
                    [_playerHelper.getAVPlayer pause];
                    [_playerHelper.getAVPlayer play];
                
            }
//        }
        
    }
    
 }
-(instancetype)initWithUrl:(NSURL*)url{
    self=[super init];
    if(self){
        self.movieURL=url;
        isfromDown=NO;
    }
    return self;
}
-(instancetype)initWithUrl:(NSURL*)url fromDownCenter:(BOOL)flag{
      self=[super init];
      if(self){
          self.movieURL=url;
          isfromDown=YES;
     }
    return self;
}

  //页面加载
  -(void)viewDidLoad{
        [super viewDidLoad];
       [self setNeedsStatusBarAppearanceUpdate];
        [self.contentBaseView setBackgroundColor:[UIColor colorWithHexString:@"#030303"]];
       self.firstplay=YES;
        RecordRect=CGRectMake(0,CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide);
        [self.rac_willDeallocSignal subscribeCompleted:^{
            CMTLog(@"CMTRecordedViewController willDeallocSignal");
        }];
      
        [self setNeedsStatusBarAppearanceUpdate];
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        //初始时间进度设为0秒
        self.initTime = 0;
         isPlay=YES;
        float with=[CMTGetStringWith_Height CMTGetLableTitleWith:@"视频正在加载中,请耐心等待" fontSize:17];
        self.indicatorLabel=[[SSIndicatorLabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-with-30)/2, (self.videoView.height-20)/2, with+30, 20)];
        self.indicatorLabel.backgroundColor = self.videoView.backgroundColor;
        self.indicatorLabel.textLabel.textColor = [UIColor whiteColor];
        [self.indicatorLabel startWithText:@"视频正在加载中,请耐心等待"];
        self.indicatorLabel.backgroundColor=[UIColor clearColor];
        [self.videoView addSubview:self.indicatorLabel];
        [self.contentBaseView addSubview:self.videoView];
        [self.contentBaseView addSubview:self.toolbarView];
        [self addAVPlayer];
        [self addNotificationCenters];
       @weakify(self)
        #pragma mark 网络监听处理
      if(!isfromDown){
        [[[RACObserve([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus)distinctUntilChanged]
          deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            CMTNavigationController *nav=[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
            if ([nav.topViewController isKindOfClass:[self class]]) {
                if (self.isfullScreen) {
                    [self FulScreenRotation:self.fullModeButton];
                }
                if (self.firstplay) {
                    NSLog(@"jsjsjsjsjsjsjsjsjsjsjsj");
                    
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

}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
                [self setVideoPlay];
                
                
            }
        }];
    }
}
-(void) performDismiss:(NSTimer *)timer
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    self.alertView=nil;
}
#pragma mark 页面消失释放对象
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self videoStastics];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    self.alertView=nil;
     //  移除观察者,使用观察者模式的时候,记得在不使用的时候,进行移除
     [self setVideoStop];
    [self removeObserverFromPlayerItem: _playerHelper.getAVPlayer.currentItem];
    [self.playerHelper.getAVPlayer replaceCurrentItemWithPlayerItem:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
     [self setNeedsStatusBarAppearanceUpdate];
    if(isfromDown){
        if(self.updateReadtime!=nil){
            self.updateReadtime(self.initTime);
        }
    }
}
#pragma mark 监听
-(void)ResignActiveNotification:(NSNotification *)aNotification{
    if (isPlay) {
        [self setVideoStop];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
