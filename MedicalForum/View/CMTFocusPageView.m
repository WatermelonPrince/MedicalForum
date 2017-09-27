//
//  CMTFocusPageView.m
//  MedicalForum
//
//  Created by fenglei on 15/4/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTFocusPageView.h"                // header file
#import "CMTFocusPageIndicator.h"           // 焦点图分页提示器
#import "CMTFocusCaption.h"                 // 焦点图说明

static const CGFloat CMTFocusPageViewScrollViewHeightWidthRatio = 9.0 / 16.0;
static const CGFloat CMTFocusPageViewIndicatorBottomGap = 6.0;
static const CGFloat CMTFocusPageViewBottomBlankHeight = 6.0;
static const CGFloat CMTFocusPageViewShadowHeight = 5.0 / 3.0;

@interface CMTFocusPageView ()

// view
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CMTFocusPageIndicator *indicator;
@property (nonatomic, strong) CMTFocusCaption *caption;
@property (nonatomic, strong) UIView *bottomBlank;
@property (nonatomic, strong) UIImageView *bottomShadow;
@property (nonatomic, strong) UIView *bottomLine;

// data
@property (nonatomic, assign) BOOL initialization;                  // 是否初始化frame
@property (nonatomic, assign) NSInteger currentPage;                // 当前显示的页码
@property(nonatomic,assign) BOOL isAllowShuffling;

@end

@implementation CMTFocusPageView

#pragma mark Initializers

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = COLOR(c_clear);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    
    return _scrollView;
}

- (CMTFocusPageIndicator *)indicator {
    if (_indicator == nil) {
        _indicator = [[CMTFocusPageIndicator alloc] init];
        _indicator.backgroundColor = COLOR(c_clear);
        _indicator.hidesForSinglePage = YES;
    }
    
    return _indicator;
}

- (CMTFocusCaption *)caption {
    if (_caption == nil) {
        _caption = [[CMTFocusCaption alloc] init];
        _caption.backgroundColor = COLOR(c_ffffff);
    }
    
    return _caption;
}

- (UIView *)bottomBlank {
    if (_bottomBlank == nil) {
        _bottomBlank = [[UIView alloc] init];
        _bottomBlank.backgroundColor = COLOR(c_efeff4);
    }
    
    return _bottomBlank;
}

- (UIImageView *)bottomShadow {
    if (_bottomShadow == nil) {
        _bottomShadow = [[UIImageView alloc] init];
        _bottomShadow.backgroundColor = COLOR(c_clear);
        _bottomShadow.image = IMAGE(@"shadow_bottom");
    }
    
    return _bottomShadow;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _bottomLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"FocusView willDeallocSignal");
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
    
    // 点击手势
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:singleTapGestureRecognizer];
    [[singleTapGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(focusPageView:didSelectFocusAtIndex:)]) {
            [self.delegate focusPageView:self didSelectFocusAtIndex:self.currentPage];
        }
    }];
    
    return self;
}

+ (CGFloat)heightForWidth:(CGFloat)width {
    return width * CMTFocusPageViewScrollViewHeightWidthRatio + CMTFocusCaptionDefaultHeight + CMTFocusPageViewBottomBlankHeight;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    // scrollView
    CGFloat scrollViewHeight = self.width * CMTFocusPageViewScrollViewHeightWidthRatio;
    [self.scrollView builtinContainer:self WithLeft:0.0 Top:0.0 Width:self.width Height:scrollViewHeight];
    // indicator
    CGFloat indicatorTop = self.scrollView.height - CMTFocusPageViewIndicatorBottomGap - CMTFocusPageIndicatorDefaultHeight;
    [self.indicator builtinContainer:self WithLeft:0.0 Top:indicatorTop Width:self.width Height:CMTFocusPageIndicatorDefaultHeight];
    // caption
    [self.caption builtinContainer:self WithLeft:0.0 Top:self.scrollView.bottom Width:self.width Height:CMTFocusCaptionDefaultHeight];
    // bottomBlank
    [self.bottomBlank builtinContainer:self WithLeft:0.0 Top:self.caption.bottom Width:self.width Height:CMTFocusPageViewBottomBlankHeight];
    // bottomShadow
    [self.bottomShadow builtinContainer:self.bottomBlank WithLeft:0.0 Top:0.0 Width:self.bottomBlank.width Height:CMTFocusPageViewShadowHeight];
    // bottomLine
    [self.bottomLine builtinContainer:self.bottomBlank WithLeft:0.0 Top:self.bottomBlank.height - PIXEL Width:self.bottomBlank.width Height:PIXEL];
    
    // 初始化向左移动一页 留给最后一页
    self.scrollView.contentSize = CGSizeMake(self.width * 2.0, self.height);
    [self.scrollView setContentOffset:CGPointMake(self.width, 0.0) animated:NO];
    self.currentPage = 0;
    
    return YES;
}

#pragma mark LifeCycle

// 焦点图数量
- (NSInteger)numberOfFocus {
    if ([self.delegate respondsToSelector:@selector(numberOfFocusInFocusPageView:)]) {
        
        return [self.delegate numberOfFocusInFocusPageView:self];
    }
    else {
        
        return 0;
    }
}

// 获取指定的焦点图信息
- (CMTFocus *)focusAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(focusPageView:focusAtIndex:)]) {
        
        return [self.delegate focusPageView:self focusAtIndex:index];
    }
    else {
        
        return nil;
    }
}

// 刷新焦点图
- (void)reloadData {
    
    // to do 刷新时contentOffset是否需要归零? 防止当前的contentOffset超过新的contentSize
    
    // 焦点图数量
    NSInteger numberOfFocus = [self numberOfFocus];
    
    // 焦点图大小
    CGFloat focusWidth = self.scrollView.width;
    CGFloat focusHeight = self.scrollView.height;
    
    // 获取旧图片
    NSArray *oldImageViews = self.scrollView.subviews;
    
    // 设置新图片
    for (NSInteger index = 0; index < numberOfFocus; index++) {
        CMTFocus *focus = [self focusAtIndex:index];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = COLOR(c_clear);
        imageView.frame = CGRectMake(focusWidth * (index + 1), 0.0, focusWidth, focusHeight);
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setLimitedImageURL:focus.picture placeholderImage:IMAGE(@"focus_default")];
        [self.scrollView addSubview:imageView];
    }
    
    // 最左侧补充最后一张焦点图
    CMTFocus *lastFocus = [self focusAtIndex:numberOfFocus - 1];
    UIImageView *lastFocusImageView = [[UIImageView alloc] init];
    lastFocusImageView.backgroundColor = COLOR(c_clear);
    lastFocusImageView.frame = CGRectMake(0.0, 0.0, focusWidth, focusHeight);
    lastFocusImageView.clipsToBounds = YES;
    lastFocusImageView.contentMode = UIViewContentModeScaleAspectFill;
    [lastFocusImageView setLimitedImageURL:lastFocus.picture placeholderImage:IMAGE(@"focus_default")];
    [self.scrollView addSubview:lastFocusImageView];
    
    // 最后侧补充第一张焦点图
    CMTFocus *firstFocus = [self focusAtIndex:0];
    UIImageView *firstFocusImageView = [[UIImageView alloc] init];
    firstFocusImageView.backgroundColor = COLOR(c_clear);
    firstFocusImageView.frame = CGRectMake(focusWidth * (numberOfFocus + 1), 0.0, focusWidth, focusHeight);
    firstFocusImageView.clipsToBounds = YES;
    firstFocusImageView.contentMode = UIViewContentModeScaleAspectFill;
    [firstFocusImageView setLimitedImageURL:firstFocus.picture placeholderImage:IMAGE(@"focus_default")];
    [self.scrollView addSubview:firstFocusImageView];
    
    // 清空旧图片
    for (UIView *view in oldImageViews) {
        [view removeFromSuperview];
    }
    
    // 重置焦点图
    [self.scrollView setContentSize:CGSizeMake(focusWidth * (numberOfFocus + 2), focusHeight)];
    [self.scrollView setContentOffset:CGPointMake(self.width, 0.0) animated:NO];
    self.currentPage = 0;
    
    // 只有一页时 不可滑动
    if (numberOfFocus <= 1) {
        self.scrollView.scrollEnabled = NO;
    }
    else {
        self.scrollView.scrollEnabled = YES;
    }
    
    // 刷新分页提示
    self.indicator.numberOfPages = numberOfFocus;
    self.indicator.currentPage = self.currentPage;
    // 刷新说明
    [self refreshCaption];
}

// 当前显示的页码
- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage) return;
    
    _currentPage = currentPage;
    
    // 刷新分页提示
    self.indicator.currentPage = currentPage;
    // 刷新说明
    [self refreshCaption];
}

// 刷新焦点图说明
- (void)refreshCaption {
    if (self.currentPage < [self numberOfFocus]) {
        self.caption.focus = [self focusAtIndex:self.currentPage];
    }
    else {
        self.caption.focus = nil;
    }
}
//设置图片轮播 add by guoyuasnchao
-(void)CMT_shuffling_pic{
    
    NSInteger pageNumber=self.currentPage;
    NSInteger numberOfFocus = [self numberOfFocus];
    long pageIndex = lround((float)self.scrollView.contentOffset.x /self.scrollView.frame.size.width) - 1;
    
    // 从第一页到最后一页
    if (pageIndex == -1) {
        self.currentPage = numberOfFocus - 1;
    }
    // 从最后一页到第一页
    else if (pageIndex == numberOfFocus) {
        self.currentPage = 0;
    }
    // 临近两页之间滑动
    else {
        self.currentPage = pageIndex;
    }

    if (pageNumber<numberOfFocus-1) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x+self.width, 0) animated:YES];
        self.currentPage=pageNumber+1;
    }else{
        
        [self.scrollView setContentOffset:CGPointMake(self.width, 0.0) animated:NO];
        self.currentPage=0;
    }
}


#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    long pageIndex = lround((float)scrollView.contentOffset.x / scrollView.frame.size.width) - 1;
    
    // 焦点图数量
    NSInteger numberOfFocus = [self numberOfFocus];
    
    // 从第一页到最后一页
    if (pageIndex == -1) {
        self.currentPage = numberOfFocus - 1;
    }
    // 从最后一页到第一页
    else if (pageIndex == numberOfFocus) {
        self.currentPage = 0;
    }
    // 临近两页之间滑动
    else {
        self.currentPage = pageIndex;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.isAllowShuffling=NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    long pageIndex = lround((float)scrollView.contentOffset.x / scrollView.frame.size.width) - 1;
    
    // 焦点图数量
    NSInteger numberOfFocus = [self numberOfFocus];
    
    // 从第一页到最后一页
    if (pageIndex == -1) {
        [self.scrollView setContentOffset:CGPointMake(numberOfFocus * self.width, 0.0) animated:NO];
        self.currentPage = numberOfFocus - 1;
    }
    // 从最后一页到第一页
    else if (pageIndex == numberOfFocus) {
        [self.scrollView setContentOffset:CGPointMake(self.width, 0.0) animated:NO];
        self.currentPage = 0;
    }
    // 临近两页之间滑动
    else {
        self.currentPage = pageIndex;
    }

 }

@end
