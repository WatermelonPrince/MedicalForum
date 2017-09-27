//
//  CMTCommentEditListViewController.h
//  MedicalForum
//
//  Created by fenglei on 14/12/28.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

/// 评论编辑列表类型
typedef NS_ENUM(NSUInteger, CMTCommentEditListType) {
    CMTCommentEditListTypeUnDefind = 0,         // 未定义
    CMTCommentEditListTypeHome,                 // '首页'评论通知列表
    CMTCommentEditListTypeCase,                 // '病例'评论通知列表
    CMTCommentEditListTypeSent,                 // '我的'我的评论列表
};

/// 评论编辑列表
@interface CMTCommentEditListViewController : CMTBaseViewController

@end
