//
//  CMTWebBrowserViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/2/4.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// controller
#import "CMTWebBrowserViewController.h"             // header file
#import "CMTBindingViewController.h"                // 登录页
#import "CMTUpgradeViewController.h"                // 申请认证页
#import "CMTOtherPostListViewController.h"          // 其他文章列表
#import "MWPhotoBrowser.h"                          // 图片浏览器
#import "CMTPDFBrowserViewController.h"             // PDF浏览器
#import "CMTPostDetailViewController.h"             //文章详情
#import "SDWebImageManager.h"

// view
#import "NJKWebViewProgress.h"                      // 加载进度
#import "NJKWebViewProgressView.h"                  // 加载进度条
#import "CMTGroupInfoViewController.h"
#import "CMTLiveDetailViewController.h"
#import "CMTLiveViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface CMTWebBrowserViewController () <UIWebViewDelegate, MWPhotoBrowserDelegate, UIActionSheetDelegate>

// view
@property (nonatomic, strong) UIWebView *webView;                               // 网页内容
@property (nonatomic, strong) NJKWebViewProgress *webViewProgress;              // 加载进度
@property (nonatomic, strong) NJKWebViewProgressView *webViewProgressView;      // 加载进度条
@property (nonatomic, strong) UIView *backGroundLayer;                          //购买数字报alertView的背景图层
@property (nonatomic, strong) UIAlertView *orderAlertView;                       //购买数字报alert提示

// data
@property (nonatomic, strong) NSTimer *webViewProgressTimer;                    // 加载进度条计时器
@property (nonatomic, strong) NSArray *photoBrowserPhotos;                      // 图片对象数组

@property (nonatomic, assign) BOOL isrefreshWebView;                            // 是否刷新webView

@property (nonatomic, strong) NSString *urlString;                              // webViewUrl路径
@property (nonatomic, assign) NSInteger webViewLoadNumbers;                     // webViewurl为http开头的加载的次数;

@property (strong, nonatomic) NSString *shareTitle;                             // 分享title
@property (strong, nonatomic) NSString *shareBrief;                             // 分享brief
@property (strong, nonatomic) NSString *shareUrl;                               // 分享url
@property (strong, nonatomic) NSString *sharePic;                              //分享UIImage

@property (strong, nonatomic) NSString *postID;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;                          // 取消按钮
@property(nonatomic,strong)NSArray *rightItems;//右侧按钮数组
@property(nonatomic,strong)UIBarButtonItem *MoreItem;
//活动分享
@property(nonatomic, strong)CMTActivities *activities;
@property(nonatomic,strong)NSMutableArray *requestArray;//记录加载了多少url
@property(nonatomic,strong)NSURLRequest *lastRequest;//记录上一次加载的url
@property(nonatomic,strong)UIBarButtonItem *leftButtonItem;
@property (nonatomic, strong) NSArray *leftItems;
@property(nonatomic,assign)BOOL ishaveAbout;
@end

@implementation CMTWebBrowserViewController

#pragma mark - Initializers

- (instancetype)initWithURL:(NSString *)URL {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.urlString = URL;
    self.webViewLoadNumbers = 1;
    self.requestArray=[[NSMutableArray alloc]init];
    self.lastRequest=[[NSURLRequest alloc]init];
    [self CMT_ISHTML_LoadWebview:URL];
    
    return self;
}
- (instancetype)initWithURL:(NSString *)URL activities:(CMTActivities *)activities{
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.urlString = URL;
    self.activities=activities;
    self.webViewLoadNumbers = 1;
    self.requestArray=[NSMutableArray array];
    self.lastRequest=[[NSURLRequest alloc]init];


    [self CMT_ISHTML_LoadWebview:URL];
    
    return self;
}


-(instancetype)initWithActivities:(CMTActivities *)activities{
    self = [super initWithNibName:nil bundle:nil];
    if(nil != self){
        self.urlString = activities.link;
        self.webViewLoadNumbers = 1;
        self.requestArray=[NSMutableArray array];
        self.lastRequest=[[NSURLRequest alloc]init];
        self.activities = activities;


        [self CMT_ISHTML_LoadWebview: self.urlString];
    }
    return self;
}

- (UIView *)backGroundLayer{
    if (_backGroundLayer == nil) {
        _backGroundLayer = [[UIView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT - CMTNavigationBarBottomGuide)];
        _backGroundLayer.backgroundColor = [UIColor colorWithHexString:@"#4e4e4e"];
        _backGroundLayer.alpha = 0.2;
        _backGroundLayer.hidden = YES;
    }
    return _backGroundLayer;
}
- (UIAlertView *)orderAlertView{
    if (_orderAlertView == nil) {
         _orderAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"阅读码将在订单生成后的24小时内，以短信方式发送至你的手机" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    }
    return _orderAlertView;
}
- (UIBarButtonItem *)leftButtonItem {
    if (_leftButtonItem == nil) {
        _leftButtonItem = [[UIBarButtonItem alloc]initWithImage:IMAGE(@"naviBar_back") style:UIBarButtonItemStyleDone target:self action:@selector(GobackAction)];
    }
    return _leftButtonItem;
}
- (NSArray *)leftItems {
    if (_leftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _leftItems = @[leftFixedSpace, self.leftButtonItem];
    }
    
    return _leftItems;
}
- (UIBarButtonItem *)cancelItem {
    if (_cancelItem == nil) {
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
        _cancelItem.tintColor=[UIColor colorWithHexString:@"#32c7c2"];

    }
    
    return _cancelItem;
}

-(void)GobackAction{
    if (!self.webView.canGoBack||self.ishaveAbout) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.webView goBack];

    }
}
-(void)cancelAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
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

- (UIBarButtonItem *)MoreItem {
    if (_MoreItem == nil) {
        _MoreItem = [[UIBarButtonItem alloc]initWithImage:IMAGE(@"activities_left_more") style:UIBarButtonItemStyleDone target:self action:@selector(CMTMore)];
        NSDictionary* textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        COLOR(c_46CDC8),NSForegroundColorAttributeName,
                                        nil];
        [_MoreItem setTitleTextAttributes:textAttributes forState:0];
    }
    
    
    
    
    return _MoreItem;
}

- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        FixedSpace.width = (RATIO - 1.0)*(CGFloat)10;
        _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.MoreItem, nil];
        
    }
    
    return _rightItems;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"WebBrowser willDeallocSignal");
    }];
     self.ishaveAbout=NO;
    self.navigationItem.leftBarButtonItems=self.leftItems;
    [self.webView fillinContainer:self.contentBaseView WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
    [self.contentBaseView addSubview:self.webViewProgressView];
    [self.contentBaseView addSubview:self.backGroundLayer];
    // to do 断网情况 重新联网后 reload webView
    if(nil != self.activities){
        //活动详情右上角展示更多
        self.navigationItem.rightBarButtonItems = self.rightItems;
        self.sharePic=self.activities.sharePic.picFilepath;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
    if( self.webViewProgressTimer != nil) {
        [self.webViewProgressTimer setFireDate:[NSDate distantPast]];
    }
    
    if (self.isrefreshWebView == YES) {
        self.webViewLoadNumbers=1;
        [self CMT_ISHTML_LoadWebview:self.urlString];
        self.isrefreshWebView=NO;
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
    [self.webView stopLoading];
    [self.webViewProgressTimer invalidate];
}

#pragma mark - WebViewProgress

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
    @try {
        NSString *URLString = request.URL.absoluteString;
        NSString *URLScheme = request.URL.scheme;
        
        //处理空白页和系统标签
        if ([URLString hasPrefix:@"about"]||[URLString hasPrefix:@"chrome"]) {
            self.ishaveAbout=YES;
            return YES;
        }
        

        CMTLog(@"WebBrowser URLString: %@",URLString);
#pragma mark HTML动作标签
        
        // scheme: cmtopdr
        if ([URLScheme rangeOfString:CMTNSStringHTMLTagScheme_CMTOPDR
                             options:NSCaseInsensitiveSearch].length > 0) {
            
            [self handleHTMLTag:URLString];
        }
        
        // other scheme
        else {
            
#pragma mark 动态文章详情
        
            if (self.webViewLoadNumbers == 1&&[self.requestArray count]==0) {
                [self.requestArray addObject:request.URL.absoluteString];
                if ([URLString rangeOfString:@"koudaitong"].length > 0) {
                    if ([self.lastViewController isKindOfClass:[CMTReadCodeBlindViewController class]]) {
                        self.backGroundLayer.hidden = NO;
                        [self.orderAlertView show];
                        [[self.orderAlertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                            if (index.integerValue == 0) {
                                self.backGroundLayer.hidden = YES;
                            }
                        }];
                    }
                }
                return YES;
            }
#pragma mark 其他链接
            
            else if([self.requestArray count]==0) {
                   BOOL flag=[URLString handleWithinArticle:URLString viewController:self];
                        if(!flag){
                            return flag;
                        }
                // 判断是否是内部文章/直播
                 BOOL isSelfHtml_url=[URLString JudgeLinktype:URLString url:@"media/phone/"];
                // 动情文章详情 内部文章/直播
                if (isSelfHtml_url) {
                    if ([self.urlString isEqualToString:[[URLString componentsSeparatedByString:@"?"]objectAtIndex:0]]) {
                        [self CMT_ISHTML_LoadWebview:URLString];
                        self.webViewLoadNumbers=1;
                        return NO;
                        
                    }else{
                        if (self.activities!=nil) {
                            CMTWebBrowserViewController *webBrowserViewController = [[CMTWebBrowserViewController alloc] initWithURL:URLString activities:self.activities];
                            [self.navigationController pushViewController:webBrowserViewController animated:YES];
                        }else{
                          CMTWebBrowserViewController *webBrowserViewController =    [[CMTWebBrowserViewController alloc] initWithURL:URLString];
                           [self.navigationController pushViewController:webBrowserViewController animated:YES];
                        }
                        return NO;
                    }
                }
                if ([URLString rangeOfString:@"koudaitong"].length > 0) {
                    [self.requestArray addObject:request.URL.absoluteString];
                    return YES;
                }
            }else{
                [self.requestArray addObject:request.URL.absoluteString];
                return YES;
            }
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"WebBrowser Analyze WebView Request Exception: %@", exception);
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.canGoBack) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        self.leftItems = @[leftFixedSpace, self.leftButtonItem,self.cancelItem];
        self.navigationItem.leftBarButtonItems=self.leftItems;
    }else{
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        self.leftItems = @[leftFixedSpace, self.leftButtonItem];
        self.navigationItem.leftBarButtonItems=self.leftItems;
    }
    [self.requestArray removeObject:webView.request.URL.absoluteString];
    if (self.requestArray.count==0) {
        self.webViewLoadNumbers++;
    }
    
    [webView stringByEvaluatingJavaScriptFromString:@"hidePraise()"];
    NSURL *URL = [NSURL URLWithString:self.urlString.URLEncodeString];
    NSString *URLHost = URL.host;
    NSString *URLPath = URL.path;
    
    // host: CMTCLIENT
    if ([URLHost isEqual:CMTCLIENT.baseURL.host]) {
        
        // 专题
        if ([URLPath rangeOfString:@"/media/phone/theme"
                           options:NSCaseInsensitiveSearch].length > 0) {
            
#pragma mark 标题 Title
            
            self.titleText = [webView stringByEvaluatingJavaScriptFromString:@"document.title"] ?: @"";
        }
    }
    
    // to do 页面多的网站加载完成时progressBarView不消失 尝试代理中刷新self.webViewProgressView.progressBarView
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // to do 网站加载失败时progressBarView不消失 尝试代理中刷新self.webViewProgressView.progressBarView
}

- (void)handleHTMLTag:(NSString *)HTMLTag {
    if (![HTMLTag isKindOfClass:[NSString class]]) {
        CMTLogError(@"PostDetail handle HTMLTag Error: HTMLTag is not Kind Of NSString Class");
        return;
    }
    
    NSDictionary *parseDictionary = HTMLTag.CMT_HTMLTag_parseDictionary;
    NSDictionary *parameters = parseDictionary[CMTNSStringHTMLTagParseKey_parameters];
    NSString *action = parameters[CMTNSStringHTMLTagParameterKey_action];
    NSString *domain = parseDictionary[CMTNSStringHTMLTagParseKey_domain];
    
    if([domain isEqualToString:@"activity"]){
#pragma mark 点击跳转到文章详情

        if ([action isEqual:CMTNSStringHTMLTagAction_postDetail]) {

            NSString *postId = parameters[CMTNSStringHTMLTagParameterKey_postId];
//            NSString *userId = parameters[@"userId"];
            NSString *isHTML = parameters[@"isHTML"];
            NSString *module = parameters[@"module"];
            NSString *url = parameters[@"url"];
            CMTPostDetailViewController *postDetailViewController = [[CMTPostDetailViewController alloc] initWithPostId:postId isHTML:isHTML postURL:url postModule:module postDetailType:CMTPostDetailTypeHomePostList];
            [self.navigationController pushViewController:postDetailViewController animated:YES];
        } else if ([action isEqual:CMTNSStringHTMLTagAction_share]){
            NSString *sharetitle=[self.webView stringByEvaluatingJavaScriptFromString:@"shareTitle"];
            NSString *sharelink=[self.webView stringByEvaluatingJavaScriptFromString:@"shareLink"];
           self.sharePic=[self.webView stringByEvaluatingJavaScriptFromString:@"shareImgUrl"];
            NSString *sharedesc=[self.webView stringByEvaluatingJavaScriptFromString:@"shareDesc"];
            self.shareTitle =sharetitle.length==0?self.activities.title:sharetitle;
            self.shareBrief =sharedesc.length==0?self.activities.desc:sharedesc;
            self.shareUrl =sharelink.length==0?self.activities.link:sharelink;
            self.postID = self.activities.activityId;
            [self CMTShareAction];

        }else{
            [self goUpdateHTMLTag:HTMLTag parseDictionary:parseDictionary];
        }
        
    }else if([domain isEqualToString:@"postDetail"]){
        
#pragma mark 点击作者
        
        if ([action isEqual:CMTNSStringHTMLTagAction_author]) {
            
            [self.navigationController pushViewController:
             [[CMTOtherPostListViewController alloc] initWithAuthor:[parameters[CMTNSStringHTMLTagParameterKey_nickname] URLDecodeString]
                                                           authorId:parameters[CMTNSStringHTMLTagParameterKey_authorid]]
                                                 animated:YES];
        }
        
#pragma mark 点击类型
        
        else if ([action isEqual:CMTNSStringHTMLTagAction_type]) {
            
            [self.navigationController pushViewController:
             [[CMTOtherPostListViewController alloc] initWithPostType:[parameters[CMTNSStringHTMLTagParameterKey_posttype] URLDecodeString]
                                                           postTypeId:parameters[CMTNSStringHTMLTagParameterKey_posttypeid]]
                                                 animated:YES];
        }
        
#pragma mark 点击专题标签
        
        else if ([action isEqual:CMTNSStringHTMLTagAction_themeTag]) {
            
            [self.navigationController pushViewController:
             [[CMTOtherPostListViewController alloc] initWithThemeId:parameters[CMTNSStringHTMLTagParameterKey_themeId]
                                                              postId:parameters[CMTNSStringHTMLTagParameterKey_postId]
                                                              isHTML:@"1"
                                                             postURL:self.urlString]
                                                 animated:YES];
        }
        
#pragma mark 点击疾病标签
        
        else if ([action isEqual:CMTNSStringHTMLTagAction_diseaseTag]) {
            
            [self.navigationController pushViewController:
             [[CMTOtherPostListViewController alloc] initWithDisease:[parameters[CMTNSStringHTMLTagParameterKey_disease] URLDecodeString]
                                                          diseaseIds:parameters[CMTNSStringHTMLTagParameterKey_diseaseId]
                                                              module:parameters[CMTNSStringHTMLTagParameterKey_module]]
                                                 animated:YES];
        }
        
#pragma mark 点击二级标签
        
        else if ([action isEqual:CMTNSStringHTMLTagAction_searchKeyword]) {
            
            [self.navigationController pushViewController:
             [[CMTOtherPostListViewController alloc] initWithKeyword:parameters[CMTNSStringHTMLTagParameterKey_keyword]
                                                              module:parameters[CMTNSStringHTMLTagParameterKey_module]]
                                                 animated:YES];
        }
        
#pragma mark 点击图片
        
        else if ([action isEqual:CMTNSStringHTMLTagAction_showPicture]) {
            NSString *curImageURL = [parameters[CMTNSStringHTMLTagParameterKey_curPic] URLDecodeString];
            NSString *imageURLArrayString = [parameters[CMTNSStringHTMLTagParameterKey_picList] URLDecodeString];
            NSArray *imageURLArray = nil;
            if ([imageURLArrayString isKindOfClass:[NSString class]] && !BEMPTY(imageURLArrayString)) {
                imageURLArray = [imageURLArrayString componentsSeparatedByString:@","];
            }
            
            [self openPhotoBrowserWithCurrentImageURL:curImageURL
                                       totalImageURLs:imageURLArray];
        }
        
#pragma mark 点击PDF
        
        else if ([action isEqual:CMTNSStringHTMLTagAction_openPDF]) {
            NSString *PDFURL = parameters[CMTNSStringHTMLTagParameterKey_pdfUrl];
            NSString *PDFSize = parameters[CMTNSStringHTMLTagParameterKey_size];
            NSString *PDFID = parameters[CMTNSStringHTMLTagParameterKey_id];
            if (!BEMPTY(PDFURL) && !BEMPTY(PDFSize)) {
                
                [self openPDFBrowserWithPDFURL:PDFURL PDFSize:PDFSize PDFID:PDFID];
            }
            else {
                
                CMTLogError(@"PostDetail Open PDFBrowser Error:  Empty PDFURL or Empty PDFSize");
            }
        }
        
#pragma mark 点击登陆
        
        else if ([action isEqual:CMTNSStringHTMLTagAction_login]) {
            self.isrefreshWebView=YES;
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            
            [self.navigationController pushViewController:loginVC animated:YES];
        }
        
#pragma mark 点击分享
        
        else if ([action isEqual:CMTNSStringHTMLTagAction_share]) {
            self.shareTitle =[parameters[CMTNSStringHTMLTagParameterKey_title] decodeFromPercentEscapeString];
            self.shareBrief = [parameters[CMTNSStringHTMLTagParameterKey_brief]decodeFromPercentEscapeString];
            self.shareUrl =[parameters[CMTNSStringHTMLTagParameterKey_url]decodeFromPercentEscapeString];
            self.postID = parameters[CMTNSStringHTMLTagParameterKey_postid];
            self.sharePic=[parameters[CMTNSStringHTMLTagParameterKey_sharePic]decodeFromPercentEscapeString];
            [self CMTShareAction];
        }
        
#pragma mark 其他
        
        else {
            [self goUpdateHTMLTag:HTMLTag parseDictionary:parseDictionary];
        }
    }else {
        [self goUpdateHTMLTag:HTMLTag parseDictionary:parseDictionary];
    }
}

-(void)goUpdateHTMLTag : (NSString *)HTMLTag
        parseDictionary: (NSDictionary *)parseDictionary{
    CMTLog(@"HTMLTag: %@\nparseDictionary: %@", HTMLTag, parseDictionary);
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

#pragma mark - MWPhotoBrowser

- (void)openPhotoBrowserWithCurrentImageURL:(NSString *)imageURL
                             totalImageURLs:(NSArray *)totalImageURLs {
    // Photos
    if (self.photoBrowserPhotos.count == 0) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSInteger index = 0; index < totalImageURLs.count; index++) {
            // 原始图片URL
            NSString *imageURLString = [UIImage fullQualityImageURLWithURL:totalImageURLs[index]];
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
            photo.caption = [NSString stringWithFormat:@"%ld/%ld", (long)(index + 1), (long)totalImageURLs.count];
            [photos addObject:photo];
        }
        self.photoBrowserPhotos = photos;
    }
    
    // PhotoBrowser
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableSwipeToDismiss = NO;
    [photoBrowser setCurrentPhotoIndex:[totalImageURLs indexOfObject:imageURL]];
    
    // Show
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photoBrowserPhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photoBrowserPhotos.count) {
        return self.photoBrowserPhotos[index];
    }
    return nil;
}

#pragma mark - PDF

- (void)refreshPDFFileStatus:(CMTPDFFileStatus)PDFFileStatus WithPDFID:(NSString *)PDFID {
    
    NSString *javascriptString = [NSString stringWithFormat:@"javascript:setStatus('%@', %ld)", PDFID, (long)PDFFileStatus];
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
}

- (void)openPDFBrowserWithPDFURL:(NSString *)PDFURL PDFSize:(NSString *)PDFSize PDFID:(NSString *)PDFID {
    @weakify(self);
    CMTPDFBrowserViewController *PDFBrowserViewController = [[CMTPDFBrowserViewController alloc] initWithPDFURL:PDFURL PDFSize:PDFSize PDFID:PDFID
                                                                                                updatePDFStatus:^(CMTPDFFileStatus PDFFileStatus) {
                                                                                                    @strongify(self);
                                                                                                    [self refreshPDFFileStatus:PDFFileStatus WithPDFID:PDFID];
                                                                                                }];
    [self.navigationController pushViewController:PDFBrowserViewController animated:YES];
}

#pragma mark - ShareMethod

// 分享处理方法 add byguoyuanchao
- (void)CMTShareAction{
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
    
    NSString *shareType = nil;
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
            shareType = @"3";
                if ([self respondsToSelector:@selector(weiboShare)]) {
                [self performSelector:@selector(weiboShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 4444:
        {
            CMTLog(@"邮件");
            shareType = @"4";
            NSString *pContent = [NSString stringWithFormat:@"#壹生#《%@》%@ <br>来自@壹生 <br>", self.shareTitle , self.shareUrl];
            CMTPost *post=[[CMTPost alloc]init];
            post.postId=self.postID;
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_Email shareTitle:self.shareTitle sharetext:pContent sharetype:shareType sharepic:self.sharePic shareUrl:self.shareUrl StatisticalType:self.activities!=nil?@"commonShare":@"sharePost" shareData:post];
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
    [self.mShareView.cancelBtn removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    
}
/// 朋友圈分享
- (void)friendCircleShare
{
    NSString *shareType = @"1";
    CMTLog(@"朋友圈");
    NSString *shareText =self.shareTitle;
    CMTPost *post=[[CMTPost alloc]init];
    post.postId=self.postID;
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.sharePic shareUrl:self.shareUrl StatisticalType:self.activities!=nil?@"commonShare":@"sharePost" shareData:post];
}
/// 微信好友分享
- (void)weixinShare
{
    NSString *shareType = @"2";
    NSString *shareTitle = self.shareTitle;
    NSString *shareText = self.shareBrief;
    NSString *shareURL = self.shareUrl;
    if (BEMPTY(shareText)) {
        shareText =@"壹生文章分享";
    }
    CMTPost *post=[[CMTPost alloc]init];
    post.postId=self.postID;
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.sharePic shareUrl:shareURL StatisticalType:self.activities!=nil?@"commonShare":@"sharePost" shareData:post];
}

- (void)weiboShare
{
    NSString *shareType = @"3";
    NSString *shareText = [NSString stringWithFormat:@"#%@# %@。%@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY,self.shareTitle,self.shareUrl];
    
    CMTPost *post=[[CMTPost alloc]init];
    post.postId=self.postID;
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.sharePic shareUrl:self.shareUrl StatisticalType:self.activities!=nil?@"commonShare":@"sharePost" shareData:post];
}

//右上角更多按钮
-(void)CMTMore{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"刷新",@"分享",@"用浏览器打开", nil];
    [actionSheet showInView:self.contentBaseView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(0 == buttonIndex){
        //刷新
        [self.webView reload];
    }else if (1 == buttonIndex){
        //分享
        NSString *sharetitle=[self.webView stringByEvaluatingJavaScriptFromString:@"shareTitle"];
        NSString *sharelink=[self.webView stringByEvaluatingJavaScriptFromString:@"shareLink"];
        NSString *shareimgUrl=[self.webView stringByEvaluatingJavaScriptFromString:@"shareImgUrl"];
        NSString *sharedesc=[self.webView stringByEvaluatingJavaScriptFromString:@"shareDesc"];
        self.sharePic=shareimgUrl;
        self.shareTitle =sharetitle.length==0?self.activities.title:sharetitle;
        self.shareBrief =sharedesc.length==0?self.activities.desc:sharedesc;
        self.shareUrl =sharelink.length==0?self.activities.link:sharelink;
        self.postID =self.activities.activityId;
        [self CMTShareAction];

    }else if(2==buttonIndex){
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    }
}
@end
