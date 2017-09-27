//
//  CMTIntroViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/3/13.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTIntroViewController.h"
#import "CMTIntroPage.h"

@interface CMTIntroViewController ()<StartAction>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation CMTIntroViewController

#pragma mark Initializers

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//        _scrollView.backgroundColor = COLOR(c_53ae93);
        _scrollView.backgroundColor = COLOR(c_ffffff);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_scrollView];
    }
    
    return _scrollView;
}

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"IntroView willDeallocSignal");
    }];
    
    self.view.backgroundColor = COLOR(c_clear);
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    //此次迭代只要一张引导图，所以只添加了一张图片
    CMTIntroPage *page1 = [CMTIntroPage pageWithFrame:self.view.bounds
                                    title:nil
                                     descriptionImage:IMAGE(@"introPageDescription")
                                           indexImage:IMAGE(@"nil")
                                    actionButtonTitle:@"立即开启"];
    [self.scrollView addSubview:page1];
    self.scrollView.contentSize = CGSizeMake(self.view.width, self.view.bounds.size.height);
    
    page1.startActionDelegate = self;
    @weakify(self);
    [[page1.actionButtonSignal deliverOn:[RACScheduler mainThreadScheduler]]   subscribeNext:^(id x) {
        @strongify(self);
        [self onStartAction];
    } error:^(NSError *error) {
        
    }];
}

- (void)onStartAction{
            // 切换动画
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.view.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (APPDELEGATE.subscriptionGuideWindow != nil) {
                    [APPDELEGATE.subscriptionGuideWindow makeKeyAndVisible];
                }
                else {
                    [APPDELEGATE.window makeKeyAndVisible];
                }
    
                APPDELEGATE.introWindow = nil;
            }];
            CMTAPPCONFIG.IsStartedGuidePage=YES;
            APPDELEGATE.tabBarController.selectedIndex=2;
            // 记录当前版本
            CMTAPPCONFIG.recordedVersion = APP_VERSION;
    
            // 之前版本有订阅缓存的用户此版本标记为点击过强制订阅的确定按钮 以此作为强制订阅的第一次启动记录
            if (CMTAPPCONFIG.subscriptionCached == YES) {
                // 记录强制订阅版本
                CMTAPPCONFIG.subscriptionRecordedVersion = APP_VERSION;
            }

}

#pragma mark StatusBar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
