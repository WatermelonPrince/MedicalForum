//
//  CardCellModel.h
//  MedicalForum
//
//  Created by jiahongfei on 15/8/25.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CardCellModel : CMTObject

//直播ID或者病例id
@property(nonatomic,copy,readwrite)NSString *cellId;

/// themeStatus 专题状态
/// 0 非专题；1 专题未上线；2 专题已上线；
/// 当该值为2时，将此文章标识为专题(0,1忽略)，根据下面的themeId字段跳转到专题列表；
@property (nonatomic, copy, readwrite) NSString *themeStatus;

//参与者
@property(nonatomic,copy,readwrite)NSArray *participators;

// 列表中 文章中的9张图片
// 详情中 文章中的所有图片
@property (nonatomic, copy, readwrite) NSArray *imageList;

/// authorId    作者ID
@property (nonatomic, copy, readwrite) NSString *authorId;
/// author  作者昵称
@property (nonatomic, copy, readwrite) NSString *author;
// authorPic 作者头像
@property (nonatomic, copy, readwrite) NSString *authorPic;

//小组ID
@property(nonatomic,copy,readwrite)NSString *groupId;
//小组名字
@property(nonatomic,copy,readwrite)NSString *groupName;
//小组图片
@property(nonatomic,copy,readwrite)NSString *picture;

/// commentCount	评论数
@property (nonatomic, copy, readwrite) NSString *commentCount;

//是否点赞
@property(nonatomic,copy,readwrite)NSString *isPraise;
//点赞数量
@property(nonatomic,copy,readwrite)NSString *praiseCount;
//postType	类型名称
@property(nonatomic, copy, readwrite) NSString *postType;

/// postAttr 文章属性
/// 0 默认普通文章；1pdf；2 答题；4 投票
/// 按位与运算，判断结果是否和参与与运算的数相等，得是否包含以上属性
/// 如PDF + 投票 用5表示
@property (nonatomic, copy, readwrite) NSString *postAttr;
/// heat	热度		int
@property (nonatomic, copy, readwrite) NSString *heat;
/// title	文章标题		string
@property (nonatomic, copy, readwrite) NSString *title;

//发布时间
@property(nonatomic,copy,readwrite)NSString *createTime;
//是否有分会场标签	0 没有 1 有
@property(nonatomic,copy,readwrite)NSString *hasTags;
//liveBroadcastTag 直播标签
@property(nonatomic,copy,readwrite)CMTLiveTag *liveBroadcastTag;
//发布人描述
@property(nonatomic,copy,readwrite)NSString *createUserDesc;

//是否置顶 默认0。1表示置顶
@property(nonatomic,copy,readwrite)NSString *topFlag;

//是否是官方账户 0表示不是。1表示是
@property(nonatomic,copy,readwrite)NSString *isOfficial;
@property(nonatomic,copy,readwrite)NSString *liveBroadcastMessageId;



@end
