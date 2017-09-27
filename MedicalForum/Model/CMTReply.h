//
//  CMTReply.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTReply : CMTObject

//userId	回复人ID
@property(nonatomic, copy, readonly) NSString *userId;
//nickname	回复人昵称
@property(nonatomic, copy, readonly) NSString *nickname;
//picture	回复人头像
@property(nonatomic, copy, readonly) NSString *picture;
//content	回复内容
@property(nonatomic, copy, readonly) NSString *content;
//createTime	创建时间
@property(nonatomic, copy, readonly) NSString *createTime;
//replyType	回复类型	0直接回复评论；1回复一条回复
@property(nonatomic, copy, readonly) NSNumber *replyType;
//beUserId	被回复人ID			replyType=1时有效，否则为空
@property(nonatomic, copy, readonly) NSString *beUserId;
//beNickname	被回复人昵称			replyType=1时有效，否则为空
@property(nonatomic, copy, readonly) NSString *beNickname;
//bePicture	被回复人头像			replyType=1时有效，否则为空
@property(nonatomic, copy, readonly) NSString *bePicture;
//replyId	本条回复ID	供回复一条回复时上传
@property(nonatomic, copy, readonly) NSString *replyId;
//commentId	所属的评论ID	供回复时上传
@property(nonatomic, copy, readonly) NSString *commentId;

//beReplyId 被回复条ID 回复评论接口返回 replyType = 1 时，值有效
@property(nonatomic, copy, readonly) NSString *beReplyId;
//评论点赞数
@property(nonatomic,copy,readwrite)NSString *praiseCount;
//是否点赞
@property(nonatomic,copy,readwrite)NSString *isPraise;



@end
