//
//  CMTBlurView.m
//  MedicalForum
//
//  Created by fenglei on 15/4/7.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBlurView.h"

@interface CMTBlurView ()

// view
@property (nonatomic, strong, readwrite) UIView *contentView;                       // 内容视图
@property (nonatomic, strong) UIToolbar *blurView;                                  // 模糊视图

// data
@property (nonatomic, assign) BOOL initialization;                                  // 是否初始化frame

@end

@implementation CMTBlurView

#pragma mark Initializers

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = COLOR(c_clear);
        [_contentView addSubview:self.blurView];
    }
    
    return _contentView;
}

- (UIToolbar *)blurView {
    if (_blurView == nil) {
        _blurView = [[UIToolbar alloc] init];
        _blurView.backgroundColor = COLOR(c_clear);
        _blurView.barStyle = UIBarStyleBlack;
        _blurView.translucent = YES;
        _blurView.tintColor = nil;
    }
    
    return _blurView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    self.backgroundColor = COLOR(c_clear);
    [self addSubview:self.contentView];
    
    self.contentView.frame = self.bounds;
    self.blurView.frame = self.contentView.bounds;
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTBlurView willDeallocSignal");
    }];
    
    // 初始化frame
    [[RACObserve(self, frame)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.frame.size.height > 0 && !self.initialization) {
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];
    
    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    self.contentView.frame = self.bounds;
    self.blurView.frame = self.contentView.bounds;
    
    return YES;
}

@end
