//
//  CMTAddPost.h
//  MedicalForum
//
//  Created by fenglei on 15/8/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTPost.h"
#import "CMTLive.h"

@interface CMTAddPost : CMTObject

/* send parameters */

/// userId  用户ID    long
@property (nonatomic, copy, readwrite) NSString *userId;
//直播ID
@property(nonatomic,copy,readwrite)NSString *liveBroadcastId;
//直播分会场 标签
@property(nonatomic,copy,readwrite)CMTLiveTag *livetag;
/// postType    疾病类型    int
/// 参考接口70中文章类型id
@property (nonatomic, copy, readwrite) NSString *postTypeId;
/// content 发帖内容  string
@property (nonatomic, copy, readwrite) NSString *addPostContent;
/// title   标题  string
@property (nonatomic, copy, readwrite) NSString *title;
/// groupId 小组id    long
/// 可为空，空表示广场发表
@property (nonatomic, copy, readwrite) NSString *groupId;
/// diseaseTag  疾病标签    String
/// 多个以英文逗号分隔，内容为疾病标签id
@property (nonatomic, copy, readwrite) NSArray *diseaseTagArray;
//多个以英文逗号分隔，内容为用户ID
@property (nonatomic, copy, readwrite) NSArray *userinfoArray;
//投票选项
@property(nonatomic,copy,readwrite)NSArray *voteArray;
//发帖标题
@property(nonatomic,copy,readwrite)NSString *voteTilte;

/// postId  文章ID    long
@property (nonatomic, copy, readwrite) NSString *postId;
/// contentType   内容类型    int
/// 0.追加的描述 1.结论 可不传 默认0
@property (nonatomic, copy, readwrite) NSString *contentType;

/// picture 本地图片路径
@property (nonatomic, copy, readwrite) NSArray *pictureFilePaths;

/// addPostStatus   发帖状态
/// 0: 未发帖 1:发帖中 2:发帖成功 3:发帖失败
@property (nonatomic, copy, readwrite) NSString *addPostStatus;

/* receive parameters */

/// postBrief   病例简述
/// 该字段与病例筛选接口中的对象一致
@property (nonatomic, copy, readwrite) CMTPost *postBrief;

/// content 发表内容    string
/// html格式的内容
@property (nonatomic, copy, readwrite) NSString *content;
/// picList 上传的图片列表
@property (nonatomic, copy, readwrite) NSArray *picList;

/// opTime  操作时间    long
/// 13位UNIX时间戳
@property (nonatomic, copy, readwrite) NSString *opTime;
/// score   积分  int
/// 大于0的积分需要提示
@property (nonatomic, copy, readwrite) NSString *score;

/// createTime  发表时间    long
/// 13位UNIX时间戳
@property (nonatomic, copy, readwrite) NSString *createTime;
//直播消息
@property(nonatomic,copy,readwrite)CMTLive *liveBroadcastMessage;
//是否被禁言
@property(nonatomic,copy,readwrite)NSString *isBanned;

@end