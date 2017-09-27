//
//  CMTTapToRefresh.m
//  MedicalForum
//
//  Created by fenglei on 15/1/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTTapToRefresh.h"

const CGFloat CMTTapToRefreshDefaultHeight = 30.0;

@interface CMTTapToRefresh ()

// output
@property (nonatomic, strong, readwrite) RACSignal *refreshButtonSignal;            // 点击刷新按钮

// view
@property (nonatomic, strong) UIButton *refreshButton;                              // 刷新按钮
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;       // 提示
@property (nonatomic, strong) UIView *separatorLine;                                // 分隔线
@property (nonatomic, strong, readwrite) UIView *bottomLine;                        // 底部分隔线

@end

@implementation CMTTapToRefresh

- (UIButton *)refreshButton {
    if (_refreshButton == nil) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton sizeToFillinContainer:self WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        _refreshButton.backgroundColor = COLOR(c_fafafa);
        [_refreshButton setTitleColor:COLOR(c_151515) forState:UIControlStateNormal];
        [_refreshButton setTitleColor:COLOR(c_151515) forState:UIControlStateHighlighted];
        [_refreshButton.titleLabel setFont:FONT(12.0)];
        [_refreshButton setTitle:@"点击加载评论" forState:UIControlStateNormal];
    }
    
    return _refreshButton;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.center = self.center;
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    
    return _activityIndicatorView;
}

- (UIView *)separatorLine {
    if (_separatorLine == nil) {
        _separatorLine = [[UIView alloc] init];
        [_separatorLine sizeToBuiltinContainer:self WithLeft:0.0 Top:0.0 Width:self.width Height:PIXEL];
        _separatorLine.backgroundColor = COLOR(c_9e9e9e);
    }
    
    return _separatorLine;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        [_bottomLine sizeToBuiltinContainer:self WithLeft:0.0 Top:self.height - PIXEL Width:self.width Height:PIXEL];
        _bottomLine.backgroundColor = COLOR(c_9e9e9e);
    }
    
    return _bottomLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"TapToRefresh willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_fafafa);
    [self addSubview:self.activityIndicatorView];
    [self addSubview:self.refreshButton];
    [self addSubview:self.separatorLine];
    [self addSubview:self.bottomLine];
    self.bottomLine.hidden = YES;
    
    [[RACObserve(self, active) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *active) {
        @strongify(self);
        self.refreshButton.hidden = [active boolValue];
        if ([active boolValue] == YES) {
            [self.activityIndicatorView startAnimating];
        } else {
            [self.activityIndicatorView stopAnimating];
        }
    }];
    
    self.refreshButtonSignal = [self.refreshButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

@end
