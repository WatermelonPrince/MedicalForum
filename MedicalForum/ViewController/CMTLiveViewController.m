//
//  CMTLiveViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLiveViewController.h"
#import "CMTCaseListCell.h"
#import "CMTTableSectionHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "CMTBindingViewController.h"
#import "CMTNoticeViewController.h"
#import "CMTLiveNoticeViewController.h"
#import "CMTSendCaseViewController.h"
#import "CMTLiveDetailViewController.h"
#import "CMTPostProgressView.h"
#import "CMTLiveTagFilterViewController.h"
#import "UITableView+CMTExtension_PlaceholderView.h"
#import "CMTBaseViewController+CMTExtension.h"

static  NSString * const CMTCellLiveCellIdentifier = @"CMTCellliveCell";
static NSString * const CMTPostListSectionPostDateKey = @"PostDate";
static NSString * const CMTPostListSectionPostArrayKey = @"PostArray";

@interface CMTLiveViewController ()<UITableViewDataSource,UITableViewDelegate,CMTCaseListCellDelegate,UIActionSheetDelegate,CMTPostProgressViewDelegate, CMTLiveListCellDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)UIView *headView;//导航条
@property(nonatomic,strong)UIImageView *headimageView;//导航条背景图
@property(nonatomic,strong)UIButton *filitebutton;//过滤按钮
@property(nonatomic,strong)CMTLive *mylive;
@property(nonatomic,strong)UIButton *backbutton;//返回
@property(nonatomic,strong)UIButton *sharebutton;//分享
@property(nonatomic,strong)UITableView *livetableView;//列表
@property(nonatomic,strong)NSMutableArray *livedataArray;
@property(nonatomic,strong)NSArray *liveSectionArray;
@property(nonatomic,strong)CMTLive *liveinfo;
@property(nonatomic,strong)CMTLive *topmessage;
@property(nonatomic,strong)NSString *isOfficial;
@property(nonatomic,strong)UIButton *PostingButton;
@property (strong, nonatomic) NSString *shareCreateUserName;                    // 直播消息发布者名称
@property (strong, nonatomic) NSString *shareContent;                           // 直播消息content
@property (strong, nonatomic) NSString *shareUrl;                               // 分享链接
@property(strong,nonatomic)UIControl *noticeView;
@property(strong,nonatomic)UILabel *noticelalbe;
@property(strong,nonatomic)UIView *tableViewHeadView;
@property(strong,nonatomic)NSIndexPath *indexpath;
@property(strong,nonatomic)CMTPostProgressView *progressView;
@property(strong,nonatomic)NSString *liveUuid;
@end

@implementation CMTLiveViewController
-(UIControl*)noticeView{
    if (_noticeView==nil) {
        _noticeView=[[UIControl alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,40)];
        _noticeView.backgroundColor=COLOR(c_f6f6f6);
        [_noticeView addSubview:self.noticelalbe];
        _noticelalbe.autoresizesSubviews=YES;
        [_noticeView addTarget:self action:@selector(showNotice) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _noticeView;
}
-(UIView*)tableViewHeadView{
    if (_tableViewHeadView==nil) {
        _tableViewHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
         _tableViewHeadView.backgroundColor=COLOR(c_f6f6f6);
        [_tableViewHeadView addSubview:self.noticeView];
    }
    return _tableViewHeadView;
}
-(UILabel*)noticelalbe{
    if (_noticelalbe==nil) {
        _noticelalbe=[[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,40)];
        _noticelalbe.layer.cornerRadius=5;
        _noticelalbe.layer.masksToBounds=YES;
        _noticelalbe.font=[UIFont boldSystemFontOfSize:15];
        _noticelalbe.textColor=[UIColor whiteColor];
        _noticelalbe.textAlignment=NSTextAlignmentCenter;
        _noticelalbe.backgroundColor=[UIColor colorWithHexString:@"#373B3A"];
    }
    return _noticelalbe;
}
-(NSMutableArray*)livedataArray{
    if (_livedataArray==nil) {
        _livedataArray=[[NSMutableArray alloc]init];
    }
    return _livedataArray;
}
-(UIView*)headView{
    if (_headView==nil) {
        _headView=[[UIView alloc]init];
        _headView.backgroundColor=COLOR(c_f6f6f6);
        [_headView addSubview:self.headimageView];
        [_headView addSubview:self.filitebutton];
    }
    return _headView;
}
-(UIImageView*)headimageView{
    if (_headimageView==nil) {
        _headimageView=[[UIImageView alloc]init];
        _headimageView.contentMode=UIViewContentModeScaleToFill;
        _headimageView.clipsToBounds=YES;
        _headimageView.userInteractionEnabled=NO;
    }
    return _headimageView;
}
-(UIButton*)filitebutton{
    if (_filitebutton==nil) {
        _filitebutton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        _filitebutton.layer.borderWidth=1;
        _filitebutton.layer.cornerRadius=5;
        _filitebutton.tag=0;
        _filitebutton.layer.borderColor=[UIColor whiteColor].CGColor;
        _filitebutton.showsTouchWhenHighlighted=NO;
        _filitebutton.adjustsImageWhenHighlighted=NO;
        [_filitebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_filitebutton setBackgroundColor:ColorWithHexStringIndex(c_clear)];
        _filitebutton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [_filitebutton addTarget:self action:@selector(CmtfilteLiveData:) forControlEvents:UIControlEventTouchDown];
    }
    return _filitebutton;
}
-(UIButton*)backbutton{
    if (_backbutton==nil) {
        _backbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 20, 50, 50)];
        _backbutton.showsTouchWhenHighlighted=NO;
        _backbutton.adjustsImageWhenHighlighted=NO;
        [_backbutton setBackgroundColor:ColorWithHexStringIndex(c_clear)];
        [_backbutton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10,0, 27, 27)];
        imageView.image=IMAGE(@"liveback");
        [_backbutton addSubview:imageView];
    }
    return _backbutton;
}
-(UIButton*)sharebutton{
    if (_sharebutton==nil) {
        _sharebutton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-40, 20, 30, 30)];
        [_sharebutton setImage:IMAGE(@"liveShare") forState:UIControlStateNormal];
        [_sharebutton addTarget:self action:@selector(CMTShareAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sharebutton;
}
-(UIButton*)PostingButton{
    if (_PostingButton==nil) {
        _PostingButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-80, SCREEN_HEIGHT-90, 60, 60)];
        _PostingButton.hidden=YES;
        [_PostingButton setImage:IMAGE(@"livePosting") forState:UIControlStateNormal];
        _PostingButton.showsTouchWhenHighlighted=NO;
        _PostingButton.adjustsImageWhenHighlighted=NO;
        [_PostingButton addTarget:self action:@selector(sendPost) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pangesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [_PostingButton addGestureRecognizer:pangesture];
    }
    return _PostingButton;
}

-(UITableView*)livetableView{
    if (_livetableView==nil) {
        _livetableView=[[UITableView alloc]initWithFrame:CGRectMake(0, self.headView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT-self.headView.bottom)];
        _livetableView.backgroundColor = COLOR(c_efeff4);
        _livetableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _livetableView.dataSource = self;
        _livetableView.delegate = self;
        [_livetableView registerClass:[CMTCaseListCell class]forCellReuseIdentifier:CMTCellLiveCellIdentifier];
        [self.contentBaseView addSubview:_livetableView];

//        UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction)];
//        Swipe.numberOfTouchesRequired=1;
//        Swipe.direction=UISwipeGestureRecognizerDirectionRight;
//        [Swipe setDelaysTouchesBegan:YES];
//        Swipe.delegate=self;
//        [self.livetableView addGestureRecognizer:Swipe];

    }
    return _livetableView;
}
- (UIView *)tableViewPlaceholderView {
    UIView *placeholderView = [[UIView alloc] init];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width,100)];
    placeholderLabel.center=CGPointMake(self.livetableView.centerX, self.livetableView.centerY-200);
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(18);
    placeholderLabel.numberOfLines=0;
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text = @"直播即将开始！\n 一大波精彩动态正在赶来！";
    
    [placeholderView addSubview:placeholderLabel];
    
    return placeholderView;
}

 #pragma 展示通知
-(void)showNotice{
    @weakify(self);
    CMTLiveNoticeViewController *liveNoticeViewController = [[CMTLiveNoticeViewController alloc] initWithLiveId:self.mylive.liveBroadcastId];
    liveNoticeViewController.updateNoticeCount=^(NSString *count){
        @strongify(self);
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"liveBroadcastId":self.liveinfo.liveBroadcastId,
                               };
        [[[CMTCLIENT getLiveNoticeCount:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNoticeData *teamdata) {
            @strongify(self);
            self.liveinfo.noticeCount=teamdata.noticeCount;
            [self shownoticeLable];
        }error:^(NSError *error) {
            CMTLog(@"获取通知总数失败");
            @strongify(self);
            self.liveinfo.noticeCount=@"0";
            [self shownoticeLable];
        }];
    };
    [self.navigationController pushViewController:liveNoticeViewController animated:YES];
    
}
//发布按钮移动
- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    float recx=recognizer.view.center.x + translation.x;
    if (recx<60) {
        recx=60;
    }else if(recx>SCREEN_WIDTH-60){
          recx=SCREEN_WIDTH-60;
    }
    float recy=recognizer.view.center.y + translation.y;
    if (recy<self.headView.bottom) {
        recy=self.headView.bottom;
    }else if(recy>SCREEN_HEIGHT-60){
        recy=SCREEN_HEIGHT-60;
    }


    recognizer.view.center = CGPointMake(recx,recy);
    [recognizer setTranslation:CGPointZero inView:self.contentBaseView];
    
}
#pragma 返回
-(void)backAction{
    if (self.updatelivedata!=nil) {
         self.updatelivedata(self.liveinfo);
    }
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma 发帖
-(void)sendPost{
   if(CMTAPPCONFIG.addLivemessageData.addPostStatus.integerValue!=0){
        [self toastAnimation:@"还有未发送成功的帖子"];
        return;
    }
    if (!self.liveinfo.participationLimit.boolValue) {
        if (!CMTUSER.login ) {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [self.navigationController pushViewController:loginVC animated:YES];
            return;
        }
     }
    CMTSendCaseViewController *send=[[CMTSendCaseViewController alloc]initWithSenLivemassge:self.liveinfo];
    CMTNavigationController *navi = [[CMTNavigationController alloc] initWithRootViewController:send];
    [self presentViewController:navi animated:YES completion:nil];
    @weakify(self);
    send.updateCaseList=^(CMTAddPost * livemessage){
        @strongify(self);
        NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:livemessage.liveBroadcastMessage, nil];
        [array addObjectsFromArray:self.livedataArray];
        self.livedataArray=[array mutableCopy];
        [self setCacheLiveList:[self.livedataArray copy]];
        [self.livetableView reloadData];
        [self.progressView SendSuccess];
        [self.contentBaseView bringSubviewToFront:self.headView];

        
    };

}
-(instancetype)initWithliveUuid:(NSString*)Uuid{
    self=[super init];
    if (self) {
        self.liveUuid=Uuid;
        self.isOfficial=@"0";
    }
    return self;

}
-(instancetype)initWithlive:(CMTLive*)live{
    self=[super init];
    if (self) {
        self.mylive=live;
        self.isOfficial=@"0";
    }
    return self;
}
//绘制导航条
-(void)CmtDrawNavCationbar{
    
    [self.contentBaseView addSubview:self.headView];

  
   //宽高比
    float base=[@"69" floatValue]/[@"20" floatValue];
    if (!isEmptyObject(((CMTPicture*)self.mylive.headPic).picFilepath)) {
        NSArray *attr=[((CMTPicture*)self.mylive.headPic).picAttr componentsSeparatedByString:@"_"];
        base=[[attr objectAtIndex:0] floatValue]/[[attr objectAtIndex:1] floatValue];
    }
    
    self.headimageView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/base);
    [self.headimageView setImageURL:((CMTPicture*)self.mylive.headPic).picFilepath placeholderImage:IMAGE(@"livehead") contentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH/base)];
    [self.headView addSubview:self.backbutton];
    [self.headView addSubview:self.sharebutton];
    
     self.filitebutton.frame=CGRectMake(SCREEN_WIDTH-120,20, 60, 30);
     [self.filitebutton setTitle:@"官方" forState:UIControlStateNormal];
     self.filitebutton.tag=0;
    self.filitebutton.hidden=self.mylive.participationLimit.boolValue;
    
     self.headView.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.headimageView.bottom);
    [self.contentBaseView bringSubviewToFront:self.headView];
    
    
}
#pragma 生命周期
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 返回按钮
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"LiveList willDeallocSignal");
    }];
    
    [self setNeedsStatusBarAppearanceUpdate];

    //绘制导航条
    [self CmtDrawNavCationbar];
    [self CmtLivePullToRefresh];
    [self CmtLiveIniteRefresh];
    //绘制列表
    self.livetableView.frame=CGRectMake(0, self.headView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT-self.headView.bottom);
    [self.contentBaseView addSubview:self.livetableView];
    //发帖按钮
    [self.contentBaseView addSubview:self.PostingButton];
    
    //跳立方
    [self setContentState:CMTContentStateLoading moldel:@"1"];
    self.mReloadBaseView.frame=CGRectMake(0, self.headView.height, SCREEN_WIDTH, SCREEN_HEIGHT-self.headView.height);
    [self CmtGetLiveData];
    @weakify(self);
#pragma 监听发送进度条
    [[RACObserve(CMTAPPCONFIG,addLivemessageData.addPostStatus) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        if (CMTAPPCONFIG.addLivemessageData.addPostStatus.integerValue==1) {
            if (self.progressView==nil) {
                if (self.liveinfo.noticeCount.integerValue==0) {
                    self.progressView=[[CMTPostProgressView alloc]initWithFrame:CGRectMake(10,10,SCREEN_WIDTH-20 ,30) module:CmtSendLiveTypeAddpost];
                     [self.tableViewHeadView addSubview:self.progressView];
                    self.noticeView.frame=CGRectMake( self.noticeView.left,  self.progressView.bottom+10, self.noticeView.width,0);
                    self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,0);
                    self.tableViewHeadView.frame=CGRectMake(0, 0,SCREEN_WIDTH,self.noticeView.bottom);

                }else{
                    self.progressView=[[CMTPostProgressView alloc]initWithFrame:CGRectMake(10,10,SCREEN_WIDTH-20 ,30) module:CmtSendLiveTypeAddpost];
                     [self.tableViewHeadView addSubview:self.progressView];
                    self.noticeView.frame=CGRectMake( self.noticeView.left,  self.progressView.bottom+10, self.noticeView.width, self.noticeView.height);
                    self.tableViewHeadView.frame=CGRectMake(0, 0,SCREEN_WIDTH,self.noticeView.bottom+10);
                }
                self.progressView.delegate=self;
                self.livetableView.tableHeaderView=self.tableViewHeadView;
                [self.progressView start];
            }else{
                [self.progressView start];
                
            }
        }else if(CMTAPPCONFIG.addLivemessageData.addPostStatus.integerValue==3){
            if (self.progressView==nil) {
                if (self.liveinfo.noticeCount.integerValue==0) {
                    self.progressView=[[CMTPostProgressView alloc]initWithFrame:CGRectMake(10,10,SCREEN_WIDTH-20 ,30) module:CmtSendLiveTypeAddpost];
                    self.noticeView.frame=CGRectMake( self.noticeView.left,  self.progressView.bottom+10, self.noticeView.width,0);
                    self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,0);
                    self.tableViewHeadView.frame=CGRectMake(0, 0,SCREEN_WIDTH,self.noticeView.bottom);
                    
                }else{
                    self.progressView=[[CMTPostProgressView alloc]initWithFrame:CGRectMake(10,10,SCREEN_WIDTH-20 ,30) module:CmtSendLiveTypeAddpost];
                    self.noticeView.frame=CGRectMake( self.noticeView.left,  self.progressView.bottom+10, self.noticeView.width, self.noticeView.height);
                    self.tableViewHeadView.frame=CGRectMake(0, 0,SCREEN_WIDTH,self.noticeView.bottom+10);
                }
                 self.progressView.delegate=self;
                [self.tableViewHeadView addSubview:self.progressView];
            }
            [self.progressView SendFailure];
        }
        
    }];

    [[RACSignal merge:@[[CMTUSER loginSignal] ?: [RACSignal empty],
                        [CMTUSER logoutSignal] ?: [RACSignal empty]
                        ]]
     subscribeNext:^(id x) {
         @strongify(self);
         [self CmtGetLiveData];
     }];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma 进度条代理
-(void)DeletePosting{
    self.noticeView.frame=CGRectMake(self.noticeView.left, 10, self.noticeView.width,self.noticeView.height);
    self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,40);

    self.tableViewHeadView.frame=CGRectMake(0, 0,SCREEN_WIDTH, self.noticeView.bottom+10);
    if (self.liveinfo.noticeCount.integerValue==0) {
        self.livetableView.tableHeaderView=nil;
    }else{
        self.livetableView.tableHeaderView=self.tableViewHeadView;
    }
    self.progressView=nil;
    
}
-(void)reloadCaselistData:(CMTAddPost*)newCase{
    [self.progressView SendSuccess];
    NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:newCase.liveBroadcastMessage, nil];
    [array addObjectsFromArray:[self.livedataArray copy]];
    self.livedataArray=[array mutableCopy];
    [self setCacheLiveList:[self.livedataArray copy]];
    [self.livetableView reloadData];
}
#pragma shownotice
-(void)shownoticeLable{
  if (self.liveinfo.noticeCount.integerValue>0) {
    if (self.progressView==nil) {
        self.noticeView.frame=CGRectMake(0, 10, SCREEN_WIDTH, 40);
        self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,40);
        self.tableViewHeadView.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.noticeView.bottom+10);
    }else{
        self.noticeView.frame=CGRectMake(0, self.progressView.bottom+10, SCREEN_WIDTH, 40);
        self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,40);
        self.tableViewHeadView.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.noticeView.bottom+10);
    }
   
    self.noticelalbe.text=[self.liveinfo.noticeCount stringByAppendingString:@"条新消息"];
    self.livetableView.tableHeaderView=self.tableViewHeadView;
  }else{
      if (self.progressView==nil) {
          self.noticeView.frame=CGRectMake(0, 10, SCREEN_WIDTH, 0);
          self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,0);
          self.tableViewHeadView.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.noticeView.bottom);
          self.livetableView.tableHeaderView=nil;

      }else{
          self.noticeView.frame=CGRectMake(0, self.progressView.bottom+10, SCREEN_WIDTH, 0);
          self.noticelalbe.frame=CGRectMake((SCREEN_WIDTH-120)/2, 0, 120,0);
          self.tableViewHeadView.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.noticeView.bottom);
           self.livetableView.tableHeaderView=self.tableViewHeadView;
      }
      
  }
  
    
}
#pragma 判断发帖按钮是否隐藏
-(BOOL)isHiddenpostbutton{
    BOOL ishidden=NO;
    if (self.mylive.outOfDate.boolValue) {
        ishidden=YES;
    }else if(self.mylive.participationLimit.boolValue){
        if (!CMTUSER.login) {
            ishidden=YES;
        }else if(!self.mylive.isOfficial.boolValue){
            ishidden=YES;
        }
    }
    return ishidden;
}

#pragma 筛选过滤
-(void)CmtfilteLiveData:(UIButton*)sender{
    if (sender!=nil) {
       self.isOfficial=(sender.tag==0?@"1":@"0");
    }
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"liveBroadcastId":self.liveinfo.liveBroadcastId ?: @"",
                           @"liveBroadcastUuid":self.liveUuid?:@"",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"liveBroadcastTagId":self.mylive.liveBroadcastTag.liveBroadcastTagId?:@"",
                           @"liveBroadcastTagId":@"0",
                           @"pageSize":@"10",
                           @"sortOrder":self.mylive.outOfDate?:@"",
                           @"isOfficial":self.isOfficial?:@"",
                           
                           };
    @weakify(self);
    [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
        @strongify(self);
            self.liveinfo=LiveListData.liveInfo;
            self.shareUrl=LiveListData.liveInfo.liveBroadcastShareUrl;
            self.topmessage=LiveListData.topMessage; 
            self.livedataArray=[LiveListData.liveMessageList mutableCopy];
        if ([self.livedataArray count]==0) {
            self.livetableView.placeholderView=[self tableViewPlaceholderView];
        }

            [self setCacheLiveList:[self.livedataArray copy]];
            [self.livetableView reloadData];
        if (sender.tag==0) {
            [sender setBackgroundColor:[UIColor whiteColor]];
            [sender setTitleColor:[UIColor colorWithPatternImage:self.headimageView.image] forState:UIControlStateNormal];
            sender.tag=1;
        }else{
             [sender setBackgroundColor:[UIColor clearColor]];
             [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
             sender.tag=0;
        }
        
    }error:^(NSError *error) {
        @strongify(self);
        [self setContentState:CMTContentStateReload moldel:@"1"];
        
        CMTLog(@"刷新失败");
    }];

}
 #pragma 初次加载
-(void)CmtGetLiveData{
    
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"liveBroadcastId":self.mylive.liveBroadcastId ?: @"",
                           @"liveBroadcastUuid":self.liveUuid?:@"",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"liveBroadcastTagId":self.mylive.liveBroadcastTag.liveBroadcastTagId?:@"0",
                           @"liveBroadcastTagId":@"0",
                           @"pageSize":@"10",
                           @"sortOrder":self.mylive.outOfDate?:@"",
                           @"isOfficial":self.isOfficial,
                           
                           };
    @weakify(self);
    [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
        @strongify(self);
            self.liveinfo=LiveListData.liveInfo;
         if(self.mylive==nil){
             self.mylive=[LiveListData.liveInfo copy];
        }
           //是否隐藏发帖按钮
            self.PostingButton.hidden=[self isHiddenpostbutton];
           [self shownoticeLable];
            self.shareUrl=LiveListData.liveInfo.sharePic.picFilepath;
            self.topmessage=LiveListData.topMessage;
            self.livedataArray=[LiveListData.liveMessageList mutableCopy];
            [self setCacheLiveList:[self.livedataArray copy]];
           if ([self.livedataArray count]==0) {
              self.livetableView.placeholderView=[self tableViewPlaceholderView];
            }
            [self.livetableView reloadData];
            [self setContentState:CMTContentStateNormal];
            [self stopAnimation];


    }error:^(NSError *error) {
        @strongify(self);
        [self setContentState:CMTContentStateReload moldel:@"1"];
        CMTLog(@"刷新失败");
    }];


}
#pragma 重新加载
-(void)reloaddata{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"liveBroadcastId":self.mylive.liveBroadcastId ?: @"",
                           @"liveBroadcastUuid":self.liveUuid?:@"",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"liveBroadcastTagId":self.mylive.liveBroadcastTag.liveBroadcastTagId?:@"0",
                           @"liveBroadcastTagId":@"0",
                           @"pageSize":@"10",
                           @"sortOrder":self.mylive.outOfDate?:@"",
                           @"isOfficial":self.isOfficial?:@"",
                           
                           };
    @weakify(self);
    [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
        @strongify(self);
        self.liveinfo=LiveListData.liveInfo;
        
        [self shownoticeLable];
         self.PostingButton.hidden=[self isHiddenpostbutton];
        self.shareUrl=LiveListData.liveInfo.liveBroadcastShareUrl;
        self.topmessage=LiveListData.topMessage;
        self.livedataArray=[LiveListData.liveMessageList mutableCopy];
        [self setCacheLiveList:[self.livedataArray copy]];
        if ([self.livedataArray count]==0) {
            self.livetableView.placeholderView=[self tableViewPlaceholderView];
        }

        [self.livetableView reloadData];
        [self setContentState:CMTContentStateNormal];
        [self stopAnimation];
        
        
    }error:^(NSError *error) {
        
        CMTLog(@"刷新失败");
    }];

}

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self CmtGetLiveData];
}


#pragma 下拉刷新
-(void)CmtLivePullToRefresh{
     @weakify(self);
   [self.livetableView addPullToRefreshWithActionHandler:^{
       @strongify(self);
       NSDictionary *dic=[self.liveSectionArray firstObject];
       CMTLive *live=[[CMTLive alloc]init];
       if ([(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count]>0) {
           live=[(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]firstObject];
       }
       
       NSDictionary *params=@{
                              @"userId": CMTUSERINFO.userId ?:@"0",
                              @"liveBroadcastId":self.mylive.liveBroadcastId ?: @"",
                              @"incrId":live.incrId?:@"0",
                              @"incrIdFlag":@"0",
                              @"liveBroadcastTagId":self.mylive.liveBroadcastTag.liveBroadcastTagId?:@"0",
                              @"liveBroadcastTagId":@"0",
                              @"pageSize":@"10",
                              @"sortOrder":self.mylive.outOfDate,
                              @"isOfficial":self.isOfficial,
                              
                              };
      
       [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
           @strongify(self);
           if([LiveListData.liveMessageList count]>0){
               [self shownoticeLable];
               NSMutableArray *array=[LiveListData.liveMessageList mutableCopy];
               [array addObjectsFromArray:[self.livedataArray copy]];
               self.livedataArray=array;
               [self setCacheLiveList:[self.livedataArray copy]];
               [self.livetableView reloadData];
           }else{
               self.mToastView.frame=CGRectMake(self.mToastView.left, self.headView.bottom, self.mToastView.width, self.mToastView.height);
               [self toastAnimation:@"没有最新发帖"];
           }
           [self.livetableView.pullToRefreshView stopAnimating];
           
       }error:^(NSError *error) {
           @strongify(self);
           [self.livetableView.pullToRefreshView stopAnimating];
           CMTLog(@"刷新失败");
       }];
       

   }];
   
}
#pragma 上拉翻页
-(void)CmtLiveIniteRefresh{
     @weakify(self);
       [self.livetableView addInfiniteScrollingWithActionHandler:^{
           @strongify(self);
           NSDictionary *dic=[self.liveSectionArray lastObject];
           CMTLive *live=[[CMTLive alloc]init];
           if ([(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count]>0) {
               live=[(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]lastObject];
           }
           
           NSDictionary *params=@{
                                  @"userId": CMTUSERINFO.userId ?:@"0",
                                  @"liveBroadcastId":self.mylive.liveBroadcastId ?: @"",
                                  @"incrId":live.incrId?:@"0",
                                  @"incrIdFlag":@"1",
                                  @"liveBroadcastTagId":self.mylive.liveBroadcastTag.liveBroadcastTagId?:@"0",
                                  @"liveBroadcastTagId":@"0",
                                  @"pageSize":@"10",
                                  @"sortOrder":self.mylive.outOfDate,
                                  @"isOfficial":self.isOfficial,
                                  
                                  };

      
       [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
           @strongify(self);
           if([LiveListData.liveMessageList count]>0){
               [self.livedataArray addObjectsFromArray:LiveListData.liveMessageList];
               [self setCacheLiveList:[self.livedataArray copy]];
               [self.livetableView reloadData];
           }else{
               self.mToastView.frame=CGRectMake(self.mToastView.left, self.headView.bottom, self.mToastView.width, self.mToastView.height);
               [self toastAnimation:@"没有更多发帖"];
           }
           [self.livetableView.infiniteScrollingView stopAnimating];
       }error:^(NSError *error) {
           @strongify(self);
           CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
           [self.livetableView.infiniteScrollingView stopAnimating];
           
           CMTLog(@"刷新失败");
       }];
       

   }];
   
}
// 直播列表 分组 排序 显示
- (void)setCacheLiveList:(NSArray *)cachePostList {
    @try {
        // 按incrId排序
        // 按创建时间分组
        NSMutableArray *postSections = [NSMutableArray array];
        
        int index = 0;
        for (CMTLive *live in self.livedataArray) {
            // 获取当前条目的创建时间
            NSString *createTime = DATE(live.createTime);
            if (BEMPTY(createTime)) {
                [self handleErrorMessage:@"PostList Group PostList: %@\nError: Empty CreateTime at Index: [%d]", self.livedataArray, index];
                return;
            }
            
            // 查找该创建时间的分组
            NSMutableDictionary *targetPostSection = nil;
            for (NSMutableDictionary *postSection in postSections) {
                if ([postSection[CMTPostListSectionPostDateKey] isEqual:createTime]) {
                    targetPostSection = postSection;
                    break;
                }
            }
            
            // 找到该分组
            if (targetPostSection != nil) {
                // 当前条目加入该分组
                NSMutableArray *postArray = targetPostSection[CMTPostListSectionPostArrayKey];
                [postArray addObject:live];
            }
            // 未找到该分组 则创建新分组
            else {
                NSMutableDictionary *postSection = [NSMutableDictionary dictionary];
                NSMutableArray *postArray = [NSMutableArray array];
                postSection[CMTPostListSectionPostDateKey] = createTime;
                postSection[CMTPostListSectionPostArrayKey] = postArray;
                [postArray addObject:live];
                [postSections addObject:postSection];
            }
            index++;
        }
        
        // 分组按创建时间排序
        [postSections sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *createTime1, *createTime2;
            if ([obj1 respondsToSelector:@selector(objectForKey:)]) {
                createTime1 = [obj1 objectForKey:CMTPostListSectionPostDateKey];
            }
            if ([obj2 respondsToSelector:@selector(objectForKey:)]) {
                createTime2 = [obj2 objectForKey:CMTPostListSectionPostDateKey];
            }
            
            if (createTime1 && createTime2) {
                // 创建时间大的在前
                if(!self.mylive.outOfDate.boolValue){
                   return [createTime2 compare:createTime1];
                }else{
                     return [createTime1 compare:createTime2];
                }
            }
            else {
                // 默认保持不变
                return NSOrderedAscending;
            }
        }];
        
        // 分组成功
        if ([postSections count] > 0) {
            // 刷新分组列表
            self.liveSectionArray = [NSArray arrayWithArray:postSections];
        }
        else {
            self.liveSectionArray =@[];
            [self handleErrorMessage:@"PostList Group PostList Error: Empty PostSection"];
        }
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostList Group PostList Exception: %@", exception];
    }
}

// 处理错误信息
- (void)handleErrorMessage:(NSString *)errorMessgae, ... {
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            CMTLogError(@"%@", [[NSString alloc] initWithFormat:errorMessgae arguments:args]);
            va_end(args);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Comment List HandleErrorMessage Exception: %@", exception);
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.topmessage.createUserId==nil) {
         return [self.liveSectionArray count];
    }else{
        return [self.liveSectionArray count]+1;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CMTTableSectionHeader *header = [CMTTableSectionHeader headerWithHeaderWidth:tableView.width
                                                                    headerHeight: 25.0 isneedbuttomLine:NO];
    if (self.topmessage.createUserId!=nil) {

       
        header.title = section==0?@"":[[self.liveSectionArray objectAtIndex:section-1]objectForKey:CMTPostListSectionPostDateKey];
        
       
    }else{
        header.title = [[self.liveSectionArray objectAtIndex:section]objectForKey:CMTPostListSectionPostDateKey];

    }
    return header;
   }
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.topmessage.createUserId==nil) {
         return 25.0;
    }else{
        if (section==0) {
            return 0;
        }else{
            return 25.0;
        }
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.topmessage.createUserId==nil) {
        NSDictionary *dic=[self.liveSectionArray objectAtIndex:section];
        return [(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count];

    }else{
        if (section==0) {
            return 1;
        }else{
            NSDictionary *dic=[self.liveSectionArray objectAtIndex:section-1];
            return [(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        CMTCaseListCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellLiveCellIdentifier];
        if(cell==nil){
            cell=[[CMTCaseListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
        }
    cell.liveDelegate = self;
    cell.lastController=self;
    CMTLive *live=nil;
    if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:indexPath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row];
    }else{
      live=indexPath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexPath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row] ;
    }
        cell.lastController=self;
        cell.delegate=self;
        [cell reloadLiveCell:live index:indexPath];
        return cell;

}

#pragma 点击评论
-(void)CMTClickComments:(NSIndexPath*)indexPath{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        CMTLive *live=nil;
        if (self.topmessage.createUserId==nil) {
            live=[[[self.liveSectionArray objectAtIndex:indexPath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row];
        }else{
            live=indexPath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexPath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row] ;
            
        }
        CMTLiveDetailType liveDetailType = CMTLiveDetailTypeLiveList;
        if (live.commentCount.integerValue > 0) {
            liveDetailType = CMTLiveDetailTypeLiveListSeeReply;
        }
        else {
            liveDetailType = CMTLiveDetailTypeLiveListWithReply;
        }
        live.liveBroadcastId = self.liveinfo.liveBroadcastId;
        live.outOfDate = self.liveinfo.outOfDate;
        live.liveBroadcastName = self.liveinfo.name;
        live.sharePic = self.liveinfo.sharePic;
        live.userName = self.liveinfo.userName;
        live.userPic = self.liveinfo.userPic;
        CMTLiveDetailViewController *liveDetailViewController = [[CMTLiveDetailViewController alloc] initWithLiveDetail:live
                                                                                                         liveDetailType:liveDetailType];
        @weakify(self);
        liveDetailViewController.updateLiveStatistics = ^(CMTLive *liveDetail) {
            @strongify(self);
            [self.livetableView reloadData];
        };
        liveDetailViewController.deleteLiveBroadcastMessage = ^(CMTLive *liveDetail) {
            @strongify(self);
            [self deleteLiveBroadcastMessage:liveDetail];
        };
        [self.navigationController pushViewController:liveDetailViewController animated:YES];

    }
}
#pragma 点赞
-(void)CMTSomePraise:(BOOL)ISCancelPraise index:(NSIndexPath*)indexpath{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        CMTLive *live=nil;
        if (self.topmessage.createUserId==nil) {
            live=[[[self.liveSectionArray objectAtIndex:indexpath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexpath.row];
        }else{
            live=indexpath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexpath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexpath.row] ;
        }
        if (live.isPraise.boolValue) {
            return;
        }
        @weakify(self)
        NSDictionary *params=@{
                               @"userId":CMTUSERINFO.userId ?:@"0",
                               @"liveBroadcastMessageId":live.liveBroadcastMessageId?:@"",
                               };
        
        [[[CMTCLIENT live_message_praise:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            @strongify(self)
           
                [self changepost:live];
                live.isPraise=@"1";
                live.praiseCount=[@"" stringByAppendingFormat:@"%ld", (long)(live.praiseCount.integerValue+1)];
                [self.livetableView reloadData];
            
        } error:^(NSError *error) {
            @strongify(self);
            if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                [self toastAnimation:@"服务器错误"];
            }
            
        }completed:^{
            
        }];
        
        
    }
}
#pragma 更多分享
-(void)CmtLiveMore:(NSIndexPath *)indexPath{
    self.indexpath=indexPath;
    UIActionSheet *actionSheet;
        actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享", @"删除", nil];
        actionSheet.tag = 99;
        [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];

}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
      CMTLive *live=nil;
      if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:self.indexpath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:self.indexpath.row];
      }else{
          live=self.indexpath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:self.indexpath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:self.indexpath.row] ;
      }

    if (buttonIndex==0) {
        self.liveinfo.shareModel = @"1";
        self.liveinfo.shareServiceId = live.liveBroadcastMessageId;
        self.shareCreateUserName = live.createUserName;
        self.shareContent = live.content;
        self.shareUrl = live.liveBroadcastMessageShareUrl;
        [self CMTShareAction:nil];

    }else if (buttonIndex==1){
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"确定删除该篇帖子" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    CMTLive *live=nil;
    if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:self.indexpath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:self.indexpath.row];
    }else{
        live=self.indexpath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:self.indexpath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:self.indexpath.row] ;
    }

    if (buttonIndex==1) {
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"liveBroadcastMessageId":live.liveBroadcastMessageId ?: @"",
                               
                               };
        @weakify(self);
        [[[CMTCLIENT deleteLive_message:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            @strongify(self);
            [self deleteLiveBroadcastMessage:live];
        } error:^(NSError *error) {
            CMTLog(@"删除失败");
        } completed:^{
        }];
        

    }
}

- (void)deleteLiveBroadcastMessage:(CMTLive *)live {
    if (self.topmessage.createUserId==nil) {
        [self.livedataArray removeObject:live];
        [self setCacheLiveList:[self.livedataArray copy]];
    }else{
        if (self.indexpath.section==0&&[live.createUserId isEqualToString:self.topmessage.createUserId]) {
            self.topmessage=nil;
        }else{
            [self.livedataArray removeObject:live];
            [self setCacheLiveList:[self.livedataArray copy]];
        }
    }
    [self.livetableView reloadData];
}

//改变文章对象
-(void)changepost:(CMTLive*)live{
    CMTParticiPators *part=[[CMTParticiPators alloc]init];
        part.userId=CMTUSER.userInfo.userId;
        part.nickname=self.liveinfo.userName;
        part.picture=self.liveinfo.userPic;
        part.opTime=TIMESTAMP;

  
       NSMutableArray *mutable=[[NSMutableArray alloc]initWithObjects:part, nil];
    NSMutableArray *muale2=[[NSMutableArray alloc ]initWithArray:live.praiseUserList];
    NSMutableArray *partArray=[live.praiseUserList mutableCopy];
    for (int i=0;i<[partArray count];i++) {
        CMTParticiPators *CMTpart=[partArray objectAtIndex:i];
        if ([CMTpart.userId isEqualToString:part.userId]&&CMTpart.userType.integerValue==0) {
            [muale2 removeObject:CMTpart];
        }
    }
    [mutable addObjectsFromArray:muale2];
    live.praiseUserList=mutable;
}


#pragma 分享
-(void)CMTClickShare:(NSIndexPath *)indexPath{
    CMTLive *live=nil;
    if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:indexPath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row];
    }else{
        live=indexPath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexPath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row] ;
    }
    self.liveinfo.shareModel = @"1";
    self.liveinfo.shareServiceId = live.liveBroadcastMessageId;
    self.shareCreateUserName = live.createUserName;
    self.shareContent = live.content;
    self.shareUrl = live.liveBroadcastMessageShareUrl;
    [self CMTShareAction:nil];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CMTLive *live=nil;
    if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:indexPath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row];
    }else{
        live=indexPath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexPath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row] ;
    }
    
    live.liveBroadcastId = self.liveinfo.liveBroadcastId;
    live.outOfDate = self.liveinfo.outOfDate;
    live.liveBroadcastName = self.liveinfo.name;
    live.sharePic = self.liveinfo.sharePic;
    live.userName = self.liveinfo.userName;
    live.userPic = self.liveinfo.userPic;
    CMTLiveDetailViewController *liveDetailViewController = [[CMTLiveDetailViewController alloc] initWithLiveDetail:live
                                                                                                     liveDetailType:CMTLiveDetailTypeLiveList];
    @weakify(self);
    liveDetailViewController.updateLiveStatistics = ^(CMTLive *liveDetail) {
        @strongify(self);
        [self.livetableView reloadData];
    };
    liveDetailViewController.deleteLiveBroadcastMessage = ^(CMTLive *liveDetail) {
        @strongify(self);
        [self deleteLiveBroadcastMessage:liveDetail];
    };
    [self.navigationController pushViewController:liveDetailViewController animated:YES];
}
// 分享处理方法 add byguoyuanchao
- (void)CMTShareAction:(UIButton*)sender{
    if (sender!=nil) {
        self.liveinfo.shareModel = @"1";
        self.liveinfo.shareServiceId =self.liveinfo.liveBroadcastId;
        self.shareUrl = self.liveinfo.liveBroadcastShareUrl;;
    }
    [self.mShareView.mBtnFriend addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.cancelBtn addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    // 自定义分享
    [self shareViewshow:self.mShareView bgView:self.tempView currentViewController:self.navigationController];
}

- (void)showShare:(UIButton *)btn
{
    [self methodShare:btn];
}

///平台按钮关联的分享方法
- (void)methodShare:(UIButton *)btn {
      // 没有网络连接
    if (!NET_WIFI && !NET_CELL && btn.tag != 5555) {
        [self toastAnimation:@"你的网络不给力"];
        [self shareViewDisapper];
        return;
    }
    switch (btn.tag)
    {
        case 1111:
        {
            if ([self respondsToSelector:@selector(friendCircleShare)]) {
                [self performSelector:@selector(friendCircleShare) withObject:nil afterDelay:0.20];
            }
            
        }
            break;
        case 2222:
        {
            if ([self respondsToSelector:@selector(weixinShare)]) {
                [self performSelector:@selector(weixinShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 3333:
        {
            if ([self respondsToSelector:@selector(weiboShare)]) {
                [self performSelector:@selector(weiboShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 4444:
        {
            CMTLog(@"邮件");
            NSString *shareType = @"4";
            NSString *shareText = self.liveinfo.shareDesc;
            if ([self.liveinfo.shareModel isEqual:@"1"]) {
                NSInteger toIndex = self.shareContent.length;
                NSString *pointString = @"";
                if (toIndex > 15) {
                    toIndex = 15;
                    pointString = @"...";
                }
                shareText = [NSString stringWithFormat:@"%@在现场说了什么？<br>%@%@",
                             self.shareCreateUserName ?: @"",
                             [self.shareContent substringToIndex:toIndex] ?: @"",
                             pointString];
            }
            NSString *pContent = [NSString stringWithFormat:@"#壹生# %@<br>%@<br>来自@壹生<br>", shareText, self.shareUrl];
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:self.liveinfo.name sharetext:pContent sharetype:shareType sharepic:self.liveinfo.sharePic.picFilepath shareUrl:self.shareUrl StatisticalType:@"getShareLive" shareData:self.liveinfo];
          }
            break;
            case 5555:
            [self shareViewDisapper];
            break;
        default:
            CMTLog(@"其他分享");
            break;
    }
    if ([self respondsToSelector:@selector(removeTargets)]) {
        [self performSelector:@selector(removeTargets) withObject:nil afterDelay:0.2];
    }
    
    [self shareViewDisapper];
}
- (void)removeTargets
{
    [self.mShareView.mBtnFriend removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
}
/// 朋友圈分享
- (void)friendCircleShare
{
    NSString *shareType = @"1";
    CMTLog(@"朋友圈");
    NSString *shareText = self.liveinfo.shareDesc;
    if ([self.liveinfo.shareModel isEqual:@"1"]) {
        shareText = [NSString stringWithFormat:@"%@在现场说了什么？", self.shareCreateUserName ?: @""];
    }
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.liveinfo.sharePic.picFilepath shareUrl:self.shareUrl StatisticalType:@"getShareLive" shareData:self.liveinfo];
    
}
/// 微信好友分享
- (void)weixinShare
{
    NSString *shareType = @"2";
    NSString *shareTitle = self.liveinfo.name;
    NSString *shareText = self.liveinfo.shareDesc;
    if ([self.liveinfo.shareModel isEqual:@"1"]) {
        NSInteger toIndex = self.shareContent.length;
        NSString *pointString = @"";
        if (toIndex > 15) {
            toIndex = 15;
            pointString = @"...";
        }
        shareTitle = [NSString stringWithFormat:@"%@在现场说了什么？", self.shareCreateUserName ?: @""];
        shareText = [NSString stringWithFormat:@"%@%@", [self.shareContent substringToIndex:toIndex] ?: @"", pointString];
    }
    NSString *shareURL = self.shareUrl;
    if (BEMPTY(shareText)) {
        //        shareText = self.viewModel.postDetail.title;
        shareText =@"壹生文章分享";
    }
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.liveinfo.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"getShareLive" shareData:self.liveinfo];
}

- (void)weiboShare
{
    NSString *shareType = @"3";
    NSString *shareTitle = self.liveinfo.name;
    NSString *shareText = self.liveinfo.shareDesc;
    NSString *pContent = [NSString stringWithFormat:@"#%@# 《%@》%@ %@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY, shareTitle, shareText, self.shareUrl];
    if ([self.liveinfo.shareModel isEqual:@"1"]) {
        NSInteger toIndex = self.shareContent.length;
        NSString *pointString = @"";
        if (toIndex > 15) {
            toIndex = 15;
            pointString = @"...";
        }
        shareTitle = [NSString stringWithFormat:@"%@在现场说了什么？", self.shareCreateUserName ?: @""];
        shareText = [NSString stringWithFormat:@"%@%@", [self.shareContent substringToIndex:toIndex] ?: @"", pointString];
        pContent = [NSString stringWithFormat:@"#%@# %@%@ %@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY, shareTitle, shareText, self.shareUrl];
    }
    CMTLog(@"新浪文博\nshareText:%@", shareText);
   [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:pContent sharetext:pContent sharetype:shareType sharepic:self.liveinfo.sharePic.picFilepath shareUrl:self.shareUrl StatisticalType:@"getShareLive" shareData:self.liveinfo];
}
//跳转标签
-(void)CMTGoLiveTagList : (CMTLiveTag*)LiveTag {
    
    CMTLiveTagFilterViewController *liveTagFilterViewController = [[CMTLiveTagFilterViewController alloc] initWithlive:self.mylive liveBroadcastTagId:LiveTag.liveBroadcastTagId liveBroadcastTagName:LiveTag.name];
    [self.navigationController pushViewController:liveTagFilterViewController animated:YES];
}
@end
