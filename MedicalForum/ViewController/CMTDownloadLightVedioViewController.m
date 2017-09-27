//
//  CMTDownloadLightVedioViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 2017/3/23.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTDownloadLightVedioViewController.h"
#import "CMTRecordControlView.h"

@interface CMTDownloadLightVedioViewController ()<VodPlayDelegate>
{
    CGRect videoViewRect;
    CGRect docViewRect;
    CGRect littileWinRect;
    BOOL isfullScreen;
    BOOL isVideoFinished;
    float videoRestartValue;
    int druction;
    
    BOOL isDragging;
    
}
@property (nonatomic, strong)downItem *item;
@property (nonatomic, strong) VodPlayer *vodplayer;
@property(nonatomic,assign)BOOL isVedio;//当前画面是视频为YES
@property (strong, nonatomic)UIPanGestureRecognizer *pangesture;
@property (strong, nonatomic)UIView *littleWindowBGView;//小窗口背景视图；
@property (strong, nonatomic)UIView *touchView;//小窗口手势添加View;
@property(nonatomic,strong) NSTimer *controlHiddenShuffling;//控制视图隐藏的计时器;
@property (nonatomic, strong) CMTRecordControlView *recordControlView;
@property (nonatomic, assign)BOOL controlViewHidden;
@property (nonatomic,assign)BOOL hasPPT;//是否有PPT;
@property (strong, nonatomic)UIButton *windowHiddenButton;//小窗口隐藏button;
@property (nonatomic, assign)NSInteger recordTimeStamp;//记录离开控制器时，视频的进度条时间
@property (nonatomic, assign)BOOL isPlaying;//点播的播放状态，YES 为正在播放，NO为暂停活停止播放
@property (nonatomic, strong)UIImageView *playView;//默认播放视tu














@end

@implementation CMTDownloadLightVedioViewController

//-(UIImageView*)playView{
//    if (_playView==nil) {
//        _playView=[[UIImageView alloc]initWithFrame:docViewRect];
//        _playView.userInteractionEnabled=YES;
//        [_playView setImageURL:self.myliveParam.roomPic placeholderImage:IMAGE(@"recordedDefaultimage") contentSize:CGSizeMake(docViewRect.size.width, docViewRect.size.height)];
//        _playView.contentMode=UIViewContentModeScaleAspectFill;
//        _playView.clipsToBounds=YES;
//        _playView.userInteractionEnabled=YES;
//        [_playView addSubview:self.firstPlayeButton];
//    }
//    return _playView;
//}
- (UIButton *)windowHiddenButton{
    if (!_windowHiddenButton) {
        _windowHiddenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_windowHiddenButton setBackgroundImage:IMAGE(@"CloseLiveimage") forState:UIControlStateNormal];
        _windowHiddenButton.frame = CGRectMake(3, 3, 30, 30);
        _windowHiddenButton.hidden = YES;
        _windowHiddenButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            self.littleWindowBGView.hidden = YES;
            return [RACSignal empty];
        }];
        
    }
    return _windowHiddenButton;
}

- (UIView *)littleWindowBGView{
    if (!_littleWindowBGView) {
        _littleWindowBGView = [[UIView alloc]init];
        _littleWindowBGView.backgroundColor = [UIColor colorWithHexString:@"#ababab"];
        _littleWindowBGView.layer.shadowOffset = CGSizeMake(1, 1);
        _littleWindowBGView.layer.shadowColor = [UIColor blackColor].CGColor;
        _littleWindowBGView.layer.shadowOpacity = 0.5;
        
        _littleWindowBGView.hidden = YES;
    }
    return _littleWindowBGView;
}
- (UIView *)touchView{
    if (!_touchView) {
        _touchView = [[UIView alloc]init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(windowHiddenButtonShowAndHidden:)];
        [_touchView addGestureRecognizer:tap];
    }
    return _touchView;
}

- (void)switchDocAndPlayAction:(UIButton *)button{
    if (self.controlHiddenShuffling !=nil) {
        [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    if (self.isVedio) {
        
            self.windowHiddenButton.hidden = YES;
            
            if (self.littleWindowBGView.hidden) {
                self.littleWindowBGView.hidden = NO;
                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
                
                
            }else{
                [self.vodplayer.docSwfView removeFromSuperview];
                [self.vodplayer.mVideoView removeFromSuperview];
                self.littleWindowBGView.hidden = NO;
                self.vodplayer.docSwfView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
                [self.contentBaseView addSubview:self.vodplayer.docSwfView];
                [self.contentBaseView bringSubviewToFront:self.recordControlView];
                
                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
                
                self.vodplayer.mVideoView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);
                [self.littleWindowBGView addSubview:self.vodplayer.mVideoView];
                [self.littleWindowBGView bringSubviewToFront:self.touchView];
                [self.littleWindowBGView bringSubviewToFront:self.windowHiddenButton];
                self.recordControlView.topLineView.hidden = YES;
                self.recordControlView.bottomLineView.hidden = YES;
                self.isVedio = NO;
            }
        
        
        
    }else{
        
            self.windowHiddenButton.hidden = YES;
            if (self.littleWindowBGView.hidden) {
                self.littleWindowBGView.hidden = NO;
                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
                
            }else{
                [self.vodplayer.docSwfView removeFromSuperview];
                [self.vodplayer.mVideoView removeFromSuperview];
                self.windowHiddenButton.hidden = YES;
                self.recordControlView.topLineView.hidden = NO;
                self.recordControlView.bottomLineView.hidden = NO;
                self.vodplayer.mVideoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
                [self.contentBaseView addSubview:self.vodplayer.mVideoView];
                self.vodplayer.mVideoView.hidden = NO;
                self.vodplayer.docSwfView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);
                
                [self.littleWindowBGView addSubview:self.vodplayer.docSwfView];
                [self.littleWindowBGView bringSubviewToFront:self.touchView];
                [self.littleWindowBGView bringSubviewToFront:self.windowHiddenButton];
                [self.contentBaseView bringSubviewToFront:self.recordControlView];
                
                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
                
                self.isVedio = YES;
                
            }
            
            
            
            
            
        
        
    }
}

#pragma --mark窗口退出按钮hidden方法
-(void)windowHiddenButtonShowAndHidden:(UITapGestureRecognizer *)tap{
    self.windowHiddenButton.hidden = !self.windowHiddenButton.hidden;
}

//show控制视图
- (void)showAndHiddenControlView{
    
        if (self.controlViewHidden) {
            self.recordControlView.topView.hidden = NO;
            self.recordControlView.bottomView.hidden = NO;
            self.controlViewHidden = NO;
            //播放后倒计时隐藏控制视图
            if (self.controlHiddenShuffling !=nil) {
                [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
            }
        }else{
            self.recordControlView.topView.hidden = YES;
            self.recordControlView.bottomView.hidden = YES;
            self.controlViewHidden = YES;
            
        }
        
    
}


#pragma __显示控制视图并刷新倒计时时间
- (void)showAndShfflingControlView{
    self.recordControlView.bottomView.hidden = NO;
    self.recordControlView.topView.hidden = NO;
    
    self.controlViewHidden = NO;
    //播放后倒计时隐藏控制视图
    if (self.controlHiddenShuffling !=nil) {
        [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
}

#pragma mark __定时器隐藏控制视图
- (void)hiddenShufflingControlView{
    if (isfullScreen) {
        self.recordControlView.topView.hidden = YES;
        self.recordControlView.bottomView.hidden = YES;
        self.controlViewHidden = YES;
    }else{
        self.recordControlView.bottomView.hidden = YES;
        self.recordControlView.topView.hidden = YES;
        self.controlViewHidden = YES;
        
    }
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.controlHiddenShuffling!=nil) {
        [self.controlHiddenShuffling setFireDate:[NSDate distantFuture]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [self  addAVAudioSessionNotification];

    //        离线播放
    self.item = [[VodManage shareManage]findDownItem:self.myliveParam.strDownloadID];
    if (self.item) {
        if (self.vodplayer) {
            [self.vodplayer stop];
            self.vodplayer = nil;
        }
        self.vodplayer = ((AppDelegate*)[UIApplication sharedApplication].delegate).vodplayer;
        if (!self.vodplayer) {
            self.vodplayer = [[VodPlayer alloc]init];
        }
        videoViewRect = CGRectMake(0,  0, SCREEN_WIDTH, SCREEN_WIDTH*9/16 - 2);
        docViewRect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*9/16);
        littileWinRect = CGRectMake(SCREEN_WIDTH - 625/3 *XXXRATIO, 0, 625/3 * XXXRATIO, 625/3 * XXXRATIO * 9 / 16);
        self.vodplayer.playItem = self.item;
        if (!self.recordControlView) {
            self.recordControlView = [[CMTRecordControlView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9/16) isfullScreen:NO];
        }
        //旋屏状态
        self.contentBaseView.transform = CGAffineTransformMakeRotation(M_PI/2);
        self.contentBaseView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        //优先显示视频/PPT
        if (self.myliveParam.displayType.integerValue == 2) {
            self.vodplayer.mVideoView = [[VodGLView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
            self.vodplayer.mVideoView.backgroundColor = ColorWithHexStringIndex(c_000000);
            
            self.vodplayer.mVideoView.movieASImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.vodplayer.mVideoView.backgroundColor = ColorWithHexStringIndex(c_000000);
            self.vodplayer.mVideoView.clipsToBounds = YES;
            [self.contentBaseView addSubview:self.vodplayer.mVideoView ];
            self.vodplayer.docSwfView = [[GSVodDocView alloc]initWithFrame:CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height)];
            //                self.vodplayer.docSwfView.fullMode = NO;
            self.isVedio = YES;
        }else{
            self.vodplayer.mVideoView = [[VodGLView alloc]initWithFrame:CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height)];
            self.vodplayer.mVideoView.backgroundColor = ColorWithHexStringIndex(c_000000);
            
            self.vodplayer.mVideoView.movieASImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.vodplayer.mVideoView.backgroundColor = ColorWithHexStringIndex(c_000000);
            self.vodplayer.mVideoView.clipsToBounds = YES;
            self.vodplayer.docSwfView = [[GSVodDocView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
            [self.contentBaseView addSubview:self.vodplayer.docSwfView ];
            //                self.vodplayer.docSwfView.fullMode = NO;
            self.isVedio = NO;
        }
        [self.recordControlView resetFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH) isFullMode:YES];
        [self setUpWindowViewWithType:self.myliveParam.displayType];
        [self setUpWindowPanGesture];
        if ( !self.isPlaying) {
            [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
            
        }else{
            [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"pauseImage") forState:UIControlStateNormal];
        }
        
        isfullScreen = YES;
        self.navigationController.navigationBarHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
        
        self.recordControlView.returnButton.hidden = NO;
        self.hasPPT = self.hasPPT;
        self.recordControlView.shareButton.hidden = YES;
        [[RACObserve(self.littleWindowBGView, hidden) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber * x) {
            if (x.integerValue == 0) {
                [self.recordControlView.switchButton setBackgroundImage:IMAGE(@"liveChange") forState:UIControlStateNormal];
            }else{
                if (self.isVedio) {
                    [self.recordControlView.switchButton setBackgroundImage:IMAGE(@"livePPT") forState:UIControlStateNormal];
                    
                }else{
                    [self.recordControlView.switchButton setBackgroundImage:IMAGE(@"liveVideo") forState:UIControlStateNormal];
                }
                
            }
            
        }];

        self.vodplayer.delegate = self;
        
        //进度条
        [self.recordControlView.progress addTarget:self action:@selector(doSeek:) forControlEvents:UIControlEventTouchUpInside];
        [self.recordControlView.progress addTarget:self action:@selector(doHold:) forControlEvents:UIControlEventTouchDown];
        
        //播放控制按钮
        [self.recordControlView.controlButton addTarget:self action:@selector(doPause) forControlEvents:UIControlEventTouchUpInside];
        [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"pauseImage") forState:UIControlStateNormal];
        
        //切换控制
        [self.recordControlView.switchButton addTarget:self action:@selector(switchDocAndPlayAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //全屏按钮隐藏
        self.recordControlView.fullModeButton.hidden = YES;
        
        //退出按钮
        [self.recordControlView.returnButton addTarget:self action:@selector(returnBack:) forControlEvents:UIControlEventTouchUpInside];
        //分享按钮
        [self.recordControlView.shareButton addTarget:self action:@selector(shareViewShowAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.recordControlView.livetitle.text = self.myliveParam.title;
        
        [self.contentBaseView addSubview:self.recordControlView];
        [self.contentBaseView bringSubviewToFront:self.recordControlView];
        //添加手势用来隐藏展现控制视图
        UITapGestureRecognizer *tapGestureRecogizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAndHiddenControlView)];
        tapGestureRecogizer.numberOfTapsRequired = 1;
        UITapGestureRecognizer *tapGestureRecogizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAndHiddenControlView)];
        tapGestureRecogizer1.numberOfTapsRequired = 1;
        [self.recordControlView.touchView addGestureRecognizer:tapGestureRecogizer];
        self.controlViewHidden = NO;
        //添加定时器来定时隐藏控制视图
        
        [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
        //监听全屏控制条隐藏与否，来控制pan手势的移动范围
        [[RACObserve(self, controlViewHidden) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber  *x) {
            if(isfullScreen){
                if (x.intValue) {
                    if (self.littleWindowBGView.centerY >= SCREEN_WIDTH - littileWinRect.size.height/2 - self.recordControlView.bottomView.height -1) {
                        self.littleWindowBGView.centerY = SCREEN_WIDTH - littileWinRect.size.height/2;
                    }else if (self.littleWindowBGView.centerY <= littileWinRect.size.height/2 + self.recordControlView.topView.height + 1){
                        self.littleWindowBGView.centerY = littileWinRect.size.height/2;
                    }
                }else{
                    if (self.littleWindowBGView.centerY >= SCREEN_WIDTH - littileWinRect.size.height/2 - self.recordControlView.bottomView.height) {
                        self.littleWindowBGView.centerY = SCREEN_WIDTH - littileWinRect.size.height/2 - self.recordControlView.bottomView.height;
                    }else if (self.littleWindowBGView.centerY <= littileWinRect.size.height/2 + self.recordControlView.topView.height){
                        self.littleWindowBGView.centerY = littileWinRect.size.height/2 + self.recordControlView.topView.height;
                    }
                }
                
            }
        }];
       

        [self.vodplayer OfflinePlay:YES];
        [[RACObserve(self, hasPPT)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber * x) {
            if (x.integerValue == 0) {
                self.recordControlView.shareButton.frame = CGRectMake(self.recordControlView.topView.right - 110/3 - 10, 10, 110/3, 110/3);
                
            }else{
                self.recordControlView.shareButton.frame =  CGRectMake(self.recordControlView.switchButton.left - 10 - 110/3, 10, 110/3, 110/3);
            }
        }];
    }
    
    // 监控 app 活动状态，打电话/锁屏 时暂停播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark -VodPlayDelegate
//初始化VodPlayer代理
- (void)onInit:(int)result haveVideo:(BOOL)haveVideo duration:(int)duration docInfos:(NSDictionary *)docInfos
{
    
    
    
        //开始播放之后的一些初始设置
        
        self.isPlaying = YES;
    
            //点播第一次播放刚进入时，要手动暂停,
            [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"pauseImage") forState:UIControlStateNormal];
    
        
    [self.vodplayer seekTo:self.myliveParam.playDuration.integerValue];
    
    NSArray *arr = (NSArray *)docInfos;
    if (arr.count == 0) {
        self.recordControlView.switchButton.hidden = YES;
        
        
        self.hasPPT = NO;
        if (self.myliveParam.displayType.integerValue == 1) {
            [self.vodplayer.docSwfView removeFromSuperview];
            [self.vodplayer.mVideoView removeFromSuperview];
            self.windowHiddenButton.hidden = YES;
            self.recordControlView.topLineView.hidden = NO;
            self.recordControlView.bottomLineView.hidden = NO;
            self.vodplayer.mVideoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            [self.contentBaseView addSubview:self.vodplayer.mVideoView];
            self.vodplayer.mVideoView.hidden = NO;
            self.vodplayer.docSwfView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);
            [self.littleWindowBGView addSubview:self.vodplayer.docSwfView];
            [self.littleWindowBGView bringSubviewToFront:self.touchView];
            [self.littleWindowBGView bringSubviewToFront:self.windowHiddenButton];
            [self.contentBaseView bringSubviewToFront:self.recordControlView];
            [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
            [self.contentBaseView bringSubviewToFront:self.playView];
            self.isVedio = YES;
            self.littleWindowBGView.hidden = YES;
            
        }
        
        
        
        
    }else{
        self.recordControlView.switchButton.hidden = NO;
        self.littleWindowBGView.hidden = NO;
        
        self.hasPPT = YES;
    }
        [self.vodplayer getChatAndQalistAction];
        self.recordControlView.progress.maximumValue = duration;
        self.recordControlView.progress.minimumValue = 0;
        druction = duration;
        self.recordControlView.remainPlay.text = [self positionTime:duration];
        
    
    
    
}
- (void)onDocInfo:(NSArray *)docInfos{
    NSArray *arr = (NSArray *)docInfos;
    if (arr.count > 0) {
        self.recordControlView.switchButton.hidden = NO;
        self.hasPPT = YES;
        if (self.myliveParam.displayType.integerValue == 2) {
            [self.vodplayer.docSwfView removeFromSuperview];
            [self.vodplayer.mVideoView removeFromSuperview];
            self.windowHiddenButton.hidden = YES;
            self.recordControlView.topLineView.hidden = NO;
            self.recordControlView.bottomLineView.hidden = NO;
            self.vodplayer.mVideoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);;
            [self.contentBaseView addSubview:self.vodplayer.mVideoView];
            self.vodplayer.mVideoView.hidden = NO;
            self.vodplayer.docSwfView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);
            [self.littleWindowBGView addSubview:self.vodplayer.docSwfView];
            [self.littleWindowBGView bringSubviewToFront:self.touchView];
            [self.littleWindowBGView bringSubviewToFront:self.windowHiddenButton];
            [self.contentBaseView bringSubviewToFront:self.recordControlView];
            [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
            [self.contentBaseView bringSubviewToFront:self.playView];
            self.isVedio = YES;
            self.littleWindowBGView.hidden = YES;
        }else{
            [self.vodplayer.docSwfView removeFromSuperview];
            [self.vodplayer.mVideoView removeFromSuperview];
            self.windowHiddenButton.hidden = NO;
            self.recordControlView.topLineView.hidden = NO;
            self.recordControlView.bottomLineView.hidden = NO;
            self.vodplayer.mVideoView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);
            [self.contentBaseView addSubview:self.vodplayer.docSwfView];
            self.vodplayer.mVideoView.hidden = NO;
            self.vodplayer.docSwfView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);;
            [self.littleWindowBGView addSubview:self.vodplayer.mVideoView];
            [self.littleWindowBGView bringSubviewToFront:self.touchView];
            [self.littleWindowBGView bringSubviewToFront:self.windowHiddenButton];
            [self.contentBaseView bringSubviewToFront:self.recordControlView];
            [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
            [self.contentBaseView bringSubviewToFront:self.playView];
            self.isVedio = NO;
            if (self.isPlaying) {
                self.littleWindowBGView.hidden = NO;
            }else{
                self.littleWindowBGView.hidden = YES;
            }
        }
    }

}

- (void)setUpWindowViewWithType:(NSString *)type{
    self.littleWindowBGView.frame = CGRectMake(SCREEN_HEIGHT - littileWinRect.size.width, SCREEN_WIDTH - littileWinRect.size.width*9/16 - self.recordControlView.bottomView.height, littileWinRect.size.width, littileWinRect.size.width*9/16);
    [self.contentBaseView addSubview:self.littleWindowBGView];
    if (type.integerValue == 2) {
        [self.littleWindowBGView addSubview:self.vodplayer.docSwfView];
        
    }else{
        [self.littleWindowBGView addSubview:self.vodplayer.mVideoView];
        
    }
    self.touchView.frame = CGRectMake(0, 0, littileWinRect.size.width - 60 * XXXRATIO, littileWinRect.size.height -70 *XXXRATIO);
    self.touchView.center = CGPointMake(littileWinRect.size.width/2, littileWinRect.size.height/2);
    [self.littleWindowBGView addSubview:self.touchView];
    [self.littleWindowBGView addSubview:self.windowHiddenButton];
    if (self.pangesture) {
        [self.littleWindowBGView addGestureRecognizer:self.pangesture];
    }
}
- (void)setUpWindowPanGesture{
    self.pangesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.littleWindowBGView addGestureRecognizer:self.pangesture];
}
#pragma --mark 小窗口拖动
- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    self.windowHiddenButton.hidden = NO;
    CGPoint translation = [recognizer translationInView:self.contentBaseView];
    float recx=recognizer.view.center.x + translation.x;
    float recy=recognizer.view.center.y + translation.y;
    
    
        if (self.controlViewHidden) {
            if (recx<littileWinRect.size.width/2) {
                recx=littileWinRect.size.width/2;
            }else if(recx>SCREEN_HEIGHT-littileWinRect.size.width/2){
                recx=SCREEN_HEIGHT-littileWinRect.size.width/2;
            }
            if (recy < littileWinRect.size.height/2) {
                recy = littileWinRect.size.height/2 ;
            }else if (recy > SCREEN_WIDTH  - littileWinRect.size.height/2){
                recy=SCREEN_WIDTH-littileWinRect.size.height/2;
            }
            
        }else{
            if (recx<littileWinRect.size.width/2) {
                recx=littileWinRect.size.width/2;
            }else if(recx>SCREEN_HEIGHT-littileWinRect.size.width/2){
                recx=SCREEN_HEIGHT-littileWinRect.size.width/2;
            }
            if (recy < littileWinRect.size.height/2 + self.recordControlView.topView.height) {
                recy = littileWinRect.size.height/2 + self.recordControlView.topView.height;
            }else if (recy > SCREEN_WIDTH  - littileWinRect.size.height/2 - self.recordControlView.bottomView.height){
                recy=SCREEN_WIDTH-littileWinRect.size.height/2 - self.recordControlView.bottomView.height;
            }
            
        }
        
    
    
    recognizer.view.center = CGPointMake(recx,recy);
    [recognizer setTranslation:CGPointZero inView:self.contentBaseView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//滑动条监听方法
- (void)doSeek:(UISlider*)slider
{
    [self.recordControlView.controlButton  setBackgroundImage:IMAGE(@"pauseImage")forState:UIControlStateNormal];
    self.isPlaying = YES;
    float duratino = slider.value;
    videoRestartValue = slider.value;
    NSString *timeStr = [self positionTime:duratino];
    [self.vodplayer seekTo:duratino];
    self.recordControlView.havePlay.text = timeStr;
    
    
}

//进度条定位播放，如快进、快退、拖动进度条等操作回调方法
- (void) onSeek:(int) position
{
    if (isDragging){
        //点击后刷新控制视图隐藏时间
        if (self.controlHiddenShuffling !=nil) {
            [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
        }
    }
    isDragging = NO;
    //[self.recordControlView.progress setValue:position animated:YES];
    
    
}
//计算进度条时间
- (NSString *)positionTime:(NSInteger)time{
    NSInteger hour = time/1000/60/60;
    NSInteger min = time/1000/60%60;
    NSInteger sec = time/1000%60;
    NSString *hourStr;
    NSString *minStr;
    NSString *secStr;
    NSString *positonStr;
    if (hour < 10) {
        hourStr = [NSString stringWithFormat:@"0%ld",hour];
    }else{
        hourStr = [NSString stringWithFormat:@"%ld",hour];
        
    }
    if (min < 10) {
        minStr = [NSString stringWithFormat:@"0%ld",min];
    }else{
        minStr = [NSString stringWithFormat:@"%ld",min];
        
    }
    if (sec < 10) {
        secStr = [NSString stringWithFormat:@"0%ld",sec];
    }else{
        secStr = [NSString stringWithFormat:@"%ld",sec];
        
    }
    
    positonStr = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minStr,secStr];
    
    return positonStr;
}
- (void)doHold:(UISlider*)slider
{
    isDragging = YES;
}

//播放完成停止通知，
- (void)onStop{
    isDragging = NO;
    self.myliveParam.playstatus=@"1";
    self.littleWindowBGView.hidden = YES;
    [self setRecordcontrolviewSwitchButtonEnble:NO];
    isVideoFinished = YES;
    self.isPlaying = NO;
    [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
    
//    [_firstPlayeButton setBackgroundImage:IMAGE(@"secondplayimage") forState:UIControlStateNormal];
    
    self.recordControlView.havePlay.text = @"00:00:00";
    self.recordControlView.remainPlay.text = [self positionTime:druction];
    self.recordControlView.progress.value=0.0;
    self.playView.hidden = NO;
    [self.contentBaseView bringSubviewToFront:self.playView];
//    _firstPlayeButton.enabled = YES;
    //当只走viewwillApear不走viewdidLoad时，且播放完成一遍，恢复haveDidLoad,让doPause方法走正常流程
  
}

//进度回调方法
- (void)onPosition:(int)position
{
    if (isDragging) {
        return;
    }
    
    [self setRecordcontrolviewSwitchButtonEnble:YES];
    self.playView.hidden = YES;
    self.recordTimeStamp = position;
    self.recordControlView.havePlay.text = [self positionTime:position];
    
    self.recordControlView.remainPlay.text = [self positionTime:druction - position];
    
    
    [self.recordControlView.progress setValue:position animated:YES];
    self.myliveParam.playstatus=@"0";
}



- (void)setRecordcontrolviewSwitchButtonEnble:(BOOL)enble{
    if (enble) {
        self.recordControlView.switchButton.enabled = YES;
    }else{
        self.recordControlView.switchButton.enabled = NO;
    }
}

//点击播放/暂停按钮触发的方法
- (void)doPause
{
    //点击后刷新控制视图隐藏时间
    if (self.controlHiddenShuffling !=nil) {
        [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    if (self.vodplayer) {
        if (isVideoFinished) {
            //播放结后 重新初始vodplayer
            [self.vodplayer OfflinePlay:YES];
            isVideoFinished = NO;
            [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"pauseImage") forState:UIControlStateNormal];
            self.recordControlView.progress.value = 0;
            self.recordTimeStamp = 0;
            self.isPlaying = YES;
        }else if (self.isPlaying){
            //暂停
            [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
            self.isPlaying = NO;
            [self.vodplayer pause];
        }else if (!self.isPlaying ){
            //继续播放或者, pop回来  播放走此方法
            [self.recordControlView.controlButton  setBackgroundImage:IMAGE(@"pauseImage")forState:UIControlStateNormal];
            [self.vodplayer resume];
            self.isPlaying = YES;
        }
    }
}


- (void)returnBack:(UIButton *)action{
    if (self.vodplayer) {
        [self.vodplayer stop];
        self.vodplayer = nil;
        self.item = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
        
        
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    if (self.updateReadtime !=nil) {
        self.updateReadtime(self.recordTimeStamp);
    }
}

- (void)appWillResignActive:(NSNotification *)aNotification {
    [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
    if (self.vodplayer) {
        [self.vodplayer pause];
    }
    self.isPlaying = NO;
}


#pragma mark 判断是否后台播放有效
-(void)addAVAudioSessionNotification{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    
    if  ([self isHeadsetPluggedIn])
    {
        
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        [audioSession setActive:YES error:nil];
        
    }
    else
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        
        [audioSession setActive:YES error:nil];
        
    }
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
