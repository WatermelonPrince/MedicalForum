//
//  CMTCaseSystemNoticeModel.h
//  MedicalForum
//
//  Created by zhaohuan on 15/11/26.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTCaseSystemNoticeModel : CMTObject

@property (nonatomic, copy)NSString *noticeType;

@property (nonatomic, copy)NSString *message;

@property (nonatomic, copy)NSString *sendUserId;

@property (nonatomic, copy)NSString *sendUserName;

@property (nonatomic, copy)NSString *groupId;

@property (nonatomic, copy)NSString *state;

@property (nonatomic, copy)NSString *createTime;

@property (nonatomic, copy)NSString *modifyTime;

@property (nonatomic, copy)NSString *groupName;

@property (nonatomic, copy)NSString *receiveUserId;

@property (nonatomic, copy)NSString *receiveUserName;

@property (nonatomic, copy)NSString *opUserId;

@property (nonatomic, copy)NSString *opUserName;

@property (nonatomic, copy)NSString *userPic;

@property (nonatomic, copy)CMTUserInfo *userAuthInfo;
@property (nonatomic, copy)NSString *incrId;
@property (nonatomic, copy)NSString *groupLimit;//0默认公开组无限制 1任何人都可以申请加入，不需要验证消息 2任何人都可以申请加入，需要验证消息 3只有认证用户可以申请加入
@property (nonatomic, copy)NSString *step;//当noticeType=1时有效，0 未处理；1同意；2拒绝

@property (nonatomic, copy)NSString *noticeId;//通知ID
@property (nonatomic, copy)NSString *groupApplyId;//申请加入小组Id





@end
