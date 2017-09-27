 //
//  CMTPostDetailViewModel.m
//  MedicalForum
//
//  Created by fenglei on 15/1/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTPostDetailViewModel.h"      // header file
#import <AudioToolbox/AudioToolbox.h>   // 调用系统声音播放
#import "SVPullToRefresh.h"             // 下拉刷新 下拉刷新状态
#import "SDWebImageManager.h"           // 图片缓存
#import "SDWebImageOperation.h"         // 图片缓存Operation

NSString * const CMTPostDetailCommentListCommentCellIdentifier = @"CMTPostDetailCommentListCommentCell";
NSString * const CMTPostDetailCommentListReplyCellIdentifier = @"CMTPostDetailCommentListReplyCell";

static NSString * const CMTPostDetailCommentListRequestDefaultPageSize = @"30";

static SystemSoundID shake_sound_male_id = 0; //定义系统播放声音ID add by guoyuanchao
@interface CMTPostDetailViewModel ()

/* input */

// 刷新状态
@property (nonatomic, assign) NSInteger pullToRefreshState;

// binding
@property (nonatomic, copy, readwrite) CMTPostStatistics *postStatistics;                   // 文章统计 + 简单详情
@property (nonatomic, copy, readwrite) NSString *requestPostStatisticsMessage;              // 文章统计数请求提示信息

@property (nonatomic, copy, readwrite) NSString *postDetailHTMLString;                      // 文章详情HTML渲染内容
@property (nonatomic, assign, readwrite) BOOL requestPostDetailFinish;                      // 请求文章详情完成
@property (nonatomic, assign, readwrite) BOOL requestPostDetailImageFinish;                 // 请求文章详情图片完成
@property (nonatomic, assign, readwrite) BOOL requestPostDetailNetError;                    // 请求文章详情网络错误
@property (nonatomic, copy, readwrite) NSString *requestPostDetailServerErrorMessage;       // 请求文章详情服务器错误消息
@property (nonatomic, copy, readwrite) NSString *requestPostDetailSystemErrorString;        // 请求文章详情系统错误信息

@property (nonatomic, assign, readwrite) BOOL requestCommentFinish;                 // 评论列表请求完成
@property (nonatomic, assign, readwrite) BOOL requestCommentEmpty;                  // 评论列表请求为空
@property (nonatomic, assign, readwrite) BOOL requestCommentError;                  // 评论列表请求失败
@property (nonatomic, copy, readwrite) NSString *requestCommentMessage;             // 请求提示信息
@property (nonatomic, assign, readwrite) BOOL commentOrReplySend;                   // 评论/回复已经发送
@property (nonatomic, assign, readwrite) BOOL sendCommentFinish;                    // 发送评论请求完成
@property (nonatomic, assign, readwrite) BOOL sendReplyFinish;                      // 发送回复请求完成
@property (nonatomic, assign, readwrite) BOOL sendCommentError;                     // 发送评论请求失败
@property (nonatomic, copy, readwrite) NSString *sendCommentMessage;                // 发送评论请求提示信息
@property (nonatomic, assign, readwrite) BOOL deleteCommentFinish;                  // 删除评论请求完成
@property (nonatomic, assign, readwrite) BOOL deleteReplyFinish;                    // 删除回复请求完成
@property (nonatomic, assign, readwrite) BOOL deleteCommentError;                   // 删除评论请求失败
@property (nonatomic, copy, readwrite) NSString *deleteCommentMessage;              // 删除评论请求提示信息

// data
@property (nonatomic, copy, readwrite) NSString *postId;                            // 文章ID
@property (nonatomic, copy, readwrite) NSString *isHTML;                            // 是否为动态详情页
@property (nonatomic, copy, readwrite) NSString *postURL;                           // 动态详情页url
@property (nonatomic, copy, readwrite) NSString *postModule;                        // 文章模块
@property (nonatomic, copy, readwrite) CMTPost *postDetail;                         // 文章详情
@property (nonatomic, copy, readwrite) CMTObject *toDisplayedComment;               // 界面出现要显示的评论 CMTReceivedComment/CMTSendComment
@property (nonatomic, copy) NSArray *commentList;                                   // 评论列表
@property (nonatomic, copy) NSArray *commentReplyList;                              // 评论及回复列表 RACTuple(CMTComment/CMTReply, @NO/@YES(last reply of comment), CMTComment, index)

@property (nonatomic, assign, readwrite) BOOL commentNotUpToDate;                   // 评论不是最新
@property(nonatomic,strong)CMTGroup *mygroup;

@end

@implementation CMTPostDetailViewModel

#pragma mark 文章详情 Request

// 请求文章详情
- (RACSignal *)requestPostDetail {
    @weakify(self);
    return [[RACObserve(self, reloadPostDetailState) ignore:@NO] map:^id(id value) {
        @strongify(self);
        return [CMTCLIENT getPostDetail:@{
                                          @"userId": CMTUSERINFO.userId ?: @"",
                                          @"postId": self.postId ?: @"",
                                          @"groupId":self.mygroup.groupId?:@"",
                                          }];
    }];
}

#pragma mark 文章统计数 Request

// 请求文章统计数 + 简单详情
- (RACSignal *)requestPostStatistics {
    return [CMTCLIENT getPostStatistics:@{
                                          @"userId": CMTUSERINFO.userId ?: @"",
                                          @"postId": self.postId ?: @"",
                                          @"groupId":self.mygroup.groupId?:@"",
                                          }];
}

#pragma mark 评论列表 Request

// 强制刷新
- (RACSignal *)requestResetCommentListSignal {
    @weakify(self);
    return [[RACObserve(self, commentFilterState) ignore:nil] map:^id(id value) {
        @strongify(self);
        return [self getCommentListWithCommentId:nil commentIdFlag:@"0"];
    }];
}

// 刷新
- (RACSignal *)requestNewCommentListSignal {
    @weakify(self);
    return  [[RACObserve(self, pullToRefreshState)
              filter:^BOOL(NSNumber *state) {
                  return state.integerValue == SVPullToRefreshStateLoading;
              }] map:^id(id value) {
                  @strongify(self);
                  CMTComment *firstComment = self.commentList.firstObject;
                  return [self getCommentListWithCommentId:firstComment.commentId commentIdFlag:@"0"];
              }];
}

// 翻页
- (RACSignal *)requestMoreCommentListSignal {
    @weakify(self);
    return [[RACObserve(self, infiniteScrollingState)
             filter:^BOOL(NSNumber *state) {
                 return state.integerValue == SVInfiniteScrollingStateLoading;
             }] map:^id(id value) {
                 @strongify(self);
                 CMTComment *lastComment = self.commentList.lastObject;
                 return [self getCommentListWithCommentId:lastComment.commentId commentIdFlag:@"1"];
             }];
}

// 从指定评论处翻页
- (RACSignal *)requestSpecifiedCommentListSignal:(NSString *)commentId {
    return [self getCommentListWithCommentId:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:[commentId integerValue] - 1]]
                               commentIdFlag:@"1"];
}

// 请求评论列表
- (RACSignal *)getCommentListWithCommentId:(NSString *)commentId commentIdFlag:(NSString *)commentIdFlag {
    return [CMTCLIENT getCommentList:@{
                                       @"userId": CMTUSERINFO.userId ?: @"",
                                       @"postId": self.postId ?: @"",
                                       @"commentId": commentId ?: @"",
                                       @"commentIdFlag": commentIdFlag ?: @"",
                                       @"pageSize": CMTPostDetailCommentListRequestDefaultPageSize ?: @"",
                                       @"myPraise": self.commentFilterState ?: @"",
                                       }];
}

#pragma mark 发送评论 Request

// 评论文章
- (RACSignal *)sendComment {
    return [CMTCLIENT sendComment:@{
                                    @"userId": CMTUSERINFO.userId ?: @"",
                                    @"postId": self.postId ?: @"",
                                    @"authorId": self.postDetail.authorId ?: @"",
                                    @"content": self.commentText ?: @"",
                                    @"atUserIds":self.remindIDS?:@"",
                                    @"picture":self.CommentPicPath?:@"",
                                    }];
}

// 回复评论
- (RACSignal *)replyCommentWithCommentId:(NSString *)commentId replyId:(NSString *)replyId {
    return [CMTCLIENT replyComment:@{
                                    @"userId": CMTUSERINFO.userId ?: @"",
                                    @"commentId": commentId ?: @"",
                                    @"replyId": replyId ?: @"",
                                    @"content": self.commentText ?: @"",
                                    }];
}

#pragma mark 删除评论 Request

- (RACSignal *)deleteCommentWithCommentId:(NSString *)commentId {
    return [CMTCLIENT deleteComment:@{
                                      @"userId": CMTUSERINFO.userId ?: @"",
                                      @"postId": self.postId ?: @"",
                                      @"commentId": commentId ?: @"",
                                      }];
}

- (RACSignal *)deleteReplyWithReplyId:(NSString *)replyId {
    return [CMTCLIENT deleteReply:@{
                                    @"userId": CMTUSERINFO.userId ?: @"",
                                    @"postId": self.postId ?: @"",
                                    @"replyId": replyId ?: @"",
                                    }];
}

#pragma mark Initializers

- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.postId = postId;
    self.isHTML = isHTML;
    self.postURL = postURL;
    self.postModule = postModule;
    self.toDisplayedComment = toDisplayedComment;
    self.commentNotUpToDate = (toDisplayedComment == nil) ? NO : YES;
    self.mygroup=nil;
    [self initialize];
    
    return self;
}
- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                        group:(CMTGroup*)group
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.postId = postId;
    self.isHTML = isHTML;
    self.postURL = postURL;
    self.postModule = postModule;
    self.toDisplayedComment = toDisplayedComment;
    self.commentNotUpToDate = (toDisplayedComment == nil) ? NO : YES;
       self.mygroup=group;
    [self initialize];
    
    return self;
}


// 初始化
- (void)initialize {
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostDetail ViewModel willDeallocSignal");
    }];
    
#pragma mark 文章详情 initialize
    
    // 读取缓存
    // 病例模块不读取缓存
    if (!self.postModule.isPostModuleCase) {
        self.postDetail = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_CACHE_POSTS stringByAppendingPathComponent:self.postId]];
    }
    if (self.postDetail == nil) {
        self.reloadPostDetailState = YES;
    }
    
    // 文章详情
    [[self requestPostDetail] subscribeNext:^(RACSignal *getPostDetailSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getPostDetailSignal subscribeNext:^(CMTPost *postDetail) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            if (postDetail == nil) {
                self.requestPostDetailSystemErrorString = @"PostDetail Request Post Detail Get Nil";
            } else {
                self.postDetail = postDetail;
            }
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handlePostDetailError:error];
        }]];
    }];
    
#pragma mark 评论列表 initialize
    
    // 处理强制刷新
    [[self requestResetCommentListSignal] subscribeNext:^(RACSignal *getCommentListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getCommentListSignal subscribeNext:^(NSArray *resetList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            [self handleResetList:resetList];
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleError:error];
        }]];
    }];
    
    // 处理刷新
    [[self requestNewCommentListSignal] subscribeNext:^(RACSignal *getCommentListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getCommentListSignal subscribeNext:^(NSArray *newList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            if (newList.count < [CMTPostDetailCommentListRequestDefaultPageSize integerValue]) {
                self.commentNotUpToDate = NO;
            }
            [self handleNewList:newList];
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleError:error];
        }]];
    }];

    // 处理翻页
    [[self requestMoreCommentListSignal] subscribeNext:^(RACSignal *getCommentListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getCommentListSignal subscribeNext:^(NSArray *moreList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            [self handleMoreList:moreList];
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleError:error];
        }]];
    }];

    // 点击刷新 向上请求更新的评论列表
    [[RACObserve(self, tapToRefreshState) ignore:@NO] subscribeNext:^(id x) {
        @strongify(self);
        self.pullToRefreshState = SVPullToRefreshStateLoading;
    }];
    
    // 有特定的评论需要显示 请求特定的评论列表
    if (self.toDisplayedComment != nil) {
        if ([self.toDisplayedComment respondsToSelector:@selector(commentId)]) {
            
            [self.rac_deallocDisposable addDisposable:
             [[self requestSpecifiedCommentListSignal:[self.toDisplayedComment performSelector:@selector(commentId)]]
             subscribeNext:^(NSArray *moreList) {
                 @strongify(self);
                 DEALLOC_HANDLE_SUCCESS
                 [self handleMoreList:moreList];
            } error:^(NSError *error) {
                @strongify(self);
                DEALLOC_HANDLE_FAILURE
                [self handleError:error];
            }]];
        }
    }
    // 无特定需求 请求最新的评论列表
    else {
        self.pullToRefreshState = SVPullToRefreshStateLoading;
    }

    // 获取要显示的特定评论的indexPath
    [[[[RACObserve(self, toDisplayedComment) ignore:nil] distinctUntilChanged] combineLatestWith:
     [[RACObserve(self, requestCommentFinish) ignore:@NO] distinctUntilChanged]] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        NSIndexPath *indexPath = nil;
        NSString *commentId, *replyId;
        @try {
            if ([tuple.first isKindOfClass:[CMTReceivedComment class]]) {
                commentId = [(CMTReceivedComment *)tuple.first commentId];
                replyId = [(CMTReceivedComment *)tuple.first replyId];
            }
            else if ([tuple.first isKindOfClass:[CMTSendComment class]]) {
                commentId = [(CMTSendComment *)tuple.first commentId];
                replyId = [(CMTSendComment *)tuple.first replyId];
            }
        }
        @catch (NSException *exception) {
            commentId = nil;
            replyId = nil;
            CMTLogError(@"PostDetail To Display Comment Get CommentID/ReplyID Exception: %@", exception);
        }
        
        // 要显示的为回复
        if (!BEMPTY(replyId)) {
            @try {
                int index = 0;
                for (RACTuple *commentReply in self.commentReplyList) {
                    if ([commentReply.first isKindOfClass:[CMTReply class]]) {
                        if ([[(CMTReply *)commentReply.first replyId] isEqual:replyId]) {
                            indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        }
                    }
                    index++;
                }
            }
            @catch (NSException *exception) {
                indexPath = nil;
                CMTLogError(@"PostDetail To Display Comment Get IndexPath For Reply Exception: %@", exception);
            }
        }
        // 要显示的为评论
        else if (!BEMPTY(commentId)) {
            @try {
                int index = 0;
                for (RACTuple *commentReply in self.commentReplyList) {
                    if ([commentReply.first isKindOfClass:[CMTComment class]]) {
                        if ([[(CMTComment *)commentReply.first commentId] isEqual:commentId]) {
                            indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        }
                    }
                    index++;
                }
            }
            @catch (NSException *exception) {
                indexPath = nil;
                CMTLogError(@"PostDetail To Display Comment Get IndexPath For Comment Exception: %@", exception);
            }
        }
        else {
            CMTLogError(@"PostDetail To Display Comment Get CommentID/ReplyID Error");
        }
        
        // 设置要显示的特定评论的indexPath
        self.toDisplayedCommentIndexPath = indexPath;
    }];

#pragma mark 发送评论 initialize
    
    // 点击发送评论
    [[[[RACObserve(self, commentSendButtonSignal) ignore:nil] distinctUntilChanged] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return self.commentSendButtonSignal;
    }] subscribeNext:^(id x) {
        @strongify(self);
        // 登录状态
        if (CMTUSER.login == YES) {
            
            // 回复评论
            if (self.commentToReply != nil) {
                [self.rac_deallocDisposable addDisposable:
                 [[self replyCommentWithCommentId:self.commentToReply.commentId replyId:nil] subscribeNext:^(CMTReply *reply) {
                    @strongify(self);
                    DEALLOC_HANDLE_SUCCESS
                    // 播放提示音 add by guoyuanchao
                    [self CMT_SendSucess_Voice_broadcast];
                    
                    [self insertNewReply:reply];
                } error:^(NSError *error) {
                    @strongify(self);
                    DEALLOC_HANDLE_FAILURE
                    [self handleSendCommentError:error];
                }]];
            }
            // 回复回复
            else if (self.replyToReply != nil) {
                [self.rac_deallocDisposable addDisposable:
                 [[self replyCommentWithCommentId:self.replyToReply.commentId replyId:self.replyToReply.replyId] subscribeNext:^(CMTReply *reply) {
                    @strongify(self);
                    DEALLOC_HANDLE_SUCCESS
                    // 播放提示音 add by guoyuanchao
                    [self CMT_SendSucess_Voice_broadcast];
                    
                    [self insertNewReply:reply];
                } error:^(NSError *error) {
                    @strongify(self);
                    DEALLOC_HANDLE_FAILURE
                    [self handleSendCommentError:error];
                }]];
            }
            // 评论文章
            else {
                [self.rac_deallocDisposable addDisposable:
                 [[self sendComment] subscribeNext:^(CMTComment *comment) {
                    @strongify(self);
                    DEALLOC_HANDLE_SUCCESS
                     // 播放提示音 add by guoyuanchao
                    [self CMT_SendSucess_Voice_broadcast];
                    [self insertNewComment:comment];
                } error:^(NSError *error) {
                    @strongify(self);
                    DEALLOC_HANDLE_FAILURE
                    [self handleSendCommentError:error];
                }]];
            }
            // 评论/回复已经发送
            self.commentOrReplySend = YES;
        }
    }];
    
#pragma mark 删除评论 initialize
    
    // 删除评论
    [[RACObserve(self, commentToDelete) ignore:nil] subscribeNext:^(CMTComment *comment) {
        @strongify(self);
        // 登陆状态
        if (CMTUSER.login == YES) {
            // 删除列表中的评论
            [self deleteComment:comment];
            // 调用删除评论接口
            [self.rac_deallocDisposable addDisposable:
             [[self deleteCommentWithCommentId:comment.commentId] subscribeNext:^(id x) {
                @strongify(self);
                DEALLOC_HANDLE_SUCCESS
                self.deleteCommentFinish = YES;
            } error:^(NSError *error) {
                @strongify(self);
                DEALLOC_HANDLE_FAILURE
                [self handleDeleteCommentError:error];
            }]];
        }
    }];
    
    // 删除回复
    [[RACObserve(self, replyToDelete) ignore:nil] subscribeNext:^(CMTReply *reply) {
        @strongify(self);
        // 登陆状态
        if (CMTUSER.login == YES) {
            // 删除列表中的回复
            [self deleteReply:reply];
            // 调用删除回复接口
            [self.rac_deallocDisposable addDisposable:
             [[self deleteReplyWithReplyId:reply.replyId] subscribeNext:^(id x) {
                @strongify(self);
                DEALLOC_HANDLE_SUCCESS
                self.deleteReplyFinish = YES;
            } error:^(NSError *error) {
                @strongify(self);
                DEALLOC_HANDLE_FAILURE
                [self handleDeleteCommentError:error];
            }]];
        }
    }];
    
}

//添加发送成功声音提醒 add by guoyuanchao
-(void)CMT_SendSucess_Voice_broadcast{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"send_comment" ofType:@"mp3"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
    
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音
    
}
#pragma mark 更新通知数
-(void)updatePoststatics{
    @weakify(self);
    [[self requestPostStatistics] subscribeNext:^(CMTPostStatistics *postStatistics) {
        @strongify(self);
        DEALLOC_HANDLE_SUCCESS
        if (postStatistics != nil) {
            self.postStatistics = postStatistics;
        }
    } error:^(NSError *error) {
        @strongify(self);
        DEALLOC_HANDLE_FAILURE
        // 100 参数错误; 101 文章不存在; 102 文章已被下线; 107病例被移除小组
        self.postStatisticsErrorCode = error.userInfo[CMTClientServerErrorCodeKey];
        [self handlePostStatisticsError:error];
    }];

}
#pragma mark LifeCycle

#pragma mark 文章详情 handle

- (void)updatePostDetailWithAddPostAdditional:(CMTAddPost *)addPostAdditional {
    
    // 更新图片数组
    NSMutableArray *imageList = [NSMutableArray arrayWithArray:self.postDetail.imageList];
    [imageList addObjectsFromArray:addPostAdditional.picList];
    self.postDetail.imageList = imageList;
    
    // 更新文章追加
    NSMutableArray *postDiseaseExtList = [NSMutableArray arrayWithArray:self.postDetail.postDiseaseExtList];
    [postDiseaseExtList addObject:addPostAdditional];
    self.postDetail.postDiseaseExtList = postDiseaseExtList;
    
    // 更新文章详情
    self.appendDetailSend = YES;
    self.postDetail = self.postDetail;
}

// 处理文章详情
- (void)setPostDetail:(CMTPost *)postDetail {
    if (postDetail == nil) {
        return;
    }
    
    // 文章统计数 + 简单详情
    if (self.postStatistics == nil) {
        @weakify(self);
        [[self requestPostStatistics] subscribeNext:^(CMTPostStatistics *postStatistics) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            if (postStatistics != nil) {
                self.postStatistics = postStatistics;
            }
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            // 100 参数错误; 101 文章不存在; 102 文章已被下线; 107病例被移除小组
            self.postStatisticsErrorCode = error.userInfo[CMTClientServerErrorCodeKey];
            [self handlePostStatisticsError:error];
        }];
    }
    
    // 替换HTMLString
    NSString *authorId = !postDetail.module.isPostModuleGuide ? postDetail.authorId : nil;
    NSString *author = !postDetail.module.isPostModuleGuide ? postDetail.author : postDetail.issuingAgency;
    NSMutableArray *imageRequestURLPairArray = [NSMutableArray array];

    NSString *postDetailHTMLString = nil;
    if (postDetail.module.isPostModuleCase) {
        postDetailHTMLString = [NSString caseDetailHTMLStringWithPostDetail:postDetail
                                                                   authorId:authorId
                                                                     author:author
                                                   imageRequestURLPairArray:imageRequestURLPairArray];
    }
    else {
        postDetailHTMLString = [NSString postDetailHTMLStringWithTitle:postDetail.title
                                                                  date:self.postModule.integerValue==2?postDetail.guideReleaseTime:postDetail.createTime
                                                              authorId:authorId
                                                                author:author
                                                            postTypeId:postDetail.postTypeId
                                                              postType:postDetail.postType
                                                              postAttr:postDetail.postAttr
                                                                module:postDetail.module
                                                        customFontSize:CMTAPPCONFIG.customFontSize
                                                                postId:postDetail.postId
                                                               themeId:postDetail.themeId
                                                                 theme:postDetail.theme
                                                         diseaseTagArr:postDetail.diseaseTagArr
                                                            postTagArr:postDetail.postTagArr
                                                     contentHTMLString:postDetail.content
                                              imageRequestURLPairArray:imageRequestURLPairArray];
    }
    
    // 验证HTMLString
    if (!BEMPTY(postDetailHTMLString)) {
        // 刷新文章详情
        _postDetail = [postDetail copy];
        // 刷新文章详情模版
        self.postDetailHTMLString = postDetailHTMLString;
        // 刷新webView
        self.requestPostDetailFinish = YES;
        // 请求无缓存的图片
        [self requestPostDetailImageWithReplaceChipforRequestURLArray:imageRequestURLPairArray];
        // 缓存文章详情
        if (!self.isHTML.boolValue) {
          if (![NSKeyedArchiver archiveRootObject:postDetail toFile:[PATH_CACHE_POSTS stringByAppendingPathComponent:self.postId]]) {
            CMTLogError(@"Archive PostDetail:%@\nto Store Error: %@", postDetail, [PATH_CACHE_POSTS stringByAppendingPathComponent:self.postId]);

           }
        }

    }
    else {
        [self handlePostDetailErrorMessage:@"PostDetail Replace HTMLString Error: Empty HTMLString"];
    }
}

// 请求无缓存的图片
- (void)requestPostDetailImageWithReplaceChipforRequestURLArray:(NSArray *)replaceChipforRequestURLArray {
    for (NSDictionary *replaceChipforRequestURL in replaceChipforRequestURLArray) {
        // 原始图片URL
        NSString *imageURLString = [[replaceChipforRequestURL allKeys] objectAtIndex:0];
        // 被替换的路径
        NSString *replaceChip = replaceChipforRequestURL[imageURLString];
        // 请求图片
        SDWebImageManager *webImageManager = [[SDWebImageManager alloc] init];
        // 文章图片用@90Q作为原始图片
        NSString *requestImageURLString = [UIImage fullQualityImageURLWithURL:imageURLString];
        // 原始图片有缓存 用原始图片
        NSString *cacheKey = [webImageManager cacheKeyForURL:[NSURL URLWithString:requestImageURLString]];
        NSString *cachePath = [webImageManager.imageCache defaultCachePathForKey:cacheKey];
        // 原始图片没有缓存
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            // 病例模块
            if ([self.postDetail.module isPostModuleCase]) {
                // 请求@40Q并指定宽度截取图片
                CGFloat imageCount = self.postDetail.imageList.count;
                CGFloat imageWidth = (SCREEN_WIDTH - 70.0)/4.0;
                if (imageCount == 1) {
                    imageWidth = (imageWidth*3.0 + 30.0)/2.0;
                }
                else if (imageCount == 2 || imageCount == 4) {
                    imageWidth = (imageWidth*3.0 + 10.0)/2.0;
                }
                requestImageURLString = [UIImage lowQualityImageURLWithURL:imageURLString contentSize:CGSizeMake(imageWidth, imageWidth)];
            }
            // 其他模块
            else {
                // 请求@40Q图片
                requestImageURLString = [UIImage lowQualityImageURLWithURL:imageURLString];
            }
        }

        // 作者头像按尺寸截取
        if ([replaceChip isEqual:CMTNSStringHTMLTemplateDefaultAuthorImage]) {
            requestImageURLString = [UIImage quadrateScaledImageURLWithURL:imageURLString width:40.0];
        }
        
        @weakify(self);
        [webImageManager downloadImageWithURL:[NSURL URLWithString:requestImageURLString]
                                      options:SDWebImageHighPriority
                                     progress:nil
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                        @strongify(self);
                                        if (error) {
                                            CMTLogError(@"PostDetail failed to download image: %@", error);
                                        }
                                        else {
                                            // 获取本地图片路径
                                            NSString *cacheKey = [webImageManager cacheKeyForURL:imageURL];
                                            NSString *imagePathString = [webImageManager.imageCache defaultCachePathForKey:cacheKey];
                                            // 检查图片是否已经缓存到本地
                                            [[[[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                                                BOOL diskImageExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePathString];
                                                if (diskImageExists == YES) {
                                                    [subscriber sendNext:imagePathString];
                                                    [subscriber sendCompleted];
                                                }
                                                else {
                                                    [subscriber sendError:[NSError errorWithDomain:@"DiskImage Not Exists While Image Download Completed"
                                                                                              code:0
                                                                                          userInfo:@{
                                                                                                     @"imageURL": imageURL ?: @"",
                                                                                                     @"imagePath": imagePathString ?: @"",
                                                                                                     }]];
                                                }
                                                return nil;
                                            }] catch:^(NSError *error) {
                                                return [[[RACSignal empty] delay:1.0] concat:[RACSignal error:error]];
                                            }] retry:5] delay:0.5]
                                              deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                                                @strongify(self);
                                                [self updatePostDetailImageWithReplaceChip:replaceChip
                                                                            imageURLString:imageURLString
                                                                           imagePathString:imagePathString];
                                            } error:^(NSError *error) {
                                                CMTLogError(@"图片缓存过慢 读取本地路径失败: %@", error);
                                            }];
                                        }
                                    }];
    }
}

// 更新图片
- (void)updatePostDetailImageWithReplaceChip:(NSString *)replaceChip
                              imageURLString:(NSString *)imageURLString
                             imagePathString:(NSString *)imagePathString {
    // 作者头像
    if ([replaceChip isEqual:CMTNSStringHTMLTemplateDefaultAuthorImage]) {
        [self.webViewModel stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"replaceImage('%@', '%@')", CMTNSStringHTMLTemplateDefaultAuthorImage, imagePathString]];
        [self.webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"replaceImage('%@', '%@')", CMTNSStringHTMLTemplateDefaultAuthorImage, imagePathString]];
    }
    // 文章图片
    else {
        [self.webViewModel stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"replaceImage('%@', '%@')", imageURLString, imagePathString]];
        [self.webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"replaceImage('%@', '%@')", imageURLString, imagePathString]];
    }
    
    self.requestPostDetailImageFinish = YES;
}

// 处理错误
- (void)handlePostDetailError:(NSError *)error {
    // 网络错误
    if ([error.domain isEqual:NSURLErrorDomain]) {
        self.requestPostDetailNetError = YES;
    }
    // 服务器返回错误
    else if ([error.domain isEqual:CMTClientServerErrorDomain]) {
        // 业务参数错误
        if ([error.userInfo[CMTClientServerErrorCodeKey] integerValue] > 100) {
            self.requestPostDetailServerErrorMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        }
        // 系统错误/错误代码格式错误
        else {
            self.requestPostDetailSystemErrorString = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        }
    }
    // 解析错误/未知错误
    else  {
        self.requestPostDetailSystemErrorString = error.localizedDescription;
    }
}

// 处理错误信息
- (void)handlePostDetailErrorMessage:(NSString *)errorMessgae, ... {
    NSString *errorString = nil;
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            errorString = [[NSString alloc] initWithFormat:errorMessgae arguments:args];
            va_end(args);
        }
        self.requestPostDetailSystemErrorString = errorString;
    }
    @catch (NSException *exception) {
        self.requestPostDetailSystemErrorString = [NSString stringWithFormat:@"PostDetail PostDetail HandleErrorMessage Exception: %@", exception];
    }
}

#pragma mark 文章统计数 handle

// 处理错误
- (void)handlePostStatisticsError:(NSError *)error {
    @try {
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            self.requestPostStatisticsMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        } else {
            CMTLogError(@"PostDetail Request PostStatistics System Error: %@", error);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Request PostStatistics HandleError:%@\nException: %@", error, exception);
    }
}

#pragma mark 评论列表 handle

// 处理强制刷新列表
- (void)handleResetList:(NSArray *)resetList {
    @try {
        // empty list
        if ([resetList count] == 0) {
            self.commentList = @[];
        }
        // set list
        else {
            self.commentList = resetList;
        }
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostDetail Request ResetComment List Exception: %@", exception];
    }
}

// 处理刷新列表
- (void)handleNewList:(NSArray *)newList {
    @try {
        // empty list
        if ([newList count] == 0) {
            [self handleEmpty:@"最新"];
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:newList];
        [combindList addObjectsFromArray:self.commentList];
        // cut short list
        NSUInteger pageSize = CMTPostDetailCommentListRequestDefaultPageSize.integerValue;
        while (combindList.count > pageSize) {
            [combindList removeObjectAtIndex:pageSize];
        }
        // set list
        self.commentList = combindList;
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostDetail Request NewComment List Exception: %@", exception];
    }
}

// 处理翻页列表
- (void)handleMoreList:(NSArray *)moreList {
    @try {
        // empty list
        if ([moreList count] == 0) {
            [self handleEmpty:@"没有更多"];
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:self.commentList];
        [combindList addObjectsFromArray:moreList];
        // set list
        self.commentList = combindList;
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostDetail Request MoreComment List Exception: %@", exception];
    }
}

// 列表 显示
- (void)setCommentList:(NSArray *)commentList {
    
    NSMutableArray *commentReplys = [NSMutableArray array];
    @try {
        for (CMTComment *comment in commentList) {
            RACTuple *commentTuple = RACTuplePack(comment, @NO, comment, @0);
            [commentReplys addObject:commentTuple];
            
            int index = 1;
            for (CMTReply *reply in comment.replyList) {
                RACTuple *replyTuple = nil;
                if (index == comment.replyList.count) {
                    replyTuple = RACTuplePack(reply, @YES, comment, [NSNumber numberWithInt:index]);
                } else {
                    replyTuple = RACTuplePack(reply, @NO, comment, [NSNumber numberWithInt:index]);
                }
                [commentReplys addObject:replyTuple];
                index++;
            }
        }
        
        // 刷新列表 列表count可以为0
        _commentList = [commentList copy];
        self.commentReplyList = [NSArray arrayWithArray:commentReplys];
        self.requestCommentFinish = YES;
    }
    @catch (NSException *exception) {
        _commentList = [[NSArray array] copy];
        self.commentReplyList = [NSArray array];
        self.requestCommentFinish = YES;
        [self handleErrorMessage:@"PostDetail Comment List Group CommentReplys Exception: %@", exception];
    }
}

// 处理错误
- (void)handleError:(NSError *)error {
    self.requestCommentError = YES;
    
    @try {
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            self.requestCommentMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        }else if (error.code == NSURLErrorCannotConnectToHost){
            self.requestCommentMessage = @"你的网络不给力";
        }
        else {
            CMTLogError(@"PostDetail Request Comment List System Error: %@", error);
            
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Request Comment List HandleError:%@\nException: %@", error, exception);
    }
}

// 处理错误信息
- (void)handleErrorMessage:(NSString *)errorMessgae, ... {
    self.requestCommentError = YES;
    
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            CMTLogError(@"%@", [[NSString alloc] initWithFormat:errorMessgae arguments:args]);
            va_end(args);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Comment List HandleErrorMessage Exception: %@", exception);
    }
}

// 处理空结果
- (void)handleEmpty:(NSString *)emptyMessage {
    self.requestCommentEmpty = YES;
    self.requestCommentMessage = emptyMessage;
}

#pragma mark 发送评论 handle

// 插入新评论
- (void)insertNewComment:(CMTComment *)comment {
    @try {
        CMTComment *newComment = [[CMTComment alloc] initWithDictionary:@{
                                                                          @"commentId": comment.commentId ?: @"",
                                                                          @"userId": comment.userId ?: @"",
                                                                          @"nickname": CMTUSERINFO.nickname ?: @"",
                                                                          @"picture": CMTUSERINFO.picture ?: @"",
                                                                          @"content": comment.content ?: @"",
                                                                          @"isPraise": comment.isPraise ?: @"",
                                                                          @"praiseCount": comment.praiseCount ?: @"0",
                                                                          @"createTime": comment.createTime ?: @"",
                                                                           @"commentPic":comment.commentPic?: @"",
                                                                           @"atUsers": comment.atUsers?: @"",
                                                                          @"replyList": @[],
                                                                          } error:nil];
        NSMutableArray *newCommentList = [NSMutableArray arrayWithObjects:newComment, nil];
        [newCommentList  addObjectsFromArray: self.commentList];
        // 刷新评论列表
        self.commentList = [NSArray arrayWithArray:newCommentList];
        // 提示评论成功
        self.sendCommentFinish = YES;
        // 增加评论数
        self.postStatistics.commentCount = [NSString stringWithFormat:@"%ld", (long)(self.postStatistics.commentCount.integerValue + 1)];
    }
    @catch (NSException *exception) {
        [self handleSendCommentErrorMessage:@"PostDetail Insert New Comment Exception: %@", exception];
    }
}

// 插入新回复
- (void)insertNewReply:(CMTReply *)reply {
    @try {
        NSArray *commentList = [NSArray arrayWithArray:self.commentList];
        for (CMTComment *comment in commentList) {
            if ([comment.commentId isEqual:reply.commentId]) {
                NSMutableArray *replyList = [NSMutableArray arrayWithArray:comment.replyList];
                NSString *beNickname, *bePicture;
                
                // 对回复的回复
                if ([reply.replyType isEqual:@"1"]) {
                    // 获取被回复的回复的beNickname, bePicture
                    for (CMTReply *beReply in replyList) {
                        if ([beReply.replyId isEqual:reply.beReplyId]) {
                            beNickname = beReply.nickname;
                            bePicture = beReply.picture;
                        }
                    }
                }
                CMTReply *newReply = [[CMTReply alloc] initWithDictionary:@{
                                                                            @"commentId": reply.commentId ?: @"",
                                                                            @"replyId": reply.replyId ?: @"",
                                                                            @"userId": reply.userId ?: @"",
                                                                            @"nickname": CMTUSERINFO.nickname ?: @"",
                                                                            @"picture": CMTUSERINFO.picture ?: @"",
                                                                            @"content": reply.content ?: @"",
                                                                            @"isPraise": reply.isPraise ?: @"",
                                                                            @"praiseCount": reply.praiseCount ?: @"0",
                                                                            @"createTime": reply.createTime ?: @"",
                                                                            @"replyType": reply.replyType ?: @"",
                                                                            @"beUserId": reply.beUserId ?: @"",
                                                                            @"beReplyId": reply.beReplyId ?: @"",
                                                                            @"beNickname": beNickname ?: @"",
                                                                            @"bePicture": bePicture ?: @"",
                                                                            } error:nil];
                [replyList addObject:newReply];
                comment.replyList = [NSArray arrayWithArray:replyList];
            }
        }
        // 刷新评论列表
        self.commentList = commentList;
        // 提示回复成功
        self.sendReplyFinish = YES;
    }
    @catch (NSException *exception) {
        [self handleSendCommentErrorMessage:@"PostDetail Insert New Reply Exception: %@", exception];
    }
}

// 处理错误
- (void)handleSendCommentError:(NSError *)error {
    self.sendCommentError = YES;
     self.sendCommentMessage=@"你的网络不给力";
    @try {
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            self.sendCommentMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        } else {
            CMTLogError(@"PostDetail Send Comment System Error: %@", error);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Send Comment HandleError:%@\nException: %@", error, exception);
    }
}

// 处理错误信息
- (void)handleSendCommentErrorMessage:(NSString *)errorMessgae, ... {
    self.sendCommentError = YES;
    
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            CMTLogError(@"%@", [[NSString alloc] initWithFormat:errorMessgae arguments:args]);
            va_end(args);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Send Comment HandleErrorMessage Exception: %@", exception);
    }
}

#pragma mark 删除评论 handle

// 删除评论
- (void)deleteComment:(CMTComment *)commentToDelete {
    @try {
        NSMutableArray *commentList = [NSMutableArray arrayWithArray:self.commentList];
        for (NSUInteger index = 0; index < commentList.count; index++) {
            CMTComment *comment = commentList[index];
            if ([comment.commentId isEqual:commentToDelete.commentId]) {
                [commentList removeObjectAtIndex:index];
                break;
            }
        }
        // 刷新评论列表
        self.commentList = [NSArray arrayWithArray:commentList];
        // 减小评论数
        self.postStatistics.commentCount = [NSString stringWithFormat:@"%ld", (long)(self.postStatistics.commentCount.integerValue - 1)];
    }
    @catch (NSException *exception) {
        [self handleDeleteCommentErrorMessage:@"PostDetail Delete Comment Exception: %@", exception];
    }
}

// 删除回复
- (void)deleteReply:(CMTReply *)replyToDelete {
    @try {
        NSMutableArray *commentList = [NSMutableArray arrayWithArray:self.commentList];
        for (CMTComment *comment in commentList) {
            if ([comment.commentId isEqual:replyToDelete.commentId]) {
                NSMutableArray *replyList = [NSMutableArray arrayWithArray:comment.replyList];
                for (NSUInteger index = 0; index < replyList.count; index++) {
                    CMTReply *reply = replyList[index];
                    if ([reply.replyId isEqual:replyToDelete.replyId]) {
                        [replyList removeObjectAtIndex:index];
                        break;
                    }
                }
                comment.replyList = [NSArray arrayWithArray:replyList];
            }
        }
        // 刷新评论列表
        self.commentList = [NSArray arrayWithArray:commentList];
    }
    @catch (NSException *exception) {
        [self handleDeleteCommentErrorMessage:@"PostDetail Delete Reply Exception: %@", exception];
    }
}

// 处理错误
- (void)handleDeleteCommentError:(NSError *)error {
    self.deleteCommentError = YES;
    
    @try {
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            self.deleteCommentMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        } else {
            CMTLogError(@"PostDetail Delete Comment System Error: %@", error);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Delete Comment HandleError:%@\nException: %@", error, exception);
    }
}

// 处理错误信息
- (void)handleDeleteCommentErrorMessage:(NSString *)errorMessgae, ... {
    self.deleteCommentError = YES;
    
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            CMTLogError(@"%@", [[NSString alloc] initWithFormat:errorMessgae arguments:args]);
            va_end(args);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Delete Comment HandleErrorMessage Exception: %@", exception);
    }
}

#pragma mark TableView

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRowsInSection = 0;
    @try {
        numberOfRowsInSection = [self.commentReplyList count];
    }
    @catch (NSException *exception) {
        numberOfRowsInSection = 0;
        CMTLogError(@"PostDetail -numberOfRowsInSection Exception: %@", exception);
    }
    
    return numberOfRowsInSection;
}

- (RACTuple *)commentReplyForRowAtIndexPath:(NSIndexPath *)indexPath {
    RACTuple *commentReply = nil;
    @try {
        commentReply = self.commentReplyList[indexPath.row];
    }
    @catch (NSException *exception) {
        commentReply = nil;
        CMTLogError(@"PostDetail -commentReplyForRowAtIndexPath Exception: %@", exception);
    }
    
    return commentReply;
}

@end
