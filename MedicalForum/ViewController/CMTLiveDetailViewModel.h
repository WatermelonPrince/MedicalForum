//
//  CMTLiveDetailViewModel.h
//  MedicalForum
//
//  Created by fenglei on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTViewModel.h"

FOUNDATION_EXPORT NSString * const CMTLiveDetailCommentListCommentCellIdentifier;

/// 直播详情数据
@interface CMTLiveDetailViewModel : CMTViewModel

/* init */

- (instancetype)initWithLiveDetail:(CMTLive *)liveDetail;

- (instancetype)initWithLiveBroadcastMessageId:(NSString *)liveBroadcastMessageId;
- (instancetype)initWithLiveMessageUuid:(NSString *)MessageUuid;

/* input */

// 点击重新加载状态
@property (nonatomic, assign) BOOL reloadLiveDetailState;
/// 翻页状态
@property (nonatomic, assign) NSInteger infiniteScrollingState;
/// 点击发送直播评论按钮
@property (nonatomic, strong) RACSignal *liveCommentSendButtonSignal;
/// 直播评论内容
@property (nonatomic, copy) NSString *liveCommentText;
/// 被回复的直播评论/回复
@property (nonatomic, copy) CMTLiveComment *liveCommentToReply;
/// 被删除的直播评论/回复
@property (nonatomic, copy) CMTLiveComment *liveCommentToDelete;

/* input and binding */

/// 视图是否出现
@property (nonatomic, assign) BOOL viewDidAppearState;
/// 快速评论完成 用于从'直播列表'快速评论按钮进入时弹出键盘
@property (nonatomic, assign) BOOL quickReplyFinish;
/// 图片浏览器显示的图片
@property (nonatomic, copy) NSArray *photoBrowserPhotos;
/// 直播详情分享标题
@property (nonatomic, copy) NSString *shareTitle;
/// 直播详情分享描述
@property (nonatomic, copy) NSString *shareDescription;
/// 直播详情分享链接
@property (nonatomic, copy) NSString *shareURL;
/* binding */

/// 直播详情请求状态信息
@property (nonatomic, copy, readonly) CMTClientRequestStatusInfo liveDetailRequestStatusInfo;
/// 直播评论列表请求状态信息
@property (nonatomic, copy, readonly) CMTClientRequestStatusInfo liveCommentRequestStatusInfo;
/// 发送直播评论请求状态信息
@property (nonatomic, copy, readonly) CMTClientRequestStatusInfo sendLiveCommentRequestStatusInfo;
/// 删除直播评论请求状态信息
@property (nonatomic, copy, readonly) CMTClientRequestStatusInfo deleteLiveCommentRequestStatusInfo;

/* output */

/// 直播ID
@property (nonatomic, copy, readonly) NSString *liveBroadcastMessageId;
/// 直播详情
@property (nonatomic, strong, readonly) CMTLive *liveDetail;
/// 直播评论列表
@property (nonatomic, copy, readonly) NSArray *liveCommentList;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (CMTLiveComment *)liveCommentForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
