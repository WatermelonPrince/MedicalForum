//
//  CMTPost.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTPicture.h"
@interface CMTPost : CMTObject

/// postId	文章ID
@property (nonatomic, copy, readwrite) NSString *postId;
/// title	文章标题		string
@property (nonatomic, copy, readwrite) NSString *title;
/// postTypeId	文章类型ID		int
/// 1 病例; 2 影像; 3 心电图; 4 视频; 5 幻灯(ppt); 6 咨询; 7 会议; 8 指南;
/// 9 经验; 10 人文; 11 政策; 12 活动; 13 热点; 14 科研; 15 中医;
@property (nonatomic, copy, readwrite) NSString *postTypeId;
/// postType	文章类型		string
@property (nonatomic, copy, readwrite) NSString *postType;
/// smallPic	缩略图		url
@property (nonatomic, copy, readwrite) NSString *smallPic;
/// heat	热度		int
@property (nonatomic, copy, readwrite) NSString *heat;
/// createTime	创建时间	13位unixt时间戳	long
@property (nonatomic, copy, readwrite) NSString *createTime;

/// authorId    作者ID
@property (nonatomic, copy, readwrite) NSString *authorId;
/// author  作者昵称
@property (nonatomic, copy, readwrite) NSString *author;
// authorPic 作者头像
@property (nonatomic, copy, readwrite) NSString *authorPic;
/// content	文章内容	格式未定	string
@property (nonatomic, copy, readwrite) NSString *content;
/// commentCount	评论数
@property (nonatomic, copy, readwrite) NSString *commentCount;
/// shareUrl
@property (nonatomic, copy, readwrite) NSString *shareUrl;
/// 图片url
@property (nonatomic, copy, readwrite) NSArray *imageUrls;
/// incrId	自增ID
@property (nonatomic, copy, readwrite) NSString *incrId;
/// brief 摘要
@property (nonatomic, copy, readwrite) NSString *brief;

/// postAttr 文章属性
/// 0 默认普通文章；1pdf；2 答题；4 投票
/// 按位与运算，判断结果是否和参与与运算的数相等，得是否包含以上属性
/// 如PDF + 投票 用5表示
@property (nonatomic, copy, readwrite) NSString *postAttr;
/// themeStatus 专题状态
/// 0 非专题；1 专题未上线；2 专题已上线；
/// 当该值为2时，将此文章标识为专题(0,1忽略)，根据下面的themeId字段跳转到专题列表；
@property (nonatomic, copy, readwrite) NSString *themeStatus;
/// themeId 专题ID
/// 当themeStatus=2时，此值有意义，根据此id跳转对应专题
@property (nonatomic, copy, readwrite) NSString *themeId;
/// theme   专题名
@property (nonatomic, copy, readwrite) NSString *theme;
/// authViewFlag 认证查看标志
/// 控制客户端查看该文章是否需要通过认证可看；1 不认证可看；2 需要认证才能查看
@property (nonatomic, copy, readwrite) NSString *authViewFlag;
/// pdfFiles    pdf文件列表 list
@property (nonatomic, copy, readwrite) NSArray *pdfFiles;

/// 是否是动态详情页 0 非动态详情页；1 动态详情页
@property (nonatomic, copy, readwrite) NSString *isHTML;
/// 动态详情页url string
@property (nonatomic, copy, readwrite) NSString *url;

/// 标签 多个标签
@property (nonatomic, copy, readwrite) NSArray *postTagArr;

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
/// callbackParam   回传字段    string
/// 模块为指南时传值
@property (nonatomic, copy, readwrite) NSString *callbackParam;

/// module  文章模块    int
/// 0.首页 1.病例 2.指南
@property (nonatomic, copy, readwrite) NSString *module;
/// diseaseTagArr   疾病标签    数组  list
@property (nonatomic, copy, readwrite) NSArray *diseaseTagArr;

//小组ID
@property(nonatomic,copy,readwrite)NSString *groupId;
//小组名字
@property(nonatomic,copy,readwrite)NSString *groupName;
//小组图片
@property(nonatomic,copy,readwrite)NSString *picture;
//参与者
@property(nonatomic,copy,readwrite)NSArray *participators;

//是否点赞
@property(nonatomic,copy,readwrite)NSString *isPraise;
//点赞数量
@property(nonatomic,copy,readwrite)NSString *praiseCount;

// 列表中 文章中的9张图片
// 详情中 文章中的所有图片
@property (nonatomic, copy, readwrite) NSArray *imageList;

/// postDiseaseExtList  追加的描述和结论    list
@property (nonatomic, copy, readwrite) NSArray *postDiseaseExtList;
@property (nonatomic, copy, readonly)NSString *postUUID;//删除病例用
//提醒某人
@property(nonatomic,copy,readwrite)NSString*atUsers;
//组员权限
@property (nonatomic, copy)NSString *memberGrade;
//文章所在的小组类型
@property(nonatomic,copy)NSString *groupType;
//文章置顶标志 0 不置顶 1 是置顶
@property (nonatomic, copy)NSString *topFlag;

//文章下线状态
@property (nonatomic, copy)NSString *status;
//页面偏移量 用于搜索翻页
@property(nonatomic,strong)NSString *pageOffset;
//是否有文章更新
@property(nonatomic,strong)NSString *isNew;
@property(nonatomic,strong)CMTPicture *sharePic;
@property(nonatomic,strong)NSString *istop;//是否是置顶文章
@end
