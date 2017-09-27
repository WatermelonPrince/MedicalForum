//
//  CMTCustomFontSizeViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/3/23.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCustomFontSizeViewController.h"

static NSString * const CMTCustomFontSizeHTMLTemplateName = @"adjusttextsizebasic";
static NSString * const CMTCustomFontSizeHTMLContentName = @"adjusttextsizecontent";
static NSString * const CMTCustomFontSizeHTMLTemplateType = @"html";

static NSString * const CMTCustomFontSizeHTMLFontSizeLarge = @"125";
static NSString * const CMTCustomFontSizeHTMLFontSizeMiddle = @"100";
static NSString * const CMTCustomFontSizeHTMLFontSizeSmall = @"80";

@interface CMTCustomFontSizeViewController ()

// view
@property (nonatomic, strong) UIWebView *webView;               // 文章详情
@property (nonatomic, strong) UIView *toolBar;                  // 工具栏
@property (nonatomic, strong) UIButton *largeSizeButton;        // 大号按钮
@property (nonatomic, strong) UIButton *middleSizeButton;       // 中号按钮
@property (nonatomic, strong) UIButton *smallSizeButton;        // 小号按钮

// data
@property (nonatomic, assign) NSInteger curSelectedButtonTag;
@property (nonatomic, strong) NSString *htmlString;

@end

@implementation CMTCustomFontSizeViewController

#pragma mark Initializers

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
        [_webView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0 Bottom:60.0 Right:0];
        _webView.backgroundColor = COLOR(c_ffffff);
    }
    
    return _webView;
}

- (UIView *)toolBar {
    if (_toolBar == nil) {
        _toolBar = [[UIView alloc] init];
        [_toolBar sizeToFillinContainer:self.contentBaseView WithTop:self.webView.bottom Left:0 Bottom:0 Right:0];
        _toolBar.backgroundColor = COLOR(c_f5f5f5);
        
        [_toolBar addSubview:self.largeSizeButton];
        [_toolBar addSubview:self.middleSizeButton];
        [_toolBar addSubview:self.smallSizeButton];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _toolBar.width, PIXEL)];
        topLine.backgroundColor = COLOR(c_9e9e9e);
        [_toolBar addSubview:topLine];
        
        UIView *middleLeftLine = [[UIView alloc] initWithFrame:CGRectMake(self.largeSizeButton.right, PIXEL, PIXEL, _toolBar.height)];
        middleLeftLine.backgroundColor = COLOR(c_9e9e9e);
        [_toolBar addSubview:middleLeftLine];
        
        UIView *middleRightLine = [[UIView alloc] initWithFrame:CGRectMake(self.middleSizeButton.right, PIXEL, PIXEL, _toolBar.height)];
        middleRightLine.backgroundColor = COLOR(c_9e9e9e);
        [_toolBar addSubview:middleRightLine];
    }
    
    return _toolBar;
}

- (UIButton *)largeSizeButton {
    if (_largeSizeButton == nil) {
        _largeSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_largeSizeButton sizeToBuiltinContainer:self.toolBar WithLeft:0 Top:0 Width:self.toolBar.width / 3.0 Height:self.toolBar.height];
        _largeSizeButton.tag = 1001;
        _largeSizeButton.titleLabel.font = FONT(19.0);
        [_largeSizeButton setTitle:@"大号" forState:UIControlStateNormal];
    }
    
    return _largeSizeButton;
}

- (UIButton *)middleSizeButton {
    if (_middleSizeButton == nil) {
        _middleSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_middleSizeButton sizeToBuiltinContainer:self.toolBar WithLeft:self.largeSizeButton.right Top:0 Width:self.toolBar.width / 3.0 Height:self.toolBar.height];
        _middleSizeButton.tag = 1002;
        _middleSizeButton.titleLabel.font = FONT(14.0);
        [_middleSizeButton setTitle:@"中号" forState:UIControlStateNormal];
    }
    
    return _middleSizeButton;
}

- (UIButton *)smallSizeButton {
    if (_smallSizeButton == nil) {
        _smallSizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_smallSizeButton sizeToBuiltinContainer:self.toolBar WithLeft:self.middleSizeButton.right Top:0 Width:self.toolBar.width / 3.0 Height:self.toolBar.height];
        _smallSizeButton.tag = 1003;
        _smallSizeButton.titleLabel.font = FONT(10.0);
        [_smallSizeButton setTitle:@"小号" forState:UIControlStateNormal];
    }
    
    return _smallSizeButton;
}

- (NSString *)htmlString {
    if (_htmlString == nil) {
        NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:CMTCustomFontSizeHTMLTemplateName ofType:CMTCustomFontSizeHTMLTemplateType];
        NSString *htmlString = [[NSString alloc] initWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
        
        NSString *contentFilePath = [[NSBundle mainBundle] pathForResource:CMTCustomFontSizeHTMLContentName ofType:CMTCustomFontSizeHTMLTemplateType];
        NSString *contentString = [[NSString alloc] initWithContentsOfFile:contentFilePath encoding:NSUTF8StringEncoding error:nil];
        
        _htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{ARTICLE_CONTENT}" withString:contentString];
    }
    
    return _htmlString;
}

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CustomFontSize willDeallocSignal");
    }];
    [self setContentState:CMTContentStateNormal];
    self.titleText = @"调整字体大小";
    
    // webView
    NSString *customFontSize = CMTAPPCONFIG.customFontSize;
    if (customFontSize == nil) {
        customFontSize = CMTCustomFontSizeHTMLFontSizeMiddle;
    }
    [self reloadWebViewWithFontSize:customFontSize];
    
    // 工具栏
    [self.view addSubview:self.toolBar];
    
    // 按钮
    if ([customFontSize isEqual:CMTCustomFontSizeHTMLFontSizeLarge]) {
        [self selectButtonAtTag:self.largeSizeButton.tag];
    }
    else if ([customFontSize isEqual:CMTCustomFontSizeHTMLFontSizeSmall]) {
        [self selectButtonAtTag:self.smallSizeButton.tag];
    }
    else {
        [self selectButtonAtTag:self.middleSizeButton.tag];
    }

    [[RACSignal merge:@[[self.largeSizeButton rac_signalForControlEvents:UIControlEventTouchUpInside],
                        [self.middleSizeButton rac_signalForControlEvents:UIControlEventTouchUpInside],
                        [self.smallSizeButton rac_signalForControlEvents:UIControlEventTouchUpInside],
                        ]]
     subscribeNext:^(UIButton *button) {
         @strongify(self);
         if (self.curSelectedButtonTag != button.tag) {
             self.curSelectedButtonTag = button.tag;
             // 调整按钮
             [self selectButtonAtTag:button.tag];
             // 刷新
             [self reloadWebViewWithFontSize:CMTAPPCONFIG.customFontSize];
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadWebViewWithFontSize:(NSString *)fontSize {
    NSString *htmlString = [self.htmlString stringByReplacingOccurrencesOfString:@"{CUSTOM_FONTSIZE}" withString:fontSize];
    
    [self.webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] URLForResource:CMTCustomFontSizeHTMLTemplateName withExtension:CMTCustomFontSizeHTMLTemplateType]];
}

- (void)selectButtonAtTag:(NSInteger)tag {
    switch (tag) {
        case 1001: {
            self.largeSizeButton.backgroundColor = COLOR(c_32c7c2);
            [self.largeSizeButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
            [self.largeSizeButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateHighlighted];
            self.middleSizeButton.backgroundColor = COLOR(c_f5f5f5);
            [self.middleSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateNormal];
            [self.middleSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateHighlighted];
            self.smallSizeButton.backgroundColor = COLOR(c_f5f5f5);
            [self.smallSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateNormal];
            [self.smallSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateHighlighted];
            CMTAPPCONFIG.customFontSize = CMTCustomFontSizeHTMLFontSizeLarge;
        }
            break;
        case 1002: {
            self.middleSizeButton.backgroundColor = COLOR(c_32c7c2);
            [self.middleSizeButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
            [self.middleSizeButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateHighlighted];
            self.largeSizeButton.backgroundColor = COLOR(c_f5f5f5);
            [self.largeSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateNormal];
            [self.largeSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateHighlighted];
            self.smallSizeButton.backgroundColor = COLOR(c_f5f5f5);
            [self.smallSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateNormal];
            [self.smallSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateHighlighted];
            CMTAPPCONFIG.customFontSize = CMTCustomFontSizeHTMLFontSizeMiddle;
        }
            break;
        case 1003: {
            self.smallSizeButton.backgroundColor = COLOR(c_32c7c2);
            [self.smallSizeButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
            [self.smallSizeButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateHighlighted];
            self.middleSizeButton.backgroundColor = COLOR(c_f5f5f5);
            [self.middleSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateNormal];
            [self.middleSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateHighlighted];
            self.largeSizeButton.backgroundColor = COLOR(c_f5f5f5);
            [self.largeSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateNormal];
            [self.largeSizeButton setTitleColor:COLOR(c_424242) forState:UIControlStateHighlighted];
            CMTAPPCONFIG.customFontSize = CMTCustomFontSizeHTMLFontSizeSmall;
        }
            break;
            
        default:
            break;
    }
}

@end
