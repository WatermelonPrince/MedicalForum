//
//  CMTComment.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTReply.h"

@interface CMTComment : CMTObject

/// commentId 评论ID
@property(nonatomic, copy, readonly) NSString *commentId;
//用户类型
@property(nonatomic,strong)NSString *userType;

/// userId	评论人ID
@property(nonatomic, copy, readonly) NSString *userId;
/// nickname	评论人昵称
@property(nonatomic, copy, readonly) NSString *nickname;
/// picture	评论人头像
@property(nonatomic, copy, readonly) NSString *picture;
/// content	评论内容
@property(nonatomic, copy, readonly) NSString *content;
/// createTime	创建时间
@property(nonatomic, copy, readonly) NSString *createTime;
/// replyList	回复列表		list
@property(nonatomic, copy, readwrite) NSArray *replyList;
//评论点赞数
@property(nonatomic,copy,readwrite)NSString *praiseCount;
 //是否点赞
@property(nonatomic,copy,readwrite)NSString *isPraise;
//点赞上传图片
@property(nonatomic,copy,readwrite)CMTPicture *commentPic;
//点赞提醒人员
@property(nonatomic,copy,readwrite)NSString *atUsers;

@end
