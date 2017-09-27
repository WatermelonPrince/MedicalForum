//
//  CMTCommentEditListViewModel.m
//  MedicalForum
//
//  Created by fenglei on 15/1/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCommentEditListViewModel.h"
#import "SVPullToRefresh.h"

NSString * const CMTCommentEditListCellIdentifier = @"CMTCommentEditListCell";
NSString * const CMTCommentEditListReceivedCommentName = @"评论我的";
NSString * const CMTCommentEditListSentCommentName = @"我评论的";

static NSString * const CMTCommentEditListRequestDefaultPageSize = @"30";

@interface CMTCommentEditListViewModel ()

// binding
@property (nonatomic, assign, readwrite) BOOL requestReceivedCommentFinish;         // 收到的评论请求完成
@property (nonatomic, assign, readwrite) BOOL requestReceivedCommentEmpty;          // 收到的评论请求为空
@property (nonatomic, assign, readwrite) BOOL requestReceivedCommentError;          // 收到的评论请求失败
@property (nonatomic, copy, readwrite) NSString *requestReceivedCommentMessage;     // 收到的评论请求提示信息

@property (nonatomic, assign, readwrite) BOOL requestSentCommentFinish;             // 发出的评论请求完成
@property (nonatomic, assign, readwrite) BOOL requestSentCommentEmpty;              // 发出的评论请求为空
@property (nonatomic, assign, readwrite) BOOL requestSentCommentError;              // 发出的评论请求失败
@property (nonatomic, copy, readwrite) NSString *requestSentCommentMessage;         // 发出的评论请求提示信息

@end

@implementation CMTCommentEditListViewModel

#pragma mark 发出的评论 Request

// 刷新 发出的评论
- (RACSignal *)requestNewSentCommentListSignal {
    @weakify(self);
    return [[RACObserve(self, pullToRefreshState)
             filter:^BOOL(NSNumber *state) {
                 return state.integerValue == SVPullToRefreshStateLoading;
             }] map:^id(id value) {
                 @strongify(self);
//                 CMTSendComment *firstSentComment = self.sentCommentList.firstObject;
                 return [self getSentCommentListWithNoticeId:nil noticeIdFlag:@"0"];
             }];
}

// 翻页 发出的评论
- (RACSignal *)requestMoreSentCommentListSignal {
    @weakify(self);
    return [[RACObserve(self, sentCommentInfiniteScrollingState)
             filter:^BOOL(NSNumber *state) {
                 return state.integerValue == SVInfiniteScrollingStateLoading;
             }] map:^id(id value) {
                 @strongify(self);
                 CMTSendComment *lastSentComment = self.sentCommentList.lastObject;
                 return [self getSentCommentListWithNoticeId:lastSentComment.noticeId noticeIdFlag:@"1"];
             }];
}

// 请求发出的评论列表
- (RACSignal *)getSentCommentListWithNoticeId:(NSString *)noticeId noticeIdFlag:(NSString *)noticeIdFlag {
    return [CMTCLIENT getSendCommentList:@{
                                           @"userId": CMTUSERINFO.userId ?: @"",
                                           @"noticeId": noticeId ?: @"",
                                           @"noticeIdFlag": noticeIdFlag ?: @"",
                                           @"pageSize": CMTCommentEditListRequestDefaultPageSize ?: @"",
                                           }];
}

#pragma mark Initializers

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CommentEditList ViewModel willDeallocSignal");
    }];

#pragma mark 发出的评论 initialize
    
    // 处理刷新 发出的评论
    [[self requestNewSentCommentListSignal] subscribeNext:^(RACSignal *getSentCommentListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getSentCommentListSignal subscribeNext:^(NSArray *newSentCommentList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            [self handleNewSentCommentList:newSentCommentList];
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleSentCommentError:error];
        }]];
    }];
    
    // 处理翻页 发出的评论
    [[self requestMoreSentCommentListSignal] subscribeNext:^(RACSignal *getSentCommentListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getSentCommentListSignal subscribeNext:^(NSArray *moreSentCommentList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            [self handleMoreSentCommentList:moreSentCommentList];
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleSentCommentError:error];
        }]];
    }];
    
    return self;
}

#pragma mark 发出的评论 handle

// 处理刷新列表 发出的评论
- (void)handleNewSentCommentList:(NSArray *)newSentCommentList {
    @try {
        // empty list
        if ([newSentCommentList count] == 0) {
            self.sentCommentList = nil;
        }
        // set list
        else {
            self.sentCommentList = newSentCommentList;
        }
    }
    @catch (NSException *exception) {
        [self handleSentCommentErrorMessage:@"CommentEditList Request NewSentComment List Exception: %@", exception];
    }
}

// 处理翻页列表 发出的评论
- (void)handleMoreSentCommentList:(NSArray *)moreSentCommentList {
    @try {
        // empty list
        if ([moreSentCommentList count] == 0) {
            [self handleSentCommentEmpty:@"没有更多"];
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:self.sentCommentList];
        [combindList addObjectsFromArray:moreSentCommentList];
        // set list
        self.sentCommentList = combindList;
    }
    @catch (NSException *exception) {
        [self handleSentCommentErrorMessage:@"CommentEditList Request MoreSentComment List Exception: %@", exception];
    }
}

- (void)setSentCommentList:(NSArray *)sentCommentList {
//    if (_sentCommentList == sentCommentList) return;
    
    _sentCommentList = sentCommentList;
    self.requestSentCommentFinish = YES;
}

// 处理错误 发出的评论
- (void)handleSentCommentError:(NSError *)error {
    self.requestSentCommentError = YES;
    
    @try {
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            self.requestSentCommentMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        } else {
            CMTLogError(@"CommentEditList Request SentComment List System Error: %@", error);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"CommentEditList Request SentComment List HandleError:%@\nException: %@", error, exception);
    }
}

// 处理错误信息 发出的评论
- (void)handleSentCommentErrorMessage:(NSString *)errorMessgae, ... {
    self.requestSentCommentError = YES;
    
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            CMTLogError(@"%@", [[NSString alloc] initWithFormat:errorMessgae arguments:args]);
            va_end(args);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"CommentEditList SentComment List HandleErrorMessage Exception: %@", exception);
    }
}

// 处理空结果 发出的评论
- (void)handleSentCommentEmpty:(NSString *)emptyMessage {
    self.requestSentCommentEmpty = YES;
    self.requestSentCommentMessage = emptyMessage;
}

#pragma mark TableView

- (NSInteger)numberOfRowsInSectionForReceivedComment:(NSInteger)section {
    NSInteger numberOfRowsInSection = 0;
       return numberOfRowsInSection;
}

- (CMTObject *)commentForRowAtIndexPathForReceivedComment:(NSIndexPath *)indexPath {
    CMTObject *receivedComment = nil;
    
    
    return receivedComment;
}

- (NSInteger)numberOfRowsInSectionForSentComment:(NSInteger)section {
    NSInteger numberOfRowsInSection = 0;
    @try {
        numberOfRowsInSection = [self.sentCommentList count];
    }
    @catch (NSException *exception) {
        numberOfRowsInSection = 0;
        CMTLogError(@"CommentEditList -numberOfRowsInSectionForSentComment Exception: %@", exception);
    }
    
    return numberOfRowsInSection;
}

- (CMTObject *)commentForRowAtIndexPathForSentComment:(NSIndexPath *)indexPath {
    CMTObject *sentComment = nil;
    @try {
        sentComment = self.sentCommentList[indexPath.row];
    }
    @catch (NSException *exception) {
        sentComment = nil;
        CMTLogError(@"CommentEditList -commentForRowAtIndexPathForSentComment Exception: %@", exception);
    }
    
    return sentComment;
}

@end
