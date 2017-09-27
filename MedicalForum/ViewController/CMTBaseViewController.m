//
//  CMTBaseViewController.m
//  MedicalForum
//
//  Created by fenglei on 14/12/1.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

// controller
#import "CMTBaseViewController.h"           // header file
#import "SDWebImageManager.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CMTExtension_URLString.h"
#import "CMTSeriesDetailsViewController.h"
#import "CmtMoreVideoViewController.h"
const CGFloat CMTNavigationBarBottomGuide = 64.0;
const CGFloat CMTTabBarHeight = 49.0;

@interface CMTBaseViewController ()

// view
@property (nonatomic, strong) UILabel *titleLabel;

// data
@property (strong, nonatomic) NSMutableArray *mArrImages;

@end

@implementation CMTBaseViewController

#pragma mark Initializers

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = COLOR(c_clear);
        _titleLabel.textColor = COLOR(c_151515);
        _titleLabel.font = FONT(18.5);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)tabBarContainer {
    if (_tabBarContainer == nil) {
        _tabBarContainer = [[UIView alloc] init];
        [_tabBarContainer builtinContainer:self.view WithLeft:0.0 Top:self.view.height - CMTTabBarHeight Width:self.view.width Height:CMTTabBarHeight];
        [_tabBarContainer setBackgroundColor:COLOR(c_clear)];
        [_tabBarContainer setHidden:YES];
    }
    
    return _tabBarContainer;
}
-(UIView*)MaskTheview{
    if(_MaskTheview==nil){
        _MaskTheview=[[UIView alloc]initWithFrame:self.view.frame];
        _MaskTheview.hidden=YES;
        [self.view addSubview:_MaskTheview];
        
    }
    return _MaskTheview;
}
- (void)setContentState:(CMTContentState)contentState{
    if (_contentState == contentState) {
        return;
    }
    _contentState = contentState;
    self.contentBaseView.hidden = _contentState != CMTContentStateNormal;
    self.MaskTheview.hidden=YES;
    self.mAnimationImageView.hidden = _contentState != CMTContentStateLoading;
    self.mReloadBaseView.hidden = _contentState != CMTContentStateReload;
    self.contentEmptyView.hidden = _contentState != CMTContentStateEmpty;
    
    // 处理Loading
    if (_contentState == CMTContentStateLoading) {
        [self runAnimationInPosition:self.contentBaseView.center];
    } else {
        [self stopAnimation];
    }
}
- (void)setContentState:(CMTContentState)contentState moldel:(NSString*)model {
    if (_contentState == contentState) {
        return;
    }
    _contentState = contentState;
    if ([model isEqual:@"1"]) {
        self.contentBaseView.hidden =NO;
        [self.view bringSubviewToFront:self.mReloadBaseView];
    }else{
        self.contentBaseView.hidden = _contentState != CMTContentStateNormal;
    }
    self.MaskTheview.hidden=YES;
    self.mAnimationImageView.hidden = _contentState != CMTContentStateLoading;
    self.mReloadBaseView.hidden = _contentState != CMTContentStateReload;
    self.contentEmptyView.hidden = _contentState != CMTContentStateEmpty;
    
    // 处理Loading
    if (_contentState == CMTContentStateLoading) {
        [self runAnimationInPosition:self.contentBaseView.center];
    } else {
        [self stopAnimation];
    }
}
- (void)setContentState:(CMTContentState)contentState moldel:(NSString*)model height:(float)height {
    if (_contentState == contentState) {
        return;
    }
    _contentState = contentState;
    if ([model isEqual:@"1"]) {
        self.contentBaseView.hidden =NO;
        self.MaskTheview.hidden=_contentState != CMTContentStateLoading;
        self.MaskTheview.top=height;
        [self.view bringSubviewToFront:self.mReloadBaseView];
        [self.view bringSubviewToFront:self.MaskTheview];
    }else{
        self.contentBaseView.hidden = _contentState != CMTContentStateNormal;
    }
    
    self.mAnimationImageView.hidden = _contentState != CMTContentStateLoading;
    self.mReloadBaseView.hidden = _contentState != CMTContentStateReload;
    self.contentEmptyView.hidden = _contentState != CMTContentStateEmpty;
    
    // 处理Loading
    if (_contentState == CMTContentStateLoading) {
        [self runAnimationInPosition:self.contentBaseView.center];
    } else {
        [self stopAnimation];
    }
}


- (UIView *)contentBaseView {
    if (_contentBaseView == nil) {
        _contentBaseView = [[UIView alloc] init];
        [_contentBaseView fillinContainer:self.view WithTop:0 Left:0 Bottom:0 Right:0];
        [_contentBaseView setBackgroundColor:COLOR(c_clear)];
    }
    
    return _contentBaseView;
}

- (CMTContentEmptyView *)contentEmptyView {
    if (_contentEmptyView == nil) {
        _contentEmptyView = [[CMTContentEmptyView alloc] init];
        [_contentEmptyView fillinContainer:self.view WithTop:CMTNavigationBarBottomGuide Left:0 Bottom:0 Right:0];
        [_contentEmptyView setBackgroundColor:COLOR(c_clear)];
        [_contentEmptyView setHidden:YES];
    }
    
    return _contentEmptyView;
}

- (NSMutableArray *)mArrImages
{
    if (!_mArrImages)
    {
        _mArrImages = [NSMutableArray array];
        for (int i = 0 ; i < 10; i++)
        {
            NSString *imageName = [NSString stringWithFormat:@"PR_4_0000%d",i];
            UIImage *pImage = [UIImage imageNamed:imageName];
            [self.mArrImages addObject:pImage];
        }
        for (int i = 10; i < 39; i++)
        {
            NSString *imageName = [NSString stringWithFormat:@"PR_4_000%d",i];
            UIImage *pImage = [UIImage imageNamed:imageName];
            [self.mArrImages addObject:pImage];
        }
    }
    return _mArrImages;
}

- (UIImageView *)mAnimationImageView
{
    if (!_mAnimationImageView)
    {
        _mAnimationImageView = [[UIImageView alloc]initWithImage:IMAGE(@"PR_4_00000")];
        //
        _mAnimationImageView.frame = CGRectMake(0, 0, 64, 64);
        _mAnimationImageView.animationImages = self.mArrImages;
        _mAnimationImageView.animationDuration = 1.5f;
        _mAnimationImageView.animationRepeatCount = 0;
    }
    return _mAnimationImageView;
}
- (UIView *)mReloadBaseView
{
    if (!_mReloadBaseView)
    {
        _mReloadBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        _mReloadBaseView.backgroundColor = COLOR(c_f5f5f5);
        [_mReloadBaseView addSubview:self.mReloadImgView];
        self.mReloadImgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3);
        self.mLbupload.centerX = self.view.centerX;
        self.mLbupload.centerY = self.mReloadImgView.centerY + self.mReloadImgView.frame.size.height/2+13+self.mLbupload.frame.size.height/2;
        [_mReloadBaseView addSubview:self.mLbupload];
    }
    return _mReloadBaseView;
}

- (UIImageView *)mReloadImgView
{
    if (!_mReloadImgView)
    {
        _mReloadImgView = [[UIImageView alloc]initWithImage:IMAGE(@"touch")];
    }
    return _mReloadImgView;
}
- (UILabel *)mLbupload
{
    if (!_mLbupload)
    {
        _mLbupload = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
        _mLbupload.textAlignment = NSTextAlignmentCenter;
        _mLbupload.adjustsFontSizeToFitWidth = YES;
        _mLbupload.textColor = COLOR(c_ababab);
        _mLbupload.text = @"轻触屏幕, 重新加载";
        _mLbupload.font = [UIFont systemFontOfSize:15.0];
    }
    return _mLbupload;
}

- (CMTToastView *)mToastView
{
    if (!_mToastView)
    {
        _mToastView = [[CMTToastView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 30)];
    }
    return _mToastView;
}
- (CMTIntegralToastView *)mintegralToastView
{
    if (!_mintegralToastView)
    {
        _mintegralToastView = [[CMTIntegralToastView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    }
    return _mintegralToastView;
}


- (CMTToastView *)offlineToast {
    if (_offlineToast == nil) {
        _offlineToast = [[CMTToastView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 30)];
        _offlineToast.backgroundColor = COLOR(c_f07e7e);
        _offlineToast.mLbContent.text = @"无法连接到网络, 请检查网络设置";
        _offlineToast.netImageView.hidden = NO;
    }
    
    return _offlineToast;
}

///分享视图
- (CMTShareView *)mShareView
{
    if (!_mShareView){
//        _mShareView = [CMTShareView shareView:CGRectMake(20, 100, SCREEN_WIDTH-40, 100)];
        _mShareView = [[CMTShareView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 712/3)];
        _mShareView.layer.cornerRadius = 0;
        _mShareView.layer.masksToBounds = YES;
        _mShareView.lbFriend.text = @"朋友圈";
        _mShareView.lbMail.text = @"邮件";
        _mShareView.lbSina.text = @"新浪微博";
        _mShareView.lbWeix.text = @"微信好友";
    }
    
    return _mShareView;
}

- (UIView *)tempView
{
    if (!_tempView)
    {
        _tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 800)];
        _tempView.userInteractionEnabled = YES;
        [_tempView addGestureRecognizer:self.tapGesture];
    }
    return _tempView;
}
- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture)
    {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareViewDisapper)];
    }
    return _tapGesture;
}
// leftItems
- (UIBarButtonItem *)leftItem {
    if (_leftItem == nil) {
        _leftItem = [[UIBarButtonItem alloc]initWithImage:IMAGE(@"naviBar_back") style:UIBarButtonItemStyleDone target:self action:@selector(popViewController)];
        [_leftItem setBackgroundVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsDefault];
    }
    return _leftItem;
}
// leftItems
- (NSArray *)customleftItems {
    if (_customleftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -8.0;
        _customleftItems = @[leftFixedSpace, self.leftItem];
    }
    
    return _customleftItems;
}

- (void)popViewController {
    CMTLog(@"%s", __FUNCTION__);
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark   shareView  show  disappear
///自定义分享视图，动画弹出
- (void)shareViewshow:(CMTShareView *)shareView bgView:(UIView *)bgView
{
    [APPDELEGATE.window.rootViewController.view  addSubview:bgView];
    bgView.alpha = 0.5;
    [APPDELEGATE.window.rootViewController.view  addSubview:shareView];
    shareView.alpha = 1.0;
    //shareView.transform = CGAffineTransformMakeScale(0, 0);
    shareView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 712/3);
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.20];
    //shareView.transform = CGAffineTransformMakeScale(1, 1);
    shareView.frame = CGRectMake(0, SCREEN_HEIGHT - 712/3, SCREEN_WIDTH, 712/3);
    [UIView commitAnimations];
    [UIView animateWithDuration:1.0 animations:^{
        self.tempView.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:135.0/255.0 blue:135.0/255.0 alpha:1.0];
    }];
}

///自定义分享视图，动画弹出 传入当前的控制器
- (void)shareViewshow:(CMTShareView *)shareView bgView:(UIView *)bgView currentViewController:(UIViewController*)controller{
    [controller.view  addSubview:bgView];
     bgView.alpha = 0.5;
    [controller.view  addSubview:shareView];
    shareView.alpha = 1.0;
    //shareView.transform = CGAffineTransformMakeScale(0, 0);
     shareView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 712/3);
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.20];
    //shareView.transform = CGAffineTransformMakeScale(1, 1);
    shareView.frame = CGRectMake(0, SCREEN_HEIGHT - 712/3, SCREEN_WIDTH, 712/3);
    [UIView commitAnimations];
    [UIView animateWithDuration:1.0 animations:^{
        self.tempView.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:135.0/255.0 blue:135.0/255.0 alpha:1.0];
    }];
}


///自定义分享视图,动画弹回
- (void)shareViewDisapper
{
    CMTLog(@"%s",__func__);
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.mShareView.transform = CGAffineTransformMakeScale(1, 1);
        self.tempView.alpha = 0.5;
        self.mShareView.alpha = 1.0;
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.2];
//        self.mShareView.transform = CGAffineTransformMakeScale(0.001, 0.001);
//        self.view.backgroundColor = [UIColor whiteColor];
        self.tempView.alpha = 0.0;
        self.mShareView.alpha = 0.0;
        if ([self.mShareView respondsToSelector:@selector(removeFromSuperview)])
        {
            [self.mShareView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
        }
        [UIView commitAnimations];
        
        if ([self.tempView respondsToSelector:@selector(removeFromSuperview)])
        {
            [self.tempView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
        }
    });
}




- (void)runAnimationInPosition:(CGPoint)point
{
    [self.view addSubview:self.mAnimationImageView];
    self.mAnimationImageView.center = point;
    [self.mAnimationImageView startAnimating];
}
- (void)stopAnimation
{
    [self.mAnimationImageView stopAnimating];
    [self.mAnimationImageView resignFirstResponder];
    if (self.mAnimationImageView) {
        [self.mAnimationImageView removeFromSuperview];
    }
}

#pragma mark LifeCycle

- (void)loadView {
    [super loadView];
    
    if (self.contentBaseView.height == 0.0) {
        self.contentBaseView.frame = self.view.bounds;
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self shareViewDisapper];
    [MobClick endLogPageView:[NSString
                              stringWithUTF8String:object_getClassName([self class])]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    [[AVAudioSession sharedInstance] setActive:NO error:nil];

#pragma mark 背景色 backgroundColor
    self.view.backgroundColor = COLOR(c_ffffff);

#pragma mark scrollViewInsets
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
#pragma mark 导航栏标题
    
    self.title = @"";
    [RACObserve(self, titleText) subscribeNext:^(NSString *titleText) {
        @strongify(self);
        CGSize titleSize = [titleText boundingRectWithSize:CGSizeMake(self.view.width, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                attributes:@{NSFontAttributeName:self.titleLabel.font}
                                                   context:nil].size;
        self.titleLabel.text = titleText;
        self.titleLabel.bounds = CGRectMake(0.0, 0.0, ceil(titleSize.width), ceil(titleSize.height));
        self.navigationItem.titleView = self.titleLabel;
    }];
    
#pragma mark 页面内容
    
    [self.view bringSubviewToFront:self.contentBaseView];
    
#pragma mark 空内容提示 (默认隐藏)
    
    [self.view insertSubview:self.contentEmptyView belowSubview:self.contentBaseView];
    
#pragma mark 点击加载
    
    [self.view addSubview:self.mReloadBaseView];
    [self.view insertSubview:self.mReloadBaseView belowSubview:self.contentBaseView];
    UITapGestureRecognizer *pTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(animationFlash)];
    [self.mReloadBaseView addGestureRecognizer:pTapGesture];
    self.mReloadBaseView.hidden = YES;
    
#pragma mark 底部导航栏视图层 (默认隐藏)
    
    [self.view insertSubview:self.tabBarContainer aboveSubview:self.contentBaseView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#pragma mark 显示导航栏
      if(self.navigationController.navigationBarHidden){
          [self.navigationController setNavigationBarHidden:NO animated:animated];
      }else{
          self.navigationController.navigationBarHidden=NO;
      }
    [MobClick beginLogPageView:[NSString
                              stringWithUTF8String:object_getClassName([self class])]];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

  }

- (void)toastAnimation:(NSString *)prompt
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mToastView.mLbContent.text = prompt;
        [self.view addSubview:self.mToastView];
        [self hidden:self.mToastView];
    });

}
- (void)toastAnimation:(NSString *)prompt top:(float)top
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mToastView.top=top;
        self.mToastView.mLbContent.text = prompt;
        [self.view addSubview:self.mToastView];
        [self hidden:self.mToastView];
    });
    
}

- (void)toastIntegralAnimation:(NSString *)prompt title:(NSString*)title;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mintegralToastView.Content.text = prompt;
        self.mintegralToastView.titlelable.text = title;
        self.mintegralToastView.center=self.view.center;
        [self.view addSubview:self.mintegralToastView];
        [self hiddenIntegral:self.mintegralToastView];
    });
    
}

- (void)hiddenIntegral:(CMTIntegralToastView *)view
{
    view.alpha = 1.0;
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:2.0];
    view.alpha = 0.0;
    [UIView commitAnimations];
    
}

- (void)hidden:(CMTToastView *)view
{
    view.alpha = 1.0;
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:2.0];
    view.alpha = 0.0;
    [UIView commitAnimations];
    
}

- (void)animationFlash
{
    [UIView beginAnimations:@"flash" context:nil];
    self.mReloadImgView.alpha = 0.0;
    self.mLbupload.alpha = 0.0;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    self.mReloadImgView.alpha = 1.0;
    self.mLbupload.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *@brief 字符串上色
 *@param str: 需要修改颜色的字符串
 *@param color: 修改颜色
 */
- (NSString *)string:(NSString *)str WithColor:(UIColor *)color
{
    NSMutableAttributedString *pAttStr = [[NSMutableAttributedString alloc]initWithString:str];
    [pAttStr addAttribute:NSForegroundColorAttributeName value:color range:NSRangeFromString(str)];
    return [pAttStr string];
}
//获取网络状态
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
//查找并替换字符串
-(NSString*)findAndreplacestring:(NSString*)str formatten:(NSString*)regulaStr {
    NSMutableString *tempString = [NSMutableString stringWithString:[str copy]];
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:tempString options:0 range:NSMakeRange(0, [tempString length])];
    
    NSString *substringForMatch = [NSString string];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        substringForMatch = [tempString substringWithRange:match.range];
        NSLog(@"substringForMatch: %@",substringForMatch);
        str=[str stringByReplacingOccurrencesOfString:substringForMatch withString:@"\n"];
    }
    return str;
}
//列表为空提示
- (UIView *)tableViewPlaceholderView:(UITableView*)tableView text:(NSString*)text {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,tableView.width, 100.0)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, placeholderView.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(15.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text =text;
    
    [placeholderView addSubview:placeholderLabel];
    
    
    return placeholderView;
}
#pragma mark 统计观看人数
-(void)StatisticsThenumber:(CMTLivesRecord*)myliveParam{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"0",
                            @"classRoomId":myliveParam.classRoomId?:@"",
                            @"classRoomType":myliveParam.classRoomType?:@"",
                            @"coursewareId":myliveParam.coursewareId?:@"",
                            
                            };
    @weakify(self);
    [[[CMTCLIENT getJoinroomNumber:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *param){
        NSLog(@"统计成功");
    } error:^(NSError *error) {
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力"];
            [self setContentState:CMTContentStateReload moldel:@"1"];
        }else{
           [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }

    } completed:^{
        
    } ];
    
}
//删除学习记录
-(void)DeleteLearningRecord:(NSDictionary*)param sucess:(void (^)(CMTObject *))sucessback error:(void (^)(NSError *))errorback{
    [[[CMTCLIENT CMTDeleteTheLearningRecord:param]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTObject*x) {
        if(sucessback!=nil){
            sucessback(x);
        }
    } error:^(NSError *error) {
        if(errorback!=nil){
            errorback(error);
        }
     
    }];
    
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


// If the user pulls out he headphone jack, stop playing.
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            NSLog(@"Headphone/Line plugged in");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            NSLog(@"Headphone/Line was pulled. Stopping player....");
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
            
            [audioSession setActive:YES error:nil];
            
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
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

#pragma mark 处理应用内点播webView链接
-(BOOL)handleWithinLightVedio:(NSString*)urlString URLScheme:(NSString *)URLScheme viewController:(CMTBaseViewController*)Controller{
    if ([urlString hasPrefix:@"about"]||[urlString hasPrefix:@"chrome"]) {
        return YES;
    }else if ([URLScheme rangeOfString:CMTNSStringHTMLTagScheme_CMTOPDR
                              options:NSCaseInsensitiveSearch].length > 0) {
        NSDictionary *parseDictionary = urlString.CMT_HTMLTag_parseDictionary;
        NSDictionary *parameters = parseDictionary[CMTNSStringHTMLTagParseKey_parameters];
        NSString *action = parameters[CMTNSStringHTMLTagParameterKey_action];
        if ([action isEqualToString:@"theme"]) {
            CMTSeriesDetails *sDetail=[[CMTSeriesDetails alloc]init];
            sDetail.themeUuid=[parameters[@"themeuuid"] URLDecodeString];
            sDetail.seriesName=[parameters[@"themeName"] URLDecodeString];
            CMTSeriesDetailsViewController *sd=[[CMTSeriesDetailsViewController alloc]initWithParam:sDetail];
            Controller.nextVC = @"CMTSeriesDetailsViewController";
            [Controller.navigationController pushViewController:sd animated:YES];
        }else if([action isEqualToString:@"college"]){
            CMTCollegeDetail *college=[[CMTCollegeDetail alloc]init];
            college.collegeId=[parameters[@"collegeId"] URLDecodeString];
            college.collegeName=[parameters[@"collegeName"] URLDecodeString];
            CmtMoreVideoViewController *more=[[CmtMoreVideoViewController alloc]initWithCollege:college type:CMTCollCollegeVideo];
            Controller.nextVC = @"CmtMoreVideoViewController";
            [Controller.navigationController pushViewController:more animated:YES];
        }else{
            CMTLog(@"HTMLTag: %@\nparseDictionary: %@", urlString, parameters);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请升级新版本"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
            [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                // 确定 跳转App Store
                if ([index integerValue] == 1) {
                    [[UIApplication sharedApplication] openURL:
                     [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/yi-sheng/id548271766?l=zh&ls=1&mt=8"]];
                }
            }];
            [alert show];
            
        }
        
        return NO;
        
    }
    return YES;
}

@end
