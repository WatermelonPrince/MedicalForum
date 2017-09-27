//
//  CMTNotice.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTNotice : CMTObject
//翻页ID
@property(nonatomic,copy,readwrite)NSString *incrId;
//消息id
@property(nonatomic,copy,readwrite)NSString *noticeId;
//评论ID
@property(nonatomic,copy,readwrite)NSString *commentId;
//回复ID
@property(nonatomic,copy,readwrite)NSString *replyId;
//评论或赞用户ID
@property(nonatomic,copy,readwrite)NSString *userId;
//评论或赞用户类型
@property(nonatomic,copy,readwrite)NSString *userType;
//评论或赞用户昵称
@property(nonatomic,copy,readwrite)NSString *nickname;
//评论或赞用户头像
@property(nonatomic,copy,readwrite)NSString *picture;
//评论内容
@property(nonatomic,copy,readwrite)NSString *content;
//文章ID
@property(nonatomic,copy,readwrite)NSString *postId;
//文章标题
@property(nonatomic,copy,readwrite)NSString *postTitle;
//通知类型 1 评论文章; 2 回复评论；3 回复一条回复; 4 对文章点赞；5 对评论点赞；6 对回复点赞；7追加描述；8追加结论；9创建病例@某人；10评论@某人；11文章被群主下线；12文章被管理员下线；13文章被管理员推荐文精品',
@property(nonatomic,copy,readwrite)NSString *noticeType;
//读取状态 0 未读；1 已读；
@property(nonatomic,copy,readwrite)NSString *status;
//创建时间
@property(nonatomic,copy,readwrite)NSString *createTime;
//文章缩略图
@property(nonatomic,copy,readwrite)NSString *smallPic;
//通知数量
@property(nonatomic,copy,readwrite)NSString *count;
//是否是动态详情 0 非动态详情页；1 动态详情页
@property(nonatomic,copy,readwrite)NSString *isHTML;

//动态详情url
@property(nonatomic,copy,readwrite)NSString *url;
//model
@property(nonatomic,copy,readwrite)NSString *module;

@property(nonatomic,copy,readwrite)NSString *noticeCount;
//权限状态
@property(nonatomic,copy,readwrite)NSString *authStatus;







@end
