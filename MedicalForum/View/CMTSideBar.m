//
//  CMTSideBar.m
//  MedicalForum
//
//  Created by fenglei on 15/5/2.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// controller
#import "CMTSideBar.h"                  // header file
#import "CMTNavigationController.h"     // 导航控制器

@interface CMTSideBar ()

// view
@property (nonatomic, strong) UIView *contentView;                          // 内容视图
@property (nonatomic, strong) UIImageView *contentBlurView;                 // 内容背景视图
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;           // 点击手势

@end

@implementation CMTSideBar

#pragma mark Initializers

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil) return nil;
    
    // 侧边栏宽
    self.sideBarWidth = SCREEN_WIDTH * (2.0 / 3.0);
    
    // 从右边出现
    self.showFromRight = NO;
    
    // 动画时间
    self.animationDuration = 0.25;
    
    // 内容背景视图着色
    self.blurTintColor = COLOR(c_f5f5f5f5);
    
    return self;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
    }
    
    return _contentView;
}

- (UIImageView *)contentBlurView {
    if (_contentBlurView == nil) {
        _contentBlurView = [[UIImageView alloc] init];
    }
    
    return _contentBlurView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        _tapGesture.delegate = self;
    }
    
    return _tapGesture;
}

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"SideBar willDeallocSignal");
    }];
    
    self.view.backgroundColor = COLOR(c_clear);
    
    // 内容视图
    [self.view addSubview:self.contentView];
    self.contentView.backgroundColor = COLOR(c_clear);
    
    // 内容背景视图
    [self.view addSubview:self.contentBlurView];
    self.contentBlurView.backgroundColor = COLOR(c_clear);
    
    [self.view insertSubview:self.contentBlurView belowSubview:self.contentView];
    
    // 点击手势
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show

- (void)showAnimated:(BOOL)animated {
    
    // 侧边栏 将要出现
    if ([self.delegate respondsToSelector:@selector(sidebar:willShowAnimated:)]) {
        [self.delegate sidebar:self willShowAnimated:animated];
    }
    
    // 准备内容背景视图图片
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIImage *blurImage = [keyWindow screenshot];
    blurImage = [blurImage applyBlurWithRadius:5.0 tintColor:self.blurTintColor saturationDeltaFactor:1.8 maskImage:nil];
    
    // 添加到window
    [APPDELEGATE.window addSubview:self.view];
    
    // 内容视图 初始位置
    CGRect contentFrame = self.view.bounds;
    contentFrame.origin.x = self.showFromRight ? self.view.width : (-self.sideBarWidth);
    contentFrame.size.width = self.sideBarWidth;
    self.contentView.frame = contentFrame;
    
    // 内容视图 最终位置
    contentFrame.origin.x = self.showFromRight ? self.view.width - self.sideBarWidth : 0.0;
    
    // 内容背景视图 初始位置
    CGRect blurFrame = self.view.bounds;
    blurFrame.origin.x = self.showFromRight ? self.view.width : 0.0;
    blurFrame.size.width = 0.0;
    self.contentBlurView.frame = blurFrame;
    self.contentBlurView.image = blurImage;
    self.contentBlurView.contentMode = self.showFromRight ? UIViewContentModeTopRight : UIViewContentModeTopLeft;
    self.contentBlurView.clipsToBounds = YES;
    
    // 内容背景视图 最终位置
    blurFrame.origin.x = contentFrame.origin.x;
    blurFrame.size.width = self.sideBarWidth;
    
    // 出现动画
    void (^animations)() = ^{
        self.contentView.frame = contentFrame;
        self.contentBlurView.frame = blurFrame;
        self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    };
    // 出现动画结束
    void (^completion)(BOOL) = ^(BOOL finished) {
        // 侧边栏 已经出现
        if (finished && [self.delegate respondsToSelector:@selector(sidebar:didShowAnimated:)]) {
            [self.delegate sidebar:self didShowAnimated:animated];
        }
    };
    
    // 动画执行
    if (animated == YES) {
        UIViewAnimationOptions keyboardAnimationCurve = 7;
        keyboardAnimationCurve |= keyboardAnimationCurve<<16;
        [UIView animateWithDuration:self.animationDuration
                              delay:0.0
                            options:keyboardAnimationCurve
                         animations:animations
                         completion:completion];
    }
    // 无动画执行
    else{
        animations();
        completion(YES);
    }
}

#pragma mark - Dismiss

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    
    // 消失动画结束
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        // 从window移除
        [self.view removeFromSuperview];
        
        // 侧边栏 已经消失
        if ([self.delegate respondsToSelector:@selector(sidebar:didDismissAnimated:)]) {
            [self.delegate sidebar:self didDismissAnimated:animated];
        }
        
        // 额外的完成动作
        if (completion) {
            completion(finished);
        }
    };
    
    // 侧边栏 将要消失
    if ([self.delegate respondsToSelector:@selector(sidebar:willDismissAnimated:)]) {
        [self.delegate sidebar:self willDismissAnimated:animated];
    }
    
    // 动画执行
    if (animated == YES) {
        CGRect contentFrame = self.contentView.frame;
        contentFrame.origin.x = self.showFromRight ? self.view.width : (-self.sideBarWidth);
        
        CGRect blurFrame = self.contentBlurView.frame;
        blurFrame.origin.x = self.showFromRight ? self.view.width : 0.0;
        blurFrame.size.width = 0.0;
        
        UIViewAnimationOptions keyboardAnimationCurve = 7;
        keyboardAnimationCurve |= keyboardAnimationCurve<<16;
        [UIView animateWithDuration:self.animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | keyboardAnimationCurve
                         animations:^{
                             self.contentView.frame = contentFrame;
                             self.contentBlurView.frame = blurFrame;
                             self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
                         }
                         completion:completionBlock];
    }
    // 无动画执行
    else {
        completionBlock(YES);
    }
}

#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    
    // 点击内容视图之外
    CGPoint location = [recognizer locationInView:self.view];
    if (! CGRectContainsPoint(self.contentView.frame, location)) {
        // 隐藏侧边栏
        [self dismissAnimated:YES completion:nil];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (gestureRecognizer == self.tapGesture) {
        // 点击内容视图之内
        CGPoint location = [touch locationInView:self.view];
        if (CGRectContainsPoint(self.contentView.frame, location)) {
            return NO;
        }
    }
    
    return YES;
}

@end
