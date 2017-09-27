//
//  LiveVideoPlayViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/5/31.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "LiveVideoPlayViewController.h"
#import <PlayerSDK/PlayerSDK.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "BBFlashCtntLabel.h"
#import "CMTBindingViewController.h"
#import "CMTChartView.h"
#import "CmtChartdefaultView.h"
#import "UITextView+Placeholder.h"
#import <QuartzCore/QuartzCore.h>
#import "CMTLiveShareView.h"
#import "AFNetworkReachabilityManager.h"
@interface LiveVideoPlayViewController ()<GSPPlayerManagerDelegate,UIWebViewDelegate,UIScrollViewDelegate,UITextViewDelegate>
@property(nonatomic,strong)UIButton *chartButton;//小组按钮
@property(nonatomic,strong)UIButton *liveDteilButton;//病例按钮
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIView *buttonView;
@property(nonatomic, strong) GSPVideoView *vieoView;//视频画面
@property(nonatomic, strong) MBProgressHUD *progressHUD;//等待画面
@property(nonatomic, strong) GSPDocView *docView;//文本画面
@property(nonatomic,strong) UIImageView *playView;//直播间默认图片
@property(nonatomic,strong)UIAlertView *alert;
@property(nonatomic,strong)UIButton *fullbutton;//全屏按钮
@property(nonatomic,strong)CMTLivesRecord *myliveParam;//直播间参数
@property(nonatomic,assign)BOOL isfullScreen;//是否已经全屏
@property(nonatomic,strong)UIView *toolbarView;//上工具条
@property(nonatomic,strong)UIButton *backButton;//返回按钮
@property(nonatomic,strong)UIButton *changgemodel;//切换视频和ppt
@property(nonatomic,strong)UIButton *signUpbutton;//报名
@property(nonatomic,strong)UIWebView *liveteilWebdetails;//直播详情
@property(nonatomic,strong)UIScrollView *scroll;//直播滚动视图
@property(nonatomic,strong)CMTChartView *chartView;//直播聊天视图
@property(nonatomic,strong)NSMutableArray *ChartSource;
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIView *replayView;//直播回复视图
@property(nonatomic,strong)UITextView *replayField;//直播回复输入框
@property(nonatomic,strong)UIButton*senderButton;//直播发送按钮
@property(nonatomic,strong)CmtChartdefaultView *defaultView;
@property(nonatomic,strong)NSTimer *time;
@property(nonatomic,strong)NSString *Playtypes;
@property(nonatomic,strong)NSString *ishaveDoc;
@property(nonatomic,strong)NSString *ishaveVideo;
@property(nonatomic, strong)UIAlertView *alertView;
@property(nonatomic,strong)NSString *pagenumber;
@property(nonatomic,assign)BOOL isFromPush;
@property (nonatomic, strong)UIButton *shareItem;  // 分享按钮
@property(nonatomic,strong)CMTLiveShareView *ShareView;
@property(nonatomic,strong)NSTimer *HideToolbarTimer;
@end

@implementation LiveVideoPlayViewController
-(NSMutableArray*)ChartSource{
    if (_ChartSource==nil) {
        _ChartSource=[[NSMutableArray alloc]init];
    }
    return _ChartSource;
}
-(UIImageView*)playView{
    if (_playView==nil) {
        _playView=[[UIImageView alloc]initWithFrame:docRect];
        _playView.userInteractionEnabled=YES;
        [_playView setImageURL:self.myliveParam.roomPic placeholderImage:IMAGE(@"LivenotBegin") contentSize:CGSizeMake(docRect.size.width, docRect.size.height)];
        _playView.contentMode=UIViewContentModeScaleAspectFill;
        _playView.clipsToBounds=YES;
        UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0,0, _playView.width, _playView.height)];
        bgView.backgroundColor=[[UIColor colorWithHexString:@"#151515"] colorWithAlphaComponent:0.5];
        bgView.userInteractionEnabled=NO;
        [_playView addSubview:bgView];
        self.signUpbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.signUpbutton.frame = CGRectMake((_playView.width-100)/2,_playView.height-90*XXXRATIO, 100, 30);
        [self.signUpbutton setTitle:self.myliveParam.isJoin.integerValue==0?@"":@"点击报名" forState:UIControlStateNormal];
        self.signUpbutton.titleLabel.font=FONT(15);
        if(self.myliveParam.isJoin.integerValue==0){
           [self.signUpbutton setBackgroundImage:IMAGE(@"registedImage") forState:UIControlStateNormal];
        }
        [self.signUpbutton addTarget:self action:@selector(signUpAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.myliveParam.isJoin.integerValue==1) {
            [self.signUpbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.signUpbutton.layer.cornerRadius = 8;
            self.signUpbutton.layer.masksToBounds = YES;
            self.signUpbutton.backgroundColor = ColorWithHexStringIndex(c_32c7c2);
        }else{
            [self.signUpbutton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
            self.signUpbutton.layer.masksToBounds = YES;
             self.signUpbutton.layer.cornerRadius = 8;
             self.signUpbutton.layer.borderWidth = 1;
             self.signUpbutton.layer.borderColor = COLOR(c_32c7c2).CGColor;
             self.signUpbutton.backgroundColor = [UIColor clearColor];
             self.signUpbutton.userInteractionEnabled=NO;

        }
      [_playView addSubview:self.signUpbutton];

    }
    return _playView;
}
-(GSPDocView*)docView{
    if (_docView==nil) {
        _docView=[[GSPDocView alloc]initWithFrame:docRect];
        _docView.zoomEnabled=NO;
        _docView.hidden=YES;
        _docView.layer.borderWidth=1;
        _docView.layer.borderColor=[UIColor colorWithHexString:@"#dfe5e7"].CGColor;
        _docView.backgroundColor=[UIColor whiteColor];
        UIButton *deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(1,1,32*XXXRATIO, 32*XXXRATIO)];
        [deleteButton setImage:IMAGE(@"CloseLiveimage") forState:UIControlStateNormal];
        deleteButton.tag=100;
        [deleteButton addTarget:self action:@selector(deleteView:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.hidden=YES;
        [_docView addSubview:deleteButton];
        UITapGestureRecognizer *gest=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLiveTopbar:)];
        [_docView addGestureRecognizer:gest];
        UIPanGestureRecognizer *pangesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanView:)];
        [_docView addGestureRecognizer:pangesture];
    }
        return _docView;
}
-(GSPVideoView*)vieoView{
    if (_vieoView==nil) {
        _vieoView=[[GSPVideoView alloc]initWithFrame:docRect];
        _vieoView.hidden=YES;
        _vieoView.contentMode=UIViewContentModeScaleAspectFit;
        UIButton *deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(1,1,32*XXXRATIO, 32*XXXRATIO)];
        [deleteButton setImage:IMAGE(@"CloseLiveimage") forState:UIControlStateNormal];
        deleteButton.tag=100;
        [deleteButton addTarget:self action:@selector(deleteView:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.hidden=YES;
        [_vieoView addSubview:deleteButton];
        UITapGestureRecognizer *gest=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLiveTopbar:)];
        [_vieoView addGestureRecognizer:gest];
        UIPanGestureRecognizer *pangesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanView:)];
        [_vieoView addGestureRecognizer:pangesture];
    }
    return _vieoView;
}
-(UIButton*)fullbutton{
    if (_fullbutton==nil) {
        _fullbutton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-110/3-10, docRect.origin.y+(docRect.size.height-110/3-10), 110/3,110/3)];
        [_fullbutton addTarget:self action:@selector(FulScreenRotation:) forControlEvents:UIControlEventTouchUpInside];
        [_fullbutton setImage:IMAGE(@"liveFullModeImage") forState:UIControlStateNormal];
        _fullbutton.hidden=YES;
    }
    return _fullbutton;
}
-(UIButton*)backButton{
    if(_backButton==nil){
        _backButton=[[UIButton alloc]initWithFrame:CGRectMake(10,10,110/3, 110/3)];
        [_backButton setImage:IMAGE(@"livebackImage") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(gotoback) forControlEvents:UIControlEventTouchUpInside];
        [self.contentBaseView addSubview:_backButton];

    }
    return _backButton;
}
-(UIView*)toolbarView{
    if(_toolbarView==nil){
        _toolbarView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,110/3)];
        [_toolbarView setBackgroundColor:[UIColor clearColor]];
        self.changgemodel=[UIButton buttonWithType:UIButtonTypeCustom];
         self.changgemodel.frame=CGRectMake(SCREEN_WIDTH-110/3-10,10, 110/3, 110/3);
        [ self.changgemodel setImage:IMAGE(@"livePPT") forState:UIControlStateNormal];
        [ self.changgemodel addTarget:self action:@selector(Changemodel:) forControlEvents:UIControlEventTouchUpInside];
          self.changgemodel.hidden=YES;
        [_toolbarView addSubview:self.changgemodel];
        
        self.shareItem=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-110/3-10,10, 110/3, 110/3)];
        [self.shareItem setImage:IMAGE(@"liveShareImage") forState:UIControlStateNormal];
        //分享按钮事件
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
-(UIView*)buttonView{
    if (_buttonView==nil) {
        _buttonView=[[UIView alloc]initWithFrame:CGRectMake(0,docRect.origin.y+docRect.size.height, SCREEN_WIDTH, 40)];
        self.chartButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH/2, _buttonView.height-1)];
        [self.chartButton setTitle:@"问答" forState:UIControlStateNormal];
        self.chartButton.titleLabel.font=FONT(15);
        [self.chartButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
        [self.chartButton addTarget:self action:@selector(ChangeThetab:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:self.chartButton];
        
        self.liveDteilButton=[[UIButton alloc]initWithFrame:CGRectMake(self.chartButton.right, 0, SCREEN_WIDTH/2, _buttonView.height-1)];
        [self.liveDteilButton setTitle:@"详情" forState:UIControlStateNormal];
         self.liveDteilButton.titleLabel.font=FONT(15);
         [self.liveDteilButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        [self.liveDteilButton addTarget:self action:@selector(ChangeThetab:) forControlEvents:UIControlEventTouchUpInside];
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(self.liveDteilButton.left, self.liveDteilButton.height-2,SCREEN_WIDTH/2, 2)];
        _lineView.backgroundColor=ColorWithHexStringIndex(c_4acbb5);
        [_buttonView addSubview: self.chartButton];
        [_buttonView addSubview: self.liveDteilButton];
        UIView *buttomline=[[UIView alloc]initWithFrame:CGRectMake(0,  self.liveDteilButton.bottom, SCREEN_WIDTH, 1)];
        buttomline.backgroundColor=[UIColor colorWithHexString:@"F8F8F8"];
        [_buttonView addSubview:buttomline];
        [_buttonView addSubview:_lineView];
        
        
    }
    return _buttonView;
}
-(UIView*)replayView{
    if (_replayView==nil) {
        _replayView=[[UIView alloc]initWithFrame:CGRectMake(0,self.contentBaseView.height-50,SCREEN_WIDTH, 50)];
        [_replayView setBackgroundColor:[UIColor colorWithHexString:@"#ededf2"]];
        self.replayField=[[UITextView alloc]initWithFrame:CGRectMake(10, 5,SCREEN_WIDTH-100, 40)];
        self.replayField.delegate=self;
        self.replayField.font=[UIFont systemFontOfSize:16];
        self.replayField.placeholder=@"点击此处可以提问";
        [_replayView addSubview:self.replayField];
        self.senderButton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.senderButton.frame=CGRectMake(SCREEN_WIDTH-80, 5,70, 40);
        [self.senderButton setTitle:@"发送" forState:UIControlStateNormal];
        [self.senderButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        self.senderButton.userInteractionEnabled=NO;
        [self.senderButton setBackgroundColor:[UIColor colorWithHexString:@"dcdce2"]];
        [self.senderButton setTitleColor:[UIColor colorWithHexString:@"#989899"] forState:UIControlStateNormal];
        self.senderButton.layer.cornerRadius=5;
        [_replayView addSubview:self.senderButton];
        _replayView.hidden=YES;
        
    }
    return _replayView;
}

-(UIWebView*)liveteilWebdetails{
    if(_liveteilWebdetails==nil){
        _liveteilWebdetails=[[UIWebView alloc]initWithFrame:CGRectMake(self.chartView.right, 0, self.scroll.width, self.scroll.height)];
        _liveteilWebdetails.delegate=self;
         _liveteilWebdetails.backgroundColor = ColorWithHexStringIndex(c_ffffff);
    }
    return _liveteilWebdetails;
}
-(UIScrollView*)scroll{
    if (_scroll==nil) {
        _scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, self.buttonView.bottom, SCREEN_WIDTH,SCREEN_HEIGHT-self.buttonView.bottom)];
        _scroll.delegate=self;
        _scroll.contentSize=CGSizeMake(SCREEN_WIDTH*2, _scroll.height);
        _scroll.showsHorizontalScrollIndicator=NO;
         _scroll.showsVerticalScrollIndicator=NO;
        _scroll.bounces=NO;
        _scroll.pagingEnabled=YES;
        [_scroll addSubview:self.defaultView];
        [_scroll addSubview:self.chartView];
        if (self.myliveParam.qaswitch.integerValue==1) {
             [_scroll addSubview:self.liveteilWebdetails];
        }
       
    }
    return _scroll;
}
-(CMTChartView*)chartView{
    if (_chartView==nil) {
        _chartView=[[CMTChartView alloc]initWithFrame:CGRectMake(0, 0, self.scroll.width, self.scroll.height)];
        [_chartView setBackgroundColor:ColorWithHexStringIndex(c_ffffff)];
        self.chartView.hidden=YES;
    }
    return _chartView;
}
-(CmtChartdefaultView*)defaultView{
    if (_defaultView==nil) {
        _defaultView=[[CmtChartdefaultView alloc]initWithFrame:CGRectMake(0, 0, self.scroll.width, self.scroll.height)];
        [_defaultView setBackgroundColor:ColorWithHexStringIndex(c_ffffff)];
    }
    return _defaultView;
}
-(CMTLiveShareView*)ShareView{
    if (_ShareView==nil) {
        _ShareView=[[CMTLiveShareView alloc]init];
        _ShareView.parentView=self;
        @weakify(self);
        _ShareView.updateUsersnumber=^(CMTLivesRecord*rect){
            @strongify(self);
            self.myliveParam.users=rect.users;
            if (self.updateLiveList!=nil) {
                self.updateLiveList(self.myliveParam);
            }
        };
        CMTLivesRecord *liveCode=[self.myliveParam copy];
         liveCode.classRoomType=@"1";
        liveCode.title=[@"【直播】" stringByAppendingString:self.myliveParam.title?:@""];
        _ShareView.LivesRecord=liveCode;
    }
    return _ShareView;
}
#pragma mark 处理小窗口滑动
-(void)handlePanView:(UIPanGestureRecognizer*)recognizer{
    if (recognizer.view.width==smallRect.size.width&&!recognizer.view.hidden) {
        //显示删除按钮
        if([recognizer.view viewWithTag:100].hidden){
            [recognizer.view viewWithTag:100].hidden=NO;
        }
        CGPoint translation = [recognizer translationInView:self.contentBaseView];
        if (!self.isfullScreen) {
            float recx=recognizer.view.center.x + translation.x;
            if (recx<smallRect.size.width/2) {
                recx=smallRect.size.width/2;
            }else if(recx>SCREEN_WIDTH-smallRect.size.width/2){
                recx=SCREEN_WIDTH-smallRect.size.width/2;
            }
            float recy=recognizer.view.center.y + translation.y;
            if (recy<(CMTNavigationBarBottomGuide-smallRect.size.height/2)+smallRect.size.height){
                recy=(CMTNavigationBarBottomGuide-smallRect.size.height/2)+smallRect.size.height;
            }else if(recy>SCREEN_HEIGHT-smallRect.size.height){
                recy=SCREEN_HEIGHT-smallRect.size.height;
            }
            recognizer.view.center = CGPointMake(recx,recy);
            [recognizer setTranslation:CGPointZero inView:self.contentBaseView];
        }else{
            float recx=recognizer.view.center.x + translation.x;
            if (recx<landscapesmallRect.size.width/2) {
                recx=landscapesmallRect.size.width/2;
            }else if(recx>SCREEN_HEIGHT-landscapesmallRect.size.width/2){
                recx=SCREEN_HEIGHT-landscapesmallRect.size.width/2;
            }
            float recy=recognizer.view.center.y + translation.y;
            if (self.toolbarView.hidden) {
                if (recy<landscapesmallRect.size.height/2) {
                    recy=landscapesmallRect.size.height/2;
                }else if(recy>SCREEN_WIDTH-landscapesmallRect.size.height/2){
                    recy=SCREEN_WIDTH-landscapesmallRect.size.height/2;
                }

            }else{
                if (recy<(44-landscapesmallRect.size.height/2)+landscapesmallRect.size.height) {
                    recy=(44-landscapesmallRect.size.height/2)+landscapesmallRect.size.height;
                }else if(recy>SCREEN_WIDTH-landscapesmallRect.size.height/2){
                    recy=SCREEN_WIDTH-landscapesmallRect.size.height/2;
                }

            }
            recognizer.view.center = CGPointMake(recx,recy);
            [recognizer setTranslation:CGPointZero inView:self.contentBaseView];
        }
       
    }
    
}
#pragma mark 隐藏小窗口
-(void)deleteView:(UIButton*)sender{
    [sender superview].hidden=YES;
     sender.hidden=YES;
    if ([[sender superview] isKindOfClass:[GSPVideoView class]]) {
         [self.changgemodel setImage:IMAGE(@"liveVideo") forState:UIControlStateNormal];
    }else{
         [self.changgemodel setImage:IMAGE(@"livePPT") forState:UIControlStateNormal];
    }
}
#pragma mark 显示工具条
-(void)showLiveTopbar:(UITapGestureRecognizer*)tap{
    if (tap.view.frame.size.width==smallRect.size.width&&!tap.view.hidden) {
        if ([tap.view viewWithTag:100].hidden) {
            [tap.view viewWithTag:100].hidden=NO;
        }else{
            [tap.view viewWithTag:100].hidden=YES;

        }
        
       
    }else{
        if (self.isfullScreen) {
            if (self.toolbarView.hidden) {
                if (self.vieoView.width==landscapesmallRect.size.width&&!self.vieoView.hidden) {
                    if (self.vieoView.top<=44) {
                        self.vieoView.centerY=(44-landscapesmallRect.size.height/2)+landscapesmallRect.size.height;
                    }
                }else if(self.docView.width==landscapesmallRect.size.width&&!self.docView.hidden) {
                    if (self.docView.top<=44) {
                        self.docView.centerY=(44-landscapesmallRect.size.height/2)+landscapesmallRect.size.height;;
                    }
                }
                self.toolbarView.hidden=NO;
                self.fullbutton.hidden=NO;
                self.backButton.hidden=NO;
                [self.HideToolbarTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
            }else{
                if (self.vieoView.width==landscapesmallRect.size.width&&!self.vieoView.hidden) {
                    if (self.vieoView.centerY<=(44-landscapesmallRect.size.height/2)+landscapesmallRect.size.height) {
                        self.vieoView.top=0;
                    }
                }else if(self.docView.width==landscapesmallRect.size.width&&!self.docView.hidden) {
                    if (self.docView.centerY<=(44-landscapesmallRect.size.height/2)+landscapesmallRect.size.height) {
                        self.docView.top=0;
                    }
                }

                self.toolbarView.hidden=YES;
                 self.fullbutton.hidden=YES;
                self.backButton.hidden=YES;
                self.HideToolbarTimer.fireDate=[NSDate distantFuture];
            }

        }else{
            if(!self.toolbarView.hidden){
              self.toolbarView.hidden=YES;
              self.fullbutton.hidden=YES;
            self.HideToolbarTimer.fireDate=[NSDate distantFuture];
            }else{
                self.toolbarView.hidden=NO;
                self.fullbutton.hidden=NO;
                [self.HideToolbarTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
            }

        }
     }
   }
#pragma mark 隐藏工具条
-(void)CMTHideTheToolbar{
  if(!self.toolbarView.hidden){
    if(self.isfullScreen){
        if (self.vieoView.width==landscapesmallRect.size.width&&!self.vieoView.hidden) {
            if (self.vieoView.centerY<=(44-landscapesmallRect.size.height/2)+landscapesmallRect.size.height) {
                self.vieoView.top=0;
            }
        }else if(self.docView.width==landscapesmallRect.size.width&&!self.docView.hidden) {
            if (self.docView.centerY<=(44-landscapesmallRect.size.height/2)+landscapesmallRect.size.height) {
                self.docView.top=0;
            }
        }
    }
    self.toolbarView.hidden=YES;
    self.fullbutton.hidden=YES;
      self.backButton.hidden=self.isfullScreen;
  }else{
      NSLog(@"已经隐藏");
  }
    self.HideToolbarTimer.fireDate=[NSDate distantFuture];
}
//返回函数
-(void)gotoback{
    if (self.isfullScreen) {
        [self FulScreenRotation:self.fullbutton];
    }else{
        [self dealwithTimer];
    }
}
#pragma mark 处理计时器
-(void)dealwithTimer{
    [self.navigationController popViewControllerAnimated:YES];
    [self getNewSystemTime];
    if (self.time!=nil) {
        [self.time setFireDate:[NSDate distantFuture]];
        if ([self.time isValid] == YES) {
            [self.time invalidate];
            self.time = nil;
        }
    }
    NSLog(@"11");
    [self deallocobject];
}
//获取最新时间
-(void)getNewSystemTime{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"0",
                            @"liveUuid":self.myliveParam.liveUuid?:@"",
                            };
    @weakify(self);
    [[[CMTCLIENT CMTGetRoomStatus:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *x) {
        @strongify(self);
        self.myliveParam.sysDate=x.sysDate;
        if (self.updateLiveList!=nil) {
            self.updateLiveList(self.myliveParam);
        }

    } error:^(NSError *error) {
        NSLog(@"请求失败");
    }];
        
}
#pragma mark 切换问答和详情
-(void)ChangeThetab:(UIButton*)sender{
    self.scroll.userInteractionEnabled=NO;
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self);
        self.lineView.frame=CGRectMake(sender==self.chartButton?0:sender.frame.origin.x, self.lineView.top, self.lineView.width, self.lineView.height);
        
    } completion:^(BOOL finished) {
        @strongify(self);
        if (sender==self.chartButton) {
            [self.chartButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
            [self.liveDteilButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
            [self.scroll setContentOffset:CGPointMake(0,0) animated:YES];
            self.replayView.hidden=NO;
            if (!self.chartView.hidden) {
                self.replayView.hidden=NO;
            }else{
                self.replayView.hidden=YES;
            }

        }else{
            [self.liveDteilButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
            [self.chartButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
            [self.scroll setContentOffset:CGPointMake(SCREEN_WIDTH,0) animated:YES];
            self.replayView.hidden=YES;
           }
        self.scroll.userInteractionEnabled=YES;
        
    }];
    

}
#pragma mark ScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x/scrollView.width==0) {
        self.pagenumber=@"0";
    }else{
         self.pagenumber=@"1";
    }
}

#pragma mark 翻页控制
-(void)TurnThePage:(NSString*)page{
    if (page.integerValue==0) {
        [self.chartButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        [self.liveDteilButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
        [self.scroll setContentOffset:CGPointMake(0,0) animated:YES];
        if (!self.chartView.hidden) {
            self.replayView.hidden=NO;
        }else{
            self.replayView.hidden=YES;
        }
        
        self.lineView.frame=CGRectMake(0, self.lineView.top, self.lineView.width, self.lineView.height);
    }else{
        [self.liveDteilButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        [self.chartButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
        [self.scroll setContentOffset:CGPointMake(SCREEN_WIDTH,0) animated:YES];
        self.replayView.hidden=YES;
        self.lineView.frame=CGRectMake(self.liveDteilButton.frame.origin.x, self.lineView.top, self.lineView.width, self.lineView.height);
    }

}
#pragma mark 点击报名
-(void)signUpAction:(UIButton*)btn{
    btn.userInteractionEnabled=NO;
    if (!CMTUSER.login) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        
        [self.navigationController pushViewController:loginVC animated:YES];
         btn.userInteractionEnabled=YES;
        return;
    }
    NSDictionary *params = @{@"userId":CMTUSERINFO.userId?:@"0",
                             @"classRoomId": self.myliveParam.classRoomId,
                             @"flag":self.myliveParam.isJoin.integerValue==0?@"1":@"0",
                             };
    @weakify(self);
    [[[CMTCLIENT getCMTPlayRegistStatus:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord* x){
          @strongify(self);
        [self toastAnimation:@"报名成功" top:0] ;
          self.myliveParam.isJoin=x.isJoin;
        self.myliveParam.sysDate=x.sysDate;
          [btn setTitle:self.myliveParam.isJoin.integerValue==0?@"":@"点击报名" forState:UIControlStateNormal];
          [btn setBackgroundImage:IMAGE(@"registedImage") forState:UIControlStateNormal];
            [self.signUpbutton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
            self.signUpbutton.layer.cornerRadius = 8;
            self.signUpbutton.layer.borderWidth = 1;
            self.signUpbutton.layer.borderColor =COLOR(c_32c7c2).CGColor;
            self.signUpbutton.backgroundColor = [UIColor clearColor];
        if ((self.myliveParam.sysDate.longLongValue>=self.myliveParam.startDate.longLongValue)&& (self.myliveParam.sysDate.longLongValue<self.myliveParam.endDate.longLongValue)) {
               [self GSPJoinLiveVideo];
        }else{
                if (x.sysDate.longLongValue<self.myliveParam.startDate.longLongValue) {
                    self.time=[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(getTheSystemTime) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];
                }else{
                    self.myliveParam.status=@"0";
                }
        }
        if (self.updateLiveList!=nil) {
            self.updateLiveList(self.myliveParam);
        }
        if (self.EnterType==1) {
            CMTAPPCONFIG.isrefreshLivelist=@"1";
        }
    } error:^(NSError *error) {
          btn.userInteractionEnabled=YES;
        if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
              @strongify(self);
            [self toastAnimation:@"你的网络不给力" top:0];
        }else{
              @strongify(self);
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"] top:0];
        }

    }];
  
}
#pragma mark 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark 页面初始化方法
-(instancetype)initWithParam:(CMTLivesRecord*)param{
    self=[super init];
    if (self) {
         self.isFromPush=NO;
        self.isfullScreen=NO;
        docRect=CGRectMake(0,0,SCREEN_WIDTH,SCREEN_WIDTH/16.0*9.0);
        landscapedocRect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        smallRect=CGRectMake(SCREEN_WIDTH/2,docRect.size.height+41,(SCREEN_WIDTH/2),SCREEN_WIDTH/2/16*9);
        landscapesmallRect=CGRectMake([UIScreen mainScreen].bounds.size.height-smallRect.size.width,[UIScreen mainScreen].bounds.size.width-smallRect.size.height, smallRect.size.width,smallRect.size.height);
        self.playerManager=[[GSPPlayerManager alloc]init];
        self.playerManager.delegate=self;
        self.myliveParam=param;
        if(self.myliveParam.iswarmup.integerValue==1){
            NSLog(@"jdjdjdjjdjjdjdjdjdjjdjdjdjdddd");
            self.myliveParam.startDate=self.myliveParam.warmupStime;
        }
        self.myliveParam.status=@"1";
    }
    return self;
}
-(instancetype)initWithPushContent:(CMTLivesRecord*)param from:(BOOL)push{
    self=[super init];
    if (self) {
        self.isFromPush=push;
        self.isfullScreen=NO;
        docRect=CGRectMake(0, CMTNavigationBarBottomGuide,SCREEN_WIDTH,SCREEN_WIDTH/16.0*9.0);
        landscapedocRect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        smallRect=CGRectMake(SCREEN_WIDTH/2,docRect.size.height+41,(SCREEN_WIDTH/2),SCREEN_WIDTH/2/16*9);
        landscapesmallRect=CGRectMake([UIScreen mainScreen].bounds.size.height-smallRect.size.width,[UIScreen mainScreen].bounds.size.width-smallRect.size.height, smallRect.size.width,smallRect.size.height);
        self.playerManager=[[GSPPlayerManager alloc]init];
        self.playerManager.delegate=self;
        self.myliveParam=param;
        self.myliveParam.status=@"1";

    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    if (self.myliveParam.isJoin.integerValue==0) {
        if (self.myliveParam.sysDate.integerValue<self.myliveParam.startDate.integerValue) {
            if (self.time!=nil) {
                [self.time setFireDate:[NSDate dateWithTimeIntervalSinceNow:60]];
            }
        }

    }
    [self.playerManager enableVideo:YES];
    [self.playerManager enableAudio:YES];
    [self.playerManager resetAudioHelper];
}


#pragma mark 视图消失
-(void)viewWillDisappear:(BOOL)animated{
     [super viewWillDisappear:animated];
    
    //设置阻止锁屏代码
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    [audioSession setActive:NO error:nil];
    [self.playerManager enableVideo:NO];
    [self.playerManager enableAudio:NO];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
       [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    if (self.time!=nil) {
         [self.time setFireDate:[NSDate distantFuture]];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    self.HideToolbarTimer.fireDate=[NSDate distantFuture];
    if (self.HideToolbarTimer.isValid) {
        [self.HideToolbarTimer invalidate];
    }
    self.HideToolbarTimer=nil;

}
#pragma mark 键盘展示
- (void)keyboardWillShow:(NSNotification *)notif {
    if(self.replayField.isFirstResponder){
        CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.replayView.frame=CGRectMake(self.replayView.left ,(SCREEN_HEIGHT-rect.size.height-50), self.replayView.width,self.chartView.height);
        if (self.bgView==nil) {
            self.bgView=[[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            self.bgView.backgroundColor=[UIColor colorWithHexString:@"#ffffff"];
            self.bgView.alpha=0.5;
            [self.contentBaseView addSubview:self.bgView];
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardCancel)];
            tap.numberOfTapsRequired=1;
            [self.bgView addGestureRecognizer:tap];
        }else{
            self.bgView.hidden=NO;
        }
        [self.contentBaseView bringSubviewToFront:self.replayView];
    }
    
}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length==0) {
        self.senderButton.userInteractionEnabled=NO;
        [self.senderButton setTitleColor:[UIColor colorWithHexString:@"#989899"] forState:UIControlStateNormal];
        [self.senderButton setBackgroundColor:[UIColor colorWithHexString:@"dcdce2"]];
    }else{
        [self.senderButton setTitleColor:ColorWithHexStringIndex(c_ffffff) forState:UIControlStateNormal];
        [self.senderButton setBackgroundColor:ColorWithHexStringIndex(c_4acbb5)];

        self.senderButton.userInteractionEnabled=YES;
    }

}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
}
#pragma mark 键盘消失点击事件
-(void)keyboardCancel{
    [self.replayField resignFirstResponder];
     self.replayField.text=@"";
}
#pragma mark 键盘消失
- (void)keyboardWillHide:(NSNotification *)notif {
    [self.playerManager resetAudioHelper];
    [self.senderButton setBackgroundColor:[UIColor colorWithHexString:@"dcdce2"]];
    [self.senderButton setTitleColor:[UIColor colorWithHexString:@"#989899"] forState:UIControlStateNormal];    self.senderButton.userInteractionEnabled=NO;
    self.replayView.frame=CGRectMake(0,self.contentBaseView.height-50,SCREEN_WIDTH, 50);
    self.bgView.hidden=YES;
}
-(void)appResignActiveNotification:(NSNotification *)aNotification{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [self.playerManager enableVideo:NO];
    [self.playerManager enableAudio:NO];
     if (self.time!=nil) {
        [self.time setFireDate:[NSDate distantFuture]];
    }
}
-(void)appDidBecomeActive:(NSNotification *)aNotification{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
     [self.playerManager enableAudio:YES];
    [self.playerManager enableVideo:YES];
    [self.playerManager resetAudioHelper];
    if (self.time!=nil) {
        [self.time setFireDate:[NSDate dateWithTimeIntervalSinceNow:60]];
    }
}
#pragma mark 发送消息
-(void)sendMessage{
    if ([self getNetworkReachabilityStatus].integerValue==0) {
        [self toastAnimation:@"你的网络不给力" top:0];
        return;
    }
    NSString *uuid=[CMTAPPCONFIG uuidString];
    NSString *replayString=self.replayField.text;
    if ([replayString stringByReplacingOccurrencesOfString:@" " withString:@""].length==0||[replayString stringByReplacingOccurrencesOfString:@"\n" withString:@""].length==0) {
        [self toastAnimation:@"输入内容不能都为空格或换行符" top:0];
        self.replayField.text=@"";
        return;
    }
    replayString=[self findAndreplacestring:replayString formatten:@"\n*"];
    if([replayString hasSuffix:@"\n"]){
        replayString=[replayString stringByReplacingCharactersInRange:NSMakeRange(replayString.length-1, 1) withString:@""] ;
    }
    if ([replayString hasPrefix:@"\n"]) {
        replayString=[replayString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""] ;
    }
    @try{
        if(![self.playerManager askQuestion:uuid content:replayString]){
         [self.replayField resignFirstResponder];
         self.replayField.text=@"";
            [self toastAnimation:@"消息发送失败" top:0];
    }else{
            GSPQaData *data=[[GSPQaData alloc]init];
            data.questionID=uuid;
            data.ownnerID=CMTUSERINFO.userId.integerValue+1000000000;
            data.isQuestion=YES;
            data.content=replayString;
            data.ownerName=CMTUSERINFO.nickname?:@"未知用户";
            data.time=[[NSDate date] timeIntervalSince1970]*1000*1000;
            [self.ChartSource addObject:data];
            self.chartView.dataSourceArray=[self.ChartSource copy];
            [self.chartView.chartTableView reloadData];
            if (self.chartView.chartTableView.contentSize.height>self.chartView.chartTableView.bounds.size.height) {
                [self.chartView.chartTableView setContentOffset:CGPointMake(0, self.chartView.chartTableView.contentSize.height -self.chartView.chartTableView.bounds.size.height) animated:YES];
            }
            [self.replayField resignFirstResponder];
            self.replayField.text=@"";
        }
    }@catch (NSException * e){
        [self.replayField resignFirstResponder];
        self.replayField.text=@"";
        [self toastAnimation:@"消息发送失败" top:0];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"直播页面 willDeallocSignal");
    }];
    [self setNeedsStatusBarAppearanceUpdate];
    //设置声音模式
    [self setContentState:CMTContentStateLoading moldel:@"1" height:self.toolbarView.height];
    [self.contentBaseView addSubview:self.playView];
    [self.contentBaseView addSubview:self.toolbarView];
    [self.contentBaseView addSubview:self.backButton];
    if (!self.isFromPush) {
        if (self.myliveParam.qaswitch.integerValue==1) {
            [self.contentBaseView addSubview:self.buttonView];
            [self.contentBaseView addSubview:self.scroll];
            [self.contentBaseView addSubview:self.replayView];
        }else{
            self.liveteilWebdetails.frame=CGRectMake(0,docRect.origin.y+docRect.size.height, SCREEN_WIDTH,SCREEN_HEIGHT-(docRect.origin.y+docRect.size.height));
            [self.contentBaseView addSubview:self.liveteilWebdetails];
        }

         [self loadLiveDeilWebView];
        //如果有问答则滚动
        if(self.myliveParam.qaswitch.integerValue==1){
            [self.scroll setContentOffset:CGPointMake(SCREEN_WIDTH,0) animated:NO];
        }
        //获取系统时间
        [self getTheSystemTime];
    }else{
        [self getLivefordetails];
    }
   
     @weakify(self);
    [[RACObserve(self, self.myliveParam.isJoin)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString *x) {
        @strongify(self);
        if (x.integerValue==0) {
            self.defaultView.tipLable.text=@"直播未开始，还不能提问哦！";
        }else{
            self.defaultView.tipLable.text=@"请先报名再向老师请教哦！";

        }
        
    } error:^(NSError *error) {
        
    }];
    //监听直播离开状态
    [[[[RACObserve(self, self.myliveParam.status)ignore:@"1"]distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString *x) {
          @strongify(self);
        if ([x isEqualToString:@"0"]) {
            if (self.updateLiveList!=nil) {
                self.updateLiveList(nil);
            }
            [self AlertAction:NSLocalizedString(@"直播已结束", @"") message:NSLocalizedString(@"请退出重试", @"")];
        }
                   
    } error:^(NSError *error) {
        
    }];
    RACSignal *docSignal=[[RACObserve(self, ishaveDoc)ignore:nil]distinctUntilChanged];
     RACSignal *VideoSignal=[[RACObserve(self, ishaveVideo)ignore:nil]distinctUntilChanged];
    [[[RACSignal merge:@[docSignal,
                        VideoSignal
                        
      ]]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
         @strongify(self);
        [self IShaveswitchButton];
    } error:^(NSError *error) {
        
    }];
    #pragma mark 网络监听处理
    [[[RACObserve([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus)distinctUntilChanged]
       deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        CMTNavigationController *nav=[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
        if ([nav.topViewController isKindOfClass:[LiveVideoPlayViewController class]]) {
            if ([self.networkReachabilityStatus isEqualToString:[self getNetworkReachabilityStatus]]) {
                NSLog(@"jsjsjsjsjsjsjsjsjsjsjsj");
                
            }else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable) {
                [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
                self.alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"你的网络已断开" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [self.alertView show];
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                self.networkReachabilityStatus =[self getNetworkReachabilityStatus];

                
            }else if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWiFi) {
                [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
                self.alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"已连接至wifi" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [self.alertView show];
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                CMTLogError(@"APPCONFIG Reachability Error Value: %@", CMTAPPCONFIG.reachability);
                self.networkReachabilityStatus =[self getNetworkReachabilityStatus];

                
            }
            else if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusReachableViaWWAN){
                if (self.alertView==nil) {
                    self.alertView=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看直播" message:nil delegate:nil
                                                   cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
                    [self.alertView show];
                    @weakify(self)
                    [[[self.alertView rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
                        @strongify(self);
                        if(index.integerValue==0){
                            [self dealwithTimer];
                            
                        }
                    }];

                }
            self.networkReachabilityStatus =[self getNetworkReachabilityStatus];

         }
        }
    } error:^(NSError *error) {;
        
    }];
 //监听页码
 [[[RACObserve(self, pagenumber)distinctUntilChanged]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString *x) {
     @strongify(self);
     [self TurnThePage:x];
 } error:^(NSError *error) {
     
 }];
}
#pragma mark 是否存在切换按钮
-(void)IShaveswitchButton{
    if (self.ishaveVideo.integerValue==1) {
        if (self.ishaveDoc.integerValue==1) {
            self.changgemodel.hidden=NO;
            self.vieoView.hidden=NO;
            self.docView.hidden=NO;
            [self.changgemodel setImage:IMAGE(@"liveChange") forState:UIControlStateNormal];
            self.shareItem.right=self.changgemodel.left-10;
            if(self.myliveParam.displayType.integerValue==1){
              self.docView.frame=self.isfullScreen?landscapedocRect:docRect;
              self.vieoView.frame=self.isfullScreen?landscapesmallRect:smallRect;
            }else{
                self.vieoView.frame=self.isfullScreen?landscapedocRect:docRect;
                self.docView.frame=self.isfullScreen?landscapesmallRect:smallRect;
                [self.contentBaseView insertSubview: self.docView aboveSubview: self.vieoView];
            }
        }else{
            self.shareItem.right=self.changgemodel.right;
            self.changgemodel.hidden=YES;
            self.vieoView.hidden=NO;
            self.docView.hidden=YES;
            self.vieoView.frame=self.isfullScreen?landscapedocRect:docRect;
        }
    }else{
        if (self.ishaveDoc.integerValue==1) {
            self.shareItem.right=self.changgemodel.right;
            self.changgemodel.hidden=YES;
            self.vieoView.hidden=YES;
            self.docView.hidden=NO;
            self.docView.frame=self.isfullScreen?landscapedocRect:docRect;
        }else{
            self.shareItem.right=self.changgemodel.right;
            self.changgemodel.hidden=YES;
            self.vieoView.hidden=YES;
            self.docView.hidden=YES;
            if (self.isfullScreen) {
                self.fullbutton.hidden=YES;
                [self FulScreenRotation:self.fullbutton];
            }else{
                self.fullbutton.hidden=YES;
            }
            
        }
        
    }
    self.fullbutton.hidden=self.toolbarView.hidden;
    [self.contentBaseView bringSubviewToFront:self.toolbarView];
     [self.contentBaseView bringSubviewToFront:self.backButton];
    if(!self.toolbarView.hidden){
        [self addHideToolbarTimer];
    }
}
-(void) performDismiss:(NSTimer *)timer
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    self.alertView=nil;
}
#pragma mark 加入直播
-(void)GSPJoinLiveVideo{
    GSPJoinParam *joinParam = [GSPJoinParam new];
    [self.playerManager enableVideo:YES];
    [self.playerManager enableAudio:YES];
    [self.playerManager activateMicrophone:NO];
    _progressHUD = nil;
    
    joinParam.domain = [self.myliveParam.studentJoinUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[self.myliveParam.serviceType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"training"]) {
        joinParam.serviceType = GSPServiceTypeTraining;
    }else{
        joinParam.serviceType = GSPServiceTypeWebcast;
    }
    
    joinParam.roomNumber = [self.myliveParam.number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    joinParam.nickName =CMTUSERINFO.nickname;
    joinParam.customUserID=CMTUSERINFO.userId.longLongValue+1000000000;
    joinParam.needsValidateCustomUserID=YES;
    
    joinParam.watchPassword = [self.myliveParam.studentClientToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    joinParam.thirdToken = self.myliveParam.roomId;
    
    joinParam.oldVersion = NO;
    [self.playerManager joinWithParam:joinParam];
     self.playerManager.docView=self.docView;
    [self.contentBaseView addSubview:self.docView];
    self.playerManager.videoView=self.vieoView;
    [self.contentBaseView addSubview:self.vieoView];
    [self.contentBaseView addSubview:self.fullbutton];
    //设置阻止锁屏代码
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [self addAVAudioSessionNotification];

}
#pragma mark 加载webView
-(void)loadLiveDeilWebView{
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
    
    [self.liveteilWebdetails loadRequest:request];
}
#pragma mark 获取直播详情
-(void)getLivefordetails{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"0",
                            @"liveUuid":self.myliveParam.liveUuid?:@"",
                            };
    @weakify(self);
    [[[CMTCLIENT CMTGetRoomInfo:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *param) {
        @strongify(self);
        self.myliveParam=param;
        [self.signUpbutton setTitle:self.myliveParam.isJoin.integerValue==0?@"":@"点击报名" forState:UIControlStateNormal];
        if(self.myliveParam.isJoin.integerValue==0){
            [self.signUpbutton setBackgroundImage:IMAGE(@"registedImage") forState:UIControlStateNormal];
        }
        if (self.myliveParam.isJoin.integerValue==1) {
            [self.signUpbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.signUpbutton.layer.cornerRadius = 8;
            self.signUpbutton.layer.masksToBounds = YES;
            self.signUpbutton.backgroundColor = ColorWithHexStringIndex(c_32c7c2);
            self.signUpbutton.userInteractionEnabled=YES;
        }else{
            [self.signUpbutton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
            self.signUpbutton.layer.masksToBounds = YES;
            self.signUpbutton.layer.cornerRadius = 8;
            self.signUpbutton.layer.borderWidth = 1;
            self.signUpbutton.layer.borderColor = COLOR(c_32c7c2).CGColor;
            self.signUpbutton.backgroundColor = [UIColor clearColor];
            self.signUpbutton.userInteractionEnabled=NO;
            
        }
        if(self.myliveParam.iswarmup.integerValue==1){
            NSLog(@"jdjdjdjjdjjdjdjdjdjjdjdjdjdddd");
            self.myliveParam.startDate=self.myliveParam.warmupStime;
        }
        if (self.myliveParam.qaswitch.integerValue==1) {
            [self.contentBaseView addSubview:self.buttonView];
            [self.contentBaseView addSubview:self.scroll];
            [self.scroll addSubview:self.liveteilWebdetails];
            [self.contentBaseView addSubview:self.replayView];
        }else{
            self.liveteilWebdetails.frame=CGRectMake(0,docRect.origin.y+docRect.size.height, SCREEN_WIDTH,SCREEN_HEIGHT-(docRect.origin.y+docRect.size.height));
            [self.contentBaseView addSubview:self.liveteilWebdetails];
        }
        [self loadLiveDeilWebView];
        //如果有问答则滚动
        if(self.myliveParam.qaswitch.integerValue==1){
            [self.scroll setContentOffset:CGPointMake(SCREEN_WIDTH,0) animated:NO];
        }
        if ((param.sysDate.longLongValue>=self.myliveParam.startDate.longLongValue)&&(param.sysDate.longLongValue<self.myliveParam.endDate.longLongValue)) {
            if (self.myliveParam.status.integerValue==1) {
                if (self.myliveParam.isJoin.boolValue==0) {
                    [self GSPJoinLiveVideo];
                }
                if (self.myliveParam.qaswitch.integerValue==1){
                    [self ShowChartView:self.chartButton];
                }
            }
            if (self.time!=nil) {
                [self.time setFireDate:[NSDate distantFuture]];
                if ([self.time isValid] == YES) {
                    [self.time invalidate];
                    self.time = nil;
                }
                
            }
        }else{
            if(self.myliveParam.isJoin.integerValue==0){
                if (param.sysDate.longLongValue<self.myliveParam.startDate.longLongValue) {
                    if (self.time==nil) {
                        self.time=[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(getTheSystemTime) userInfo:nil repeats:YES];
                        [[NSRunLoop currentRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];
                    }else{
                        if ([self.time.fireDate isEqualToDate:[NSDate distantFuture]]) {
                            [self.time setFireDate:[NSDate dateWithTimeIntervalSinceNow:60]];
                        }
                        
                    }
                }else{
                    self.myliveParam.status=@"0";
                    if (self.time!=nil) {
                        [self.time setFireDate:[NSDate distantFuture]];
                    }
                    
                }
            }else{
                if (self.time!=nil) {
                    [self.time setFireDate:[NSDate distantFuture]];
                    if ([self.time isValid] == YES) {
                        [self.time invalidate];
                        self.time = nil;
                    }
                }
                
                
            }
            
        }
        if (self.updateLiveList!=nil) {
            self.updateLiveList(self.myliveParam);
        }
        [self setContentState:CMTContentStateNormal];
        
    } error:^(NSError *error) {
          @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力" top:0];
            [self setContentState:CMTContentStateReload moldel:@"1"];
        }else{
            NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
            if (errcode.integerValue==112200) {
                if (self.updateLiveList!=nil) {
                    self.updateLiveList(nil);
                }
                [self AlertAction:[error.userInfo objectForKey:@"errmsg"] message:nil];
            }else{
                [self toastAnimation:[error.userInfo objectForKey:@"errmsg"] top:0];
                [self setContentState:CMTContentStateReload moldel:@"1"];
            }
            
            
        }
        
    }];
    

}
#pragma mark 获取当前系统时间
-(void)getTheSystemTime{
           NSDictionary *param = @{
                                @"userId":CMTUSERINFO.userId?:@"0",
                                @"liveUuid":self.myliveParam.liveUuid?:@"",
            };
          @weakify(self);
    [[[CMTCLIENT CMTGetRoomStatus:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *x) {
        @strongify(self);
        self.myliveParam.sysDate=x.sysDate;
        self.myliveParam.startDate=x.startDate;
        self.myliveParam.endDate=x.endDate;
        self.myliveParam.status=x.status;
        if ((x.sysDate.longLongValue>=self.myliveParam.startDate.longLongValue)&&(x.sysDate.longLongValue<self.myliveParam.endDate.longLongValue)) {
            if (self.myliveParam.status.integerValue==1) {
                if (self.myliveParam.isJoin.boolValue==0) {
                    [self GSPJoinLiveVideo];
                }
                if (self.myliveParam.qaswitch.integerValue==1) {
                    [self ShowChartView:self.chartButton];
                }
            }
            if (self.time!=nil) {
                [self.time setFireDate:[NSDate distantFuture]];
                if ([self.time isValid] == YES) {
                    [self.time invalidate];
                    self.time = nil;
                }

            }
        }else{
            if(self.myliveParam.isJoin.integerValue==0){
                if (x.sysDate.longLongValue<self.myliveParam.startDate.longLongValue) {
                    if (self.time==nil) {
                        self.time=[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(getTheSystemTime) userInfo:nil repeats:YES];
                        [[NSRunLoop currentRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];
                    }else{
                        if ([self.time.fireDate isEqualToDate:[NSDate distantFuture]]) {
                             [self.time setFireDate:[NSDate dateWithTimeIntervalSinceNow:60]];
                        }
                        
                    }
                }else{
                    self.myliveParam.status=@"0";
                    if (self.time!=nil) {
                        [self.time setFireDate:[NSDate distantFuture]];
                    }

                }
            }else{
                if (self.time!=nil) {
                    [self.time setFireDate:[NSDate distantFuture]];
                    if ([self.time isValid] == YES) {
                        [self.time invalidate];
                        self.time = nil;
                    }
                }

                
            }
 
        }
        if (self.updateLiveList!=nil) {
            self.updateLiveList(self.myliveParam);
        }
        [self setContentState:CMTContentStateNormal moldel:@"1"];
        
    } error:^(NSError *error) {
          @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力" top:0];
             [self setContentState:CMTContentStateReload moldel:@"1"];
        }else{
            NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
            if (errcode.integerValue==112200) {
                if (self.updateLiveList!=nil) {
                    self.updateLiveList(nil);
                }
                [self AlertAction:[error.userInfo objectForKey:@"errmsg"] message:nil];
            }else{
                 [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]top:0];
                 [self setContentState:CMTContentStateReload moldel:@"1"];
            }

           
        }

    }];
   

}
#pragma mark 展示问答页面
-(void)ShowChartView:(UIButton*)sender{
           self.lineView.frame=CGRectMake(sender.frame.origin.x, self.lineView.top, self.lineView.width, self.lineView.height);
            [self.chartButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
            [self.liveDteilButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
            [self.scroll setContentOffset:CGPointMake(0,0) animated:NO];
            self.replayView.hidden=NO;
            if (!self.chartView.hidden) {
                self.replayView.hidden=NO;
            }else{
                self.replayView.hidden=YES;
        }
}
#pragma mark 加载失败后从新加载
-(void)animationFlash{
    [super animationFlash];
    [self getTheSystemTime];
}
#pragma mark 切换ppt和视频
-(void)Changemodel:(UIButton *)changemodel{
    [self.vieoView viewWithTag:100].hidden=YES;
    [self.docView viewWithTag:100].hidden=YES;
    if (self.vieoView.hidden) {
        self.vieoView.hidden=NO;
        if(!self.isfullScreen){
           self.vieoView.frame=smallRect;
        }else{
            self.vieoView.frame =landscapesmallRect;
        }
        [self.contentBaseView bringSubviewToFront:self.vieoView];
         [self.contentBaseView bringSubviewToFront:self.fullbutton];
        [self.contentBaseView bringSubviewToFront:self.toolbarView];
        [self.contentBaseView bringSubviewToFront:self.backButton];
        [changemodel setImage:IMAGE(@"liveChange") forState:UIControlStateNormal];
    }else if(self.docView.hidden){
        self.docView.hidden=NO;
        if(!self.isfullScreen){
            self.docView.frame=smallRect;
        }else{
            self.docView.frame =landscapesmallRect;
        }

         [changemodel setImage:IMAGE(@"liveChange") forState:UIControlStateNormal];
         [self.contentBaseView bringSubviewToFront:self.docView];
        [self.contentBaseView bringSubviewToFront:self.fullbutton];
         [self.contentBaseView bringSubviewToFront:self.toolbarView];
         [self.contentBaseView bringSubviewToFront:self.backButton];
    }else{
        if (!self.isfullScreen) {
            if (self.vieoView.frame.size.width==docRect.size.width){
                self.vieoView.frame=smallRect;
                self.docView.frame=docRect;
            [self.contentBaseView insertSubview:self.vieoView aboveSubview:self.docView];

            }else{
                self.vieoView.frame=docRect;
                self.docView.frame=smallRect;
                [self.contentBaseView insertSubview:self.docView aboveSubview:self.vieoView];
            }
        }else{
            if (self.vieoView.frame.size.width==[UIScreen mainScreen].bounds.size.height){
                self.vieoView.frame=landscapesmallRect;
                self.docView.frame=landscapedocRect;
                [self.contentBaseView insertSubview:self.vieoView aboveSubview:self.docView];

            }else{
                self.vieoView.frame=landscapedocRect;
                self.docView.frame=landscapesmallRect;
                [self.contentBaseView insertSubview:self.docView aboveSubview:self.vieoView];
            }

            
        }
       
        
    }
}
//添加定时隐藏
-(void)addHideToolbarTimer{
    if(self.HideToolbarTimer==nil){
        self.HideToolbarTimer=[NSTimer timerWithTimeInterval:5 target:self selector:@selector(CMTHideTheToolbar) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.HideToolbarTimer forMode:NSRunLoopCommonModes];
    }else{
        [self.HideToolbarTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    
}

#pragma mark 全屏
-(void)FulScreenRotation:(UIButton*)btn{
    [self.view endEditing:YES];//收起键盘
    //强制旋转
    if (!self.isfullScreen) {
          @weakify(self);
        [UIView animateWithDuration:0.5 animations:^{
            @strongify(self);
            self.contentBaseView.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.contentBaseView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            if(self.docView.frame.size.width==smallRect.size.width&&!self.docView.hidden){
               self.docView.frame = CGRectMake([UIScreen mainScreen].bounds.size.height-self.docView.width,[UIScreen mainScreen].bounds.size.width-self.docView.height, self.docView.width,self.docView.height);
            }else{
                self.docView.frame =landscapedocRect;
            }
            self.isfullScreen = YES;
            if(self.vieoView.frame.size.width==smallRect.size.width&&!self.vieoView.hidden){
                self.vieoView.frame = CGRectMake([UIScreen mainScreen].bounds.size.height-self.vieoView.width,[UIScreen mainScreen].bounds.size.width-self.vieoView.height, self.vieoView.width,self.vieoView.height);
            }else{
                self.vieoView.frame =landscapedocRect;
            }
            self.playView.hidden=YES;
            self.scroll.hidden=YES;
            self.buttonView.hidden=YES;
            [self.contentBaseView bringSubviewToFront:self.toolbarView];
            [self.contentBaseView bringSubviewToFront:self.backButton];
            [self changeTooBarView];
            [btn setImage:IMAGE(@"liveZoomButton") forState:UIControlStateNormal] ;
            [self.contentBaseView bringSubviewToFront:btn];
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    } else {
          @weakify(self);
        [UIView animateWithDuration:0.5 animations:^{
            @strongify(self);
            self.contentBaseView.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(0));
            self.contentBaseView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            if(self.vieoView.frame.size.width==smallRect.size.width&&!self.vieoView.hidden){
                 self.vieoView.frame=smallRect;
            }else{
                self.vieoView.frame=docRect;

            }
            if(self.docView.frame.size.width==smallRect.size.width&&!self.docView.hidden){
                self.docView.frame=smallRect;
            }else{
                self.docView.frame=docRect;
                
            }
             self.isfullScreen = NO;
             self.playView.hidden=NO;
            self.toolbarView.hidden=NO;
            self.scroll.hidden=NO;
            self.buttonView.hidden=NO;
            [self changeTooBarView];
            [self setNeedsStatusBarAppearanceUpdate];
            [btn setImage:IMAGE(@"liveFullModeImage") forState:UIControlStateNormal] ;
        }];
    }
   self.shareItem.hidden=self.isfullScreen;
}
#pragma mark 旋屏自适应
-(void)changeTooBarView{
    if (self.isfullScreen) {
        self.toolbarView.frame=CGRectMake(0, 0,self.view.height, self.toolbarView.height);
        self.backButton.frame=CGRectMake(10, self.backButton.top, self.backButton.width, self.backButton.height);
        self.changgemodel.frame=CGRectMake(self.toolbarView.width-self.changgemodel.width-10, self.changgemodel.top, self.changgemodel.width, self.changgemodel.height);
        self.fullbutton.frame=CGRectMake(SCREEN_HEIGHT-self.fullbutton.width-10, SCREEN_WIDTH-self.fullbutton.height-10,  self.fullbutton.width,self.fullbutton.height);
    }else{
        self.toolbarView.frame=CGRectMake(0, 0,self.view.width, self.toolbarView.height);
        self.backButton.frame=CGRectMake(10, self.backButton.top, self.backButton.width, self.backButton.height);
        self.changgemodel.frame=CGRectMake(self.toolbarView.width-self.changgemodel.width-10, self.changgemodel.top, self.changgemodel.width, self.changgemodel.height);
        self.fullbutton.frame=CGRectMake(SCREEN_WIDTH-self.fullbutton.width-10, docRect.origin.y+(docRect.size.height-self.fullbutton.height-10), self.fullbutton.width,self.fullbutton.height);

    }
    if(self.changgemodel.hidden){
        self.shareItem.right=self.changgemodel.right;
    }else{
        self.shareItem.right=self.changgemodel.left-10;
    }

}

#pragma mark - GSPPlayerManagerDelegate

- (void)playerManager:(GSPPlayerManager *)playerManager didSelfLeaveFor:(GSPLeaveReason)reason {
    NSString *reasonStr = nil;
    switch (reason) {
        case GSPLeaveReasonEjected:
            reasonStr = NSLocalizedString(@"被踢出直播", @"");
            break;
        case GSPLeaveReasonTimeout:
            reasonStr = NSLocalizedString(@"连接超时", @"");
            break;
        case GSPLeaveReasonClosed:
            reasonStr = NSLocalizedString(@"直播已结束", @"");
            break;
        case GSPLeaveReasonUnknown:
            reasonStr = NSLocalizedString(@"位置错误", @"");
            break;
        default:
            break;
    }
    if (reasonStr != nil) {
        if (self.updateLiveList!=nil) {
            self.updateLiveList(nil);
        }
        [self AlertAction:reasonStr message:NSLocalizedString(@"退出直播", @"")];
    }
    
}

- (void)playerManager:(GSPPlayerManager *)playerManager didReceiveSelfJoinResult:(GSPJoinResult)joinResult {
    NSString *result = @"";
    switch (joinResult) {
        case GSPJoinResultCreateRtmpPlayerFailed:
            result = NSLocalizedString(@"创建直播实例失败", @"");
            break;
        case GSPJoinResultJoinReturnFailed:
            result = NSLocalizedString(@"调用加入直播失败", @"");
            break;
        case GSPJoinResultNetworkError:
            result = NSLocalizedString(@"网络错误", @"");
            break;
        case GSPJoinResultUnknowError:
            result = NSLocalizedString(@"未知错误", @"");
            break;
        case GSPJoinResultParamsError:
            result = NSLocalizedString(@"参数错误", @"");
            break;
        case GSPJoinResultOK:
            result = @"加入成功";
            NSLog(@"加入成功");
             self.defaultView.tipLable.text=@"评论加载中，请稍候！";
            self.signUpbutton.hidden = YES;
            if(self.myliveParam.qaswitch.integerValue==1){
              [self ChangeThetab:self.chartButton];
              self.replayView.hidden=NO;
               self.chartView.hidden=NO;
            }
            break;
        case GSPJoinResultCONNECT_FAILED:
            result = NSLocalizedString(@"连接失败", @"");
            break;
        case GSPJoinResultTimeout:
            result = NSLocalizedString(@"连接超时", @"");
            break;
        case GSPJoinResultRTMP_FAILED:
            result = NSLocalizedString(@"连接媒体服务器失败", @"");
            break;
        case GSPJoinResultTOO_EARLY:
            result =NSLocalizedString(@"直播尚未开始", @"");
            break;
        case GSPJoinResultLICENSE:
            result = NSLocalizedString(@"人数已满", @"");
            break;
        default:
            result = NSLocalizedString(@"错误", @"");
            break;
    }
    
    //用于断线重连
    if (_progressHUD != nil) {
        [_progressHUD hide:YES];
        _progressHUD = nil;
    }

    if ([result isEqualToString:@"加入成功"]) {
        self.myliveParam.classRoomType=@"1";
        [self StatisticsThenumber:self.myliveParam];
    } else {
        if (self.updateLiveList!=nil) {
            self.updateLiveList(self.myliveParam);
        }
        [self AlertAction:result message:NSLocalizedString(@"请退出重试", @"")];
       
    }
    
    
}
#pragma mark 弹出提示
-(void)AlertAction:(NSString*)result message:(NSString*)message{
    UIAlertView *alertView;
    alertView = [[UIAlertView alloc] initWithTitle:result message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:nil];
    [alertView show];
    @weakify(self);
    [[alertView rac_buttonClickedSignal]subscribeNext:^(NSNumber *x) {
        @strongify(self);
        [self deallocobject];
        [self.navigationController popViewControllerAnimated:YES];
    }];

}

- (void)playerManagerWillReconnect:(GSPPlayerManager *)playerManager {
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.vieoView];
    _progressHUD.labelText = NSLocalizedString(@"断线重连", @"");
    [self.view addSubview:_progressHUD];
    [_progressHUD show:YES];
}
/**
 *  视频开始事件代理
 *
 *  @param playerManager 调用该代理的直播管理实例
 */
- (void)playerManagerDidVideoBegin:(GSPPlayerManager*)playerManager{
    NSLog(@"ddddddddd");
    self.ishaveVideo=@"1";
}

/**
 *  视频结束事件代理
 *
 *  @param playerManager 调用该代理的直播管理实例
 */
- (void)playerManagerDidVideoEnd:(GSPPlayerManager*)playerManager{
     NSLog(@"ccccccc");
    self.ishaveVideo=@"0";
}

/**
 *  文档关闭事件代理
 *
 *  @param playerManager 调用该代理的直播管理实例
 */
- (void)playerManagerDidDocumentClose:(GSPPlayerManager*)playerManager{
     NSLog(@"eeeeeeeeeeeeeee");
     self.ishaveDoc=@"0";
}
- (void)playerManagerDidDocumentSwitch:(GSPPlayerManager*)playerManager{
    NSLog(@"sssssss");
     self.ishaveDoc=@"1";
}



//chatView
- (void)playerManager:(GSPPlayerManager *)playerManager didUserJoin:(GSPUserInfo *)userInfo {
    
}

//chatView
- (void)playerManager:(GSPPlayerManager *)playerManager didUserLeave:(GSPUserInfo *)userInfo {
    
}



/**
 *  收到聊天信息代理
 *
 *  @param playerManager 调用该代理的直播管理实例
 *  @param message       收到的聊天信息
 */
- (void)playerManager:(GSPPlayerManager*)playerManager didReceiveChatMessage:(GSPChatMessage*)message
{
    
    NSLog(@"didReceiveChatMessage******");
    
    
}
- (void)playerManager:(GSPPlayerManager *)playerManager didReceiveQaData:(NSArray *)qaDatas{
    NSLog(@"didReceiveChatMessage******%@",qaDatas);
    for (GSPQaData *data in qaDatas) {
        if (data.isCanceled) {
            NSArray *array=[self.ChartSource copy];
            for (GSPQaData *ss in array) {
                if (ss.ownnerID==1000000000+CMTUSERINFO.userId.integerValue) {
                    if ([ss.questionID isEqualToString:data.questionID]&&ss.isQuestion==NO) {
                        [self.ChartSource removeObject:ss];
                    }
                }else{
                    if ([ss.questionID isEqualToString:data.questionID]) {
                        [self.ChartSource removeObject:ss];
                    }
                }
               
            }
            
        }else{
            NSArray *array=[self.ChartSource copy];
            if (data.isQuestion) {
                 BOOL ishave=NO;
                for (GSPQaData *ss in array) {
                    if ([ss.questionID isEqualToString:data.questionID]&&(ss.isQuestion==YES)) {
                        ishave=YES;
                    }
                }
                if (!ishave) {
                    if(data.content.length>0){
                        [self.ChartSource addObject:data];
                    }
                }

                
            }else{
                if (data.content.length>0) {
                    [self.ChartSource addObject:data];
                }
                

            }
            
        }
    }
    self.chartView.dataSourceArray=[self.ChartSource copy];
    [self.chartView.chartTableView reloadData];
    if (self.chartView.chartTableView.contentSize.height>self.chartView.chartTableView.bounds.size.height) {
        [self.chartView.chartTableView setContentOffset:CGPointMake(0, self.chartView.chartTableView.contentSize.height -self.chartView.chartTableView.bounds.size.height) animated:YES];
    }
    
}


/**
 *  直播是否暂停
 *
 *  @param playerManager 调用该代理的直播管理实例
 *  @param isPaused      YES表示直播已暂停，NO表示直播进行中
 */
- (void)playerManager:(GSPPlayerManager*)playerManager isPaused:(BOOL)isPaused
{
    
    NSLog(@"isPaused******");
    
}


- (void)playerManager:(GSPPlayerManager *)playerManager  didReceiveMediaInvitation:(GSPMediaInvitationType)type action:(BOOL)on
{
    [_alert dismissWithClickedButtonIndex:1 animated:YES];
    
    if (GSPMediaInvitationTypeAudioOnly == type) {
        
        if (on) {
            
            if (!_alert) {
                _alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"直播间邀请您语音对话", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"拒绝", nil) otherButtonTitles:NSLocalizedString(@"接受", nil), nil];
                _alert.tag = 999;
                
            }
            
            [_alert show];
            
            
        }
        else
        {
            [playerManager activateMicrophone:NO];
            
            [playerManager acceptMediaInvitation:NO type:type];
            
            
        }
    }
}


//直播未开始返回
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999 && buttonIndex == 1) {
        [self.playerManager activateMicrophone:YES];
        [self.playerManager acceptMediaInvitation:YES type:GSPMediaInvitationTypeAudioOnly];
        
        if(buttonIndex == 0){
            
            NSLog(@"接受");
            [self.playerManager acceptMediaInvitation:YES type:GSPMediaInvitationTypeAudioOnly];
            
            
            [self.playerManager activateMicrophone:YES];
            
            
        }else{
            
            NSLog(@"拒绝");
            [self.playerManager acceptMediaInvitation:NO type:GSPMediaInvitationTypeAudioOnly];
            
        }
        
        
    }
    else if (alertView.tag == 999 && buttonIndex == 0) {
        [self.playerManager acceptMediaInvitation:NO type:GSPMediaInvitationTypeAudioOnly];
    }
}

#pragma mark -

- (void)deallocobject {
    @try {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [self.playerManager enableVideo:NO];
        [self.playerManager enableAudio:NO];
        [self.playerManager activateMicrophone:NO];
        [self.playerManager leave];
        //离开销毁对象
        [self.playerManager invalidate];
    } @catch (NSException *exception) {
        NSLog(@"关闭失败");
    } @finally {
        [[NSNotificationCenter defaultCenter]removeObserver:self];

    }
  }





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
