//
//  CMTPostStatistics.h
//  MedicalForum
//
//  Created by fenglei on 15/2/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

/// 文章统计数 + 简单详情
@interface CMTPostStatistics : CMTObject

/* 文章统计数 */

/// commentCount    评论数
@property(nonatomic, copy, readwrite) NSString *commentCount;
/// heat    热度
@property(nonatomic, copy, readonly) NSString *heat;

/* 简单文章详情 */

/// title   文章标题
@property (nonatomic, copy, readonly) NSString *title;
/// authorId    作者ID
@property (nonatomic, copy, readonly) NSString *authorId;
/// author  作者昵称
@property (nonatomic, copy, readonly) NSString *author;
/// createTime  发布日期    unix时间  long
@property (nonatomic, copy, readonly) NSString *createTime;
/// modifyTime  修改时间    13位unixt时间戳 long
@property (nonatomic, copy, readonly) NSString *modifyTime;
/// postTypeId  文章类型ID  int
@property (nonatomic, copy, readonly) NSString *postTypeId;
/// postType    文章类型    string
@property (nonatomic, copy, readonly) NSString *postType;
/// shareUrl    分享url
@property (nonatomic, copy, readonly) NSString *shareUrl;
/// smallPic    缩略图 string
@property (nonatomic, copy, readonly) NSString *smallPic;
/// incrId  自增ID    long
@property (nonatomic, copy, readonly) NSString *incrId;
/// postAttr    文章属性
/// 0 默认普通文章；1pdf；2 答题；4 投票
/// 按位与运算，判断结果是否和参与与运算的数相等，得是否包含以上属性
/// 如PDF + 投票 用5表示
@property (nonatomic, copy, readonly) NSString *postAttr;
/// themeStatus 专题状态
/// 0 非专题；1 专题未上线；2 专题已上线；
/// 当该值为2时，将此文章标识为专题(0,1忽略)，根据下面的themeId字段跳转到专题列表；
@property (nonatomic, copy, readonly) NSString *themeStatus;
/// themeId 专题ID
/// 当themeStatus=2时，此值有意义，根据此id跳转对应专题
@property (nonatomic, copy, readonly) NSString *themeId;

/// guideDesc   指南描述    string
@property (nonatomic, copy, readwrite) NSString *guideDesc;
/// issuingAgency   指南发布机构  string
@property (nonatomic, copy, readwrite) NSString *issuingAgency;
/// guideAuthor 指南作者    string
@property (nonatomic, copy, readwrite) NSString *guideAuthor;
/// guideSource 指南来源    string
@property (nonatomic, copy, readwrite) NSString *guideSource;
/// guideReleaseTime    指南发布时间  unix时间  long
@property (nonatomic, copy, readwrite) NSString *guideReleaseTime;

/// module  文章模块    int
/// 0.首页 1.病例 2.指南
@property (nonatomic, copy, readwrite) NSString *module;

/* 客户端标记 */

/// 评论或点赞 修改标记
/// 0 未修改, 1 已修改
@property (nonatomic, copy, readwrite) NSString *commentModified;
@property(nonatomic,copy,readwrite)NSString *isPraise;
//点赞数量
@property(nonatomic,copy,readwrite)NSString *praiseCount;
/// postId	文章ID
@property (nonatomic, copy, readwrite) NSString *postId;
/// 是否是动态详情页 0 非动态详情页；1 动态详情页
@property (nonatomic, copy, readwrite) NSString *isHTML;
/// 动态详情页url string
@property (nonatomic, copy, readwrite) NSString *url;
//小组ID
@property(nonatomic,copy,readwrite)NSString *groupId;
//小组名字
@property(nonatomic,copy,readwrite)NSString *groupName;
@end
