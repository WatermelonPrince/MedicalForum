//
//  CMTLive.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTPicture.h"
#import "CMTLiveTag.h"

@interface CMTLive : CMTObject

//直播ID
@property(nonatomic,copy,readwrite)NSString *liveBroadcastId;
//筛选标签id
@property(nonatomic,copy,readwrite)NSString *liveBroadcastTagId;
//直播名称、和标签名称
@property(nonatomic,copy,readwrite)NSString *name;
//直播名称
@property(nonatomic,copy,readwrite)NSString *liveBroadcastName;
//直播描述
@property(nonatomic,copy,readwrite)NSString *liveDesc;
//头图
@property(nonatomic,copy,readwrite)CMTPicture *headPic;
//分享
@property(nonatomic,strong)CMTPicture *sharePic;
//直播间分享链接
@property(nonatomic,strong)NSString *liveBroadcastShareUrl;
//最新的一条动态消息
@property(nonatomic,copy,readwrite)NSString *latestMessage;
//最新的一条发布者
@property(nonatomic,copy,readwrite)NSString *latestMessageSendUser;
//参与限制 0.所有人都能参与 1.只有认证的可以参与
@property(nonatomic,copy,readwrite)NSString *participationLimit;
//是否有上头条功能
@property(nonatomic,copy,readwrite)NSString *hasHeadline;
//是否是官方账户 0表示不是。1表示是
@property(nonatomic,copy,readwrite)NSString *isOfficial;
//分享描述
@property(nonatomic,copy,readwrite)NSString *shareDesc;

//消息id
@property(nonatomic,copy,readwrite)NSString *liveBroadcastMessageId;
//发布人id
@property(nonatomic,copy,readwrite)NSString *createUserId;
//发布人类型 0表示系统用户。1表示微信用户
@property(nonatomic,copy,readwrite)NSString *createUserType;
//发布人名称
@property(nonatomic,copy,readwrite)NSString *createUserName;
//发布人描述
@property(nonatomic,copy,readwrite)NSString *createUserDesc;
//发布人头像url
@property(nonatomic,copy,readwrite)NSString *createUserPic;
//是否置顶
@property(nonatomic,copy,readwrite)NSString *topFlag;
//liveBroadcastTag 直播标签
@property(nonatomic,copy,readwrite)CMTLiveTag *liveBroadcastTag;
//发布时间
@property(nonatomic,copy,readwrite)NSString *createTime;
//消息正文
@property(nonatomic,copy,readwrite)NSString *content;
//图片列表
@property(nonatomic,copy,readwrite)NSArray *pictureList;
//点过赞的用户列表
@property(nonatomic,copy,readwrite)NSArray *praiseUserList;
//直播消息分享链接
@property(nonatomic,copy,readwrite)NSString *liveBroadcastMessageShareUrl;
//isPraise 是否点过赞
@property(nonatomic,copy,readwrite)NSString *isPraise;
//评论数
@property(nonatomic,copy,readwrite)NSString *commentCount;
//分页表示
@property(nonatomic,copy,readwrite)NSString *incrId;
//开始时间
@property(nonatomic,copy,readwrite)NSString *beginTime;

//结束时间
@property(nonatomic,copy,readwrite)NSString *endTime;

//是否过期 0 未过期 1 过期
@property(nonatomic,copy,readwrite)NSString *outOfDate;


//点赞数量
@property(nonatomic,copy,readwrite)NSString *praiseCount;
//点赞数量
@property(nonatomic,copy,readwrite)NSString *noticeCount;
//是否有分会场标签	0 没有 1 有
@property(nonatomic,copy,readwrite)NSString *hasTags;

// 登陆用户在本直播间的用户名
@property(nonatomic,copy,readwrite)NSString *userName;
// 登陆用户在本直播间的头像
@property(nonatomic,copy,readwrite)NSString *userPic;
@property(nonatomic,copy,readwrite)NSString *shareModel;
@property(nonatomic,copy,readwrite)NSString *shareServiceId;








@end
