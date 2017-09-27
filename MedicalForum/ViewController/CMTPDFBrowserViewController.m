//
//  CMTPDFBrowserViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/4/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// controller
#import "CMTPDFBrowserViewController.h"         // header file
#import "CMTWebBrowserViewController.h"         // 网页浏览器

/// PDF浏览器状态
typedef NS_OPTIONS(NSUInteger, CMTPDFBrowserStatus) {
    CMTPDFBrowserStatusDefault = 0,
    CMTPDFBrowserStatusLoading,             // 正在打开
    CMTPDFBrowserStatusDisplay,             // 显示PDF
    CMTPDFBrowserStatusReConnect,           // 重新连接(不清缓存 继续下载)
    CMTPDFBrowserStatusReload,              // 重新加载(清除缓存 从头下载)
};

@interface CMTPDFBrowserViewController ()

// view
@property (nonatomic, strong) UIWebView *webView;                           // PDF显示视图
@property (nonatomic, strong) UIView *loadingView;                          // 正在打开视图
@property (nonatomic, strong) UIImageView *loadingAnimationView;            // 正在打开动画
@property (nonatomic, strong) UILabel *progressLabel;                       // 下载进度提示
@property (nonatomic, strong) UIImageView *PDFIcon;                         // PDFIcon
@property (nonatomic, strong) UILabel *PDFNameLabel;                        // PDF文件名提示

// data
@property (nonatomic, copy) void (^updatePDFStatus)(CMTPDFFileStatus);      // 更新PDF文件状态
@property (nonatomic, assign) CMTPDFBrowserStatus browserStatus;            // 浏览器状态
@property (nonatomic, assign) BOOL blockClear;                              // 阻止清除webView代理

@property (nonatomic, copy) NSString *PDFURL;                               // PDFURL
@property (nonatomic, copy) NSString *PDFSize;                              // PDF文件大小(字节)
@property (nonatomic, copy) NSString *PDFID;                                // PDFID

@property (nonatomic, copy) NSString *PDFDirectoryPath;                     // PDF文件夹路径
@property (nonatomic, copy) NSString *PDFPath;                              // PDF文件路径
@property (nonatomic, copy) NSString *tempPDFPath;                          // PDF临时文件路径
@property (nonatomic, copy) NSString *PDFName;                              // PDF文件名

@property (nonatomic, strong) NSURLSessionDownloadTask *requestOperation;     // 请求operation

@end

@implementation CMTPDFBrowserViewController

#pragma mark Initializers

- (instancetype)initWithPDFURL:(NSString *)PDFURL
                       PDFSize:(NSString *)PDFSize
                         PDFID:(NSString *)PDFID
               updatePDFStatus:(void (^)(CMTPDFFileStatus))updatePDFStatus {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.browserStatus = CMTPDFBrowserStatusDefault;
    self.blockClear = NO;
    
    self.PDFURL = PDFURL;
    self.PDFSize = PDFSize;
    self.PDFID = PDFID;
    self.updatePDFStatus = updatePDFStatus;
    
    // 检查PDF文件缓存状态
    [self checkPDFFile];
    
    return self;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [UIWebView new];
        _webView.backgroundColor = COLOR(c_fafafa);
        _webView.scrollView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
    }
    
    return _webView;
}

- (UIView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [UIView new];
        _loadingView.backgroundColor = COLOR(c_ffffff);
    }
    
    return _loadingView;
}

- (UIImageView *)loadingAnimationView {
    if (_loadingAnimationView == nil) {
        _loadingAnimationView = [UIImageView new];
        _loadingAnimationView.backgroundColor = COLOR(c_clear);
        _loadingAnimationView.image = IMAGE(@"PDF_loading_1");
        NSMutableArray *images = [NSMutableArray array];
        for (int index = 1; index <= 16; index++) {
            NSString *imageName = [NSString stringWithFormat:@"PDF_loading_%d", index];
            [images addObject:IMAGE(imageName)];
        }
        _loadingAnimationView.animationImages = images;
        _loadingAnimationView.animationDuration = 1.66;
        _loadingAnimationView.animationRepeatCount = 0;
    }
    
    return _loadingAnimationView;
}

- (UILabel *)progressLabel {
    if (_progressLabel == nil) {
        _progressLabel = [UILabel new];
        _progressLabel.backgroundColor = COLOR(c_clear);
        _progressLabel.textColor = COLOR(c_ababab);
        _progressLabel.font = FONT(16.0);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _progressLabel;
}

- (UIImageView *)PDFIcon {
    if (_PDFIcon == nil) {
        _PDFIcon = [UIImageView new];
        _PDFIcon.backgroundColor = COLOR(c_clear);
        _PDFIcon.image = IMAGE(@"PDF_icon");
    }
    
    return _PDFIcon;
}

- (UILabel *)PDFNameLabel {
    if (_PDFNameLabel == nil) {
        _PDFNameLabel = [UILabel new];
        _PDFNameLabel.backgroundColor = COLOR(c_clear);
        _PDFNameLabel.textColor = COLOR(c_424242);
        _PDFNameLabel.font = FONT(14.0);
        _PDFNameLabel.numberOfLines = 2.0;
    }
    
    return _PDFNameLabel;
}

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PDFBrowser willDeallocSignal");
    }];
    self.navigationItem.leftBarButtonItems=self.customleftItems;
    // PDF显示视图
    [self.webView fillinContainer:self.contentBaseView WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
    
    // 正在打开视图
    [self.loadingView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0.0 Bottom:0.0 Right:0.0];
    
    // 配置布局
    [self performLayout];
}

// 配置布局
- (void)performLayout {
    
    // 下载进度提示
    [self.progressLabel builtinContainer:self.loadingView WithLeft:0.0 Top:self.loadingView.height/2.0 + 27.0*RATIO Width:self.loadingView.width Height:15.0];
    
    // 正在打开动画
    [self.loadingAnimationView builtinContainer:self.loadingView WithLeft:0.0 Top:self.progressLabel.top - 35.5*RATIO - 118.0 Width:123.0 Height:118.0];
    self.loadingAnimationView.centerX = self.loadingView.width/2.0;
    
    // PDFicon
    [self.PDFIcon builtinContainer:self.loadingView WithLeft:21.0*RATIO Top:self.progressLabel.bottom + 15.5*RATIO Width:self.PDFIcon.image.size.width Height:self.PDFIcon.image.size.height];
    
    // PDF文件名提示
    CGFloat PDFNameLabelLeft = self.PDFIcon.right + 6.5*RATIO;
    CGFloat PDFNameLabelWidth = self.loadingView.width - PDFNameLabelLeft - 27.0*RATIO;
    CGSize PDFNameLabelSize = [self.PDFName boundingRectWithSize:CGSizeMake(PDFNameLabelWidth, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                      attributes:@{NSFontAttributeName:self.PDFNameLabel.font}
                                                         context:nil].size;
    CGFloat PDFNameLabelHeight = ceil(PDFNameLabelSize.height);
    if (PDFNameLabelHeight > 17.0) {
        [self.PDFNameLabel builtinContainer:self.loadingView WithLeft:PDFNameLabelLeft Top:self.PDFIcon.top Width:PDFNameLabelWidth Height:34.0];
    }
    else {
        [self.PDFNameLabel builtinContainer:self.loadingView WithLeft:PDFNameLabelLeft Top:self.PDFIcon.top + 2.5*RATIO Width:PDFNameLabelWidth Height:17.0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
    self.blockClear = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CMTLog(@"%s", __FUNCTION__);
    
    if (self.blockClear == NO) {
        [self.webView stopLoading];
        self.webView.delegate = nil;
    }
    
    if (self.requestOperation.state != 3) {
        [self.requestOperation cancel];
    }
}

#pragma mark 点击返回

- (void)popViewController {
    
    // PDF没有加载完
    if (self.browserStatus != CMTPDFBrowserStatusDisplay) {
        @weakify(self);
        
        // 暂停PDF文件请求
        if (self.requestOperation.state !=1) {
            [self.requestOperation cancel];
        }
        // 停止正在打开动画
        [self.loadingAnimationView stopAnimating];
        
        // PDF文件请求未完成 弹窗提示
        NSString *alertMessage = @"下载过程正在进行，是否保留未完成的PDF文件，方便继续下载？";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:nil cancelButtonTitle:@"放弃" otherButtonTitles:@"保留", nil];
        [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            // 放弃PDF临时文件
            if (index.integerValue == 0) {
                // 删除PDF临时文件
                [self clearTempPDFFile];
                if (self.browserStatus != CMTPDFBrowserStatusDisplay) {
                    // 刷新PDF状态 无缓存
                    [self refreshPDFStatus:CMTPDFFileStatusEmpty];
                }
            }
            // 返回
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertView show];
    }
    // PDF加载完成
    else {
        // 返回
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Browser Status

// 设置浏览器状态
- (void)setBrowserStatus:(CMTPDFBrowserStatus)browserStatus {
    if (_browserStatus == browserStatus) return;
    
    _browserStatus = browserStatus;
    
    switch (browserStatus) {
        case CMTPDFBrowserStatusLoading: {
            // 刷新页面状态 正常
            self.contentState = CMTContentStateNormal;
            // 显示正在打开视图
            self.loadingView.hidden = NO;
            // 刷新标题 正在打开
            self.titleText = @"正在打开...";
            // 刷新PDF文件名提示
            self.PDFNameLabel.text = self.PDFName;
            // 开始正在打开动画
            [self.loadingAnimationView startAnimating];
            // 刷新PDF状态 下载中
            [self refreshPDFStatus:CMTPDFFileStatusDownloading];
        }
            break;
        case CMTPDFBrowserStatusDisplay: {
            // 刷新页面状态 正常
            self.contentState = CMTContentStateNormal;
            // 隐藏正在打开视图
            self.loadingView.hidden = YES;
            // 刷新标题 文件名
            self.titleText = self.PDFName;
            // 停止正在打开动画
            [self.loadingAnimationView stopAnimating];
            // 刷新PDF状态 已缓存
            [self refreshPDFStatus:CMTPDFFileStatusCached];
        }
            break;
        case CMTPDFBrowserStatusReConnect: {
            // 刷新页面状态 重新加载
            self.contentState = CMTContentStateReload;
            // 显示正在打开视图
            self.loadingView.hidden = NO;
            // 刷新标题 空
            self.titleText = nil;
            // 停止正在打开动画
            [self.loadingAnimationView stopAnimating];
            // 刷新PDF状态 下载中
            [self refreshPDFStatus:CMTPDFFileStatusDownloading];
        }
            break;
        case CMTPDFBrowserStatusReload: {
            // 刷新页面状态 重新加载
            self.contentState = CMTContentStateReload;
            // 显示正在打开视图
            self.loadingView.hidden = NO;
            // 刷新标题 空
            self.titleText = nil;
            // 停止正在打开动画
            [self.loadingAnimationView stopAnimating];
            // 刷新PDF状态 无缓存
            [self refreshPDFStatus:CMTPDFFileStatusEmpty];
        }
            break;
            
        default:
            break;
    }
}

// 刷新PDF文件状态
- (void)refreshPDFStatus:(CMTPDFFileStatus)PDFStatus {
    if (self.updatePDFStatus != nil) {
        self.updatePDFStatus(PDFStatus);
    }
}

#pragma mark Reload

// 点击重新加载
- (void)animationFlash {
    [super animationFlash];
    CMTLog(@"%s", __FUNCTION__);
    
    // 下载PDF文件
    [self downloadPDFFile];
}

#pragma mark Progress

// 更新下载进度
- (void)updateDownloadTProgress:(NSProgress*)progress {
       CGFloat fileSizeMB = (CGFloat)self.PDFSize.longLongValue/(1024*1024);
        CGFloat progressf = (CGFloat)progress.completedUnitCount/(CGFloat)(progress.totalUnitCount+1);
        self.progressLabel.text = [NSString stringWithFormat:@"%.2fM/%.2fM", progressf*fileSizeMB, fileSizeMB];
    NSLog(@"%lld  %lld",progress.totalUnitCount,progress.completedUnitCount);
    
}
// 更新下载进度
-(void)updateDownloadProgress:(float)progress {
    CGFloat fileSizeMB = (CGFloat)self.PDFSize.longLongValue/(1024*1024);
    self.progressLabel.text = [NSString stringWithFormat:@"%.2fM/%.2fM", progress*fileSizeMB, fileSizeMB];
}

#pragma mark PDF File Manage

+ (CMTPDFFileStatus)checkPDFFileStatusWithPDFURL:(NSString *)PDFURL {
    
    // 准备路径: PDF文件夹 PDF文件 PDF临时文件
    NSString *path = [[NSURL URLWithString:PDFURL] path];
    NSString *PDFDirectoryPath = [PATH_PDF stringByAppendingPathComponent:path.stringByDeletingLastPathComponent.lastPathComponent];
    NSString *PDFPath = [PDFDirectoryPath stringByAppendingPathComponent:path.lastPathComponent];
    NSString *tempPDFPath = [PDFPath.stringByDeletingPathExtension stringByAppendingString:@".tmp"];
    
    // PDF文件已存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:PDFPath]) {
        return CMTPDFFileStatusCached;
    }
    // PDF文件不存在
    else if ([[NSFileManager defaultManager] fileExistsAtPath:tempPDFPath]) {
        return CMTPDFFileStatusDownloading;
    }
    else {
        return CMTPDFFileStatusEmpty;
    }
}

// 检查PDF文件缓存状态
- (void)checkPDFFile {
    
    // 准备路径
    NSString *path = [[NSURL URLWithString:self.PDFURL] path];
    
    // PDF文件夹 PDF文件 PDF临时文件路径 PDF文件名
    self.PDFDirectoryPath = [PATH_PDF stringByAppendingPathComponent:path.stringByDeletingLastPathComponent.lastPathComponent];
    self.PDFPath = [self.PDFDirectoryPath stringByAppendingPathComponent:path.lastPathComponent];
    self.tempPDFPath = [self.PDFPath.stringByDeletingPathExtension stringByAppendingString:@".tmp"];
    self.PDFName = path.lastPathComponent;
    
    // PDF文件已存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.PDFPath]) {
        // 打开PDF文件
        [self openPDFFile];
    }
    // PDF文件不存在
    else {
        // PDF文件夹不存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.PDFDirectoryPath]) {
            // 创建PDF文件夹
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:self.PDFDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error != nil) {
                CMTLogError(@"PDFBrowser Create Directory at Path: %@\nError: %@", self.PDFDirectoryPath, error);
            }
        }
        // 下载PDF文件
        [self downloadPDFFile];
    }
}

// 下载PDF文件
- (void)downloadPDFFile {
    
    // 刷新下载进度提示
    
    // 刷新浏览器状态 正在打开
    self.browserStatus = CMTPDFBrowserStatusLoading;
    
    // 继续下载PDF文件
    [self continueDownloadPDFFile];
}

// 继续下载PDF文件
- (void)continueDownloadPDFFile {
    @weakify(self);
    
    // 准备续传断点
    long long CMTPDFRequestRangeBegin = 0;
    
    // PDF临时文件存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.tempPDFPath]) {
        CMTPDFRequestRangeBegin = [[NSFileManager defaultManager] fileSizeOfItemAtPath:self.tempPDFPath];
    }
    
    // PDF临时文件大小与PDF文件大小相同
    if (CMTPDFRequestRangeBegin == self.PDFSize.longLongValue) {
        // 显示PDF文件
        [self displayPDFFile];
        return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSMutableURLRequest *PDFRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.PDFURL]];
    self.requestOperation=[manager downloadTaskWithRequest:PDFRequest progress:^(NSProgress * _Nonnull downloadProgress) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @strongify(self)
//            [self updateDownloadTProgress:downloadProgress];
//        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:self.tempPDFPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        @strongify(self)
        [self displayPDFFile];
    }];
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"setDownloadTaskDidWriteDataBlock: %lld %lld %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self updateDownloadProgress:(float)totalBytesWritten/totalBytesExpectedToWrite];
        });

    }];
    [self.requestOperation resume];
}
// 显示PDF文件
- (void)displayPDFFile {
    
    // 转换PDF文件
    if ([self convertPDFFile] == YES) {
        // 打开PDF文件
        [self openPDFFile];
    }
    else {
        // 重新加载PDF文件
        [self reloadPDFFile];
    }
}

// 打开PDF文件
- (void)openPDFFile {
    
    // 加载PDF文件
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.PDFPath]]];
}

// 转换PDF文件
- (BOOL)convertPDFFile {
    BOOL success = YES;
    
    // 创建PDF文件
    NSError *copyError = nil;
    [[NSFileManager defaultManager] copyItemAtPath:self.tempPDFPath toPath:self.PDFPath error:&copyError];
    if (copyError != nil) {
        CMTLogError(@"Create PDF File Error: %@", copyError);
        success = NO;
    }
    
    // 删除PDF临时文件
    NSError *removeError = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.tempPDFPath error:&removeError];
    if (removeError != nil) {
        CMTLogError(@"Remove Temp PDF File Error: %@", removeError);
    }
    
    return success;
}

// 重新加载PDF文件
- (void)reloadPDFFile {
    @weakify(self);
    
    // 删除缓存文件
    [self clearPDFFile];
    // 刷新浏览器状态 重新加载
    [[RACScheduler mainThreadScheduler] schedule:^{
        @strongify(self);
        self.browserStatus = CMTPDFBrowserStatusReload;
    }];
}

// 删除PDF临时文件
- (void)clearTempPDFFile {
    
    // 删除PDF临时文件
    NSError *removeTempPDFFileError = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.tempPDFPath error:&removeTempPDFFileError];
    if (removeTempPDFFileError != nil) {
        CMTLogError(@"Remove Temp PDF File Error: %@", removeTempPDFFileError);
    }
}

// 删除缓存PDF文件 PDF临时文件
- (void)clearPDFFile {
    
    // 删除PDF文件
    NSError *removePDFFileError = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.PDFPath error:&removePDFFileError];
    if (removePDFFileError != nil) {
        CMTLogError(@"Remove PDF File Error: %@", removePDFFileError);
    }
    
    // 删除PDF临时文件
    [self clearTempPDFFile];
}

#pragma mark WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.webView == nil) {
        return NO;
    }
    
    NSURL *URL = request.URL;
    NSString *URLScheme = URL.scheme;
    
    // scheme: file
    if ([URLScheme rangeOfString:CMTNSStringHTMLScheme_FILE
                         options:NSCaseInsensitiveSearch].length > 0) {
        
#pragma mark 显示PDF文件 PDF页面跳转
        if ([URL.pathExtension rangeOfString:@"pdf"
                                     options:NSCaseInsensitiveSearch].length > 0) {
            
            return YES;
        }
    }
    
    // other scheme
    else {
        
#pragma mark 点击其他链接
        CMTWebBrowserViewController *webBrowserViewController = [[CMTWebBrowserViewController alloc] initWithURL:URL.absoluteString];
        [self.navigationController pushViewController:webBrowserViewController animated:YES];
        self.blockClear = YES;
    }
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CMTLog(@"webView finish load");
    
    // self.webView只加载PDF文件 其他链接用网页浏览器加载
    // 第一次加载PDF文件成功 调用此方法
    // 不会再次加载PDF文件
    // PDF页面跳转不会调用此方法
    
    // 刷新浏览器状态 显示PDF
    self.browserStatus = CMTPDFBrowserStatusDisplay;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    CMTLog(@"webView fail load");
    
    // 重新加载PDF文件
    [self reloadPDFFile];
}

@end
