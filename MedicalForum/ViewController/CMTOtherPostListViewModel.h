//
//  CMTOtherPostListViewModel.h
//  MedicalForum
//
//  Created by fenglei on 15/1/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTViewModel.h"

FOUNDATION_EXPORT NSString * const CMTOtherPostListCellIdentifier;
FOUNDATION_EXPORT NSString * const CMTGuidePostListCellIdentifier;
FOUNDATION_EXPORT NSString * const CMTOtherLiveListCellIdentifier;

/// 其他文章列表数据
@interface CMTOtherPostListViewModel : CMTViewModel

/* init */

/// 按作者初始化
- (instancetype)initWithAuthorId:(NSString *)authorId;

/// 按类型初始化
- (instancetype)initWithPostTypeId:(NSString *)postTypeId;

/// 按疾病标签初始化
- (instancetype)initWithDisease:(NSString *)disease
                     diseaseIds:(NSString *)diseaseIds
                         module:(NSString *)module;

/// 按二级标签初始化
- (instancetype)initWithKeyword:(NSString *)keyWord
                         module:(NSString *)module;

/// 按学科初始化
- (instancetype)initWithSubjectId:(NSString *)subjectId
                           module:(NSString *)module;

/// 按专题初始化
- (instancetype)initWithThemeId:(NSString *)themeId
                         postId:(NSString *)postId
                         isHTML:(NSString *)isHTML
                        postURL:(NSString *)postURL;
//uid 获取wen'zhan
-(instancetype)initWithThemeUIid:(NSString*)uid;

/* input */

/// 强制刷新状态
@property (nonatomic, assign) BOOL resetState;
/// 刷新状态
@property (nonatomic, assign) NSInteger pullToRefreshState;
/// 翻页状态
@property (nonatomic, assign) NSInteger infiniteScrollingState;

/* binding */

/// 请求完成
@property (nonatomic, assign, readonly) BOOL requestPostFinish;
/// 强制刷新为空
@property (nonatomic, copy, readonly) NSString *resetPostEmptyString;
/// 请求刷新为空
@property (nonatomic, copy, readonly) NSString *requestNewPostEmptyString;
/// 请求翻页为空
@property (nonatomic, copy, readonly) NSString *requestMorePostEmptyString;
/// 请求网络错误
@property (nonatomic, assign, readonly) BOOL requestPostNetError;
/// 请求服务器错误消息
@property (nonatomic, copy, readonly) NSString *requestPostServerErrorMessage;
/// 请求系统错误信息
@property (nonatomic, copy, readonly) NSString *requestPostSystemErrorString;

/// 请求专题指定文章不存在
@property (nonatomic, assign, readonly) BOOL requestThemeSpecifiedPostNotExist;

/* output */

/// 作者Id
@property (nonatomic, copy, readonly) NSString *authorId;
/// 文章类型Id
@property (nonatomic, copy, readonly) NSString *postTypeId;
/// 疾病名
@property (nonatomic, copy, readonly) NSString *disease;
/// 疾病Ids
@property (nonatomic, copy, readonly) NSString *diseaseIds;
/// 文章module
@property (nonatomic, copy, readonly) NSString *module;
/// 二级标签
@property (nonatomic, copy, readonly) NSString *keyWord;
/// 学科Id
@property (nonatomic, copy, readonly) NSString *subjectId;
/// 专题Id
@property (nonatomic, copy, readonly) NSString *themeId;
/// 文章Id
@property (nonatomic, copy, readonly) NSString *postId;
/// 是否为动态详情页
@property (nonatomic, copy, readonly) NSString *isHTML;
/// 动态详情页url
@property (nonatomic, copy, readonly) NSString *postURL;

/// 专题
@property (nonatomic, copy, readonly) CMTTheme *theme;
//直播
@property(nonatomic,copy,readonly)CMTLive *liveinfo;

/// 专题data(所有)
@property (nonatomic, strong) NSMutableArray *arrayTheme;
@property (strong, nonatomic) NSMutableArray *arrayThemeShow;

- (NSInteger)countOfCachePostList;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (CGFloat)heightForHeaderInSection:(NSInteger)section;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (CMTPost *)postForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForRowOfPostId:(NSString *)postId;

/* control */

/// '所有疾病标签'文章列表 刷新数据
- (void)updateDiseaseIds:(NSString *)diseaseIds;

@end
