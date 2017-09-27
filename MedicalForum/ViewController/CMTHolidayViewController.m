//
//  CMTHolidayViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/15.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTHolidayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CMTBindingViewController.h"                // 登录页
#import "CMTUpgradeViewController.h"                // 申请认证页
#import "CMTOtherPostListViewController.h"          // 其他文章列表
#import "MWPhotoBrowser.h"                          // 图片浏览器
#import "CMTPDFBrowserViewController.h"             // PDF浏览器
#import "CMTPostDetailViewController.h"             //文章详情
#import "SDWebImageManager.h"
#import "CMTWebBrowserViewController.h"
@interface CMTHolidayViewController ()<UIWebViewDelegate, MWPhotoBrowserDelegate>

@property(nonatomic,strong)UIWebView *webview;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)AVAudioPlayer *player;
@property(nonatomic,strong)NSData *audioData;
@property(nonatomic,strong)NSString *audioUrl;
@property (strong, nonatomic) NSString *shareTitle;                             // 分享title
@property (strong, nonatomic) NSString *shareBrief;                             // 分享brief
@property (strong, nonatomic) NSString *shareUrl;                               // 分享url
@property (strong, nonatomic) NSString *sharePic;                              //分享UIImage
@property (nonatomic, strong) NSArray *photoBrowserPhotos;                      // 图片对象数组
@property(nonatomic,strong)NSString *postID;
@property(nonatomic,assign)BOOL ispost;//是文章还是活动
@end

@implementation CMTHolidayViewController
-(UIWebView*)webview{
    if (_webview==nil) {
        _webview=[[UIWebView alloc]initWithFrame:self.contentBaseView.bounds];
        _webview.delegate=self;
        _webview.scrollView.bounces=NO;
        _webview.scrollView.backgroundColor=[UIColor colorWithHexString:@"#f7f7f7"];
        _webview.allowsInlineMediaPlayback = YES;
        [self.contentBaseView addSubview:self.webview];
    }
    return _webview;
}
-(AVAudioPlayer*)player{
    if (_player==nil) {
        _player=[[AVAudioPlayer alloc]init];
    }
    return _player;
}
-(instancetype)initWithUrl:(NSString*)url{
    self=[super init];
    if (self) {
        self.url=url;
        self.ispost=NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTHolidayViewController willDeallocSignal");
    }];

    [self setContentState:CMTContentStateNormal];
    [self CMT_ISHTML_LoadWebview:self.url];
    @weakify(self);
    [[[RACObserve(CMTAPPCONFIG, isAllowPlaymusic)ignore:@"0"]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        //播放本地音乐
        if (self.audioData!=nil) {
            NSError* err;
            self.player = [[AVAudioPlayer alloc]
                           initWithData:self.audioData  error:&err];//使用本地URL创建
            self.player.volume=1;//0.0~1.0之间
            self.player.numberOfLoops = 1000000;//默认只播放一次
            [self.player play];
        }
    } completed:^{
        
    }];

  
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
    [self.webview loadRequest:request];
}
// 增加动态模板控制页面字体,答题模式的属性
- (NSString*)getExpose_param_String {
    NSString *paramString=[@"{\"is_night_mode\":" stringByAppendingFormat:@"\"%@\"",@"true"];
    paramString=[paramString stringByAppendingFormat:@",\"font-size\":\"%@\"",CMTAPPCONFIG.customFontSize];
    paramString=[paramString stringByAppendingFormat:@",\"scr-size\":\"%ld_%ld\"}",(long)SCREEN_WIDTH,(long)SCREEN_HEIGHT];
    
    return paramString;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *URLString = request.URL.absoluteString;
    NSString *URLScheme = request.URL.scheme;
    //处理空白页和系统标签
    if ([URLString hasPrefix:@"about"]||[URLString hasPrefix:@"chrome"]||[URLString isEqualToString:self.url]) {
        return YES;
    } 
    
    CMTLog(@"WebBrowser URLString: %@",URLString);
#pragma mark HTML动作标签
    
    // scheme: cmtopdr
    if ([URLScheme rangeOfString:CMTNSStringHTMLTagScheme_CMTOPDR
                         options:NSCaseInsensitiveSearch].length > 0) {
        
        NSDictionary *parseDictionary = URLString.CMT_HTMLTag_parseDictionary;
        NSDictionary *parameters = parseDictionary[CMTNSStringHTMLTagParseKey_parameters];
        NSString *action = parameters[CMTNSStringHTMLTagParameterKey_action];
        if ([action isEqualToString:@"closeguide"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            CMTAPPCONFIG.InitObject=nil;
            return NO;
        }else if ([action isEqualToString:@"playaudio"]){
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                self.audioUrl=[parameters[@"url"] decodeFromPercentEscapeString ];
                
                NSURL *url = [[NSURL alloc]initWithString:self.audioUrl];
                self.audioData = [NSData dataWithContentsOfURL:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (CMTAPPCONFIG.isAllowPlaymusic.boolValue) {
                        //播放本地音乐
                        NSError* err;
                        self.player = [[AVAudioPlayer alloc]
                                       initWithData:self.audioData error:&err];//使用本地URL创建
                        self.player.volume=1;//0.0~1.0之间
                        self.player.numberOfLoops = 1000000;//默认只播放一次
                        [self.player play];

                    }
                    
                });

              
            });
            
           
            
        }else{
            [self handleHTMLTag:URLString];
        }
        return NO;
    }else{
            BOOL flag=[URLString handleWithinArticle:URLString viewController:self];
            if (flag) {
                    CMTWebBrowserViewController *webBrowserViewController =    [[CMTWebBrowserViewController alloc] initWithURL:URLString];
                    [self.navigationController pushViewController:webBrowserViewController animated:YES];
                    return NO;
            }else{
                return flag;
            }

    }
    return YES;

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
            self.shareTitle =[parameters[CMTNSStringHTMLTagParameterKey_title] decodeFromPercentEscapeString];
            self.shareBrief = [parameters[CMTNSStringHTMLTagParameterKey_brief]decodeFromPercentEscapeString];
            self.shareUrl =[parameters[CMTNSStringHTMLTagParameterKey_url]decodeFromPercentEscapeString];
            self.postID = parameters[CMTNSStringHTMLTagParameterKey_postid];
            self.sharePic=[parameters[CMTNSStringHTMLTagParameterKey_sharePic]decodeFromPercentEscapeString];
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
                                                             postURL:self.url]
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
    [self.webview stringByEvaluatingJavaScriptFromString:javascriptString];
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
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_Email shareTitle:self.shareTitle sharetext:pContent sharetype:shareType sharepic:self.sharePic shareUrl:self.shareUrl StatisticalType:!self.ispost?@"commonShare":@"sharePost" shareData:post];
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
     [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.sharePic shareUrl:self.shareUrl StatisticalType:!self.ispost?@"commonShare":@"sharePost" shareData:post];
    
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
     [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.sharePic shareUrl:shareURL StatisticalType:!self.ispost?@"commonShare":@"sharePost" shareData:post];
}

- (void)weiboShare
{
     NSString *shareType = @"3";
    NSString *shareText = [NSString stringWithFormat:@"#%@# %@。%@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY,self.shareTitle,self.shareUrl];
    
    CMTPost *post=[[CMTPost alloc]init];
    post.postId=self.postID;
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.sharePic shareUrl:self.shareUrl StatisticalType:!self.ispost?@"commonShare":@"sharePost" shareData:post];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"加载成功");
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [self.navigationController setNavigationBarHidden:NO animated:animated];
    if (self.audioData!=nil) {
        [self.player stop];
    }
    
    self.player=nil;
   }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
