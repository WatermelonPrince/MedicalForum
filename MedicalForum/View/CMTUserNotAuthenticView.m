//
//  CMTUserNotAuthenticView.m
//  MedicalForum
//
//  Created by fenglei on 15/2/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTUserNotAuthenticView.h"             // header file

@interface CMTUserNotAuthenticView ()

// output
@property (nonatomic, strong, readwrite) RACSignal *requestAuthenticationSignal;        /// 点击申请认证按钮

// view
@property (nonatomic, strong) UIButton *handleButton;                                   // 弹出提示按钮
@property (nonatomic, strong) UIView *notifyView;                                       // 提示
@property (nonatomic, strong) UIView *notifyShadow;                                     // 提示阴影
@property (nonatomic, strong) UILabel *notifyTitle;                                     // 提示标题
@property (nonatomic, strong) UIButton *requestAuthenticationButton;                    // 申请认证按钮

// data
@property (nonatomic, assign) BOOL initialization;                                      // 是否初始化frame

@end

@implementation CMTUserNotAuthenticView

#pragma mark Initializers

- (UIButton *)handleButton {
    if (_handleButton == nil) {
        _handleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _handleButton.backgroundColor = COLOR(c_clear);
    }
    
    return _handleButton;
}

- (UIView *)notifyView {
    if (_notifyView == nil) {
        _notifyView = [[UIView alloc] init];
        _notifyView.backgroundColor = COLOR(c_clear);
        [_notifyView addSubview:self.notifyShadow];
        [_notifyView addSubview:self.notifyTitle];
        [_notifyView addSubview:self.requestAuthenticationButton];
    }
    
    return _notifyView;
}

- (UIView *)notifyShadow {
    if (_notifyShadow == nil) {
        _notifyShadow = [[UIView alloc] init];
        _notifyShadow.backgroundColor = COLOR(c_000000);
        _notifyShadow.alpha = 0.65;
    }
    
    return _notifyShadow;
}

- (UILabel *)notifyTitle {
    if (_notifyTitle == nil) {
        _notifyTitle = [[UILabel alloc] init];
        _notifyTitle.backgroundColor = COLOR(c_clear);
        _notifyTitle.textColor = COLOR(c_ffffff);
        _notifyTitle.font = FONT(18.0);
        _notifyTitle.textAlignment = NSTextAlignmentCenter;
        _notifyTitle.numberOfLines = 0;
        _notifyTitle.text = @"为了保护患者的隐私及医生的利益, 病例只对认证用户开放";
    }
    
    return _notifyTitle;
}

- (UIButton *)requestAuthenticationButton {
    if (_requestAuthenticationButton == nil) {
        _requestAuthenticationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_requestAuthenticationButton setBackgroundColor:COLOR(c_clear)];
        [_requestAuthenticationButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [_requestAuthenticationButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateHighlighted];
        [_requestAuthenticationButton setTitle:@"申请认证用户" forState:UIControlStateNormal];
        _requestAuthenticationButton.layer.borderColor = COLOR(c_ffffff).CGColor;
        _requestAuthenticationButton.layer.borderWidth = 1.0;
        _requestAuthenticationButton.layer.cornerRadius = 3.0;
        _requestAuthenticationButton.layer.masksToBounds = YES;
    }
    
    return _requestAuthenticationButton;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"UserNotAuthenticView willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_clear);
    
    // 初始化frame
    [[RACObserve(self, frame)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.frame.size.height > 0 && !self.initialization) {
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];
    
    // 点击弹出提示按钮
    [[self.handleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        // 弹出提示
        UIViewAnimationOptions keyboardAnimationCurve = 7;
        keyboardAnimationCurve |= keyboardAnimationCurve<<16;
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect notifyFrame = self.notifyView.frame;
                             notifyFrame.origin.y = 0;
                             self.notifyView.frame = notifyFrame;
                         } completion:nil];
    }];
    
    // 点击申请认证按钮
    self.requestAuthenticationSignal = [self.requestAuthenticationButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    [self.handleButton fillinContainer:self WithTop:0 Left:0 Bottom:0 Right:0];
    [self.notifyView builtinContainer:self WithLeft:0 Top:self.height Width:self.width Height:self.height];
    [self.notifyShadow sizeToFillinContainer:self.notifyView WithTop:0 Left:0 Bottom:0 Right:0];
    [self.notifyTitle sizeToBuiltinContainer:self.notifyView WithLeft:30 Top:60.0 Width:self.notifyView.width - 60.0 Height:50.0];
    [self.requestAuthenticationButton sizeToBuiltinContainer:self.notifyView WithLeft:(self.notifyView.width - 220.0) / 2.0 Top:self.notifyView.height - 50.0 - 40.0 Width:220.0 Height:40.0];
    
    return YES;
}

@end
