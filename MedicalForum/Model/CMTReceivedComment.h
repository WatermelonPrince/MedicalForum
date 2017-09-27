//
//  CMTReceivedComment.h
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTReceivedComment : CMTObject

/// noticeId    消息ID
@property(nonatomic, copy, readwrite) NSString *noticeId;
/// commentId   评论ID
@property(nonatomic, copy, readwrite) NSString *commentId;
/// replyId	回复ID	当该条记录是评论时，该字段为空；当该条记录是回复时，值为回复ID
@property(nonatomic, copy, readwrite) NSString *replyId;
/// userId	评论人ID
@property(nonatomic, copy, readwrite) NSString *userId;
/// nickname	评论人昵称
@property(nonatomic, copy, readwrite) NSString *nickname;
/// picture	评论人头像
@property(nonatomic, copy, readwrite) NSString *picture;
/// content	评论内容
@property(nonatomic, copy, readwrite) NSString *content;
/// postId	文章ID
@property(nonatomic, copy, readwrite) NSString *postId;
/// postTitle	文章标题
@property(nonatomic, copy, readwrite) NSString *postTitle;
/// createTime	创建时间	unix时间戳
@property(nonatomic, copy, readwrite) NSString *createTime;
/// 是否是动态详情页 0 非动态详情页；1 动态详情页
@property (nonatomic, copy, readwrite) NSString *isHTML;
/// 动态详情页url string
@property(nonatomic, copy, readwrite)  NSString *url;
/// module  文章模块    int
/// 0.首页 1.病例 2.指南
@property (nonatomic, copy, readwrite) NSString *module;

@end
