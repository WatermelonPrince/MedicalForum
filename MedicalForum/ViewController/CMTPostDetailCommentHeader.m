//
//  CMTPostDetailCommentHeader.m
//  MedicalForum
//
//  Created by fenglei on 15/6/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view

#import "CMTPostDetailCommentHeader.h"          // header file

@interface CMTPostDetailCommentHeader () <UIWebViewDelegate>

// view
@property (nonatomic, strong) UIWebView *webView;                               // 简单文章详情视图
@property (nonatomic, strong, readwrite) CMTTapToRefresh *tapToRefresh;         // 点击刷新

// data
@property (nonatomic, strong) CMTPost *postDetail;                                // 文章详情数据
@property (nonatomic, strong) CMTPostStatistics *simplePostDetail;                // 简单文章详情数据

@end

@implementation CMTPostDetailCommentHeader

#pragma mark Initializers

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = COLOR(c_fafafa);
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.scrollsToTop = NO;
        _webView.delegate = self;
    }
    
    return _webView;
}

- (CMTTapToRefresh *)tapToRefresh {
    if (_tapToRefresh == nil) {
        _tapToRefresh = [[CMTTapToRefresh alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, CMTTapToRefreshDefaultHeight)];
        _tapToRefresh.backgroundColor = COLOR(c_fafafa);
    }
    
    return _tapToRefresh;
}

- (instancetype)initWithFrame:(CGRect)frame showTapToRefresh:(BOOL)showTapToRefresh {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostDetailCommentHeader willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_ffffff);
    
    [self addSubview:self.webView];
    [self addSubview:self.tapToRefresh];
    
    // 是否显示tapToRefresh
    self.tapToRefresh.visible = showTapToRefresh;
    
    return self;
}

#pragma mark LifeCycle

- (void)reloadHeaderWithPostDetail:(CMTPost *)postDetail {
    if (self.postDetail == postDetail) {
        return;
    }
    
    NSString *authorId = !postDetail.module.isPostModuleGuide ? postDetail.authorId : nil;
    NSString *author = !postDetail.module.isPostModuleGuide ? postDetail.author : postDetail.issuingAgency;
    
    NSString *simplePostDetailHTMLString = [NSString simplePostDetailHTMLStringWithTitle:postDetail.title
                                                                                    date:postDetail.createTime
                                                                                authorId:authorId
                                                                                  author:author
                                                                              postTypeId:postDetail.postTypeId
                                                                                postType:postDetail.postType
                                                                                postAttr:postDetail.postAttr
                                                                                  module:postDetail.module
                                                                          customFontSize:CMTAPPCONFIG.customFontSize];
    // 验证HTMLString
    if (!BEMPTY(simplePostDetailHTMLString)) {
        // 刷新简单文章详情
        self.postDetail = postDetail;
        [self.webView loadHTMLString:simplePostDetailHTMLString
                             baseURL:[[NSBundle mainBundle] URLForResource:CMTNSStringHTMLTemplate_fileName
                                                             withExtension:CMTNSStringHTMLTemplate_fileType]];
    }
    else {
        CMTLogError(@"PostDetailCommentHeader Replace HTMLString With PostDetail Error: Empty HTMLString");
    }
}

- (void)reloadHeaderWithSimplePostDetail:(CMTPostStatistics *)simplePostDetail {
    if (self.simplePostDetail == simplePostDetail) {
        return;
    }
    
    NSString *authorId = !simplePostDetail.module.isPostModuleGuide ? simplePostDetail.authorId : nil;
    NSString *author = !simplePostDetail.module.isPostModuleGuide ? simplePostDetail.author : simplePostDetail.issuingAgency;
    
    NSString *simplePostDetailHTMLString = [NSString simplePostDetailHTMLStringWithTitle:simplePostDetail.title
                                                                                    date:simplePostDetail.createTime
                                                                                authorId:authorId
                                                                                  author:author
                                                                              postTypeId:simplePostDetail.postTypeId
                                                                                postType:simplePostDetail.postType
                                                                                postAttr:simplePostDetail.postAttr
                                                                                  module:simplePostDetail.module
                                                                          customFontSize:CMTAPPCONFIG.customFontSize];
    // 验证HTMLString
    if (!BEMPTY(simplePostDetailHTMLString)) {
        // 刷新简单文章详情
        self.simplePostDetail = simplePostDetail;
        [self.webView loadHTMLString:simplePostDetailHTMLString
                             baseURL:[[NSBundle mainBundle] URLForResource:CMTNSStringHTMLTemplate_fileName
                                                             withExtension:CMTNSStringHTMLTemplate_fileType]];
    }
    else {
        CMTLogError(@"PostDetailCommentHeader Replace HTMLString With Simple PostDetail Error: Empty HTMLString");
    }
}

- (void)hideTapToRefresh {
    if (self.tapToRefresh.hidden == YES) {
        return;
    }
    
    // 隐藏tapToRefresh
    self.tapToRefresh.hidden = YES;
    
    self.frame = CGRectMake(0.0, 0.0, self.width, self.webView.height);
    
    // 回调高度
    if (self.updateHeaderHeight != nil) {
        self.updateHeaderHeight(self.webView.height);
    }
}

#pragma mark WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    @try {
        NSString *URLString = request.URL.absoluteString;
        
#pragma mark 显示文章详情
        
        if ([URLString rangeOfString:[NSString stringWithFormat:@"%@.%@", CMTNSStringHTMLTemplate_fileName, CMTNSStringHTMLTemplate_fileType]
                             options:NSCaseInsensitiveSearch].length > 0) {
            
            return YES;
        }
        
#pragma mark 点击其他
        
        else {
            // 回调简单文章详情点击链接
            if (self.shouldStartLoadWithRequest != nil) {
                self.shouldStartLoadWithRequest(request);
            }
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetailCommentHeader Analyze WebView Request Exception: %@", exception);
    }
    
    return NO;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // 计算高度
    
    CGFloat webViewHeight = 0.0;
    
    CGFloat topMargin = 35.0;
    
    CGFloat titleHeight = 0.0;
    CGFloat titleLineGapAddition = 4.3;
    NSInteger titleLineNumber = 0;
    CGFloat titleHeightAddition = 0.0;
    
    CGFloat titleGap = 14.0;
    CGFloat subTitleHeight = 12.0;
    CGFloat bottomMargin = 27.0;
    
    CGFloat leftMargin = 16.0;
    
    // titleHeight
    NSString *title = nil;
    if (self.postDetail != nil) {
        title = self.postDetail.title;
    }
    else if (self.simplePostDetail != nil) {
        title = self.simplePostDetail.title;
    }
    if (!BEMPTY(title)) {
        CGSize titleSize = [title boundingRectWithSize:CGSizeMake(self.width - (leftMargin*2.0), CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                       attributes:@{
                                                    NSFontAttributeName:FONT(22.0),
                                                    }
                                          context:nil].size;
        
        titleLineNumber = titleSize.height / 26.0;
        titleHeightAddition = titleLineNumber * titleLineGapAddition;
        titleHeight = titleSize.height + titleHeightAddition;
    }
    
    // webViewHeight
    if (titleHeight > 0.0) {
        webViewHeight = topMargin + titleHeight + titleGap + subTitleHeight + bottomMargin;
    }
    else {
        webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"wrapper\").offsetHeight"] floatValue];
    }
    
    // headerHeight
    CGFloat headerHeight = webViewHeight + (self.tapToRefresh.visible ? CMTTapToRefreshDefaultHeight : 0.0);
    
    // 刷新视图
    self.webView.frame = CGRectMake(0.0, 0.0, self.width, webViewHeight);
    self.tapToRefresh.frame = CGRectMake(0, webViewHeight, self.width, CMTTapToRefreshDefaultHeight);
    self.frame = CGRectMake(0.0, 0.0, self.width, headerHeight);
    
    // 回调高度
    if (self.updateHeaderHeight != nil) {
        self.updateHeaderHeight(headerHeight);
    }
}

@end
