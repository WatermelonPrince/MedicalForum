//
//  CMTLiveDetailViewController.h
//  MedicalForum
//
//  Created by fenglei on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

/// 直播详情类型
typedef NS_ENUM(NSUInteger, CMTLiveDetailType) {
    CMTLiveDetailTypeUnDefind = 0,          // 未定义
    CMTLiveDetailTypeLiveList,              // 直播列表直播详情
    CMTLiveDetailTypeLiveListWithReply,     // 直播列表直播详情快速评论弹出键盘(评论数为零)
    CMTLiveDetailTypeLiveListSeeReply,      // 直播列表直播详情快速评论查看评论(评论数不为零)
    CMTLiveDetailTypeLiveNoticeList,        // 直播通知列表直播详情
};

/// 直播详情
@interface CMTLiveDetailViewController : CMTBaseViewController

/* init */

/// designated initializer
- (instancetype)initWithLiveDetail:(CMTLive *)liveDetail
                    liveDetailType:(CMTLiveDetailType)liveDetailType;

- (instancetype)initWithLiveBroadcastMessageId:(NSString *)liveBroadcastMessageId
                                liveDetailType:(CMTLiveDetailType)liveDetailType;
- (instancetype)initWithLiveMessageUuid:(NSString *)MessageUuid
                         liveDetailType:(CMTLiveDetailType)liveDetailType;

//#warning 添加通知进入接口 滑动到指定评论

/* input */

/// 刷新直播列表统计数
@property (nonatomic, copy) void (^updateLiveStatistics)(CMTLive *);
/// 删除直播消息
@property (nonatomic, copy) void (^deleteLiveBroadcastMessage)(CMTLive *);
/// 刷新直播列表统计数
@property (nonatomic, copy) void (^updateLiveNoticeStatus)();

@end
