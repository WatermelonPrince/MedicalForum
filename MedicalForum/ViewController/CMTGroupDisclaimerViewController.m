//
//  CMTGroupDisclaimerViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/3/24.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTGroupDisclaimerViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTBindingViewController.h"
#import "CMTGroupTypeChoiceTableViewController.h"

@interface CMTGroupDisclaimerViewController ()<UIWebViewDelegate>
@property (nonatomic, strong)UIWebView *disclaimerWebView;//免责声明WebView;
@property (nonatomic, strong)UIButton *agreenButton;//同意Button;

@end

@implementation CMTGroupDisclaimerViewController
- (UIWebView *)disclaimerWebView{
    if (!_disclaimerWebView) {
        _disclaimerWebView = [[UIWebView alloc]init];
        _disclaimerWebView.frame = CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT - CMTNavigationBarBottomGuide - 100);
        _disclaimerWebView.scrollView.showsVerticalScrollIndicator = NO;
        
        _disclaimerWebView.scrollView.bounces = NO;
        _disclaimerWebView.scrollView.alwaysBounceVertical = NO;
        [_disclaimerWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://page.medtrib.cn/agreement/agreement.html"]]];
        _disclaimerWebView.delegate = self;
       
    }
    return _disclaimerWebView;
}

- (UIButton *)agreenButton{
    if (!_agreenButton) {
        _agreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreenButton.frame = CGRectMake(20, SCREEN_HEIGHT - 80, SCREEN_WIDTH - 40, 50);
        _agreenButton.backgroundColor = ColorWithHexStringIndex(c_1eba9c);
        [_agreenButton setTitle:@"同意" forState:UIControlStateNormal];
        _agreenButton.layer.cornerRadius = 5;
        _agreenButton.layer.masksToBounds = YES;
        [_agreenButton addTarget:self action:@selector(agreenAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreenButton;
}

- (void)agreenAction{
    [MobClick event:@"B_lunBa_ClickGroup"];
    CMTGroupTypeChoiceTableViewController *tabVC = [[CMTGroupTypeChoiceTableViewController alloc]init];
    tabVC.lastVC = self;
    [self.navigationController pushViewController:tabVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"___CMTGroupDisclaimerViewController");
    }];
    [self setContentState:CMTContentStateLoading];
    self.titleText = @"用户使用协议";
    [self.contentBaseView addSubview:self.disclaimerWebView];
    [self.contentBaseView addSubview:self.agreenButton];
}
#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self.disclaimerWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://page.medtrib.cn/agreement/agreement.html"]]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self setContentState:CMTContentStateNormal];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self setContentState:CMTContentStateReload];
    
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
