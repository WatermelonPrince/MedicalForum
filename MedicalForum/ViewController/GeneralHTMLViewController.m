//
//  GeneralHTMLViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 2017/4/13.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "GeneralHTMLViewController.h"
#import "NJKWebViewProgress.h"                      // 加载进度
#import "NJKWebViewProgressView.h"                  // 加载进度条

@interface GeneralHTMLViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)NSString *url;
@property (nonatomic, strong) NJKWebViewProgress *webViewProgress;              // 加载进度
@property (nonatomic, strong) NJKWebViewProgressView *webViewProgressView;      // 加载进度条
@property (nonatomic, strong) NSTimer *webViewProgressTimer;                    // 加载进度条计时器
@end

@implementation GeneralHTMLViewController
-(UIWebView*)webView{
    if(_webView==nil){
        _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _webView.allowsInlineMediaPlayback=YES;
        _webView.backgroundColor = COLOR(c_fafafa);
        _webView.scrollView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _webView.scalesPageToFit = YES;
        _webView.opaque = NO;
        _webView.delegate = self.webViewProgress;
        _webView.allowsInlineMediaPlayback = YES;
    }
    return _webView;
}
- (NJKWebViewProgress *)webViewProgress {
    if (_webViewProgress == nil) {
        _webViewProgress = [[NJKWebViewProgress alloc] init];
        _webViewProgress.webViewProxyDelegate = self;
        @weakify(self);
        _webViewProgress.progressBlock = ^(float progress) {
            @strongify(self);
            if (progress == NJKInitialProgressValue) {
                if ([self.webViewProgressTimer isValid]) {
                    [self.webViewProgressTimer invalidate];
                }
                self.webViewProgressTimer = [NSTimer timerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.webViewProgressTimer forMode:NSRunLoopCommonModes];
            }
            else {
                if (progress == NJKInteractiveProgressValue) {
                    [self.webViewProgressView setProgress:0.85 animated:YES];
                }
                else if (progress == NJKFinalProgressValue) {
                    [self.webViewProgressView setProgress:0.9 animated:YES];
                }
                else {
                    [self.webViewProgressView setProgress:progress animated:YES];
                }
            }
        };
    }
    
    return _webViewProgress;
}

- (NJKWebViewProgressView *)webViewProgressView {
    if (_webViewProgressView == nil) {
        _webViewProgressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, self.view.width, 2.5)];
        _webViewProgressView.progressBarView.backgroundColor = COLOR(c_32c7c2);
    }
    
    return _webViewProgressView;
}
- (void)timerCallback {
    CGFloat progress =  self.webViewProgressView.progressBarView.width / self.webViewProgressView.width;
    if (progress < 0.85) {
        if (progress > 0.65) {
            progress += 0.0003;
        }
        else if (progress > 0.25) {
            progress += 0.0009;
        }
        else {
            progress += 0.0025;
        }
        CGRect frame = self.webViewProgressView.progressBarView.frame;
        frame.size.width = progress * self.webViewProgressView.width;
        self.webViewProgressView.progressBarView.frame = frame;
    }
    else {
        [self.webViewProgressTimer invalidate];
    }
}
#pragma mark - WebView

// 增加动态模板控制页面字体,答题模式的属性
- (NSString*)getExpose_param_String {
    NSString *paramString=[@"{\"is_night_mode\":" stringByAppendingFormat:@"\"%@\"",@"true"];
    paramString=[paramString stringByAppendingFormat:@",\"font-size\":\"%@\"",CMTAPPCONFIG.customFontSize];
    paramString=[paramString stringByAppendingFormat:@",\"scr-size\":\"%ld_%ld\"}",(long)SCREEN_WIDTH,(long)SCREEN_HEIGHT];
    
    return paramString;
}

// 加载动态模板url add by guoyuanchao
- (void)CMT_ISHTML_LoadWebview:(NSString*)url {
    
    // 动态文章详情
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[[NSURL alloc]initWithString:url]];
    
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
    
    [request setValue:[self getExpose_param_String]forHTTPHeaderField:@"expose-param"];
    CMTLog(@"head头%@",request.allHTTPHeaderFields);
    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}
-(instancetype)initWithName:(NSString *)name url:(NSString*)url{
    self=[super init];
    if(self){
        self.titleText=name;
        self.url=url;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentBaseView addSubview:self.webView];
    [self CMT_ISHTML_LoadWebview:self.url];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if( self.webViewProgressTimer != nil) {
        [self.webViewProgressTimer setFireDate:[NSDate distantPast]];
    }
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
