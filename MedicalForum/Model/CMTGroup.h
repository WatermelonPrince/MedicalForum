//
//  CMTGroup.h
//  MedicalForum
//
//  Created by CMT on 15/7/13.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTGroupLogo.h"
@interface CMTGroup : CMTObject
//小组ID
@property(nonatomic,copy)NSString *groupId;
//小组名称
@property(nonatomic,copy)NSString *groupName;
//小组描述
@property(nonatomic,copy)NSString *groupDesc;
//小组成员数量
@property(nonatomic,copy)NSString *memNum;
//订阅学科id
@property(nonatomic,copy)NSString *subjectId;
//订阅学科
@property(nonatomic,copy)NSString *subject;
//是否加入 0未加入，1已加入，2加入申请审核中
@property(nonatomic,strong)NSString *isJoinIn;
//自增id
@property(nonatomic,copy)NSString *incrId;
@property(nonatomic,copy)NSString *groupLogoId;
//小组logo
@property(nonatomic,strong)CMTGroupLogo *groupLogo;
//推荐类型
@property(nonatomic,copy)NSString *topValue;
//小组类型 0，公开小组 1.线上封闭小组 2.线下封闭小组
@property(nonatomic,copy)NSString *groupType;
//最新的N个小组成员topMemList
@property(nonatomic,strong)NSArray *topMemList;
//操作时间
@property(nonatomic,copy)NSString *opTime;
//可视范围 
@property(nonatomic,strong)NSArray *viewRange;
//分享链接
@property(nonatomic,copy)NSString *url;
//创建者ID
@property(nonatomic,copy)NSString *createUserId;
//通知数
@property(nonatomic,copy)NSString *noticeCount;

@property (nonatomic, copy)NSString *memberGrade; //小组角色:    0 表示群主、1表示组长,2表示普通组员,3黑名单
//管理员数量
@property (nonatomic, copy)NSString *leaderCount; 

//小组文章数目
@property(nonatomic,strong)NSString *postCount;
//加入时间
@property(nonatomic,strong)NSString *joinTime;
//加入限制判断是否是封闭小组 0默认公开组无限制 1任何人都可以申请加入，不需要验证消息 2任何人都可以申请加入，需要验证消息 3只有认证用户可以申请加入
@property(nonatomic,strong)NSString *joinLimit;
//从哪个页面跳转进来
@property(nonatomic,strong)NSString *jumpFrom;
//页面偏移量 用于小组搜索翻页
@property(nonatomic,strong)NSString *pageOffset;
@property(copy,nonatomic)NSString *isSelected;//创建小组的小组类型选中状态;
@property (copy,nonatomic)NSString *auditStatus;//审核状态; //0 待审核，1，审核通过
@property(copy,nonatomic)NSString *adSwitch;//	广告开关		0关闭；1打开
@property(copy,nonatomic)CMTPicture *advertisement;//广告图片链接;
@property(copy,nonatomic)NSString *status;
@end
