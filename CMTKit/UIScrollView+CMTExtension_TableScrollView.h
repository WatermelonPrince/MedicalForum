//
//  UIScrollView+CMTExtension_TableScrollView.h
//  MedicalForum
//
//  Created by fenglei on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMTTableScrollViewDataSource <NSObject>

@required

// cell数量
- (NSUInteger)numberOfCellsInTableScrollView:(UIScrollView *)tableScrollView;

// cell高
- (CGFloat)tableScrollView:(UIScrollView *)tableScrollView heightForCellAtIndex:(NSInteger)index;

// 生成/配置cell
- (UITableViewCell *)tableScrollView:(UIScrollView *)tableScrollView cellAtIndex:(NSInteger)index;

@end

@protocol CMTTableScrollViewDelegate <NSObject>

@optional

// cell显示前调用
- (void)tableScrollView:(UIScrollView *)tableScrollView willDisplayCell:(UITableViewCell *)cell atIndex:(NSInteger)index;

// 选中cell
- (void)tableScrollView:(UIScrollView *)tableScrollView didSelectCellAtIndex:(NSInteger)index;

@end

@interface UIScrollView (CMTExtension_TableScrollView)

// delegate
@property (nonatomic, weak) id <CMTTableScrollViewDataSource> tableScrollViewDataSource;
@property (nonatomic, weak) id <CMTTableScrollViewDelegate> tableScrollViewDelegate;

// view
@property (nonatomic, strong) UITableViewCell *dequeuedCell;                // 用来复用的cell
/// 覆盖黑色区域
@property (nonatomic, strong) UIView *blackCoverView;
/// 列表空数据提示
@property (nonatomic, strong) UIView *placeholderView;

// data
@property (nonatomic, assign) NSUInteger numberOfCells;                     // cell总数 通过CMTTableScrollViewDataSource -numberOfCellsInTableScrollView获取
@property (nonatomic, strong) NSMutableDictionary *frameOfCells;            // 所有cell的frame key为cell对应的index(NSNumber*)
@property (nonatomic, strong) NSMutableArray *indexsOfVisibleCells;         // 当前添加到UIScrollView并处于可见区域的cell对应的index(NSNumber*)

// 以下参数 通过计算后 用于控制UIWebView scrollView 的 contentSize 和 contentInset
@property (nonatomic, assign) CGFloat headerHeight;                         // 病例文章内容高度
@property (nonatomic, assign) CGFloat fixedViewHeight;                      // 病例文章内容与评论之间"全部评论/我赞过的"提示视图高度
@property (nonatomic, assign) CGFloat accessoryHeight;                      // 点击刷新高度
@property (nonatomic, assign) CGFloat currentOffsetY;                       // 记录UIScrollView contentOffset y 用于判断上滑/下滑
@property (nonatomic, assign) CGFloat frameHeight;                          // UIWebView高度
@property (nonatomic, assign) CGFloat topInset;                             // UIWebView scrollView contentInset top
@property (nonatomic, assign) CGFloat bottomInset;                          // UIWebView scrollView contentInset bottom

@property (nonatomic, assign) CGFloat lastCoveredHeight;                    // 最后一个cell所覆盖的高度, 没有cell时 为UIWebView高度
@property (nonatomic, assign) BOOL afterReload;                             // 控制UIScrollView delegate 调用-reloadDataWithHeaderHeight 之前为NO 屏蔽delegate调用
@property (nonatomic, assign) BOOL lostCells;                               // 无可用的复用cell时为YES 用于滑动时生成新的cell 目前此逻辑被屏蔽
@property (nonatomic, assign) BOOL cellLostExpected;                        // 此字段目前无作用

- (void)initTableScrollView;

// 复用cell
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

// reload
- (void)reloadDataWithHeaderHeight:(CGFloat)headerHeight
                   fixedViewHeight:(CGFloat)fixedViewHeight
                   accessoryHeight:(CGFloat)accessoryHeight
                       frameHeight:(CGFloat)frameHeight
                          topInset:(CGFloat)topInset
                       bottomInset:(CGFloat)bottomInset;

// 指定cell的frame
- (CGRect)frameOfCellAtIndex:(NSInteger)index;

// 当前可见cell的index
- (NSArray *)indexsForVisibleCells;

- (void)scrollToCellAtIndex:(NSInteger)index;

// scrollView
- (void)tableScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)tableScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)tableScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)tableScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
