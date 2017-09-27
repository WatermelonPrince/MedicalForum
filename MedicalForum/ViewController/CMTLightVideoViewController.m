//
//  CMTLightVideoViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/6/1.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTLightVideoViewController.h"
#import <PlayerSDK/VodPlayer.h>
#import <PlayerSDK/downItem.h>
#import <PlayerSDK/GSVodDocSwfView.h>
#import <PlayerSDK/VodDownLoader.h>
#import "sys/utsname.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "NSDate+CMTExtension.h"
#import "CMTRecordControlView.h"
#import "CMTLiveShareView.h"
#import "MBProgressHUD.h"
#import "CMTBindingViewController.h"
#import "CMTDownLoadAndStoreView.h"
#import "CMTDownloadManagerView.h"
#import "CMTDownCenterViewController.h"

#define kScreenWidth      [UIScreen mainScreen].bounds.size.width
#define kScreenHeight     [UIScreen mainScreen].bounds.size.height
#define kButtonWidth      60
#define kButtonHeight     20

@interface CMTLightVideoViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,VodPlayDelegate,UIWebViewDelegate>

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

@property (nonatomic, strong) NSString *vodId;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UISlider *progress;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIImageView *docImageView;
@property (nonatomic, strong) CMTLivesRecord *myVideoParam;
@property (nonatomic, strong) VodDownLoader *voddownloader;
@property (nonatomic, strong) CMTRecordControlView *recordControlView;
@property (nonatomic, strong) UITableView *tableView;//目录
@property (nonatomic, strong) UIWebView *liveteilWebdetails;//详情
@property (nonatomic, strong) UIView *switchView;//目录详情切换
@property (nonatomic, strong) UIView *lineView; //绿色线条;
@property (nonatomic, strong) UIButton *listButoon;//目录
@property (nonatomic, strong) UIButton *detailBUtoon;//详情；

@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) UIScrollView *contentSrollView;//装目录跟

@property (nonatomic, strong)UIAlertView *alertView;
@property (nonatomic, assign)NSInteger timestamp;//didSelectedCell时记录要跳转的播放进度


@property (nonatomic, assign)BOOL isPlaying;//点播的播放状态，YES 为正在播放，NO为暂停活停止播放
@property (nonatomic, assign)BOOL isFirstPlay;//是否是第一次播放
@property (nonatomic,assign)BOOL  isRecordPlayTime;

@property(nonatomic,assign)BOOL isVedio;//当前画面是视频为YES
@property (nonatomic, assign)BOOL controlViewHidden;
@property (nonatomic, assign)BOOL hasFinishOnce;//视频已经结束播放过一次  onStop方法触发后为YES,视频重新播放后，重新置为NO
@property(nonatomic,strong)CMTLiveShareView *ShareView;

@property (nonatomic, strong)UIImageView *playView;//默认播放视tu
@property (nonatomic, strong)UIButton *firstPlayeButton;//第一次播放

@property (nonatomic, assign)NSInteger recordTimeStamp;//记录离开控制器时，视频的进度条时间
@property (nonatomic, assign)BOOL haveDidLoad;//push进来时走viewdidload,值为YES,pop进来只走viewwillAppear 为NO
@property (nonatomic, assign)BOOL appearSeekTo;//pop进来有3种状态，未开始状态，结束状态，已播放过的状态，
@property (nonatomic, assign)BOOL appearFinished;//pop进来后，onStop 结束状态触发过一次后，为YES

@property (strong, nonatomic)MBProgressHUD *progressHUD;

@property (strong, nonatomic)UIView *clearBgView;
@property (assign,nonatomic)NSInteger switchFlag;//记录离开时scrollView的位置，1为目录页，2为详情页
@property (strong, nonatomic)NSString *nextVC;
@property (strong, nonatomic)UIView *littleWindowBGView;//小窗口背景视图；s
@property (strong, nonatomic)UIView *touchView;//小窗口手势添加View;
@property (strong, nonatomic)UIButton *windowHiddenButton;//小窗口隐藏button;
@property (strong, nonatomic)UIPanGestureRecognizer *pangesture;
@property (nonatomic,assign)BOOL hasPPT;//是否有PPT;
@property (nonatomic, strong)UIButton *returnBackBtn;//返回上级btn;
@property(nonatomic,strong) NSTimer *controlHiddenShuffling;//控制视图隐藏的计时器;
@property (nonatomic,strong)UIImageView *backGroudImageView;//数据未回来时底部背景图
@property (nonatomic,strong)UIButton *shareButton;//分享
@property (nonatomic, strong)CMTDownLoadAndStoreView *loadAndStoreView;
@property (nonatomic,assign)BOOL isneedUpdateState;
@property (nonatomic,assign)BOOL isDelete;//防止下线重复请求，回调删除列表数据重复发生；
@property (nonatomic, assign)BOOL isOutVedio;//退出视频
@property(nonatomic,strong)  CMTDownloadManagerView *Download;
@property (nonatomic,assign)BOOL isrequirePause;//切换运营商网络  是否需要暂停标志
@property (nonatomic, assign)BOOL littelWindowHidden;//小串口隐藏标志
@end

@implementation CMTLightVideoViewController

- (CMTDownLoadAndStoreView *)loadAndStoreView{
    if (!_loadAndStoreView) {
        _loadAndStoreView = [[CMTDownLoadAndStoreView alloc]initWithFrame:CGRectMake(-5, SCREEN_HEIGHT - 44, SCREEN_WIDTH + 10, 44)];
        _loadAndStoreView.backgroundColor = ColorWithHexStringIndex(c_ffffff);
        _loadAndStoreView.layer.shadowOffset = CGSizeMake(0, -1);
        _loadAndStoreView.layer.shadowColor = ColorWithHexStringIndex(c_32c7c2).CGColor;
        _loadAndStoreView.layer.shadowOpacity = 0.5;
         [_loadAndStoreView.storeContorl addTarget:self action:@selector(storeAction:) forControlEvents:UIControlEventTouchUpInside];
         [_loadAndStoreView.storeBtn addTarget:self action:@selector(storeAction:) forControlEvents:UIControlEventTouchUpInside];
        [[RACObserve(self.myliveParam, isStore)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString * x) {
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
    if([CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.haveDownloadedList classID:self.myliveParam.classRoomId]||[CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.downloadList classID:self.myliveParam.classRoomId]){
        NSLog(@"已经下载完成");
        CMTNavigationController * navigation=[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
        BOOL flag=[CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.haveDownloadedList classID:self.myliveParam.classRoomId];
         self.nextVC = @"CMTDownCenterViewController";
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
        self.Download=[[CMTDownloadManagerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,  SCREEN_HEIGHT-SCREEN_WIDTH * 9/16)];
         [self.contentBaseView addSubview:self.Download];
        self.Download.parent=self;
        self.Download.tag=10000;
        [self.Download reloadData:self.myliveParam];
        @weakify(self);
        self.Download.updateDemanDownstate=^(NSString* str){
             @strongify(self);
             self.loadAndStoreView.downlabel.text=@"下载中";
        };
        
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self);
             self.Download.top=SCREEN_WIDTH * 9/16;
        } completion:^(BOOL finished) {
             @strongify(self);
            [self.contentBaseView bringSubviewToFront:self.Download];
        }];
    }
}

#pragma __收藏
- (void)storeAction:(UIButton *)sender{

    if (!CMTUSER.login) {
        self.isneedUpdateState=YES;
        CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
        bing.nextvc=kComment;
        self.nextVC = @"blindVC";
        self.littleWindowBGView.hidden = YES;
        self.shareButton.hidden = NO;
        [self.navigationController pushViewController:bing animated:YES];
        return;
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
                if (self.myliveParam.dataId !=nil) {
                [dleteArr addObject:self.myliveParam.dataId];
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
                    self.myliveParam.isStore = @"0";
                    self.myliveParam.isrefresh = YES;
                    if (self.updateReadNumber) {
                        self.updateReadNumber(self.myliveParam);
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
                           @"classRoomId":self.myliveParam.classRoomId?:@"",
                           @"coursewareId":self.myliveParam.coursewareId?:@"",
                           };
    @weakify(self);
    [[[CMTCLIENT CMTStoreVideoAction:pDic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord * x) {
        CMTLog(@"课程收藏成功");
        [self toastAnimation:@"收藏成功" top:0];
        [self.loadAndStoreView.storeBtn changeScaleWithAnimate];
        self.loadAndStoreView.storeBtn.selected = YES;
        self.myliveParam.isStore = @"1";
        self.myliveParam.dataId = x.dataId;

    } error:^(NSError *error) {
        if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
            @strongify(self);
            [self toastAnimation:@"你的网络不给力" top:0];
        }else{
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"] top:0];
        }
    }];
}

- (UIImageView *)backGroudImageView{
    if (_backGroudImageView == nil) {
        _backGroudImageView = [[UIImageView alloc]initWithFrame:docViewRect];
        _backGroudImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backGroudImageView.layer.masksToBounds = YES;
        _backGroudImageView.image = IMAGE(@"recordedDefaultimage");
        UIImageView *playimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 78, 78)];
        playimage.image = IMAGE(@"firstPlayimage");
        playimage.centerX = _backGroudImageView.bounds.size.width/2;
        playimage.centerY = _backGroudImageView.bounds.size.height/2;
        [_backGroudImageView addSubview:playimage];
    }
    return _backGroudImageView;
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
#pragma --mark窗口退出按钮hidden方法
-(void)windowHiddenButtonShowAndHidden:(UITapGestureRecognizer *)tap{
    self.windowHiddenButton.hidden = !self.windowHiddenButton.hidden;
}

- (UIButton *)windowHiddenButton{
    if (!_windowHiddenButton) {
        _windowHiddenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_windowHiddenButton setBackgroundImage:IMAGE(@"CloseLiveimage") forState:UIControlStateNormal];
        _windowHiddenButton.frame = CGRectMake(3, 3, 30, 30);
        _windowHiddenButton.hidden = YES;
        _windowHiddenButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            self.littleWindowBGView.hidden = YES;
            self.littelWindowHidden = YES;
            self.hasPPT = YES;
            return [RACSignal empty];
        }];

    }
    return _windowHiddenButton;
}
#pragma --mark 小窗口拖动
- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    self.windowHiddenButton.hidden = NO;
    CGPoint translation = [recognizer translationInView:self.contentBaseView];
    float recx=recognizer.view.center.x + translation.x;
    float recy=recognizer.view.center.y + translation.y;

    if(isfullScreen){
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
        
    }else{
       
        if (recx<littileWinRect.size.width/2) {
            recx=littileWinRect.size.width/2;
        }else if(recx>SCREEN_WIDTH-littileWinRect.size.width/2){
            recx=SCREEN_WIDTH-littileWinRect.size.width/2;
        }
        if (recy<64 + littileWinRect.size.height/2) {
            recy=64 + littileWinRect.size.height/2;
        }else if(recy>SCREEN_HEIGHT-littileWinRect.size.height/2){
            recy=SCREEN_HEIGHT-littileWinRect.size.height/2;
        }
 
    }
    
    
    recognizer.view.center = CGPointMake(recx,recy);
    [recognizer setTranslation:CGPointZero inView:self.contentBaseView];

}

- (UIView *)clearBgView{
    if (!_clearBgView) {
        _clearBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _clearBgView;
}

-(UIImageView*)playView{
    if (_playView==nil) {
        _playView=[[UIImageView alloc]initWithFrame:docViewRect];
        [_playView setImageURL:self.myliveParam.roomPic placeholderImage:IMAGE(@"recordedDefaultimage") contentSize:CGSizeMake(docViewRect.size.width, docViewRect.size.height)];
        _playView.contentMode=UIViewContentModeScaleAspectFill;
        _playView.clipsToBounds=YES;
        _playView.userInteractionEnabled=YES;
        [_playView addSubview:self.firstPlayeButton];
    }
    return _playView;
}
//第一次播放
- (UIButton *)firstPlayeButton{
    if (!_firstPlayeButton) {
        _firstPlayeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _firstPlayeButton.frame = CGRectMake(0,0, 78, 78);
        _firstPlayeButton.centerX = self.playView.bounds.size.width/2;
        _firstPlayeButton.centerY = self.playView.bounds.size.height/2;
         [_firstPlayeButton setBackgroundImage:IMAGE(@"firstPlayimage") forState:UIControlStateNormal];
        [_firstPlayeButton setBackgroundImage:IMAGE(@"firstPlayimage") forState:UIControlStateHighlighted];
        @weakify(self);
        _firstPlayeButton.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            return [self ClickPlayButton];
        }];
    }
    return _firstPlayeButton;
}
-(RACSignal*)ClickPlayButton{
    //播放后隐藏分享按钮
    self.shareButton.hidden = YES;
    //播放后倒计时隐藏控制视图
    if (self.controlHiddenShuffling == nil) {
        self.controlHiddenShuffling = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(hiddenShufflingControlView) userInfo:nil repeats:YES];
    }
    [[NSRunLoop currentRunLoop] addTimer:self.controlHiddenShuffling forMode:NSRunLoopCommonModes];
    
    [self showAndShfflingControlView];
    
    self.littleWindowBGView.hidden = YES;
    if ([self getNetworkReachabilityStatus].integerValue==0) {
        [self toastAnimation:@"无法连接到网络，请检查网络设置" top:0];
        return [RACSignal empty];
    }
    if ([self getNetworkReachabilityStatus].integerValue==1) {
        self.alertView=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看" message:nil delegate:nil
                                       cancelButtonTitle:@"取消" otherButtonTitles:@"继续播放", nil];
        [self.alertView show];
        [self.vodplayer pause];
        self.isrequirePause = YES;
        [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
        @weakify(self)
        [[[self.alertView rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if ([index integerValue] == 1) {
                self.isrequirePause = NO;
                //统计观看人员
                if (self.hasPPT && CMTUSER.login) {
                    self.littleWindowBGView.hidden = NO;
                }
                self.myliveParam.classRoomType=@"2";
                [self StatisticsThenumber:self.myliveParam];
                [self doPause];
                self.playView.hidden=YES;
                [_firstPlayeButton setBackgroundImage:IMAGE(@"secondplayimage") forState:UIControlStateNormal];
                [self setRecordcontrolviewSwitchButtonEnble:YES];
                if(!self.isRecordPlayTime){
                    self.isRecordPlayTime=YES;
                }
                
            }else{
                [self returnBack:nil];
            }
        }];
        
    }else{
        self.myliveParam.classRoomType=@"2";
        [self StatisticsThenumber:self.myliveParam];
        if (self.hasPPT && CMTUSER.login) {
            self.littleWindowBGView.hidden = NO;
        }
        [self doPause];
        self.playView.hidden=YES;
        [_firstPlayeButton setBackgroundImage:IMAGE(@"secondplayimage") forState:UIControlStateNormal];
        [self setRecordcontrolviewSwitchButtonEnble:YES];
        if(!self.isRecordPlayTime){
            self.isRecordPlayTime=YES;
        }
    }
    return [RACSignal empty];

}

- (NSMutableArray *)dateArray{
    if (!_dateArray) {
        self.dateArray = [NSMutableArray array];
    }
    return _dateArray;
}
-(CMTLiveShareView*)ShareView{
    if (_ShareView==nil) {
        _ShareView=[[CMTLiveShareView alloc]init];
        _ShareView.parentView=self;
        @weakify(self);
        _ShareView.updateUsersnumber=^(CMTLivesRecord*rect){
            @strongify(self);
            self.myliveParam.users=rect.users;
            if (self.updateReadNumber!=nil) {
                self.updateReadNumber(self.myliveParam);
            }
        };
        _ShareView.LivesRecord=[self.myliveParam copy];
        _ShareView.LivesRecord.classRoomType=@"2";
    }
    return _ShareView;
}
//分享
- (void)shareViewShowAction{
    [self showAndShfflingControlView];
    [self.ShareView showSharaAction];
}

- (UIScrollView *)contentSrollView{
    if (!_contentSrollView) {
        self.contentSrollView = [[UIScrollView alloc]init];
        self.contentSrollView.frame = CGRectMake(0, self.switchView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - self.switchView.bottom - 44);
        self.contentSrollView.contentSize = CGSizeMake(SCREEN_WIDTH *2, SCREEN_HEIGHT - self.switchView.bottom - 44);
        self.contentSrollView.bounces = NO;
        self.contentSrollView.pagingEnabled = YES;
        self.contentSrollView.delegate = self;
        self.contentSrollView.showsHorizontalScrollIndicator = NO;
    }
    return _contentSrollView;
}


- (UIView *)switchView{
    if (_switchView == nil) {
        _switchView = [[UIView alloc]initWithFrame:CGRectMake(0, 9/16 * SCREEN_WIDTH + 64, SCREEN_WIDTH,43)];
    }
    return _switchView;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = ColorWithHexStringIndex(c_32c7c2);

        _lineView.frame = CGRectMake(0, 40, SCREEN_WIDTH/2, 2);
    }
    return _lineView;
}

- (UIButton *)listButoon{
    if (!_listButoon) {
        _listButoon = [UIButton buttonWithType:UIButtonTypeCustom];
        _listButoon.frame = CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 40);
        [_listButoon setTitle:@"目录" forState:UIControlStateNormal];
        _listButoon.titleLabel.font = FONT(15);
        [_listButoon setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
        [_listButoon addTarget:self action:@selector(switchList) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listButoon;
}
- (UIButton *)detailBUtoon{
    if (!_detailBUtoon) {
        _detailBUtoon = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailBUtoon.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, 40);
        [_detailBUtoon setTitle:@"详情" forState:UIControlStateNormal];
        _detailBUtoon.titleLabel.font=FONT(15);
         [_detailBUtoon setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateNormal];
        [_detailBUtoon addTarget:self action:@selector(switchDetail) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailBUtoon;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.backgroundColor =COLOR(c_ffffff);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        
    }
    return _tableView;
}

-(UIWebView*)liveteilWebdetails{
    if(_liveteilWebdetails==nil){
        _liveteilWebdetails=[[UIWebView alloc]init];
        _liveteilWebdetails.backgroundColor = ColorWithHexStringIndex(c_ffffff);
        _liveteilWebdetails.delegate=self;
        NSURL *URL=[[NSURL alloc]initWithString:[[CMTClient defaultClient].baseURL.absoluteString stringByAppendingString:self.myliveParam.desUrl]];
        
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
        [_liveteilWebdetails loadRequest:request];
    }
    return _liveteilWebdetails;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *URLString = request.URL.absoluteString;
    NSString *URLScheme =request.URL.scheme;

    return [self handleWithinLightVedio:URLString URLScheme:URLScheme viewController:self];
}
- (void)setupSwitchView{
    [self.switchView addSubview:self.listButoon];
    [self.switchView addSubview:self.detailBUtoon];
    [self.switchView addSubview:self.lineView];
    self.switchView.frame = CGRectMake(0, SCREEN_WIDTH * 9/16, SCREEN_WIDTH, 43);
    UIView *bottomlineView = [[UIView alloc]initWithFrame:CGRectMake(0, 42, SCREEN_WIDTH, 1)];
    bottomlineView.backgroundColor = ColorWithHexStringIndex(c_f6f6f6);
    [self.switchView addSubview:bottomlineView];
    [self.contentBaseView addSubview:self.switchView];
    [self.contentBaseView addSubview:self.contentSrollView];
    
}
- (void)setUpTableViewAndWebView{
    self.liveteilWebdetails.frame = CGRectMake(0, 0, self.contentSrollView.width, self.contentSrollView.height);
    
    self.tableView.frame = CGRectMake(SCREEN_WIDTH, 0, self.contentSrollView.width, self.contentSrollView.height);
    
    
    [self.contentSrollView addSubview:self.tableView];
    [self.contentSrollView addSubview:self.liveteilWebdetails];
}
- (void)setUpWindowViewWithType:(NSString *)type{
    self.littleWindowBGView.frame = littileWinRect;
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

- (VodDownLoader *)voddownloader{
    if (_voddownloader == nil) {
        _voddownloader = [[VodDownLoader alloc]init];
    }
    _voddownloader.delegate = self;
    return _voddownloader;
}
- (void)switchList{
    [self.listButoon setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateNormal];
    [self.detailBUtoon setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];

    self.lineView.frame = CGRectMake(SCREEN_WIDTH/2, self.lineView.top, SCREEN_WIDTH/2, self.lineView.height);

    [self.contentSrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
   
    self.switchFlag = 1;
}
- (void)switchDetail{
    [self.detailBUtoon setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateNormal];
    [self.listButoon setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];

    self.lineView.frame = CGRectMake(0, self.lineView.top, SCREEN_WIDTH/2, self.lineView.height);

    [self.contentSrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.switchFlag = 2;
}

#pragma scrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[UITableView class]]) {
        
    }else{
        if (scrollView.contentOffset.x/SCREEN_WIDTH==1) {
            [self.listButoon setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateNormal];
            [self.detailBUtoon setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];

            self.lineView.frame = CGRectMake(SCREEN_WIDTH/2 , self.lineView.top, SCREEN_WIDTH/2, self.lineView.height);

            self.switchFlag = 1;
        }else if(scrollView.contentOffset.x == 0){
            [self.detailBUtoon setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateNormal];
            [self.listButoon setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];

            self.lineView.frame = CGRectMake(0, self.lineView.top, SCREEN_WIDTH/2, self.lineView.height);

            self.switchFlag = 2;
        }
    }
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"点播页面 willDeallocSignal");
    }];
    //监听PPT数据是否返回
    [[RACObserve(self, hasPPT)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber * x) {
        if (x.integerValue == 1) {
            if (self.isPlaying && self.littelWindowHidden == NO) {
                self.recordControlView.switchButton.hidden = NO;
                self.littleWindowBGView.hidden = NO;
            }
        }
        
    }];
    //当播放状态是正在播放时，有PPT显示PPT,无PPT不显示PPT
    [[[RACObserve(self, isPlaying)distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber * x) {
        if (x.integerValue == 1) {
            if (self.hasPPT && self.littelWindowHidden == NO) {
                self.littleWindowBGView.hidden = NO;
            }else{
                self.littleWindowBGView.hidden = YES;
            }
        }else{
            self.littleWindowBGView.hidden = YES;
        }
    }];
    
    self.isRecordPlayTime=NO;
     self.switchFlag = 1;
    self.haveDidLoad = YES;
    self.titleText=self.myliveParam.title;
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    [self  addAVAudioSessionNotification];
    [self setupSwitchView];
    [self setUpTableViewAndWebView];
    //获取直播间状态
    [self GetDemandState];
    //如果未下线则加载点播流
    if(self.myliveParam.status.integerValue==0){
        [self.voddownloader addItem:self.myliveParam.studentJoinUrl number:self.myliveParam.number loginName:CMTUSERINFO.nickname?:@"壹生游客" vodPassword:self.myliveParam.studentClientToken?:nil loginPassword:nil downFlag:0 serType:self.myliveParam.serviceType oldVersion:NO kToken:nil  customUserID:0];
        self.voddownloader.delegate = self;
    }
    isVideoFinished = NO;
    videoRestartValue = 0;
    
    CGFloat y = 20;
    videoViewRect = CGRectMake(0,  0, kScreenWidth, kScreenWidth*9/16 - 2);
    docViewRect = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
    littileWinRect = CGRectMake(SCREEN_WIDTH - 625/3 *XXXRATIO, self.contentSrollView.top, 625/3 * XXXRATIO, 625/3 * XXXRATIO * 9 / 16);
     [self setNeedsStatusBarAppearanceUpdate];
    // 监控 app 活动状态，打电话/锁屏 时暂停播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    //根据网络状态 弹出不同的提示
    @weakify(self);
    [[[RACObserve([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus)
       deliverOn:[RACScheduler mainThreadScheduler]]distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        CMTNavigationController *nav=[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
        if ([nav.topViewController isKindOfClass:[CMTLightVideoViewController class]]) {
            if (!self.playView.hidden) {
                
            }else{
                if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable) {
                [self outFullScreen];
                [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
                self.alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"你的网络已断开" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [self.alertView show];
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                
            }else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWiFi) {
                [self outFullScreen];
                [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
                self.alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"已连接至wifi" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [self.alertView show];
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                CMTLogError(@"APPCONFIG Reachability Error Value: %@", CMTAPPCONFIG.reachability);
            }
            else if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWWAN){
                [self outFullScreen];
                [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
                [self.vodplayer pause];
                self.isrequirePause = YES;
                [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
                if(self.alertView==nil){
                     self.alertView=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看" message:nil delegate:nil
                                                       cancelButtonTitle:@"取消" otherButtonTitles:@"继续播放", nil];
                    [self.alertView show];
                    @weakify(self)
                    [[[self.alertView rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
                        @strongify(self);
                        if ([index integerValue] == 1) {
                            [self.recordControlView.controlButton  setBackgroundImage:IMAGE(@"pauseImage")forState:UIControlStateNormal];
                            [self.vodplayer resume];
                            self.isrequirePause = NO;
                            
                        }else{
                            [self returnBack:nil];
                        }
                    }];
              }
            }
          }
        }
    } error:^(NSError *error) {
        
    }];
    [self.contentBaseView addSubview:self.backGroudImageView];
    self.returnBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnBackBtn.frame = CGRectMake(10, 10, 110/3, 110/3);
    //    _returnBackBtn.bottom = self.recordControlView.switchButton.bottom;
    [_returnBackBtn setBackgroundImage:IMAGE(@"livebackImage") forState:UIControlStateNormal] ;
    [_returnBackBtn addTarget:self action:@selector(returnBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBaseView addSubview:_returnBackBtn];
    [self setContentState:CMTContentStateLoading moldel:@"1" height:44];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareButton.frame = CGRectMake(SCREEN_WIDTH - 10 - 110/3, 10, 110/3, 110/3);
    [_shareButton setBackgroundImage:IMAGE(@"liveShareImage") forState:UIControlStateNormal] ;
    [_shareButton addTarget:self action:@selector(shareViewShowAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBaseView addSubview:_shareButton];
    [self.contentBaseView addSubview:self.loadAndStoreView];

}

- (void)showMBProgressHUDView{
    [self.contentBaseView addSubview:self.clearBgView];
    [self.contentBaseView bringSubviewToFront:self.clearBgView];
    self.progressHUD = [[MBProgressHUD alloc]initWithView:self.clearBgView];
    [self.clearBgView addSubview:self.progressHUD];
    self.progressHUD.labelText =  @"视频连接中";
    [self.progressHUD show:YES];
}

- (void)hiddenMBProgressHUDView{
    [self.progressHUD hide:YES];
    [self.clearBgView removeFromSuperview];
    self.clearBgView = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    //设置阻止锁屏代码
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if (!self.vodplayer && !self.haveDidLoad && ([self.nextVC isEqualToString: @"CMTSeriesDetailsViewController"]||[self.nextVC isEqualToString:@"CmtMoreVideoViewController"]||[self.nextVC isEqualToString: @"CMTDownCenterViewController"])) {
        [self.voddownloader addItem:self.myliveParam.studentJoinUrl number:self.myliveParam.number loginName:CMTUSERINFO.nickname?:@"壹生游客" vodPassword:self.myliveParam.studentClientToken?:nil loginPassword:nil downFlag:0 serType:self.myliveParam.serviceType oldVersion:NO kToken:nil customUserID:0];
        self.voddownloader.delegate = self;
        isVideoFinished = NO;
        videoRestartValue = 0;

        [self showMBProgressHUDView];
        [self setRecordcontrolviewSwitchButtonEnble:NO];
        [self.vodplayer resetAudioPlayer];
        if (self.switchFlag == 1) {
            [self.listButoon setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateNormal];
            [self.detailBUtoon setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];

            self.lineView.frame = CGRectMake(SCREEN_WIDTH/2 , self.lineView.top, SCREEN_WIDTH/2 , self.lineView.height);

            [self.contentSrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
        }else{
            [self.detailBUtoon setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateNormal];
            [self.listButoon setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
          
            

            self.lineView.frame = CGRectMake(0, self.lineView.top, SCREEN_WIDTH/2 , self.lineView.height);

            [self.contentSrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        self.firstPlayeButton.enabled = NO;
        self.nextVC = nil;
    }else{
        if ([self.nextVC isEqualToString:@"blindVC"]) {
            [self.firstPlayeButton setBackgroundImage:IMAGE(@"firstPlayimage") forState:UIControlStateNormal];
             [_firstPlayeButton setBackgroundImage:IMAGE(@"firstPlayimage") forState:UIControlStateHighlighted];
            self.playView.hidden = NO;
            self.nextVC = nil;
            self.navigationController.navigationBar.hidden = YES;
            self.navigationController.navigationBar.translucent = YES;
            
        }
        if (!self.haveDidLoad) {
            //防止二次进入导致切换按钮丢失
            self.navigationController.navigationBar.hidden = YES;
            self.navigationController.navigationBar.translucent = YES;
        }
        self.contentSrollView.contentOffset = CGPointMake(0, 0);
        //初始停留在详情页面;
        [self.detailBUtoon setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateNormal];
        [self.listButoon setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];

        self.lineView.frame = CGRectMake(0, self.lineView.top, SCREEN_WIDTH/2, self.lineView.height);
              self.switchFlag = 2;
    }
    if(self.isneedUpdateState&&CMTUSER.login){
        [self GetDemandState];
    }
     self.isneedUpdateState=NO;
    if([CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.haveDownloadedList classID:self.myliveParam.classRoomId]){
        self.loadAndStoreView.downlabel.text=@"已下载";
    }else if([CMTDownLoad checkClassRoomIsDown:CMTAPPCONFIG.downloadList classID:self.myliveParam.classRoomId]){
        self.loadAndStoreView.downlabel.text=@"下载中";
    }else{
        self.loadAndStoreView.downlabel.text=@"下载";
    }

}
#pragma mark 获取点播课程状态
-(void)GetDemandState{
     NSDictionary *params = @{
                                 @"userId":CMTUSERINFO.userId?:@"0",
                                 @"coursewareId":self.myliveParam.coursewareId?:@"0",
                                 @"roomId":self.myliveParam.classRoomId?:@"0",
                                 @"actionType":@"0",
                                 };

 @weakify(self);
  [[[CMTCLIENT CMTGetVideoPlayStatus:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *x) {
    @strongify(self);
    self.myliveParam.playDuration=x.playDuration;
    self.myliveParam.playstatus=x.playstatus;
    self.myliveParam.islearn=x.islearn;
    self.myliveParam.isStore = x.isStore;
    self.myliveParam.dataId = x.dataId.length==0?self.myliveParam.dataId:x.dataId;
    if (x.status.integerValue == 1) {
        self.myliveParam.status=x.status;
        [self setContentState:CMTContentStateEmpty];
        self.contentEmptyView.contentEmptyPrompt=@"该课程已下线";
        self.contentEmptyView.centerY = self.contentEmptyView.centerY - 64;
        [self.contentEmptyView addSubview:self.returnBackBtn];
        self.returnBackBtn.hidden = NO;
        if (self.updateReadNumber!=nil) {
            self.updateReadNumber(nil);
        }
    }else{
//        if(self.myliveParam.islearn.integerValue==1){
//            [self ClickPlayButton];
//            if (self.hasPPT && CMTUSER.login) {
//                self.littleWindowBGView.hidden = NO;
//            }
//            [self.vodplayer seekTo:self.myliveParam.playDuration.intValue];
//        }
    }
} error:^(NSError *error) {
    
}];
}
- (void)viewWillDisappear:(BOOL)animated{
     [super viewWillDisappear:animated];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    self.navigationController.navigationBar.hidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    if ([self.nextVC isEqualToString: @"CMTSeriesDetailsViewController"]||[self.nextVC isEqualToString:@"CmtMoreVideoViewController"]||[self.nextVC isEqualToString: @"CMTDownCenterViewController"]) {
        if (self.isPlaying == YES) {
            [self.vodplayer stop];
        }
        self.vodplayer = nil;
    }else{
        if (self.isPlaying) {
            [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
            [self.vodplayer pause];
            self.isPlaying = NO;
        }
        
    }
    self.haveDidLoad = NO;
    [self setRecordcontrolviewSwitchButtonEnble:NO];
    //设置阻止锁屏代码
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    
    //当退出视频时停止并注销播放器
    if (self.isOutVedio) {
        if (self.vodplayer) {
            [self.vodplayer stop];
            self.vodplayer = nil;
            self.item = nil;
        }
    }
    
   
    
}
-(void) performDismiss:(NSTimer *)timer
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    self.alertView=nil;
}

- (void)appWillResignActive:(NSNotification *)aNotification {
    [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
    if (self.vodplayer) {
        [self.vodplayer pause];
    }
    self.isPlaying = NO;
    [self RecordDemandViewingTime];
}






////设置后台运行
- (void)enterBackground
{

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
}

//视频旋转方法
- (void)totationVideoView:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.controlHiddenShuffling !=nil) {
        [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    if (self.isVedio) {
        [self totationView:gestureRecognizer whichView:YES];
    }else{
        [self totationView:gestureRecognizer whichView:NO];
    }
    
}

#pragma mark 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    if(isfullScreen){
        return YES;
    }else{
        if (self.controlViewHidden) {
            return YES;
        }else{
            return YES;

        }
    }
}

#pragma  --mark强制旋转方法(YES:videoView全屏  NO:docView全屏)

- (void)totationView:(UIGestureRecognizer *)gestureRecognizer whichView:(BOOL) touchVideoView
{
    if (!isfullScreen) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.contentBaseView.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.contentBaseView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            if (touchVideoView) {
                self.vodplayer.mVideoView.frame =  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
               
                
                
            }else{

                self.vodplayer.docSwfView.frame =  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
               
            }
             [self.recordControlView resetFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH) isFullMode:YES];
            self.littleWindowBGView.frame = CGRectMake(SCREEN_HEIGHT - littileWinRect.size.width, SCREEN_WIDTH - littileWinRect.size.width*9/16 - self.recordControlView.bottomView.height, littileWinRect.size.width, littileWinRect.size.width*9/16);
            self.contentSrollView.hidden = YES;
            
            
            
            if ( !self.isPlaying) {
                [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
                
            }else{
                [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"pauseImage") forState:UIControlStateNormal];
            }
            
            isfullScreen = YES;
            self.navigationController.navigationBarHidden = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
        
        self.recordControlView.returnButton.hidden = NO;
        self.returnBackBtn.hidden = YES;
        self.hasPPT = self.hasPPT;
        self.contentSrollView.hidden = YES;
         self.Download.hidden=YES;
        self.switchView.hidden = YES;
        self.recordControlView.shareButton.hidden = YES;
       
    } else {
        [UIView animateWithDuration: 0.5 animations:^{
            self.contentBaseView.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(0));
            self.contentBaseView.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            if (touchVideoView) {
                self.vodplayer.mVideoView.frame = videoViewRect;
            }else{
                self.vodplayer.docSwfView.frame = videoViewRect;
            }
            [self.contentBaseView bringSubviewToFront:self.recordControlView];

            self.littleWindowBGView.frame = littileWinRect;
            self.contentSrollView.hidden = NO;
            [self.recordControlView resetFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9/16) isFullMode:NO];
            self.recordControlView.hidden = NO;
            isfullScreen = NO;
            self.navigationController.navigationBarHidden = YES;
            [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
            [self setNeedsStatusBarAppearanceUpdate];
           
            
        }];
        self.recordControlView.returnButton.hidden = YES;
        self.returnBackBtn.hidden = NO;
        [self.contentBaseView bringSubviewToFront:self.returnBackBtn];
        self.hasPPT = self.hasPPT;
        self.contentSrollView.hidden = NO;
         self.Download.hidden=NO;
        self.switchView.hidden = NO;
        self.recordControlView.shareButton.hidden = NO;


    }
}

//强制退出全屏
- (void)outFullScreen{
    if (isfullScreen) {
        [UIView animateWithDuration: 0.5 animations:^{
            self.contentBaseView.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(0));
            self.contentBaseView.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            if (self.isVedio) {
               
                self.vodplayer.mVideoView.frame = videoViewRect;
                
              
                
            }else{
                self.vodplayer.docSwfView.frame = videoViewRect;
                
            }
            [self.contentBaseView bringSubviewToFront:self.recordControlView];

            self.littleWindowBGView.frame = littileWinRect;
            [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
            self.contentSrollView.hidden = NO;
            self.recordControlView.hidden = NO;
            [self.recordControlView resetFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9/16) isFullMode:NO];
            
            isfullScreen = NO;
            //            注意显示状态栏和显示navigationbar顺序
            self.navigationController.navigationBarHidden = YES;
           [self setNeedsStatusBarAppearanceUpdate];
            
            self.recordControlView.returnButton.hidden = YES;
            self.returnBackBtn.hidden = NO;
            [self.contentBaseView bringSubviewToFront:self.returnBackBtn];
            self.hasPPT = self.hasPPT;
            self.contentSrollView.hidden = NO;
            self.Download.hidden=NO;
            self.switchView.hidden = NO;
            self.recordControlView.shareButton.hidden = NO;

            
        }];
    }
}
#pragma --mark//切换控制

- (void)switchDocAndPlayAction:(UIButton *)button{
    if (self.controlHiddenShuffling !=nil) {
        [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    if (self.isVedio) {
        if (isfullScreen) {
            self.windowHiddenButton.hidden = YES;
            if (self.littleWindowBGView.hidden) {
                self.littleWindowBGView.hidden = NO;
                self.littelWindowHidden = NO;

            }else{
                [self.vodplayer.docSwfView removeFromSuperview];
                [self.vodplayer.mVideoView removeFromSuperview];
                self.vodplayer.docSwfView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
                [self.contentBaseView addSubview:self.vodplayer.docSwfView];
                [self.contentBaseView bringSubviewToFront:self.recordControlView];

                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
                
                self.vodplayer.mVideoView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);
                [self.littleWindowBGView addSubview:self.vodplayer.mVideoView];
                [self.littleWindowBGView bringSubviewToFront:self.touchView];
                [self.littleWindowBGView bringSubviewToFront:self.windowHiddenButton];
                self.isVedio = NO;
                [self.contentBaseView bringSubviewToFront:self.returnBackBtn];
            }

        }else{
            self.windowHiddenButton.hidden = YES;
            
            if (self.littleWindowBGView.hidden) {
                self.littleWindowBGView.hidden = NO;
                self.littelWindowHidden = NO;
                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];


            }else{
                [self.vodplayer.docSwfView removeFromSuperview];
                [self.vodplayer.mVideoView removeFromSuperview];
                self.littleWindowBGView.hidden = NO;
                self.vodplayer.docSwfView.frame = docViewRect;
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
                [self.contentBaseView bringSubviewToFront:self.returnBackBtn];
            }
        }
       

    }else{
        if (isfullScreen) {
            self.windowHiddenButton.hidden = YES;

            if (self.littleWindowBGView.hidden ) {
                self.littleWindowBGView.hidden = NO;
                self.littelWindowHidden = NO;


            }else{
                [self.vodplayer.docSwfView removeFromSuperview];
                [self.vodplayer.mVideoView removeFromSuperview];
                self.vodplayer.mVideoView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
                [self.contentBaseView addSubview:self.vodplayer.mVideoView];
                [self.contentBaseView bringSubviewToFront:self.recordControlView];

                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
                
                self.vodplayer.docSwfView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);
                [self.littleWindowBGView addSubview:self.vodplayer.docSwfView];
                [self.littleWindowBGView bringSubviewToFront:self.touchView];
                [self.littleWindowBGView bringSubviewToFront:self.windowHiddenButton];
                self.isVedio = YES;
                [self.contentBaseView bringSubviewToFront:self.returnBackBtn];

            }

           
            
        }else{
            self.windowHiddenButton.hidden = YES;
            if (self.littleWindowBGView.hidden) {
                self.littleWindowBGView.hidden = NO;
                self.littelWindowHidden = NO;

                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];

            }else{
                [self.vodplayer.docSwfView removeFromSuperview];
                [self.vodplayer.mVideoView removeFromSuperview];
                self.windowHiddenButton.hidden = YES;
                self.recordControlView.topLineView.hidden = NO;
                self.recordControlView.bottomLineView.hidden = NO;
                self.vodplayer.mVideoView.frame = docViewRect;
                [self.contentBaseView addSubview:self.vodplayer.mVideoView];
                self.vodplayer.mVideoView.hidden = NO;
                self.vodplayer.docSwfView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);
                
                [self.littleWindowBGView addSubview:self.vodplayer.docSwfView];
                [self.littleWindowBGView bringSubviewToFront:self.touchView];
                [self.littleWindowBGView bringSubviewToFront:self.windowHiddenButton];
                [self.contentBaseView bringSubviewToFront:self.recordControlView];

                [self.contentBaseView bringSubviewToFront:self.littleWindowBGView];
                
                self.isVedio = YES;
                [self.contentBaseView bringSubviewToFront:self.returnBackBtn];

            }

           


            
        }

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
            [self.vodplayer OnlinePlay:YES audioOnly:NO];
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
        }else if (!self.isPlaying  && self.isFirstPlay == NO){
            //继续播放或者, pop回来  播放走此方法
            [self.recordControlView.controlButton  setBackgroundImage:IMAGE(@"pauseImage")forState:UIControlStateNormal];
            [self.vodplayer resume];
            self.isPlaying = YES;
        }else if (!self.isPlaying && self.isFirstPlay == YES){
            //点播未曾播放状态
            //pop回来，如果是未播放状态走此方法
            if (!CMTUSER.login) {
                self.isneedUpdateState=YES;
                CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
                bing.nextvc=kComment;
                self.nextVC = @"blindVC";
                self.littleWindowBGView.hidden = YES;
                self.shareButton.hidden = NO;
                [self.navigationController pushViewController:bing animated:YES];
                return;
            }
            [self.recordControlView.controlButton  setBackgroundImage:IMAGE(@"pauseImage")forState:UIControlStateNormal];
            [self.vodplayer resume];
            self.isPlaying = YES;
            self.isFirstPlay = NO;
        }
        
    }
}

- (void)returnBack:(UIButton *)action{
    
    if (isfullScreen) {
        [self outFullScreen];
        //点击后刷新控制视图隐藏时间
        if (self.controlHiddenShuffling !=nil) {
            [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
        }
    }else{
        
        [self RecordDemandViewingTime];
        self.isOutVedio = YES;
        [self.navigationController popViewControllerAnimated:YES];

        
    }
}

- (void)popViewController {
    [self returnBack:nil];

}

- (void)OnChat:(NSArray *)chatArray
{
    
}

- (void)doHold:(UISlider*)slider
{
    isDragging = YES;
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

- (void)setRecordcontrolviewSwitchButtonEnble:(BOOL)enble{
    if (enble) {
        self.recordControlView.switchButton.enabled = YES;
    }else{
        self.recordControlView.switchButton.enabled = NO;
    }
}

#pragma mark -VodPlayDelegate
//初始化VodPlayer代理
- (void)onInit:(int)result haveVideo:(BOOL)haveVideo duration:(int)duration docInfos:(NSDictionary *)docInfos
{
    if (![self.navigationController.topViewController isKindOfClass:[CMTLightVideoViewController class]]) {
    [self.vodplayer stop];
    self.vodplayer = nil;
    return;
}
    if ([self.myliveParam.status isEqualToString:@"1"]) {
        [self setContentState:CMTContentStateEmpty];
        self.contentEmptyView.contentEmptyPrompt=@"该课程已下线";
    }else{
       
        [self setContentState:CMTContentStateNormal];
    }
    if (isVideoFinished) {
       //当点播未开始播放，点击didselctedCell方法加载进度时或者播放结束点击didselectedCell，走此方法
        [self.vodplayer seekTo:self.timestamp];
        
        [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"pauseImage") forState:UIControlStateNormal];
        self.isPlaying = YES;
        isVideoFinished = NO;
    }else if (!self.haveDidLoad){
        //pop回来时控制器时走的方法
        if (self.isPlaying == NO && self.isFirstPlay == YES) {
            //上次离开控制器时是点播是未开始状态
            [self.vodplayer pause];
            [self.firstPlayeButton setBackgroundImage:IMAGE(@"firstPlayimage") forState:UIControlStateNormal];
            self.playView.hidden = NO;
            [self hiddenMBProgressHUDView];
            self.firstPlayeButton.enabled = YES;
            [self setRecordcontrolviewSwitchButtonEnble:NO];
            [self showAndShfflingControlView];
        }else if ( self.recordTimeStamp > 0){
            if (self.appearFinished && self.isPlaying == NO ) {
                //上次离开控制器是点播在结束时的状态
                self.isPlaying = NO;
                self.isFirstPlay = NO;
                [self.vodplayer pause];
                [self hiddenMBProgressHUDView];
                self.firstPlayeButton.enabled = YES;
                [self setRecordcontrolviewSwitchButtonEnble:NO];
                [self showAndShfflingControlView];

            }else{
                //上次离开控制器点播在播放进度中间状态，不在开始和结束状态
                self.firstPlayeButton.enabled = YES;
                self.appearSeekTo = YES;
                [self.vodplayer seekTo:self.recordTimeStamp];
            }
           
        }

    }else{
        //开始播放之后的一些初始设置

        self.isPlaying = YES;
        if (!self.hasFinishOnce) {
            //点播第一次播放刚进入时，要手动暂停,
            [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
            self.isPlaying = NO;
            [self.vodplayer pause];
            self.isFirstPlay = YES;
        }
        
        NSArray *arr = (NSArray *)docInfos;
        if (arr.count == 0) {
            self.recordControlView.switchButton.hidden = YES;
            self.hasPPT = NO;
        }else{
            self.recordControlView.switchButton.hidden = NO;
            self.hasPPT = YES;
        }
        [self setUpTableViewAndWebView];
        if (self.dateArray.count > 0) {
            
        }else{
            self.dateArray = [NSMutableArray arrayWithArray:arr];
        }
        
        [self.tableView reloadData];
        
        [self.vodplayer getChatAndQalistAction];
        self.recordControlView.progress.maximumValue = duration;
        self.recordControlView.progress.minimumValue = 0;
        druction = duration;
        self.recordControlView.remainPlay.text = [self positionTime:duration];
        
    }
    if (self.dateArray.count > 0) {
        //此种情况下，ondocinfos代理肯定返回有数据，
    }else{
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
                self.vodplayer.mVideoView.frame = docViewRect;
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
                [self.contentBaseView bringSubviewToFront:self.returnBackBtn];
                [self.contentBaseView bringSubviewToFront:self.shareButton];
            }
        }
    }
    
    if (self.isrequirePause && self.myliveParam.islearn.integerValue == 0) {
        [self.vodplayer pause];
        [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
    }
    
    if(self.myliveParam.islearn.integerValue==1&&self.myliveParam.status.integerValue!=1&&CMTUSER.login){
        [self ClickPlayButton];
        if (self.hasPPT && CMTUSER.login){
            self.littleWindowBGView.hidden = NO;
        }
        int time= self.myliveParam.playstatus.integerValue==1?0:self.myliveParam.playDuration.intValue;
        self.recordTimeStamp=time;
        [self.vodplayer seekTo:time];
    }
    
    
}

- (void)onDocInfo:(NSArray*)docInfos{
    NSArray *arr = (NSArray *)docInfos;
    self.dateArray = [NSMutableArray arrayWithArray:arr];
    [self.tableView reloadData];
    if (arr.count > 0) {
        self.recordControlView.switchButton.hidden = NO;
        self.hasPPT = YES;
        if (self.myliveParam.displayType.integerValue == 2) {
            [self.vodplayer.docSwfView removeFromSuperview];
            [self.vodplayer.mVideoView removeFromSuperview];
            self.windowHiddenButton.hidden = YES;
            self.recordControlView.topLineView.hidden = NO;
            self.recordControlView.bottomLineView.hidden = NO;
            self.vodplayer.mVideoView.frame = docViewRect;
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
            [self.contentBaseView bringSubviewToFront:self.returnBackBtn];
            [self.contentBaseView bringSubviewToFront:self.shareButton];
        }else{
            [self.vodplayer.docSwfView removeFromSuperview];
            [self.vodplayer.mVideoView removeFromSuperview];
            self.windowHiddenButton.hidden = NO;
            self.recordControlView.topLineView.hidden = NO;
            self.recordControlView.bottomLineView.hidden = NO;
            self.vodplayer.mVideoView.frame = CGRectMake(0, 0, littileWinRect.size.width, littileWinRect.size.height);;
            [self.contentBaseView addSubview:self.vodplayer.docSwfView];
            self.vodplayer.mVideoView.hidden = NO;
            self.vodplayer.docSwfView.frame = docViewRect;
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
            [self.contentBaseView bringSubviewToFront:self.returnBackBtn];
            [self.contentBaseView bringSubviewToFront:self.shareButton];
        }
    }

    
    if (self.isrequirePause && self.myliveParam.islearn.integerValue == 0) {
        [self.vodplayer pause];
        [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
    }
    
    
   
}


/*
 *获取聊天列表
 *@chatList   列表数据 (sender: 发送者  text : 聊天内容   time： 聊天时间)
 *
 */
- (void)vodRecChatList:(NSArray*)chatList
{
    
}

/*
 *获取问题列表
 *@qaList   列表数据 （answer：回答内容 ; answerowner：回答者 ; id：问题id ;qaanswertimestamp:问题回答时间 ;question : 问题内容  ，questionowner:提问者 questiontimestamp：提问时间）
 *
 */
- (void)vodRecQaList:(NSArray*)qaList
{
    
}

//进度条定位播放，如快进、快退、拖动进度条等操作回调方法
- (void) onSeek:(int) position
{
    if (isDragging) {
        //点击后刷新控制视图隐藏时间
        if (self.controlHiddenShuffling !=nil) {
            [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
        }
    }
    isDragging = NO;
    //[self.recordControlView.progress setValue:position animated:YES];
}

//进度回调方法
- (void)onPosition:(int)position
{
    if (isDragging) {
        return;
    }
    self.myliveParam.islearn=@"0";
    self.isPlaying = YES;
    if (self.isrequirePause) {
        [self.vodplayer pause];
        [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
        self.isrequirePause = NO;
        self.isPlaying = NO;
        self.isFirstPlay = NO;
    }
    if (self.appearSeekTo) {
        [self.vodplayer pause];
        self.appearSeekTo = NO;
        self.isPlaying = NO;
        self.isFirstPlay = NO;
        [self hiddenMBProgressHUDView];
        [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
        [self showAndShfflingControlView];

    }
    [self setRecordcontrolviewSwitchButtonEnble:YES];
    self.playView.hidden = YES;
    self.recordTimeStamp = position;
    //记录下载播放观看记录时间
    self.myliveParam.playDuration = [NSString stringWithFormat:@"%ld",self.recordTimeStamp];
    
    self.recordControlView.havePlay.text = [self positionTime:position];

    self.recordControlView.remainPlay.text = [self positionTime:druction - position];

    
    [self.recordControlView.progress setValue:position animated:YES];
    self.myliveParam.playstatus=@"0";
}

- (void)onVideoStart
{
    
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

//播放完成停止通知，
- (void)onStop{
    isDragging = NO;
    self.myliveParam.playstatus=@"1";
    self.littleWindowBGView.hidden = YES;
    [self outFullScreen];
    [self setRecordcontrolviewSwitchButtonEnble:NO];
    self.appearFinished = YES;
    isVideoFinished = YES;
    self.hasFinishOnce = YES;
    self.isPlaying = NO;
    [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
    
    [_firstPlayeButton setBackgroundImage:IMAGE(@"secondplayimage") forState:UIControlStateNormal];
    
    self.recordControlView.havePlay.text = @"00:00:00";
     self.recordControlView.remainPlay.text = [self positionTime:druction];
    self.recordControlView.progress.value=0.0;
    self.playView.hidden = NO;
    [self.contentBaseView bringSubviewToFront:self.playView];
    [self.contentBaseView bringSubviewToFront:self.returnBackBtn];
    [self.contentBaseView bringSubviewToFront:self.shareButton];
    self.shareButton.hidden = NO;
    _firstPlayeButton.enabled = YES;
    //当只走viewwillApear不走viewdidLoad时，且播放完成一遍，恢复haveDidLoad,让doPause方法走正常流程
    if (!self.haveDidLoad) {
        self.haveDidLoad = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

//show控制视图
- (void)showAndHiddenControlView{
    if (isfullScreen) {
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
        
    }else{
        if (self.controlViewHidden) {
            self.recordControlView.bottomView.hidden = NO;
            self.recordControlView.topView.hidden = NO;

            self.controlViewHidden = NO;
            //播放后倒计时隐藏控制视图
            if (self.controlHiddenShuffling !=nil) {
                [self.controlHiddenShuffling setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
            }
        }else{
            self.recordControlView.bottomView.hidden = YES;
            self.recordControlView.topView.hidden = YES;
            self.controlViewHidden = YES;
        }
        [self setNeedsStatusBarAppearanceUpdate];
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

#pragma mark - VodDownLoadDelegate
- (void)onAddItemResult:(RESULT_TYPE)resultType voditem:(downItem *)item
{
    if (![self.navigationController.topViewController isKindOfClass:[CMTLightVideoViewController class]]) {
        [self.vodplayer stop];
        self.vodplayer = nil;
        return;
    }
    if (resultType == RESULT_SUCCESS) {
               downItem *Litem = [[VodManage shareManage]findDownItem:item.strDownloadID];
        if (Litem) {
            if (self.vodplayer) {
                [self.vodplayer stop];
                self.vodplayer = nil;
            }
           
            if (!self.vodplayer) {
                self.vodplayer = [[VodPlayer alloc]init];
            }
            
            self.vodplayer.playItem = Litem;
            //优先显示视频/PPT
            if (self.myliveParam.displayType.integerValue == 2) {
                self.vodplayer.mVideoView = [[VodGLView alloc]initWithFrame:videoViewRect];
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
                self.vodplayer.docSwfView = [[GSVodDocView alloc]initWithFrame:docViewRect];
                [self.contentBaseView addSubview:self.vodplayer.docSwfView ];
//                self.vodplayer.docSwfView.fullMode = NO;
                self.isVedio = NO;
            }
            
           
            [self setUpWindowViewWithType:self.myliveParam.displayType];
            [self setUpWindowPanGesture];
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
            if (!self.recordControlView) {
                self.recordControlView = [[CMTRecordControlView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9/16) isfullScreen:NO];
            }
            
            //进度条
            [self.recordControlView.progress addTarget:self action:@selector(doSeek:) forControlEvents:UIControlEventTouchUpInside];
            [self.recordControlView.progress addTarget:self action:@selector(doHold:) forControlEvents:UIControlEventTouchDown];
            
            //播放控制按钮
            [self.recordControlView.controlButton addTarget:self action:@selector(doPause) forControlEvents:UIControlEventTouchUpInside];
            [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"pauseImage") forState:UIControlStateNormal];
            
            //切换控制
            [self.recordControlView.switchButton addTarget:self action:@selector(switchDocAndPlayAction:) forControlEvents:UIControlEventTouchUpInside];
            
            //全屏控制
            [self.recordControlView.fullModeButton addTarget:self action:@selector(totationVideoView:) forControlEvents:UIControlEventTouchUpInside];
            
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
            //添加播放等待视图；
            [self.contentBaseView addSubview:self.playView];
            //移除默认背景视图
            [self.backGroudImageView removeFromSuperview];
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
            [self.vodplayer OnlinePlay:YES audioOnly:NO];
            
            [self.contentBaseView bringSubviewToFront:_returnBackBtn];
            [self.contentBaseView bringSubviewToFront:_shareButton];
            [[RACObserve(self, hasPPT)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber * x) {
                if (x.integerValue == 0) {
                    self.recordControlView.shareButton.frame = CGRectMake(self.recordControlView.topView.right - 110/3 - 10, 10, 110/3, 110/3);
                  
                }else{
                    self.recordControlView.shareButton.frame =  CGRectMake(self.recordControlView.switchButton.left - 10 - 110/3, 10, 110/3, 110/3);
                }
            }];
           
        }
    }else if (resultType == RESULT_ROOM_NUMBER_UNEXIST){
        [self outFullScreen];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"无法连接到视频源，请稍后再试" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
         self.isOutVedio = YES;
        [self.navigationController popViewControllerAnimated:NO];
    }else if (resultType == RESULT_FAILED_NET_REQUIRED){
        [self outFullScreen];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"网络请求失败" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        if ([self.navigationController.topViewController isKindOfClass:[CMTLightVideoViewController class]]) {
            [alertView show];

        }
         self.isOutVedio = YES;
        [self.navigationController popViewControllerAnimated:NO];

    }else if (resultType == RESULT_FAIL_LOGIN){
        [self outFullScreen];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"用户名或密码错误" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
       
            [alertView show];
         self.isOutVedio = YES;
        [self.navigationController popViewControllerAnimated:NO];

    }else if (resultType == RESULT_NOT_EXSITE){
        [self outFullScreen];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"无法连接到视频源，请稍后再试" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
         self.isOutVedio = YES;
        [self.navigationController popViewControllerAnimated:NO];

    }else if (resultType == RESULT_INVALID_ADDRESS){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"无效地址" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
         self.isOutVedio = YES;
        [self.navigationController popViewControllerAnimated:NO];

    }else if (resultType == RESULT_UNSURPORT_MOBILE){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"不支持移动设备" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
         self.isOutVedio = YES;
        [self.navigationController popViewControllerAnimated:NO];

    }else if (resultType == RESULT_FAIL_TOKEN){
        [self outFullScreen];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"口令错误" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
         self.isOutVedio = YES;
        [self.navigationController popViewControllerAnimated:NO];

    }
}

#pragma tableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    
    if (!(self.dateArray.count>0)) {
        return nil;
    }
        NSDictionary *dic = self.dateArray[indexPath.row];
        NSArray *detailArray = [dic objectForKey:@"pages"];
        NSDictionary *detailDic = detailArray[0];
        NSString *title = [detailDic objectForKey:@"title"];
        NSString *timeStamp = [detailDic objectForKey:@"timestamp"];
        NSString *time = [self positionTime:timeStamp.integerValue];
    
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"customCell"];
        cell.backgroundColor = COLOR(c_ffffff);
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
        UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 20, 20)];
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 20, SCREEN_WIDTH - 150, 20)];
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 20, 90, 20)];
        timeLabel.font = FONT(15);
        leftImage.image = IMAGE(@"recordListImage");
        textLabel.text = title;
        timeLabel.text = time;
        
        UIView *bottomlineView= [[UIView alloc]initWithFrame:CGRectMake(3, 60-0.8, SCREEN_WIDTH - 3, 0.8)];
        bottomlineView.backgroundColor = [UIColor colorWithHexString:@"c_f6f6f6"];
        [cell.contentView addSubview:leftImage];
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:timeLabel];
        
        [cell.contentView addSubview:bottomlineView];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.dateArray[indexPath.row];
    NSArray *detailArray = [dic objectForKey:@"pages"];
    NSDictionary *detailDic = detailArray[0];
    NSString *timeStamp = [detailDic objectForKey:@"timestamp"];
    if (isVideoFinished) {
        [self.vodplayer OnlinePlay:YES audioOnly:NO];
        self.timestamp = timeStamp.integerValue;
    }else{
        if (!CMTUSER.login){
            self.isneedUpdateState=YES;
            CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
            bing.nextvc=kComment;
            self.nextVC = @"blindVC";
            [self.navigationController pushViewController:bing animated:YES];
            return;
        }
       

        [self.vodplayer seekTo:timeStamp.integerValue];
        [self.recordControlView.controlButton setBackgroundImage:IMAGE(@"pauseImage") forState:UIControlStateNormal];
        self.isPlaying = YES;
        self.isRecordPlayTime=YES;
    }
    if (self.hasPPT) {
        self.littleWindowBGView.hidden = NO;
    }else{
        self.littleWindowBGView.hidden = YES;
    }
    //重新定位进度条时  show控制视图
    [self showAndShfflingControlView];
    self.shareButton.hidden = YES;
    
}

//获取当前网络状态
-(NSString*)getNetworkReachabilityStatus{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable) {
        return @"0";
    }else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWWAN){
        return @"1";
    }
    else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWiFi){
        return @"2";
    }
    return @"2";
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    
   
        return UIStatusBarStyleLightContent;  //默认的值是白色的
    
    
    
}
#pragma mark 记录播放时间;
-(void)RecordDemandViewingTime{
    if(!self.isRecordPlayTime||!CMTUSER.login){
        return;
    }
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"0",
                             @"coursewareId":self.myliveParam.coursewareId?:@"0",
                             @"classRoomId":self.myliveParam.classRoomId?:@"0",
                             @"duration":[@"" stringByAppendingFormat:@"%ld",self.recordTimeStamp],
                             @"playstatus":self.myliveParam.playstatus?:@"0",
                             @"type":self.myliveParam.type,
                             };
    
    [[[CMTCLIENT CMTPersonalLearningRecord:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *x) {
        
    } error:^(NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
