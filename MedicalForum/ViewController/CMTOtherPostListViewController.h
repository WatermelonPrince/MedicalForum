//
//  CMTOtherPostListViewController.h
//  MedicalForum
//
//  Created by fenglei on 15/1/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTPostStatistics.h"
typedef NS_ENUM(NSUInteger, CMTOtherPostListType) {
    CMTOtherPostListTypeUnDefind = 0,       // 未定义
    CMTOtherPostListTypeAuthor,             // 作者文章列表
    CMTOtherPostListTypePostType,           // 类型文章列表
    CMTOtherPostListTypeDisease,            // 疾病标签文章列表
    CMTOtherPostListTypeKeyword,            // 二级标签文章列表
    CMTOtherPostListTypeSubject,            // 学科文章列表
    CMTOtherPostListTypeTheme,              // 专题文章列表
};

/// 其他文章列表
@interface CMTOtherPostListViewController : CMTBaseViewController

/* init */

/// 作者文章列表
- (instancetype)initWithAuthor:(NSString *)author
                      authorId:(NSString *)authorId;

/// 类型文章列表
- (instancetype)initWithPostType:(NSString *)postType
                      postTypeId:(NSString *)postTypeId;

/// 疾病标签文章列表
- (instancetype)initWithDisease:(NSString *)disease
                     diseaseIds:(NSString *)diseaseIds
                         module:(NSString *)module;

/// 二级标签文章列表
- (instancetype)initWithKeyword:(NSString *)keyWord
                         module:(NSString *)module;

/// 学科文章列表
/// 没有整合, 目前为CMTSubjectPostsViewController
- (instancetype)initWithSubject:(NSString *)subject
                      subjectId:(NSString *)subjectId
                         module:(NSString *)module;

/// 专题文章列表
- (instancetype)initWithThemeId:(NSString *)themeId
                         postId:(NSString *)postId
                         isHTML:(NSString *)isHTML
                        postURL:(NSString *)postURL;
/**
 *  获取专题列表
 *
 *  @param UIid <#UIid description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithThemeUIid:(NSString *)UIid;
/* input */

/// 刷新首页文章统计
/// 进入专题文章列表 指定文章不存在 跳转文章详情时传入文章详情参数
@property (nonatomic, copy) void (^updatePostStatistics)(CMTPostStatistics *);
@property(nonatomic,strong)void(^updateLive)(CMTLive* liveinfo);
@property(nonatomic,strong)void(^updateFocusState)(void);

@property (strong, nonatomic) NSIndexPath *indexPath;

@end
