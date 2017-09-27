//
//  CMTLaunchViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/4/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLaunchViewController.h"

static const CGFloat CMTLaunchViewDeclarationTopGuide = 118.0;
static const CGFloat CMTLaunchViewDeclarationSmileImageCoverGap = 18.0;

@interface CMTLaunchViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;             // 背景图
@property (nonatomic, strong) UIImageView *logoImageView;                   // logo图
@property (nonatomic, strong) UIImageView *declarationImageView;            // 说明文字图
@property (nonatomic, strong) UIImageView *declarationSmileImageView;       // 说明文字笑脸图
@property (nonatomic, strong) UIView *declarationSmileImageCoverView;       // 说明文字笑脸图遮罩

@end

@implementation CMTLaunchViewController

#pragma mark Initializers

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] init];
        [_backgroundImageView fillinContainer:self.view WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        _backgroundImageView.backgroundColor = COLOR(c_f6f6f6);
        
        // 系统小于8.0 使用启动图片 背景图片与启动图片相同
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            // 3.5吋
            if (SCREEN_MODEL) {
                _backgroundImageView.image = IMAGE(@"LaunchImage-700");
            }
            else {
                _backgroundImageView.image = IMAGE(@"LaunchImage-700-568h");
            }
        }
        // 8.0以上系统 使用LaunchScreen 背景图片与LaunchScreen背景图片相同
        else {
            _backgroundImageView.image = IMAGE(@"launch_background");
        }
    }
    
    return _backgroundImageView;
}

- (UIImageView *)logoImageView {
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView builtinContainer:self.view WithLeft:0.0 Top:183.0 Width:85.0 Height:41.0];
        _logoImageView.centerX = self.view.centerX;
        _logoImageView.backgroundColor = COLOR(c_clear);
        _logoImageView.image = IMAGE(@"launch_Logo");
    }
    
    return _logoImageView;
}

- (UIImageView *)declarationImageView {
    if (_declarationImageView == nil) {
        _declarationImageView = [[UIImageView alloc] init];
        [_declarationImageView builtinContainer:self.view WithLeft:0.0 Top:self.view.height - CMTLaunchViewDeclarationTopGuide Width:251.5 Height:45.0];
        _declarationImageView.centerX = self.view.centerX;
        _declarationImageView.backgroundColor = COLOR(c_clear);
        _declarationImageView.image = IMAGE(@"launch_declaration");
    }
    
    return _declarationImageView;
}

- (UIImageView *)declarationSmileImageView {
    if (_declarationSmileImageView == nil) {
        _declarationSmileImageView = [[UIImageView alloc] init];
        [_declarationSmileImageView builtinContainer:self.view WithLeft:0.0 Top:0.0 Width:0.0 Height:0.0];
        _declarationSmileImageView.frame = self.declarationImageView.frame;
        _declarationSmileImageView.backgroundColor = COLOR(c_clear);
        _declarationSmileImageView.image = IMAGE(@"launch_declaration_smile");
    }
    
    return _declarationSmileImageView;
}

- (UIView *)declarationSmileImageCoverView {
    if (_declarationSmileImageCoverView == nil) {
        _declarationSmileImageCoverView = [[UIView alloc] init];
        CGFloat width = self.declarationSmileImageView.width;
        CGFloat height = self.declarationSmileImageView.height;
        [_declarationSmileImageCoverView builtinContainer:self.view WithLeft:0.0 Top:self.declarationSmileImageView.top + CMTLaunchViewDeclarationSmileImageCoverGap Width:width Height:height];
        _declarationSmileImageCoverView.centerX = self.declarationSmileImageView.centerX;
        _declarationSmileImageCoverView.backgroundColor = COLOR(c_f6f6f6);
    }
    
    return _declarationSmileImageCoverView;
}

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"LaunchView willDeallocSignal");
    }];
    
    self.view.backgroundColor = COLOR(c_f6f6f6);
    
    // 背景图
    self.backgroundImageView.alpha = 1.0;
    
    // 系统小于8.0 使用启动图片 不添加logo图
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        self.logoImageView.hidden = YES;
    }
    // 8.0以上系统 使用LaunchScreen 添加logo图
    else {
        self.logoImageView.hidden = NO;
    }
    
    // 说明文字图 初始隐藏
    self.declarationImageView.alpha = 0.0;
    
    // 说明文字笑脸图 初始隐藏
    self.declarationSmileImageView.alpha = 0.0;
    
    // 说明文字笑脸图遮罩 初始隐藏
    self.declarationSmileImageCoverView.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self animationStepOne];
}

- (void)animationStepOne {
    // 设置动画初始位置
    self.declarationImageView.top = self.view.height * 2.0;
    self.declarationImageView.alpha = 1.0;
    UIViewAnimationOptions keyboardAnimationCurve = 7;
    keyboardAnimationCurve |= keyboardAnimationCurve<<16;
    [UIView animateWithDuration:1.2 delay:0.0 options:keyboardAnimationCurve animations:^{
        self.declarationImageView.top = self.view.height - CMTLaunchViewDeclarationTopGuide;
    } completion:^(BOOL finished) {
        self.declarationSmileImageView.alpha = 1.0;
        self.declarationSmileImageCoverView.alpha = 1.0;
        [self animationStepTwo];
    }];
}

- (void)animationStepTwo {
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.declarationSmileImageCoverView.left = self.declarationSmileImageView.left + self.declarationSmileImageView.width;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(hideLaunchView) withObject:nil afterDelay:0.7];
        });
    }];
}

- (void)hideLaunchView {
      CMTAPPCONFIG.IsStartWebDisappear=@"1";
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (APPDELEGATE.introWindow != nil) {
            [APPDELEGATE.introWindow makeKeyAndVisible];
        }
        else if (APPDELEGATE.subscriptionGuideWindow != nil) {
            [APPDELEGATE.subscriptionGuideWindow makeKeyAndVisible];
        }
        else {
            [APPDELEGATE.window makeKeyAndVisible];
        }
        
        APPDELEGATE.launchWindow = nil;
    }];
}


@end
