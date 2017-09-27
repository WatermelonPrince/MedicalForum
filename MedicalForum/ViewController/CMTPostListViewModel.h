//
//  CMTPostListViewModel.h
//  MedicalForum
//
//  Created by fenglei on 14/12/30.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTViewModel.h"

FOUNDATION_EXPORT NSString * const CMTPostListCellIdentifier;
FOUNDATION_EXPORT NSString * const CMTLiveListCellIdentifier;

/// 首页(文章列表)数据
@interface CMTPostListViewModel : CMTViewModel

/* input */

/// 启动读取缓存状态
@property (nonatomic, assign) BOOL launchLoadCacheState;
/// 强制刷新状态
@property (nonatomic, assign) BOOL resetState;
/// 刷新状态
@property (nonatomic, assign) NSInteger pullToRefreshState;
/// 翻页状态
@property (nonatomic, assign) NSInteger infiniteScrollingState;

/* binding */

/// 焦点图列表 请求完成
@property (nonatomic, assign, readonly) BOOL focusListRequestFinish;
/// 焦点图列表 请求为空
@property (nonatomic, assign, readonly) BOOL focusListRequestEmpty;
/// 直播列表 请求为空
@property (nonatomic, assign, readonly) BOOL LiveListRequestEmpty;

/// 文章列表 启动读取缓存完成
@property (nonatomic, assign, readonly) BOOL launchLoadCacheFinish;
/// 文章列表 请求完成
@property (nonatomic, assign, readonly) BOOL postListRequestFinish;
/// 文章列表 请求为空提示
@property (nonatomic, copy, readonly) NSString *postListRequestEmptyMessage;
/// 文章列表 请求网络错误
@property (nonatomic, copy, readonly) NSError *postListRequestNetError;
/// 文章列表 请求服务器错误提示
@property (nonatomic, copy, readonly) NSString *postListRequestServerErrorMessage;
/// 文章列表 请求系统错误提示
@property (nonatomic, copy, readonly) NSString *postListRequestSystemErrorMessage;

/* output */

/// 焦点图列表 缓存
@property (nonatomic, copy, readonly) NSArray *cacheFocusList;
@property(nonatomic,copy,readonly)NSArray *caseLivelist ;//直播列表
@property(nonatomic,copy,readonly)CMTPost *topArticles;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (CGFloat)heightForHeaderInSection:(NSInteger)section;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (CMTPost *)postForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CMTLive *)liveForRowAtIndexPath:(NSIndexPath *)indexPath;

/* control */

/// 订阅信息是否有改动
@property (nonatomic, assign) BOOL subscriptionChange;

/// 保存文章列表
- (void)saveCachePostList;
/// 保存焦点图列表
- (void)saveCacheFocusList;

@end
