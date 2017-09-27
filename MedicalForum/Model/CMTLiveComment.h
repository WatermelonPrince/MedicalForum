//
//  CMTLiveComment.h
//  MedicalForum
//
//  Created by fenglei on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTLiveComment : CMTObject

/// userType    评论用户类型
/// 0 本系统用户；1 微信公众平台用户；
@property(nonatomic,strong)NSString *userType;
/// type    评论类型
/// 0 评论消息 1.回复评论
@property(nonatomic,strong)NSString *type;
/// pid 评论父id
/// type为0时，pid是liveBroadcastMessageId。type是1时，pid是commentId
@property(nonatomic, copy, readonly) NSString *pid;

/// commentId   评论ID
@property(nonatomic, copy, readonly) NSString *commentId;
/// liveBroadcastMessageId  直播动态id
@property(nonatomic, copy, readonly) NSString *liveBroadcastMessageId;
/// userId	评论人ID
@property(nonatomic, copy, readonly) NSString *userId;
/// userNickname    评论人昵称
@property(nonatomic, copy, readonly) NSString *userNickname;
/// userPic 评论人头像
@property(nonatomic, copy, readonly) NSString *userPic;
/// content	评论内容
@property(nonatomic, copy, readonly) NSString *content;
/// createTime	创建时间
@property(nonatomic, copy, readonly) NSString *createTime;
/// beUserId    被评论人id
/// type=1时有效
@property(nonatomic, copy, readonly) NSString *beUserId;
/// beUserType  被评论用户类型
/// 0 本系统用户；1 微信公众平台用户；type=1时有效
@property(nonatomic, copy, readonly) NSString *beUserType;
/// beUserNickname  被评论人昵称
/// type=1时有效
@property(nonatomic, copy, readonly) NSString *beUserNickname;
/// incrId  自增id
@property(nonatomic,copy,readwrite) NSString *incrId;

/// praiseCount 评论点赞数
@property(nonatomic,copy,readwrite) NSString *praiseCount;
/// isPraise    是否点赞
@property(nonatomic,copy,readwrite) NSString *isPraise;

@end
