//
//  CMTCommentEditListViewModel.h
//  MedicalForum
//
//  Created by fenglei on 15/1/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTViewModel.h"

FOUNDATION_EXPORT NSString * const CMTCommentEditListCellIdentifier;
FOUNDATION_EXPORT NSString * const CMTCommentEditListReceivedCommentName;
FOUNDATION_EXPORT NSString * const CMTCommentEditListSentCommentName;

/// 编辑评论列表数据
@interface CMTCommentEditListViewModel : CMTViewModel

/* input */

///  收到的评论/发出的评论 刷新状态
@property (nonatomic, assign) NSInteger pullToRefreshState;
/// 收到的评论翻页状态
@property (nonatomic, assign) NSInteger receivedCommentInfiniteScrollingState;
/// 发出的评论翻页状态
@property (nonatomic, assign) NSInteger sentCommentInfiniteScrollingState;

/* binding */

/// 收到的评论请求完成
@property (nonatomic, assign, readonly) BOOL requestReceivedCommentFinish;
/// 收到的评论请求为空
@property (nonatomic, assign, readonly) BOOL requestReceivedCommentEmpty;
/// 收到的评论请求失败
@property (nonatomic, assign, readonly) BOOL requestReceivedCommentError;
/// 收到的评论请求提示信息
@property (nonatomic, copy, readonly) NSString *requestReceivedCommentMessage;
/// 发出的评论请求完成
@property (nonatomic, assign, readonly) BOOL requestSentCommentFinish;
/// 发出的评论请求为空
@property (nonatomic, assign, readonly) BOOL requestSentCommentEmpty;
/// 发出的评论请求失败
@property (nonatomic, assign, readonly) BOOL requestSentCommentError;
/// 发出的评论请求提示信息
@property (nonatomic, copy, readonly) NSString *requestSentCommentMessage;

// data
@property (nonatomic, copy) NSArray *sentCommentList;                               // 发出的评论列表


/* output */

- (NSInteger)numberOfRowsInSectionForReceivedComment:(NSInteger)section;
- (CMTObject *)commentForRowAtIndexPathForReceivedComment:(NSIndexPath *)indexPath;
- (NSInteger)numberOfRowsInSectionForSentComment:(NSInteger)section;
- (CMTObject *)commentForRowAtIndexPathForSentComment:(NSIndexPath *)indexPath;

@end