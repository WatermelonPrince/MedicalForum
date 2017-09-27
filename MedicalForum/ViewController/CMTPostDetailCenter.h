//
//  CMTPostDetailCenter.h
//  MedicalForum
//
//  Created by fenglei on 15/7/30.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTPostStatistics.h"
#import "CMTGroup.h"

/// 详情类型
typedef NS_ENUM(NSUInteger, CMTPostDetailType) {
    CMTPostDetailTypeUnDefind = 0,          // 未定义
    CMTPostDetailTypeHomePostList,          // 首页文章列表文章详情
    CMTPostDetailTypeCaseList,              // 病例文章列表病例详情
    CMTPostDetailTypeCaseListWithReply,     // 病例文章列表病例详情快速评论弹出键盘(评论数为零)
    CMTPostDetailTypeCaseListSeeReply,      // 病例文章列表病例详情快速评论查看评论(评论数不为零)
    CMTPostDetailTypeCaseGroup,             // 病例小组文章列表病例详情
    CMTPostDetailTypeCommentEdit,           // 通知列表/发出评论列表文章详情
    CMTPostDetailTypeFavoraites,            // 收藏文章列表文章详情
    CMTPostDetailTypeAuthorPostList,        // 作者文章列表文章详情
    CMTPostDetailTypeSearchPostList,        // 搜索文章列表文章详情
    CMTPostDetailTypeCanShare,             //组内文章可以分享
};

/// 详情中心(文章/病例详情)
@interface CMTPostDetailCenter : CMTBaseViewController

/* init */

/// designated constructor
+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                          postModule:(NSString *)postModule
                      postDetailType:(CMTPostDetailType)postDetailType;

+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                          postModule:(NSString *)postModule
                               group:(CMTGroup *)group
                          iscanShare:(BOOL)iscanShare
                      postDetailType:(CMTPostDetailType)postDetailType;
/// 发出评论中的初始化方法
+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                          postModule:(NSString *)postModule
                  toDisplayedComment:(CMTObject *)toDisplayedComment;
/**
 *  <#Description#>
 *
 *  @param postId         文章ID
 *  @param isHTML         是否是动态详情页
 *  @param postURL        页面地址
 *  @param group        小组ID
 *  @param postModule     是否是组内文章
 *  @param postDetailType 键盘弹出方式
 *
 *  @return <#return value description#>
 */
+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                             group:(CMTGroup *)group
                          postModule:(NSString *)postModule
                      postDetailType:(CMTPostDetailType)postDetailType;
/**
 *  Description
 *
 *  @param postId         文章ID
 *  @param isHTML         是否是动态详情页
 *  @param postURL        页面地址
 *  @param group        小组ID
 *  @param postModule     是否是组内文章
 *  @param toDisplayedComment 滚动到评论
 *
 *  @return <#return value description#>
 */
+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                               group:(CMTGroup *)group
                          postModule:(NSString *)postModule
                  toDisplayedComment:(CMTObject *)toDisplayedComment;

// 刷新文章列表文章统计
@property(nonatomic, copy) void (^updatePostStatistics)(CMTPostStatistics *);
//文章屏蔽成功
@property(nonatomic, copy) void (^ShieldingArticleSucess)(CMTPost *post);
//文章置顶或取消置顶成功
@property(nonatomic, copy) void (^PlacedTheTopSucess)(CMTPost *post);
/// 记录收藏页indexPath
@property (nonatomic, strong) NSIndexPath *path;
@end
