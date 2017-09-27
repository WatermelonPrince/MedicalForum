 //
//  CMTDigitalWebViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTDigitalWebViewController.h"
#import "CMTWebBrowserViewController.h"
#import "CMTPDFBrowserViewController.h"
#import "CMTBindingViewController.h"
#import "CMTReadCodeBlindViewController.h"
#import "CMTSettingViewController.h"
@interface CMTDigitalWebViewController ()<UIWebViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)UIWebView *nextwebView;
@property(nonatomic,strong)NSString *model;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSMutableArray *requestArray;//记录加载了多少url
@property(nonatomic,strong)NSURLRequest *lastRequest;//记录上一次加载的url;
@property (nonatomic, assign) NSInteger webViewLoadNumbers;                     // webViewurl为http开头的加载的次数;
@property(nonatomic,assign)UIWebView *loadingWebView;


@end

@implementation CMTDigitalWebViewController
-(UIWebView*)webView{
    if (_webView==nil) {
        _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _webView.backgroundColor=COLOR(c_ffffff);
        _webView.scrollView.backgroundColor=COLOR(c_ffffff);
        _webView.scrollView.scrollsToTop=YES;
        _webView.delegate=self;
        _webView.scrollView.delegate=self;
         _webView.allowsInlineMediaPlayback = YES;
         [self.contentBaseView addSubview:_webView];
    }
    return _webView;
}
-(UIWebView*)nextwebView{
    if (_nextwebView==nil) {
        _nextwebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _nextwebView.backgroundColor=COLOR(c_ffffff);
         _nextwebView.scrollView.backgroundColor=COLOR(c_ffffff);
        _nextwebView.delegate=self;
        _nextwebView.scrollView.scrollsToTop=YES;
        _nextwebView.scrollView.delegate=self;
         _nextwebView.allowsInlineMediaPlayback = YES;
        [self.contentBaseView addSubview:_nextwebView];
    }
    return _nextwebView;
}


-(instancetype)initWithURl:(NSString*)url model:(NSString*)model{
     self=[super init];
    if (self) {
        self.model=model;
        self.url=url;
        self.requestArray=[NSMutableArray array];
        self.lastRequest=[[NSURLRequest alloc]init];
        self.webViewLoadNumbers=1;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTDigitalWebViewController willDeallocSignal");
    }];

    self.view.backgroundColor=[UIColor whiteColor];
    [self setContentState:CMTContentStateLoading];
    //初次加载
    [self getdata:self.url webView:self.webView];
}
//获取数据
-(void)getdata:(NSString*)url webView:(UIWebView*)webView{
    self.url=url;
    self.loadingWebView=webView;
    @weakify(self);
     webView.userInteractionEnabled=NO;
    if(self.contentState==CMTContentStateNormal){
      [self setContentState:CMTContentStateLoading];
        self.contentBaseView.hidden=NO;
    }
    [[[CMTCLIENT GetDigitalHtml:[url stringByReplacingOccurrencesOfString:CMTCLIENT.baseURL.absoluteString withString:@""]]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTDigitalObject *dig) {
        @strongify(self);
        NSString *htmlString=dig.html?:@"";
           if (dig.encrypt.integerValue==1) {
       
           htmlString=[NSString doDecEncryptStr:dig.html  key:[CMTMD5 md5:CMTUSERINFO.decryptKey] padding:@"" ];
               
           }
        if (htmlString.length>0) {
            [self CMTLodeWebView:webView html:htmlString url:url];
            [self setContentState:CMTContentStateNormal];
            [self stopAnimation];

        }else{
            if(dig.encrypt.integerValue==1){
             [self getDecencrypt:dig.html?:@"" webView:(UIWebView*)webView url:url];
            }
        }
        
    } error:^(NSError *error) {
          @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力"];
            CMTLogError(@"Request verification code System Error: %@", error);
            
        } else {
            CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
            [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
        }
        [self setContentState:CMTContentStateReload];
        
    }];
}
/**
 *  key 失效
 *
 *  @param html    <#html description#>
 *  @param webView <#webView description#>
 *  @param url     <#url description#>
 */
-(void)getDecencrypt:(NSString*)html webView:(UIWebView*)webView url:(NSString*)url{
    @weakify(self);
    NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"onlyDecryptKey":@"1"};
    [[[CMTCLIENT GetDigitalSubject:dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTDigitalObject *Digital) {
        @strongify(self);
        CMTUSERINFO.decryptKey=Digital.decryptKey;
        CMTUSERINFO.canRead=Digital.canRead;
        CMTUSERINFO.rcodeState = Digital.rcodeState;
         NSString *htmlstring=[NSString doDecEncryptStr:html key:[CMTMD5 md5:CMTUSERINFO.decryptKey] padding:@"" ];
        [self CMTLodeWebView:webView html:htmlstring url:url];
        [self setContentState:CMTContentStateNormal];
        [self stopAnimation];
    } error:^(NSError *error) {
        CMTLog(@"错误信息%@",error);
    } completed:^{
        CMTLog(@"完成");
    }];

}
-(void)animationFlash{
    [super animationFlash];
    [self getdata:self.url webView:self.loadingWebView];

}
-(void)CMTLodeWebView:(UIWebView*)webview1 html:(NSString*)htmlString url:(NSString*)urlString{
    
    [webview1 loadHTMLString:htmlString baseURL:[[NSURL alloc]initWithString:urlString]];

}
- (NSString*)getExpose_param_String {
    NSString *paramString=[@"{\"is_night_mode\":" stringByAppendingFormat:@"\"%@\"",@"true"];
    paramString=[paramString stringByAppendingFormat:@",\"font-size\":\"%@\"",CMTAPPCONFIG.customFontSize];
    paramString=[paramString stringByAppendingFormat:@",\"scr-size\":\"%ld_%ld\"}",(long)SCREEN_WIDTH,(long)SCREEN_HEIGHT];
    
    return paramString;
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType{
    
    @try{
            NSString *URLString = request.URL.absoluteString;
            NSString *URLScheme = request.URL.scheme;
            //处理空白页和系统标签
            if ([URLString hasPrefix:@"about"]||[URLString hasPrefix:@"chrome"]) {
                return YES;
            }

            CMTLog(@"WebBrowser URLString: %@",URLString);
            
            if ([URLScheme rangeOfString:CMTNSStringHTMLTagScheme_CMTOPDR
                                 options:NSCaseInsensitiveSearch].length > 0) {
                
                NSDictionary *parseDictionary = URLString.CMT_HTMLTag_parseDictionary;
                NSDictionary *parameters = parseDictionary[CMTNSStringHTMLTagParseKey_parameters];
                NSString *action = parameters[CMTNSStringHTMLTagParameterKey_action];
                NSMutableDictionary *mutableDic=[[NSMutableDictionary alloc]initWithDictionary:[parameters copy]];
                [mutableDic removeObjectForKey:CMTNSStringHTMLTagParameterKey_action];
                [mutableDic removeObjectForKey:CMTNSStringHTMLTagScheme_CMTOPDR];
                if ([action isEqualToString:@"preEpaper"]) {
                    [self CMTprepageAction:webView param:mutableDic];
                    return NO;
                }else if ([action isEqualToString:@"nextEpaper"]){
                    [self CMTnextPageAction:webView param:mutableDic];
                    return NO;
                }else if ([action isEqualToString:@"preIssue"]){
                    [self CMTprepageAction:webView param:mutableDic];
                    return NO;
                    
                }else if ([action isEqualToString:@"nextIssue"]){
                    [self CMTnextPageAction:webView param:mutableDic];
                    return NO;
                }else if ([action isEqual:CMTNSStringHTMLTagAction_openPDF]) {
                    NSString *PDFURL = parameters[CMTNSStringHTMLTagParameterKey_pdfUrl];
                    NSString *PDFSize = parameters[CMTNSStringHTMLTagParameterKey_size];
                    NSString *PDFID = parameters[CMTNSStringHTMLTagParameterKey_id];
                    if (!BEMPTY(PDFURL) && !BEMPTY(PDFSize)) {
                        
                        [self openPDFBrowserWithPDFURL:PDFURL PDFSize:PDFSize PDFID:PDFID];
                    }
                    else {
                        
                        CMTLogError(@"PostDetail Open PDFBrowser Error:  Empty PDFURL or Empty PDFSize");
                    }
                    return NO;
                } else{
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
            }else{
                if (self.webViewLoadNumbers == 1&&self.requestArray.count==0) {
                    self.lastRequest=request;
                    [self.requestArray addObject: self.lastRequest];
                    
                    return YES;
                }else if(self.requestArray.count==0){
                        BOOL flag=[URLString handleWithinArticle:URLString viewController:self];
                        if(!flag){
                            return flag;
                        }
                        BOOL isSelfHtml_url=[URLString JudgeLinktype:URLString url:@"epaper" ];
                    if (isSelfHtml_url) {
                        if(!CMTUSER.login){
                            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
                            loginVC.nextvc = FromDigitalAndLogin;
                            [self.navigationController pushViewController:loginVC animated:YES];
                        }else if(CMTUSERINFO.roleId.integerValue==0&&CMTUSERINFO.improveStatus.integerValue==0){
                            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"完善信息用户方可浏览数字报" message:nil delegate:nil cancelButtonTitle:@"立刻去完善" otherButtonTitles:@"以后再说", nil];
                            [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *x) {
                                if(x.integerValue==0){
                                    CMTSettingViewController *setting=[[CMTSettingViewController alloc]init];
                                    setting.nextvc=FromDigital;
                                    [self.navigationController pushViewController:setting animated:YES];
                                }
                            } error:^(NSError *error) {
                                NSLog(@"完善失败");
                            }];
                            [alert show];

                        }else if(CMTUSERINFO.canRead.integerValue==1){
                            CMTDigitalWebViewController *webView=[[CMTDigitalWebViewController alloc]initWithURl:URLString model:@"0"];
                            [self.navigationController pushViewController:webView animated:YES];
                            
                        }else if (CMTUSERINFO.rcodeState.integerValue == 2){
                            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"阅读码已过期，想要继续阅读？" message:nil delegate:self cancelButtonTitle:@"重新绑定" otherButtonTitles:@"以后再说", nil];
                            [alert show];
                        }else{
                            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"绑定阅读码 即刻畅读数字报" message:nil delegate:self cancelButtonTitle:@"立即绑定" otherButtonTitles:@"以后再说", nil];
                            [alert show];
                        }

                        return NO;
                    }else{
                        CMTWebBrowserViewController *wenBrower=[[CMTWebBrowserViewController alloc]initWithURL:URLString];
                        [self.navigationController pushViewController:wenBrower animated:YES];
                        return NO;
                    }
            }else{
                    self.lastRequest=request;
                    [self.requestArray addObject: self.lastRequest];
                    return YES;
                }
            }
    }@catch (NSException *exception) {
        CMTLogError(@"PostDetail Analyze WebView Request Exception: %@", exception);
    }
    
    return YES;

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
     if(buttonIndex==0){
        CMTReadCodeBlindViewController *readCodeVC = [[CMTReadCodeBlindViewController alloc]init];
        [self.navigationController pushViewController:readCodeVC animated:YES];

    }
}
//打开PDF
- (void)openPDFBrowserWithPDFURL:(NSString *)PDFURL PDFSize:(NSString *)PDFSize PDFID:(NSString *)PDFID {
    @weakify(self);
    CMTPDFBrowserViewController *PDFBrowserViewController = [[CMTPDFBrowserViewController alloc] initWithPDFURL:PDFURL PDFSize:PDFSize PDFID:PDFID
                                                                                                updatePDFStatus:^(CMTPDFFileStatus PDFFileStatus) {
                                                                                                    @strongify(self);
                                                                                                    [self refreshPDFFileStatus:PDFFileStatus WithPDFID:PDFID];
                                                                                                }];
    [self.navigationController pushViewController:PDFBrowserViewController animated:YES];
}

- (void)refreshPDFFileStatus:(CMTPDFFileStatus)PDFFileStatus WithPDFID:(NSString *)PDFID {
    
    NSString *javascriptString = [NSString stringWithFormat:@"javascript:setStatus('%@', %ld)", PDFID, (long)PDFFileStatus];
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
}
/**
 *  向上翻页
 *
 *  @param webView <#webView description#>
 *  @param url     <#url description#>
 */
-(void)CMTprepageAction:(UIWebView*)webView param:(NSMutableDictionary*)parameters{
    self.webViewLoadNumbers=1;
    @weakify(self);
    NSString *url=parameters[@"url"];
    [parameters removeObjectForKey:@"url"];
    for (NSString *key in [parameters allKeys]) {
      url=[url stringByAppendingFormat:@"&%@=%@",key,parameters[key]];
    }
    webView.userInteractionEnabled=NO;
    if (webView!=self.webView) {
        self.webView.frame=CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide);
        [self.contentBaseView sendSubviewToBack:self.webView];
        [self getdata:url  webView:self.webView];
        [UIView animateWithDuration:0.5 animations:^{
            @strongify(self);
            self.nextwebView.frame=CGRectMake(0, SCREEN_HEIGHT, self.nextwebView.width, self.nextwebView.height);
        } completion:^(BOOL finished) {

        }];
        
        
    }else if(webView!=self.nextwebView){
        self.webViewLoadNumbers=1;
        self.nextwebView.frame=CGRectMake(0,CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide);
        [self.contentBaseView sendSubviewToBack:self.nextwebView];
          [self getdata:url webView:self.nextwebView];
        [UIView animateWithDuration:0.5 animations:^{
             @strongify(self);
            self.webView.frame=CGRectMake(0, SCREEN_HEIGHT, self.webView.width, self.webView.height);
            
        } completion:^(BOOL finished) {

        }];
      
        
    }
   

    
}
/**
 *  下一页动作
 *
 *  @param webView <#webView description#>
 *  @param url     <#url description#>
 */
-(void)CMTnextPageAction:(UIWebView*)webView param:(NSMutableDictionary*)parameters{
    self.webViewLoadNumbers=1;
     @weakify(self);
     NSString *url=parameters[@"url"];
    [parameters removeObjectForKey:@"url"];
    for (NSString *key in [parameters allKeys]) {
        url=[url stringByAppendingFormat:@"&%@=%@",key,parameters[key]];
    }
    webView.userInteractionEnabled=NO;
    if (webView!=self.webView) {
        self.webView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide);
        [self.contentBaseView bringSubviewToFront:self.webView];
        [self getdata:url webView:self.webView];
        [UIView animateWithDuration:0.5 animations:^{
            @strongify(self);
            self.webView.frame=CGRectMake(0,CMTNavigationBarBottomGuide, self.webView.width, self.webView.height);
        } completion:^(BOOL finished) {

        }];
        
        
    }else if(webView!=self.nextwebView){
        self.webViewLoadNumbers=1;
        self.nextwebView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide);
        [self.contentBaseView bringSubviewToFront:self.nextwebView];
        [self getdata:url webView:self.nextwebView];
        [UIView animateWithDuration:0.5 animations:^{
            self.nextwebView.frame=CGRectMake(0, CMTNavigationBarBottomGuide, self.nextwebView.width, self.nextwebView.height);
            
        } completion:^(BOOL finished) {
            webView.userInteractionEnabled=YES;
        }];
        
    }

}
-(void)webViewDidStartLoad:(UIWebView *)webView{
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.requestArray removeObject:self.lastRequest];
    if(self.requestArray.count==0){
          self.webViewLoadNumbers++;
         webView.userInteractionEnabled=YES;
    }
    if([webView.request.URL.absoluteString hasPrefix:@"http://topdr.test.medtrib.cn/epaper/scroll/list"]){
      NSString *isShowDigGuide=[[NSUserDefaults standardUserDefaults]objectForKey:@"DigitallistGuide"];
     if (isEmptyString(isShowDigGuide)||![isShowDigGuide boolValue]){
        [webView stringByEvaluatingJavaScriptFromString:@"showGuide()"];
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"DigitallistGuide"];
      }
    }else if([webView.request.URL.absoluteString hasPrefix:@"http://topdr.test.medtrib.cn/epaper/scroll/detail"]){
        NSString *isShowDigGuide=[[NSUserDefaults standardUserDefaults]objectForKey:@"DigitaldetailGuide"];
        if (isEmptyString(isShowDigGuide)||![isShowDigGuide boolValue]){
            [webView stringByEvaluatingJavaScriptFromString:@"showGuide()"];
            [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"DigitaldetailGuide"];
        }
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    CMTLog(@"页面加载失败");
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
