//
//  CMTSendComment.h
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTSendComment : CMTObject

/// noticeId    消息ID
@property(nonatomic, copy, readonly) NSString *noticeId;
/// commentId   评论ID
@property(nonatomic, copy, readonly) NSString *commentId;
/// replyId 回复ID    当该条记录是评论时，该字段为空；当该条记录是回复时，值为回复ID
@property(nonatomic, copy, readonly) NSString *replyId;
/// userId  被评论人ID
@property(nonatomic, copy, readonly) NSString *beUserId;
///nickname 被评论人昵称
@property(nonatomic, copy, readonly) NSString *beNickname;
/// picture 被评论人头像
@property(nonatomic, copy, readonly) NSString *bePicture;
/// content 评论内容
@property(nonatomic, copy, readonly) NSString *content;
/// postId  文章ID
@property(nonatomic, copy, readonly) NSString *postId;
/// postTitle   文章标题
@property(nonatomic, copy, readonly) NSString *postTitle;
/// createTime  创建时间	unix时间戳
@property(nonatomic, copy, readonly) NSString *createTime;

/// 是否是动态详情页 0 非动态详情页；1 动态详情页
@property (nonatomic, copy, readonly) NSString *isHTML;
/// 动态详情页url string
@property (nonatomic, copy, readonly) NSString *url;

/// module  文章模块    int
/// 0.首页 1.病例 2.指南
@property (nonatomic, copy, readwrite) NSString *module;

/// noticeType  评论类型    int
/// 1 评论文章; 2 回复评论；3 回复一条回复
@property (nonatomic, copy, readwrite) NSString *noticeType;

@end
