//
//  CMTPostDetailViewModel.h
//  MedicalForum
//
//  Created by fenglei on 15/1/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTViewModel.h"

FOUNDATION_EXPORT NSString * const CMTPostDetailCommentListCommentCellIdentifier;
FOUNDATION_EXPORT NSString * const CMTPostDetailCommentListReplyCellIdentifier;

/// 文章详情数据
@interface CMTPostDetailViewModel : CMTViewModel

/* init */

- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment;
- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                         group:(CMTGroup*)group
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment;
/* input */

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, weak) UIWebView *webViewModel;

/// 点击重新加载状态
@property (nonatomic, assign) BOOL reloadPostDetailState;
/// 点击刷新状态
@property (nonatomic, assign) BOOL tapToRefreshState;
/// 评论过滤状态
/// 0:全部评论 1:我赞过的评论
@property (nonatomic, copy) NSString *commentFilterState;
/// 翻页状态
@property (nonatomic, assign) NSInteger infiniteScrollingState;
/// 点击发送评论按钮
@property (nonatomic, strong) RACSignal *commentSendButtonSignal;
/// 评论内容
@property (nonatomic, copy) NSString *commentText;
//评论图片
@property(nonatomic,copy)NSString *CommentPicPath;
//提醒人员数组
@property(nonatomic,copy)NSString *remindIDS;
/// 被回复的评论
@property (nonatomic, copy) CMTComment *commentToReply;
/// 被回复的回复
@property (nonatomic, copy) CMTReply *replyToReply;
/// 被删除的评论
@property (nonatomic, copy) CMTComment *commentToDelete;
/// 被删除的回复
@property (nonatomic, copy) CMTReply *replyToDelete;

/* input and binding */

/// 视图是否出现
@property (nonatomic, assign) BOOL viewDidAppearState;
/// 文章详情高度
@property (nonatomic, assign) CGFloat postDetailContentHeight;
/// 简单文章详情高度
@property (nonatomic, assign) CGFloat postDetailHeaderHeight;
/// 阅读文章
@property (nonatomic, assign) BOOL readingPostDetail;
/// 上次阅读文章位置
@property (nonatomic, assign) CGFloat lastContentOffsetY;
/// 快速评论完成 用于从'疾病列表'快速评论按钮进入时弹出键盘
@property (nonatomic, assign) BOOL quickReplyFinish;
/// 文章详情加载完成
@property (nonatomic, assign) BOOL webViewLoadFinish;
@property (nonatomic, assign) BOOL webViewModelLoadFinish;
@property (nonatomic, assign) BOOL postDetailLoadFinish;
/// 评论列表刷新完成 用于从'我发出的评论'页面进入时滑动到指定评论处
@property (nonatomic, assign) BOOL replyListReloadFinish;
/// 文章追加是否发送
@property (nonatomic, assign) BOOL appendDetailSend;
/// 网页链接
@property (nonatomic, copy) NSString *webLink;
/// 文章是否已收藏
@property (nonatomic, assign) BOOL isFavoritePost;
/// 收藏按钮是否生效
@property (nonatomic, assign) BOOL favoriteItemEnable;
/// 图片浏览器是否显示中
@property (nonatomic, assign) BOOL photoBrowserOpening;
/// 图片浏览器显示的图片
@property (nonatomic, copy) NSArray *photoBrowserPhotos;
/// tableView 当前选中的indexPath
@property (nonatomic, copy) NSIndexPath *selectedIndexPath;

/* binding */

/// 文章统计 + 简单详情
@property (nonatomic, copy, readonly) CMTPostStatistics *postStatistics;
/// 文章详情HTML渲染内容
@property (nonatomic, copy, readonly) NSString *postDetailHTMLString;
/// 请求文章详情完成
@property (nonatomic, assign, readonly) BOOL requestPostDetailFinish;
/// 请求文章详情图片完成
@property (nonatomic, assign, readonly) BOOL requestPostDetailImageFinish;
/// 请求文章详情网络错误
@property (nonatomic, assign, readonly) BOOL requestPostDetailNetError;
/// 请求文章详情服务器错误消息
@property (nonatomic, copy, readonly) NSString *requestPostDetailServerErrorMessage;
/// 请求文章详情系统错误信息
@property (nonatomic, copy, readonly) NSString *requestPostDetailSystemErrorString;

/// 文章统计数请求提示信息
@property (nonatomic, copy, readonly) NSString *requestPostStatisticsMessage;
/// 评论列表请求完成
@property (nonatomic, assign, readonly) BOOL requestCommentFinish;
/// 评论列表请求为空
@property (nonatomic, assign, readonly) BOOL requestCommentEmpty;
/// 评论列表请求失败
@property (nonatomic, assign, readonly) BOOL requestCommentError;
/// 评论列表请求提示信息
@property (nonatomic, copy, readonly) NSString *requestCommentMessage;
/// 评论/回复已经发送
@property (nonatomic, assign, readonly) BOOL commentOrReplySend;
/// 发送评论请求完成
@property (nonatomic, assign, readonly) BOOL sendCommentFinish;
/// 发送回复请求完成
@property (nonatomic, assign, readonly) BOOL sendReplyFinish;
/// 发送评论请求失败
@property (nonatomic, assign, readonly) BOOL sendCommentError;
/// 发送评论请求提示信息
@property (nonatomic, copy, readonly) NSString *sendCommentMessage;
/// 删除评论请求完成
@property (nonatomic, assign, readonly) BOOL deleteCommentFinish;
/// 删除回复请求完成
@property (nonatomic, assign, readonly) BOOL deleteReplyFinish;
/// 删除评论请求失败
@property (nonatomic, assign, readonly) BOOL deleteCommentError;
/// 删除评论请求提示信息
@property (nonatomic, copy, readonly) NSString *deleteCommentMessage;

/* output */

/// 文章ID
@property (nonatomic, copy, readonly) NSString *postId;
/// 是否为动态详情页
@property (nonatomic, copy, readonly) NSString *isHTML;
/// 动态详情页url
@property (nonatomic, copy, readonly) NSString *postURL;
/// 文章模块
@property (nonatomic, copy, readonly) NSString *postModule;
/// 文章详情
@property (nonatomic, copy, readonly) CMTPost *postDetail;
/// 评论及回复列表
@property (nonatomic, copy, readonly) NSArray *commentReplyList;
/// 评论列表出现时要显示的评论的indexPath
@property (nonatomic, copy) NSIndexPath *toDisplayedCommentIndexPath;
/// 评论不是最新
@property (nonatomic, assign, readonly) BOOL commentNotUpToDate;
//文章下线错误码标志
@property (nonatomic, copy) NSString *postStatisticsErrorCode;
-(void)updatePoststatics;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (RACTuple *)commentReplyForRowAtIndexPath:(NSIndexPath *)indexPath;

/* control */

- (void)updatePostDetailWithAddPostAdditional:(CMTAddPost *)addPostAdditional;

@end
