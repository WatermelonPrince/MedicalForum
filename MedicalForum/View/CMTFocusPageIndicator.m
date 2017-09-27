//
//  CMTFocusPageIndicator.m
//  MedicalForum
//
//  Created by fenglei on 15/4/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTFocusPageIndicator.h"          // header file

const CGFloat CMTFocusPageIndicatorDefaultHeight = 4.0;

static const CGFloat CMTFocusPageIndicatorGap = 8.0;

@interface CMTFocusPageIndicator ()

// data
@property (nonatomic, strong) NSMutableArray *indicatorList;        // 提示图标列表

@end

@implementation CMTFocusPageIndicator

#pragma mark Initializers

- (NSMutableArray *)indicatorList {
    if (_indicatorList == nil) {
        _indicatorList = [NSMutableArray array];
    }
    
    return _indicatorList;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"FocusPageIndicator willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_clear);
    self.currentPage = 0;

    return self;
}

#pragma mark LifeCycle

// 页面数量
- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages == numberOfPages) return;
    
    _numberOfPages = numberOfPages;
    
    [self reloadData];
}

// 当前页面
- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage) return;
    
    _currentPage = currentPage;
    
    [self refreshIndicator];
}

- (void)configImageView:(UIImageView *)imageView atIndex:(NSInteger)index {
    if (index == self.currentPage) {
        UIImage *selectedImage = IMAGE(@"focus_indicator_selected");
        imageView.image = selectedImage;
        imageView.size = selectedImage.size;
    }
    else {
        UIImage *unselectedImage = IMAGE(@"focus_indicator_unselected");
        imageView.image = unselectedImage;
        imageView.size = unselectedImage.size;
    }
    imageView.center = CGPointMake((index + 1) * CMTFocusPageIndicatorGap, imageView.superview.height / 2.0);
}

// 刷新提示图标列表
- (void)reloadData {
    
    // 获取旧图标列表
    NSArray *oldIndicatorList = self.subviews;
    [self.indicatorList removeAllObjects];
    
    // 设置新图标列表
    CGFloat indicatorViewWidth = (self.numberOfPages + 1) * CMTFocusPageIndicatorGap;
    CGFloat indicatorViewLeft = (self.width - indicatorViewWidth) / 2.0;
    UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(indicatorViewLeft, 0, indicatorViewWidth, self.height)];
    indicatorView.backgroundColor = COLOR(c_clear);
    for (NSInteger index = 0; index < self.numberOfPages; index++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = COLOR(c_clear);
        [indicatorView addSubview:imageView];
        [self.indicatorList addObject:imageView];
        [self configImageView:imageView atIndex:index];
    }
    
    // 清空旧图标列表
    for (UIView *view in oldIndicatorList) {
        [view removeFromSuperview];
    }
    
    // 添加新图标列表
    [self addSubview:indicatorView];
    
    // 只有一页时 隐藏提示器
    if (self.hidesForSinglePage == YES && self.numberOfPages == 1) {
        self.hidden = YES;
    }
    else {
        self.hidden = NO;
    }
}

// 刷新提示图标
- (void)refreshIndicator {
    for (NSInteger index = 0; index < self.indicatorList.count; index++) {
        UIImageView *imageView = self.indicatorList[index];
        [self configImageView:imageView atIndex:index];
    }
}

@end
