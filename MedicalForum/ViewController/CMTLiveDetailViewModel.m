//
//  CMTLiveDetailViewModel.m
//  MedicalForum
//
//  Created by fenglei on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLiveDetailViewModel.h"      // header file
#import <AudioToolbox/AudioToolbox.h>   // 调用系统声音播放
#import "SVPullToRefresh.h"             // 下拉刷新 下拉刷新状态
#import "SDWebImageManager.h"           // 图片缓存
#import "SDWebImageOperation.h"         // 图片缓存Operation

NSString * const CMTLiveDetailCommentListCommentCellIdentifier = @"CMTLiveDetailCommentListCommentCell";

static NSString * const CMTLiveDetailCommentListRequestDefaultPageSize = @"30";

static SystemSoundID shake_sound_male_id = 0; //定义系统播放声音ID add by guoyuanchao

@interface CMTLiveDetailViewModel ()

/* input */

// 刷新状态
@property (nonatomic, assign) NSInteger pullToRefreshState;

// binding
@property (nonatomic, copy, readwrite) CMTClientRequestStatusInfo liveDetailRequestStatusInfo;              // 直播详情请求状态信息
@property (nonatomic, copy, readwrite) CMTClientRequestStatusInfo liveCommentRequestStatusInfo;             // 直播评论列表请求状态信息
@property (nonatomic, copy, readwrite) CMTClientRequestStatusInfo sendLiveCommentRequestStatusInfo;         // 发送直播评论请求状态信息
@property (nonatomic, copy, readwrite) CMTClientRequestStatusInfo deleteLiveCommentRequestStatusInfo;       // 删除直播评论请求状态信息

// output
@property (nonatomic, copy, readwrite) NSString *liveBroadcastMessageId;            // 直播ID
@property (nonatomic, strong, readwrite) CMTLive *liveDetail;                       // 直播详情
@property (nonatomic, copy, readwrite) NSArray *liveCommentList;                    // 直播评论列表
@property (nonatomic, copy, readwrite) NSString *MessageUuid;            // 直播ID

@end

@implementation CMTLiveDetailViewModel

#pragma mark 直播详情 Request

// 请求直播详情
- (RACSignal *)requestLiveDetail {
    @weakify(self);
    return [[RACObserve(self, reloadLiveDetailState) ignore:@NO] map:^id(id value) {
        @strongify(self);
        return [CMTCLIENT getLiveDetail:@{
                                          @"userId": CMTUSERINFO.userId ?: @"",
                                          @"liveBroadcastMessageId": self.liveBroadcastMessageId ?: @"",
                                          @"liveBroadcastMessageUuid":self.MessageUuid?:@"",
                                          }];
    }];
}

#pragma mark 直播评论列表 Request

// 刷新
- (RACSignal *)requestNewLiveCommentListSignal {
    @weakify(self);
    return  [[RACObserve(self, pullToRefreshState)
              filter:^BOOL(NSNumber *state) {
                  return state.integerValue == SVPullToRefreshStateLoading;
              }] map:^id(id value) {
                  @strongify(self);
                  CMTLiveComment *firstComment = self.liveCommentList.firstObject;
                  return [self getLiveCommentListWithIncrId:firstComment.incrId incrIdFlag:@"0"];
              }];
}

// 翻页
- (RACSignal *)requestMoreLiveCommentListSignal {
    @weakify(self);
    return [[RACObserve(self, infiniteScrollingState)
             filter:^BOOL(NSNumber *state) {
                 return state.integerValue == SVInfiniteScrollingStateLoading;
             }] map:^id(id value) {
                 @strongify(self);
                 CMTLiveComment *lastComment = self.liveCommentList.lastObject;
                 return [self getLiveCommentListWithIncrId:lastComment.incrId incrIdFlag:@"1"];
             }];
}

// 请求直播评论列表
- (RACSignal *)getLiveCommentListWithIncrId:(NSString *)incrId incrIdFlag:(NSString *)incrIdFlag {
    return [CMTCLIENT getLiveCommentList:@{
                                           @"userId": CMTUSERINFO.userId ?: @"",
                                           @"liveBroadcastMessageId": self.liveBroadcastMessageId ?: @"",
                                           @"liveBroadcastMessageUuid":self.MessageUuid?:@"",
                                           @"incrId": incrId ?: @"",
                                           @"incrIdFlag": incrIdFlag ?: @"",
                                           @"pageSize": CMTLiveDetailCommentListRequestDefaultPageSize ?: @"",
                                           }];
}

#pragma mark 发送直播评论 Request

// 评论直播/回复评论
- (RACSignal *)sendLiveCommentWithCommentId:(NSString *)commentId type:(NSString *)type{
    return [CMTCLIENT sendLiveComment:@{
                                        @"userId": CMTUSERINFO.userId ?: @"",
                                        @"liveBroadcastMessageId": self.liveBroadcastMessageId ?: @"",
                                        @"commentId": commentId ?: @"",
                                        @"type": type ?: @"",
                                        @"content": self.liveCommentText ?: @"",
                                        }];
}

#pragma mark 删除直播评论 Request

- (RACSignal *)deleteLiveCommentWithCommentId:(NSString *)commentId {
    return [CMTCLIENT deleteLiveComment:@{
                                          @"userId": CMTUSERINFO.userId ?: @"",
                                          @"commentId": commentId ?: @"",
                                          @"userType" : @"0",
                                          }];
}

#pragma mark Initializers

- (instancetype)initWithLiveDetail:(CMTLive *)liveDetail {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);

    self.liveBroadcastMessageId = liveDetail.liveBroadcastMessageId;
    self.liveDetail = liveDetail;
    [self initialize];
    
    return self;
}

- (instancetype)initWithLiveBroadcastMessageId:(NSString *)liveBroadcastMessageId {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.liveBroadcastMessageId = liveBroadcastMessageId;
    [self initialize];
    
    return self;
}
- (instancetype)initWithLiveMessageUuid:(NSString *)MessageUuid {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.MessageUuid =MessageUuid;
    [self initialize];
    
    return self;
}

// 初始化
- (void)initialize {
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"LiveDetail ViewModel willDeallocSignal");
    }];
    
#pragma mark 直播详情 initialize
    
    // 获取直播详情
    if (self.liveDetail == nil) {
        self.reloadLiveDetailState = YES;
    }
    else {
        [[CMTCLIENT get_live_message_praiser_list:@{
                                                    @"liveBroadcastMessageId": self.liveDetail.liveBroadcastMessageId ?: @"",
                                                    @"liveBroadcastMessageUuid":self.MessageUuid?:@"",
                                                    @"incrId": @"0",
                                                    @"incrIdFlag": @"0",
                                                    @"pageSize": @"32",
                                                    }]
         subscribeNext:^(NSArray *partsArray) {
             @strongify(self);
             self.liveDetail.praiseUserList = partsArray;
             self.liveDetailRequestStatusInfo = CMTClientRequestStatusInfoFinish;
         }];
    }
    
    // 直播详情
    [[self requestLiveDetail] subscribeNext:^(RACSignal *getLiveDetailSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getLiveDetailSignal subscribeNext:^(CMTLive *liveDetail) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            self.liveBroadcastMessageId = liveDetail.liveBroadcastMessageId;
            self.liveDetail = liveDetail;
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            self.liveDetailRequestStatusInfo = error.CMTUserInfo;
        }]];
    }];

#pragma mark 直播评论列表 initialize
    
    // 处理刷新
    [[self requestNewLiveCommentListSignal] subscribeNext:^(RACSignal *getLiveCommentListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getLiveCommentListSignal subscribeNext:^(NSArray *newLiveCommentList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            [self handleNewLiveCommentList:newLiveCommentList];
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            self.liveCommentRequestStatusInfo = error.CMTUserInfo;
        }]];
    }];
    
    // 处理翻页
    [[self requestMoreLiveCommentListSignal] subscribeNext:^(RACSignal *getLiveCommentListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getLiveCommentListSignal subscribeNext:^(NSArray *moreLiveCommentList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            [self handleMoreLiveCommentList:moreLiveCommentList];
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            self.liveCommentRequestStatusInfo = error.CMTUserInfo;
        }]];
    }];
    

    // 请求直播评论列表
    self.pullToRefreshState = SVPullToRefreshStateLoading;
    
#pragma mark 发送直播评论 initialize
    
    // 点击发送直播评论
    [[[[RACObserve(self, liveCommentSendButtonSignal) ignore:nil] distinctUntilChanged] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return self.liveCommentSendButtonSignal;
    }] subscribeNext:^(id x) {
        @strongify(self);
        // 登录状态
        if (CMTUSER.login == YES) {
            // 直播评论
            NSString *commentId = nil;
            NSString *type = @"0";
            // 直播回复
            if (self.liveCommentToReply != nil) {
                commentId = self.liveCommentToReply.commentId;
                type = @"1";
            }
            // 调用发送直播评论/回复接口
            [self.rac_deallocDisposable addDisposable:
             [[self sendLiveCommentWithCommentId:commentId type:type] subscribeNext:^(CMTLiveComment *liveComment) {
                @strongify(self);
                DEALLOC_HANDLE_SUCCESS
                // 播放提示音 add by guoyuanchao
                [self CMT_SendSucess_Voice_broadcast];
                // 直播评论列表中插入
                [self insertNewLiveComment:liveComment];
            } error:^(NSError *error) {
                @strongify(self);
                DEALLOC_HANDLE_FAILURE
                self.sendLiveCommentRequestStatusInfo = error.CMTUserInfo;
            }]];
            // 直播评论/回复已经发送
            self.sendLiveCommentRequestStatusInfo = CMTClientRequestStatusInfoSent;
        }
    }];
    
#pragma mark 删除直播评论 initialize
    
    // 删除直播评论
    [[RACObserve(self, liveCommentToDelete) ignore:nil] subscribeNext:^(CMTLiveComment *liveComment) {
        @strongify(self);
        // 登陆状态
        if (CMTUSER.login == YES) {
            // 直播评论列表中删除
            [self deleteLiveComment:liveComment];
            // 调用删除直播评论接口
            [self.rac_deallocDisposable addDisposable:
             [[self deleteLiveCommentWithCommentId:liveComment.commentId] subscribeNext:^(id x) {
                @strongify(self);
                DEALLOC_HANDLE_SUCCESS
                self.deleteLiveCommentRequestStatusInfo = CMTClientRequestStatusInfoFinish;
            } error:^(NSError *error) {
                @strongify(self);
                DEALLOC_HANDLE_FAILURE
                self.deleteLiveCommentRequestStatusInfo = error.CMTUserInfo;
            }]];
        }
    }];
}

// 添加发送成功声音提醒 add by guoyuanchao
- (void)CMT_SendSucess_Voice_broadcast{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"send_comment" ofType:@"mp3"];
    if (path) {
        // 注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
    // 播放注册的声音
    AudioServicesPlaySystemSound(shake_sound_male_id);
}

#pragma mark 直播评论列表 handle

// 直播评论列表刷新
- (void)handleNewLiveCommentList:(NSArray *)newLiveCommentList {
    @try {
        // empty
        if ([newLiveCommentList count] == 0) {
            self.liveCommentRequestStatusInfo = CMTClientRequestStatusInfoEmptyLatest;
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:newLiveCommentList];
        [combindList addObjectsFromArray:self.liveCommentList];
        // cut short list
        NSUInteger pageSize = CMTLiveDetailCommentListRequestDefaultPageSize.integerValue;
        while (combindList.count > pageSize) {
            [combindList removeObjectAtIndex:pageSize];
        }
        // set list
        self.liveCommentList = [NSArray arrayWithArray:combindList];
    }
    @catch (NSException *exception) {
        CMTLogError(@"LiveDetail Request New LiveComment List Exception: %@", exception);
    }
}

// 直播评论列表翻页
- (void)handleMoreLiveCommentList:(NSArray *)moreLiveCommentList {
    @try {
        // empty
        if ([moreLiveCommentList count] == 0) {
            self.liveCommentRequestStatusInfo = CMTClientRequestStatusInfoEmptyNoMore;
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:self.liveCommentList];
        [combindList addObjectsFromArray:moreLiveCommentList];
        // set list
        self.liveCommentList = [NSArray arrayWithArray:combindList];
    }
    @catch (NSException *exception) {
        CMTLogError(@"LiveDetail Request More LiveComment List Exception: %@", exception);
    }
}

// 直播评论列表 显示
- (void)setLiveCommentList:(NSArray *)liveCommentList {
    _liveCommentList = [liveCommentList copy];
    self.liveCommentRequestStatusInfo = CMTClientRequestStatusInfoFinish;
}

#pragma mark 发送直播评论/回复 handle

- (void)insertNewLiveComment:(CMTLiveComment *)newLiveComment {
    @try {
        NSMutableArray *liveCommentList = [NSMutableArray arrayWithArray:self.liveCommentList];
        [liveCommentList addObject:newLiveComment];
        // 刷新直播评论列表
        self.liveCommentList = [NSArray arrayWithArray:liveCommentList];
        // 增加直播评论数
        self.liveDetail.commentCount = [NSString stringWithFormat:@"%ld", (long)(self.liveDetail.commentCount.integerValue + 1)];
    }
    @catch (NSException *exception) {
        CMTLogError(@"LiveDetail Insert New LiveComment Exception: %@", exception);
    }
}

#pragma mark 删除直播评论 handle

- (void)deleteLiveComment:(CMTLiveComment *)liveCommentToDelete {
    @try {
        NSMutableArray *liveCommentList = [NSMutableArray arrayWithArray:self.liveCommentList];
        for (NSUInteger index = 0; index < liveCommentList.count; index++) {
            CMTLiveComment *liveComment = liveCommentList[index];
            if ([liveComment.commentId isEqual:liveCommentToDelete.commentId]) {
                [liveCommentList removeObjectAtIndex:index];
                break;
            }
        }
        // 刷新直播评论列表
        self.liveCommentList = [NSArray arrayWithArray:liveCommentList];
        // 减小直播评论数
        self.liveDetail.commentCount = [NSString stringWithFormat:@"%ld", (long)(self.liveDetail.commentCount.integerValue - 1)];
    }
    @catch (NSException *exception) {
        CMTLogError(@"LiveDetail Delete LiveComment Exception: %@", exception);
    }
}

#pragma mark TableView

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRowsInSection = 0;
    @try {
        numberOfRowsInSection = [self.liveCommentList count];
    }
    @catch (NSException *exception) {
        numberOfRowsInSection = 0;
        CMTLogError(@"LiveDetail -numberOfRowsInSection Exception: %@", exception);
    }
    
    return numberOfRowsInSection;
}

- (CMTLiveComment *)liveCommentForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTLiveComment *liveComment = nil;
    @try {
        liveComment = self.liveCommentList[indexPath.row];
    }
    @catch (NSException *exception) {
        liveComment = nil;
        CMTLogError(@"LiveDetail -liveCommentForRowAtIndexPath Exception: %@", exception);
    }
    
    return liveComment;
}

@end
