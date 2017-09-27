//
//  CMTLiveNotice.h
//  MedicalForum
//
//  Created by jiahongfei on 15/8/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTLiveNotice : CMTObject

@property(nonatomic,copy,readwrite)NSString *incrId;// 	翻页ID 		long
@property(nonatomic,copy,readwrite)NSString *noticeId;// 	消息id 		long
@property(nonatomic,copy,readwrite)NSString *noticeType;// 		通知类型 0 评论了直播 1.回复了评论 2.赞了直播 	long
@property(nonatomic,copy,readwrite)NSString *liveBroadcastMessageId;// 	直播动态id 		long
@property(nonatomic,copy,readwrite)NSString *sendUserId;// 	评论或赞用户ID
@property(nonatomic,copy,readwrite)NSString *sendUserType;// 	评论或赞用户类型 	0表示系统用户;1 表示微信用户
@property(nonatomic,copy,readwrite)NSString *sendUserNickname;// 	评论或赞用户昵称
@property(nonatomic,copy,readwrite)NSString *userPic;// 	评论或赞用户头像
@property(nonatomic,copy,readwrite)NSString *content;// 	评论内容
@property(nonatomic,copy,readwrite)NSString *status;// 	读取状态 	0 未读；1 已读； 	int
@property(nonatomic,copy,readwrite)NSString *createTime ;//	创建时间 	unix时间戳 	long
@property(nonatomic,copy,readwrite)NSString *receiveUserId;// 	被评论或赞用户ID
@property(nonatomic,copy,readwrite)NSString *receiveUserName;// 	被评论或赞用户昵称
@property(nonatomic,copy,readwrite)NSString *receiveUserPic ;//	被评论或赞用户头像
@property(nonatomic,copy,readwrite)NSString *liveBroadcastMessagePic;// 	被评论直播动态图片 	当noticeType=0、2时有效
@property(nonatomic,copy,readwrite)NSString *beContent;// 	被评论内容

@end
