//
//  CMTContentEmptyView.m
//  MedicalForum
//
//  Created by fenglei on 15/2/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTContentEmptyView.h"          // header file

static const CGFloat kCMTContentEmptyViewMargen = 30.0;
static const CGFloat kCMTContentEmptyViewOffsetTop = 30.0;

@interface CMTContentEmptyView ()



// data
@property (nonatomic, assign) BOOL initialization;                  // 是否初始化frame
@property (nonatomic, assign) BOOL reload;                          // 是否重新计算frame

@end

@implementation CMTContentEmptyView

#pragma mark Initializers

- (UILabel *)promptLabel {
    if (_promptLabel == nil) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = COLOR(c_clear);
        _promptLabel.textColor = COLOR(c_d2d2d2);
        _promptLabel.font = [UIFont boldSystemFontOfSize:18.0];
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.numberOfLines = 0;
    }
    
    return _promptLabel;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"ContentEmptyView willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_clear);
    self.reload = NO;
    
    // 初始化frame
    [[RACObserve(self, frame)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.frame.size.height > 0 && !self.initialization) {
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];
    
    // 提示
    [[[RACObserve(self, contentEmptyPrompt) ignore:nil]
      distinctUntilChanged] subscribeNext:^(NSString *contentEmptyPrompt) {
        @strongify(self);
        self.promptLabel.text = contentEmptyPrompt;
        if (self.frame.size.height > 0 && self.reload == NO) {
            [self reloadDisplaySize];
        }
    }];
    
    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    [self addSubview:self.promptLabel];
    
    if (self.promptLabel.text != nil && self.reload == NO) {
        [self reloadDisplaySize];
    }
    
    return YES;
}

#pragma mark LifeCycle

- (void)reloadDisplaySize {
    // to do 重复执行reloadDisplaySize方法 promptLabel不显示 需找到原因 去掉reload判断
    self.reload = YES;
    
    // promptLabelSize
    CGFloat promptLabelMaxWidth = self.width - 2.0*kCMTContentEmptyViewMargen*RATIO;
    CGSize promptLabelSize = [self.promptLabel.text boundingRectWithSize:CGSizeMake(promptLabelMaxWidth, CGFLOAT_MAX)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                              attributes:@{NSFontAttributeName:self.promptLabel.font}
                                                                 context:nil].size;
    CGFloat promptLabelWidth = ceil(promptLabelSize.width);
    CGFloat promptLabelHeight = ceil(promptLabelSize.height);
    CGFloat promptLeftGuide = (self.width - promptLabelWidth) / 2.0;
    CGFloat promptTopGuide = (self.height - promptLabelHeight) / 2.0 - kCMTContentEmptyViewOffsetTop;
    
    // promptLabel
    self.promptLabel.frame = CGRectMake(promptLeftGuide,
                                        promptTopGuide,
                                        promptLabelWidth,
                                        promptLabelHeight);
}

@end
