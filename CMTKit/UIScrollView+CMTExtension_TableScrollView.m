//
//  UIScrollView+CMTExtension_TableScrollView.m
//  MedicalForum
//
//  Created by fenglei on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "UIScrollView+CMTExtension_TableScrollView.h"
#import "CMTReplyListWrapCell.h"
#import <objc/runtime.h>

static const NSString *CMTTableScrollViewDataSourceAssociatedKey = @"CMTTableScrollViewDataSourceAssociatedKey";
static const NSString *CMTTableScrollViewDelegateAssociatedKey = @"CMTTableScrollViewDelegateAssociatedKey";
static const NSString *CMTTableScrollViewDequeuedCellAssociatedKey = @"CMTTableScrollViewDequeuedCellAssociatedKey";
static const NSString *CMTTableScrollViewBlackCoverViewAssociatedKey = @"CMTTableScrollViewBlackCoverViewAssociatedKey";
static const NSString *CMTTableScrollViewPlaceholderViewAssociatedKey = @"CMTTableScrollViewPlaceholderViewAssociatedKey";
static const NSString *CMTTableScrollViewFrameOfCellsAssociatedKey = @"CMTTableScrollViewFrameOfCellsAssociatedKey";
static const NSString *CMTTableScrollViewIndexsOfVisibleCellsAssociatedKey = @"CMTTableScrollViewIndexsOfVisibleCellsAssociatedKey";
static const NSString *CMTTableScrollViewNumberOfCellsAssociatedKey = @"CMTTableScrollViewNumberOfCellsAssociatedKey";
static const NSString *CMTTableScrollViewHeaderHeightAssociatedKey = @"CMTTableScrollViewHeaderHeightAssociatedKey";
static const NSString *CMTTableScrollViewFixedViewHeightAssociatedKey = @"CMTTableScrollViewFixedViewHeightAssociatedKey";
static const NSString *CMTTableScrollViewAccessoryHeightAssociatedKey = @"CMTTableScrollViewAccessoryHeightAssociatedKey";
static const NSString *CMTTableScrollViewCurrentOffsetYAssociatedKey = @"CMTTableScrollViewCurrentOffsetYAssociatedKey";
static const NSString *CMTTableScrollViewFrameHeightAssociatedKey = @"CMTTableScrollViewFrameHeightAssociatedKey";
static const NSString *CMTTableScrollViewTopInsetAssociatedKey = @"CMTTableScrollViewTopInsetAssociatedKey";
static const NSString *CMTTableScrollViewBottomInsetAssociatedKey = @"CMTTableScrollViewBottomInsetAssociatedKey";
static const NSString *CMTTableScrollViewLastCoveredHeightAssociatedKey = @"CMTTableScrollViewLastCoveredHeightAssociatedKey";
static const NSString *CMTTableScrollViewAfterReloadAssociatedKey = @"CMTTableScrollViewAfterReloadAssociatedKey";
static const NSString *CMTTableScrollViewLostCellsAssociatedKey = @"CMTTableScrollViewLostCellsAssociatedKey";
static const NSString *CMTTableScrollViewCellLostExpectedAssociatedKey = @"CMTTableScrollViewCellLostExpectedAssociatedKey";

static const NSUInteger CMTTableScrollViewBaseCellTag = 1000;

@interface CMTTableScrollViewCellTapGesture : UITapGestureRecognizer <UIGestureRecognizerDelegate>
@property (nonatomic, copy) NSString *gestureName;
@end
@implementation CMTTableScrollViewCellTapGesture
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[UITableViewCell class]] == NO) {
        return YES;
    }
    
    UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
    CGPoint location =  [gestureRecognizer locationInView:cell];
    
    BOOL locationInControl = NO;
    for (UIView *subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UIControl class]]) {
            if (CGRectContainsPoint(subView.frame, location)) {
                locationInControl = YES;
                break;
            }
        }
    }
    
    return !locationInControl;
}
@end

@implementation UIScrollView (CMTExtension_TableScrollView)

#pragma mark - Property

- (id<CMTTableScrollViewDataSource>)tableScrollViewDataSource {
    return objc_getAssociatedObject(self, &CMTTableScrollViewDataSourceAssociatedKey);
}

- (void)setTableScrollViewDataSource:(id<CMTTableScrollViewDataSource>)tableScrollViewDataSource {
    if ([self.tableScrollViewDataSource isEqual:tableScrollViewDataSource]) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewDataSourceAssociatedKey, tableScrollViewDataSource, OBJC_ASSOCIATION_ASSIGN);
}

- (id<CMTTableScrollViewDelegate>)tableScrollViewDelegate {
    return objc_getAssociatedObject(self, &CMTTableScrollViewDelegateAssociatedKey);
}

- (void)setTableScrollViewDelegate:(id<CMTTableScrollViewDelegate>)tableScrollViewDelegate {
    if ([self.tableScrollViewDelegate isEqual:tableScrollViewDelegate]) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewDelegateAssociatedKey, tableScrollViewDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (UITableViewCell *)dequeuedCell {
    return objc_getAssociatedObject(self, &CMTTableScrollViewDequeuedCellAssociatedKey);
}

- (void)setDequeuedCell:(UITableViewCell *)dequeuedCell {
    if ([self.dequeuedCell isEqual:dequeuedCell]) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewDequeuedCellAssociatedKey, dequeuedCell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)blackCoverView {
    return objc_getAssociatedObject(self, &CMTTableScrollViewBlackCoverViewAssociatedKey);
}

- (void)setBlackCoverView:(UIView *)blackCoverView {
    if ([self.blackCoverView isEqual:blackCoverView]) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewBlackCoverViewAssociatedKey, blackCoverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)placeholderView {
    return objc_getAssociatedObject(self, &CMTTableScrollViewPlaceholderViewAssociatedKey);
}

- (void)setPlaceholderView:(UIView *)placeholderView {
    if ([self.placeholderView isEqual:placeholderView]) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewPlaceholderViewAssociatedKey, placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)frameOfCells {
    return objc_getAssociatedObject(self, &CMTTableScrollViewFrameOfCellsAssociatedKey);
}

- (void)setFrameOfCells:(NSMutableDictionary *)frameOfCells {
    if ([self.frameOfCells isEqual:frameOfCells]) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewFrameOfCellsAssociatedKey, frameOfCells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)indexsOfVisibleCells {
    return objc_getAssociatedObject(self, &CMTTableScrollViewIndexsOfVisibleCellsAssociatedKey);
}

- (void)setIndexsOfVisibleCells:(NSMutableArray *)indexsOfVisibleCells {
    if ([self.indexsOfVisibleCells isEqual:indexsOfVisibleCells]) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewIndexsOfVisibleCellsAssociatedKey, indexsOfVisibleCells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)numberOfCells {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewNumberOfCellsAssociatedKey) unsignedIntegerValue];
}

- (void)setNumberOfCells:(NSUInteger)numberOfCells {
    if (self.numberOfCells == numberOfCells) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewNumberOfCellsAssociatedKey, [NSNumber numberWithUnsignedInteger:numberOfCells], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)headerHeight {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewHeaderHeightAssociatedKey) floatValue];
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
    if (self.headerHeight == headerHeight) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewHeaderHeightAssociatedKey, [NSNumber numberWithFloat:headerHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)fixedViewHeight {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewFixedViewHeightAssociatedKey) floatValue];
}

- (void)setFixedViewHeight:(CGFloat)fixedViewHeight {
    if (self.fixedViewHeight == fixedViewHeight) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewFixedViewHeightAssociatedKey, [NSNumber numberWithFloat:fixedViewHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)accessoryHeight {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewAccessoryHeightAssociatedKey) floatValue];
}

- (void)setAccessoryHeight:(CGFloat)accessoryHeight {
    if (self.accessoryHeight == accessoryHeight) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewAccessoryHeightAssociatedKey, [NSNumber numberWithFloat:accessoryHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)currentOffsetY {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewCurrentOffsetYAssociatedKey) floatValue];
}

- (void)setCurrentOffsetY:(CGFloat)currentOffsetY {
    if (self.currentOffsetY == currentOffsetY) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewCurrentOffsetYAssociatedKey, [NSNumber numberWithFloat:currentOffsetY], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)frameHeight {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewFrameHeightAssociatedKey) floatValue];
}

- (void)setFrameHeight:(CGFloat)frameHeight {
    if (self.frameHeight == frameHeight) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewFrameHeightAssociatedKey, [NSNumber numberWithFloat:frameHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)topInset {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewTopInsetAssociatedKey) floatValue];
}

- (void)setTopInset:(CGFloat)topInset {
    if (self.topInset == topInset) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewTopInsetAssociatedKey, [NSNumber numberWithFloat:topInset], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)bottomInset {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewBottomInsetAssociatedKey) floatValue];
}

- (void)setBottomInset:(CGFloat)bottomInset {
    if (self.bottomInset == bottomInset) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewBottomInsetAssociatedKey, [NSNumber numberWithFloat:bottomInset], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)lastCoveredHeight {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewLastCoveredHeightAssociatedKey) floatValue];
}

- (void)setLastCoveredHeight:(CGFloat)lastCoveredHeight {
    if (self.lastCoveredHeight == lastCoveredHeight) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewLastCoveredHeightAssociatedKey, [NSNumber numberWithFloat:lastCoveredHeight], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)afterReload {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewAfterReloadAssociatedKey) boolValue];
}

- (void)setAfterReload:(BOOL)afterReload {
    if (self.afterReload == afterReload) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewAfterReloadAssociatedKey, [NSNumber numberWithBool:afterReload], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)lostCells {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewLostCellsAssociatedKey) boolValue];
}

- (void)setLostCells:(BOOL)lostCells {
    if (self.lostCells == lostCells) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewLostCellsAssociatedKey, [NSNumber numberWithBool:lostCells], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)cellLostExpected {
    return [objc_getAssociatedObject(self, &CMTTableScrollViewCellLostExpectedAssociatedKey) boolValue];
}

- (void)setCellLostExpected:(BOOL)cellLostExpected {
    if (self.cellLostExpected == cellLostExpected) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTTableScrollViewCellLostExpectedAssociatedKey, [NSNumber numberWithBool:cellLostExpected], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - Initialize

- (void)initTableScrollView {
    
    // UI
    self.dequeuedCell = nil;
    self.blackCoverView = nil;
    self.placeholderView = nil;
    
    // data
    self.frameOfCells = [[NSMutableDictionary alloc] init];
    self.indexsOfVisibleCells = [[NSMutableArray alloc] init];
    self.numberOfCells = 0;
    self.headerHeight = 0.0;
    self.fixedViewHeight = 0.0;
    self.accessoryHeight = 0.0;
    self.currentOffsetY = 0.0;
    self.frameHeight = 0.0;
    self.topInset = 0.0;
    self.bottomInset = 0.0;
    self.lastCoveredHeight = 0.0;
    self.lostCells = NO;
    self.cellLostExpected = NO;
}

#pragma mark - Control

- (void)reloadDataWithHeaderHeight:(CGFloat)headerHeight
                   fixedViewHeight:(CGFloat)fixedViewHeight
                   accessoryHeight:(CGFloat)accessoryHeight
                       frameHeight:(CGFloat)frameHeight
                          topInset:(CGFloat)topInset
                       bottomInset:(CGFloat)bottomInset {
    
    self.afterReload = YES;
    self.headerHeight = headerHeight;
    self.fixedViewHeight = fixedViewHeight;
    self.accessoryHeight = accessoryHeight;
    self.currentOffsetY = 0.0;
    self.frameHeight = frameHeight;
    self.topInset = topInset;
    self.bottomInset = bottomInset;
    self.lastCoveredHeight = headerHeight;
    
    [self reloadScrollData];
}

- (void)reloadScrollData {
    
    [self removeAllCells];
    [self.frameOfCells removeAllObjects];
    [self.indexsOfVisibleCells removeAllObjects];
    
    [self initializeFrameOfCells];
    [self configScrollContent];
    [self initializeCells];
}

- (void)scrollToCellAtIndex:(NSInteger)index {
    // this is the case when cell lost is expected one would scroll from first view to 100th view...fast scrolling looses cell.
    self.cellLostExpected = YES;
    
    [self scrollRectToVisible:[self frameOfCellAtIndex:index] animated:YES];
}

- (void)removeAllCells {
    for (UITableViewCell *cell in self.subviews) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            [cell removeFromSuperview];
        }
    }
}

// 初始化坐标
- (void)initializeFrameOfCells {
    // 获取cell总数
    if ([self.tableScrollViewDataSource respondsToSelector:@selector(numberOfCellsInTableScrollView:)]) {
        self.numberOfCells = [self.tableScrollViewDataSource numberOfCellsInTableScrollView:self];
    }
    if (self.numberOfCells <= 0) {
        return;
    }
    
    // 计算第一个cell的y
    CGFloat frameYOfCell = self.headerHeight + self.fixedViewHeight + self.accessoryHeight;
    
    // 遍历cell的index 获取dataSource -heightForCellAtIndex 计算cell的frame
    for (NSInteger index = 0; index < self.numberOfCells; index++) {
        
        CGFloat cellHeight = 0.0;
        if ([self.tableScrollViewDataSource respondsToSelector:@selector(tableScrollView:heightForCellAtIndex:)]) {
            cellHeight = [self.tableScrollViewDataSource tableScrollView:self heightForCellAtIndex:index];
        }
        
        // 设置相应cell的frame
        self.frameOfCells[[NSNumber numberWithInteger:index]] = [NSValue valueWithCGRect:
                                                                 CGRectMake(0.0,
                                                                            frameYOfCell,
                                                                            self.bounds.size.width,
                                                                            cellHeight)];
        
        frameYOfCell += cellHeight;
    }
    
    // 最后一个cell覆盖的高度
    self.lastCoveredHeight = frameYOfCell;
}

// 调整滑动区域
// numberOfCells为0时 也需要调整
- (void)configScrollContent {
    
    // 容器(文章内容+评论列表)高度
    CGFloat webViewHeight = self.frameHeight;
    // 容器顶部contentInset
    CGFloat webViewTopInset = self.topInset;
    // 容器底部contentInset
    CGFloat webViewBottomInset = self.bottomInset;
    // 一般为导航栏底部至屏幕底部高度
    CGFloat webViewContainerHeight = webViewHeight - webViewTopInset;
    // 一般为导航栏底部与评论回复框顶部之间高度
    CGFloat webViewDisplayHeight = webViewContainerHeight - webViewBottomInset;
    
    // 文章内容高度
    CGFloat postDetailHeight = self.headerHeight;
    
    // 评论上方固定视图(如评论列表顶部视图)高度
    CGFloat replyFixedViewHeight = self.fixedViewHeight;
    // 评论上方额外视图(如点击加载)高度
    CGFloat replyAccessoryHeight = self.accessoryHeight;
    // 无评论placeholder视图高度
    CGFloat replyPlaceholderViewHeight = self.placeholderView.height;
    // 所有cell高度
    CGFloat replyCellsHeight = 0;
    if (self.numberOfCells > 0) {
        replyCellsHeight = self.lastCoveredHeight - (postDetailHeight + replyFixedViewHeight + replyAccessoryHeight);
    }
    
    // 默认评论列表总高度("全部评论"提示高度+点击刷新高度+所有cell高度)
    CGFloat replyTotalHeight = replyFixedViewHeight + replyAccessoryHeight + replyCellsHeight;
    // "全部评论"提示始终显示
    // 如果(点击刷新高度+所有cell高度)为0, 则点击刷新与评论cell隐藏, 显示placeholder
    if (replyAccessoryHeight + replyCellsHeight == 0.0) {
        // 评论列表总高度替换为("全部评论"提示高度+placeholder视图高度)
        replyTotalHeight = replyFixedViewHeight + replyPlaceholderViewHeight;
    }
    
    CMTLog(@"webViewHeight: %g", webViewHeight);
    
    CMTLog(@"postDetailHeight: %g", postDetailHeight);
    
    CMTLog(@"replyFixedViewHeight: %g", replyFixedViewHeight);
    
    CMTLog(@"replyAccessoryHeight: %g", replyAccessoryHeight);
    
    CMTLog(@"replyCellsHeight: %g", replyCellsHeight);
    
    CMTLog(@"replyPlaceholderViewHeight: %g", replyPlaceholderViewHeight);
    
    CMTLog(@"replyTotalHeight: %g", replyTotalHeight);
    
    CMTLog(@"\nbefore\nwebView.scrollView.contentSize: %@\nwebView.scrollView.contentInset: %@",
           NSStringFromCGSize(self.contentSize),
           NSStringFromUIEdgeInsets(self.contentInset));
    
    UIEdgeInsets contentInset = UIEdgeInsetsMake(webViewTopInset, 0.0, webViewBottomInset, 0.0);
    
    // 内容高度小于displayHeight
    if (postDetailHeight < webViewDisplayHeight) {
        CGFloat replyTotalHeightAdd = replyTotalHeight - (webViewDisplayHeight - postDetailHeight);
        // 评论高度小于displayHeight
        // 使用contentInset 压缩webView.scrollView.contentSize.height
        if (replyTotalHeight < webViewDisplayHeight) {
            contentInset.bottom = webViewContainerHeight - postDetailHeight + (replyTotalHeightAdd > 0.0 ? replyTotalHeightAdd : 0.0);
            self.contentInset = contentInset;
            self.contentSize = CGSizeMake(self.width, postDetailHeight);
        }
        // 评论高度大于等于displayHeight
        // 如果使用contentInset 无法压缩webView.scrollView.contentSize.height
        // webView.scrollView.contentSize.height会自动扩展到displayHeight
        // 所以直接扩展contentSize, contentInset为默认的CMTReplyViewDefaultHeight
        else {
            self.contentInset = contentInset;
            self.contentSize = CGSizeMake(self.width, webViewDisplayHeight + replyTotalHeightAdd);
        }
    }
    // 内容高度在displayHeight与webViewHeight之间
    else if (webViewDisplayHeight <= postDetailHeight && postDetailHeight <= webViewHeight) {
        // 评论高度
        contentInset.bottom = webViewBottomInset + replyTotalHeight;
        self.contentInset = contentInset;
        
        // 此时webView.scrollView.contentSize.height总是等于webViewHeight
        // 但实际webView展现内容高度为postDetailHeight
        // 第一次进入详情页webView展现内容高度有时会扩展到webViewHeight, 扩展区域为黑色
        // 所以强制设定webView.scrollView.contentSize.height为postDetailHeight
        self.contentSize = CGSizeMake(self.width, postDetailHeight);
    }
    // 内容高度大于containerHeight
    else {
        contentInset.bottom = webViewBottomInset + replyTotalHeight;
        self.contentInset = contentInset;
        self.contentSize = self.contentSize;
    }
    
    CMTLog(@"\nafter\nwebView.scrollView.contentSize: %@\nwebView.scrollView.contentInset: %@",
           NSStringFromCGSize(self.contentSize),
           NSStringFromUIEdgeInsets(self.contentInset));
}

// 初始化cell
- (void)initializeCells {
    
    // blackCoverView 覆盖UIWebView的黑色区域
    if (self.blackCoverView == nil) {
        self.blackCoverView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.frameHeight)];
        self.blackCoverView.backgroundColor = COLOR(c_fafafa);
        UIView *verticalScrollIndicator = [self valueForKey:@"verticalScrollIndicator"];
        if (verticalScrollIndicator == nil) {
            [self addSubview:self.blackCoverView];
        }
        else {
            [self insertSubview:self.blackCoverView belowSubview:verticalScrollIndicator];
        }
    }
    // blackCoverView的y与第一个cell的y相等
    self.blackCoverView.top = self.headerHeight + self.fixedViewHeight + self.accessoryHeight;
    
    // placeholderView
    [self.placeholderView removeFromSuperview];
    // 无cell
    if (self.numberOfCells == 0) {
        // 对应 -configScrollContent方法中 评论列表总高度为0
        if (self.accessoryHeight == 0.0) {
            // 加载placeholderView
            self.placeholderView.top = self.headerHeight + self.fixedViewHeight;
            [self insertSubview:self.placeholderView aboveSubview:self.blackCoverView];
        }
    }
    
    // 有cell 刷新cell
    for (NSInteger index = 0; index < self.numberOfCells; index++) {
        
        // 检查指定index的cell是否可见
        CGRect frameOfVisibleCell = [self frameOfVisibleCellAtIndex:index];
        if (CGRectEqualToRect(frameOfVisibleCell, CGRectZero) == NO) {
            
            // 获取cell
            UITableViewCell *visibleCell = nil;
            if ([self.tableScrollViewDataSource respondsToSelector:@selector(tableScrollView:cellAtIndex:)]) {
                visibleCell = [self.tableScrollViewDataSource tableScrollView:self cellAtIndex:index];
            }
            if (visibleCell == nil) {
                CMTLogError(@"Get VisibleCell Error: VisibleCell is nil");
                return;
            }
            
            // 设置frame
            visibleCell.frame = frameOfVisibleCell;
            visibleCell.tag = CMTTableScrollViewBaseCellTag + index;
            
            // 检查是否重复
            // tag相同 则index相同 则frame相同
            // 如果重复 不用处理
            if ([self viewWithTag:visibleCell.tag] == nil) {
                
                // 添加cell
                [self insertSubview:visibleCell aboveSubview:self.blackCoverView];
                
                // 添加cell点击手势
                if (visibleCell.gestureRecognizers.count > 0) {
                    for (UIGestureRecognizer *gestureRecognizer in visibleCell.gestureRecognizers) {
                        gestureRecognizer.delegate = nil;
                        [visibleCell removeGestureRecognizer:gestureRecognizer];
                    }
                }
                if ([visibleCell isKindOfClass:[CMTReplyListWrapCell class]] == NO) {
                    CMTTableScrollViewCellTapGesture *tapGestureRecognizer = [[CMTTableScrollViewCellTapGesture alloc] initWithTarget:self action:@selector(handleTap:)];
                    tapGestureRecognizer.delegate = tapGestureRecognizer;
                    [visibleCell addGestureRecognizer:tapGestureRecognizer];
                }
            }
            
            // 调用willDisplayCell
            if ([self.tableScrollViewDelegate respondsToSelector:@selector(tableScrollView:willDisplayCell:atIndex:)]) {
                [self.tableScrollViewDelegate tableScrollView:self willDisplayCell:visibleCell atIndex:index];
            }
            
            // 更新indexsOfVisibleCells
            [self.indexsOfVisibleCells addObject:[NSNumber numberWithInteger:index]];
            NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
            [self.indexsOfVisibleCells sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
        }
    }
}

#pragma mark - Data

// 如果指定index的cell当前可见, 返回其frame
// 否则, 返回CGRectZero
- (CGRect)frameOfVisibleCellAtIndex:(NSInteger)index {
    CGRect frameOfCell = [self frameOfCellAtIndex:index];
    
    if (CGRectIntersectsRect(self.bounds, frameOfCell) == YES) {
        
        return frameOfCell;
    }
    
    return CGRectZero;
}

- (CGRect)frameOfCellAtIndex:(NSInteger)index {
    return [self.frameOfCells[[NSNumber numberWithInteger:index]] CGRectValue];
}

- (NSArray *)indexsForVisibleCells {
    return [NSArray arrayWithArray:self.indexsOfVisibleCells];
}

#pragma mark - ReCycle

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    // 判断dequeuedCell是否存在
    UITableViewCell *dequeuedCell = self.dequeuedCell;
    self.dequeuedCell = nil;
    
    if ([dequeuedCell.reuseIdentifier isEqualToString:identifier]) {
        if (dequeuedCell != nil) {
            // 如果dequeuedCell存在 直接返回
            return dequeuedCell;
        }
    }
    
    // dequeuedCell不存在 返回一个不应显示但仍在UIScrollView上的cell
    for (UITableViewCell *cell in [self subviews]) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            if ([cell.reuseIdentifier isEqualToString:identifier]) {
                if (CGRectIntersectsRect(self.bounds, cell.frame) == NO) {
                    
                    return cell;
                }
            }
        }
    }
    
    return nil;
}

- (void)inqueueReusableCellWithForwardDirection:(BOOL)forwardDirection {
    NSInteger nextIndex;
    NSInteger previousIndex;
    
    // 当前有可见cell
    if ([self.indexsOfVisibleCells count] > 0) {
        
        // 在所有可见cell之后添加新cell
        if (forwardDirection == YES) {
            nextIndex = [[self.indexsOfVisibleCells lastObject] integerValue] + 1;
            previousIndex = [[self.indexsOfVisibleCells objectAtIndex:0] integerValue];
            
        }
        // 在所有可见cell之前添加新cell
        else {
            nextIndex = [[self.indexsOfVisibleCells objectAtIndex:0] integerValue] - 1;
            previousIndex = [[self.indexsOfVisibleCells lastObject] integerValue];
        }
        
        // nextIndex未越界 (越界的无数据, 不用显示)
        if (-1 < nextIndex && nextIndex < self.numberOfCells) {
            
            // nextIndex指定的cell为可见cell (不可见cell不用显示)
            CGRect frameOfCellAtNextIndex = [self frameOfCellAtIndex:nextIndex];
            if (CGRectIntersectsRect(self.bounds, frameOfCellAtNextIndex) == YES) {
                
                // indexsOfVisibleCells不包含nextIndex (避免重复?)
                if ([self.indexsOfVisibleCells containsObject:[NSNumber numberWithInteger:nextIndex]] == NO) {
                    
                    NSInteger insertIndex = forwardDirection ? [self.indexsOfVisibleCells count] : 0;
                    [self.indexsOfVisibleCells insertObject:[NSNumber numberWithInteger:nextIndex] atIndex:insertIndex];
                    
                    UITableViewCell *cell = [self.tableScrollViewDataSource tableScrollView:self cellAtIndex:nextIndex];
                    cell.frame = frameOfCellAtNextIndex;
                    cell.tag = CMTTableScrollViewBaseCellTag + nextIndex;
                    
                    if ([self viewWithTag:cell.tag] == nil) {
                        
                        // 添加cell
                        [self insertSubview:cell aboveSubview:self.blackCoverView];
                        
                        // 添加cell点击手势
                        if (cell.gestureRecognizers.count > 0) {
                            for (UIGestureRecognizer *gestureRecognizer in cell.gestureRecognizers) {
                                gestureRecognizer.delegate = nil;
                                [cell removeGestureRecognizer:gestureRecognizer];
                            }
                        }
                        if ([cell isKindOfClass:[CMTReplyListWrapCell class]] == NO) {
                            CMTTableScrollViewCellTapGesture *tapGestureRecognizer = [[CMTTableScrollViewCellTapGesture alloc] initWithTarget:self action:@selector(handleTap:)];
                            tapGestureRecognizer.delegate = tapGestureRecognizer;
                            [cell addGestureRecognizer:tapGestureRecognizer];
                        }
                    }
                    
                    if ([self.tableScrollViewDelegate respondsToSelector:@selector(tableScrollView:willDisplayCell:atIndex:)]) {
                        [self.tableScrollViewDelegate tableScrollView:self willDisplayCell:cell atIndex:nextIndex];
                    }
                }
            }
        }
        
        // 反向顶端cell如不可见
        CGRect frameOfCellAtPreviousIndex = [self frameOfCellAtIndex:previousIndex];
        if (CGRectIntersectsRect(self.bounds, frameOfCellAtPreviousIndex) == NO) {
            
            // 从indexsOfVisibleCells中移除
            [self.indexsOfVisibleCells removeObject:[NSNumber numberWithInteger:previousIndex]];
            // 并设置为dequeuedCell
            self.dequeuedCell = (UITableViewCell *)[self viewWithTag:CMTTableScrollViewBaseCellTag + previousIndex];
        }
    }
    
    // when cell's width is small , during fast scrolling , scrollview looses cells to display. In this case self.lostCells is set to 'YES' . Need to work on this more. Called when [self.indexsOfVisibleCells count]<=0
    else {
        self.lostCells = YES;
//        CMTLogError(@"lostCells happen");
    }
}

#pragma mark - Lost

// 寻找应该显示 但没有显示的cell
- (void)findLostCells {
    BOOL found = NO;
    
    for (NSInteger index = 0; index < self.numberOfCells; index++) {
        
        // 寻找应该显示的cell
        CGRect frameOfCell = [self frameOfCellAtIndex:index];
        if (CGRectIntersectsRect(self.bounds, frameOfCell) == YES) {
            
            // 应该显示但没有显示的cell
            if ([self.indexsOfVisibleCells containsObject:[NSNumber numberWithInteger:index]] == NO) {
                // cell对应index加入indexsOfVisibleCells
                [self.indexsOfVisibleCells addObject:[NSNumber numberWithInteger:index]];
                found = YES;
            }
        }
        else if (found == YES) {
            [self retrieveLostCells];
            return;
        }
    }
    // 刷新需要显示的cell
    if (found == YES) {
        [self retrieveLostCells];
    }
}

// 刷新所有需要显示的cell的frame等
- (void)retrieveLostCells {
    // 遍历需要显示的cell的index
    for (NSInteger index = 0; index < self.indexsOfVisibleCells.count; index++) {
        // 获取cell
        NSInteger cellIndex = [[self.indexsOfVisibleCells objectAtIndex:index] integerValue];
        UITableViewCell *cell = [self.tableScrollViewDataSource tableScrollView:self cellAtIndex:cellIndex];
        // 刷新cell的frame
        cell.frame = [self frameOfCellAtIndex:cellIndex];
        // 刷新cell的tag
        cell.tag = CMTTableScrollViewBaseCellTag + cellIndex;
        
        // 如果cell是新生成的 还没有添加到UIScrollView上
        // 将cell添加到UIScrollView上 并 添加相应点击事件
        if ([self viewWithTag:cell.tag] == nil) {
            
            // 添加cell
            [self insertSubview:cell aboveSubview:self.blackCoverView];
            
            // 添加cell点击手势
            if (cell.gestureRecognizers.count > 0) {
                for (UIGestureRecognizer *gestureRecognizer in cell.gestureRecognizers) {
                    gestureRecognizer.delegate = nil;
                    [cell removeGestureRecognizer:gestureRecognizer];
                }
            }
            if ([cell isKindOfClass:[CMTReplyListWrapCell class]] == NO) {
                CMTTableScrollViewCellTapGesture *tapGestureRecognizer = [[CMTTableScrollViewCellTapGesture alloc] initWithTarget:self action:@selector(handleTap:)];
                tapGestureRecognizer.delegate = tapGestureRecognizer;
                [cell addGestureRecognizer:tapGestureRecognizer];
            }
        }
        else {
            // to do
        }
        
        // 调用delegate -willDisplayCell
        if ([self.tableScrollViewDelegate respondsToSelector:@selector(tableScrollView:willDisplayCell:atIndex:)]) {
            [self.tableScrollViewDelegate tableScrollView:self willDisplayCell:cell atIndex:cellIndex];
        }
    }
}

#pragma mark - ScrollView

- (void)tableScrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.afterReload == NO) {
        return;
    }
    
//    if (self.lostCells == YES && self.cellLostExpected == NO) {
//        
//        [self findLostCells];
//        self.lostCells = NO;
//    }
    
    // 寻找应该显示 但没有显示的cell
    [self findLostCells];
    self.lostCells = NO;

    // scrollView上滑/下滑
    [self inqueueReusableCellWithForwardDirection:(scrollView.bounds.origin.y - self.headerHeight) > self.currentOffsetY];
    self.currentOffsetY = (scrollView.bounds.origin.y - self.headerHeight);
}


- (void)tableScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.afterReload == NO) {
        return;
    }

//    if (self.lostCells == YES) {
//        
//        [self findLostCells];
//        self.lostCells = NO;
//    }
//    
//    self.cellLostExpected = NO;
    
    // scroll Animation 之后会丢失cell 所以重新加载所有cell
    [self reloadScrollData];
}

- (void)tableScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.afterReload == NO) {
        return;
    }

    if (decelerate == NO) {
        // 移除不应显示 但仍在UIScrollView上的cell
        [self removeAliveOutOfBoundsCells];
    }
}

- (void)tableScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.afterReload == NO) {
        return;
    }

    // 移除不应显示 但仍在UIScrollView上的cell
    [self removeAliveOutOfBoundsCells];
}

// 移除不应显示 但仍在UIScrollView上的cell
- (void)removeAliveOutOfBoundsCells {
    UIView __weak *dequedCell = nil;
    UIView __weak *otherView = nil;
    
    // 遍历UIScrollView上的cell
    for (UITableViewCell *cell in self.subviews) {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            // 不应显示的cell
            if (CGRectIntersectsRect(self.bounds, cell.frame) == NO) {
                // 此cell不为复用cell
                if ([cell isEqual:self.dequeuedCell] == NO) {
                    // 总cell数大于1
                    if (self.numberOfCells > 1) {
                        // 移除此不应显示的cell
                        [cell removeFromSuperview];
                    }
                    // cell数量为1
                    else {
                        // 临时获取此cell 看是否需要移除
                        otherView = cell;
                    }
                }
                // 此cell为复用cell
                else {
                    dequedCell = cell;
                }
            }
        }
    }
    
    // 如果复用的cell存在 则移除临时获取的cell
    if (dequedCell != nil) {
        [otherView removeFromSuperview];
    }
}

#pragma mark - Gesture

- (void)handleTap:(CMTTableScrollViewCellTapGesture *)recognizer {
//    NSNumber *index = [self indexOfLocation:[recognizer locationInView:self]];
//    if (index != nil) {
//        [self didSelectedItemAtIndex:index];
//    }
    
    NSInteger index = recognizer.view.tag - CMTTableScrollViewBaseCellTag;
    if (0 <= index && index < self.numberOfCells) {
        [self didSelectedItemAtIndex:[NSNumber numberWithInteger:index]];
    }
}

- (NSNumber *)indexOfLocation:(CGPoint)location {
    NSNumber *index = nil;
    
    for (NSInteger cellIndex = 0; cellIndex < self.numberOfCells; cellIndex++) {
        CGRect cellFrame = [self frameOfCellAtIndex:cellIndex];
        if (CGRectContainsPoint(cellFrame, location)) {
            index = [NSNumber numberWithInteger:cellIndex];
            break;
        }
    }
    
    return index;
}

- (void)didSelectedItemAtIndex:(NSNumber *)index {
    if ([self.tableScrollViewDelegate respondsToSelector:@selector(tableScrollView:didSelectCellAtIndex:)]) {
        [self.tableScrollViewDelegate tableScrollView:self didSelectCellAtIndex:index.integerValue];
    }
}

@end

