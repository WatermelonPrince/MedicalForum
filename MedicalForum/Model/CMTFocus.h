//
//  CMTFocus.h
//  MedicalForum
//
//  Created by fenglei on 15/4/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTFocus : CMTObject

/// postId  文章ID    int
@property(nonatomic, copy, readwrite) NSString *postId;
/// title   文章标题    string
@property(nonatomic, copy, readwrite) NSString *title;
/// picture 大图url   string
@property(nonatomic, copy, readwrite) NSString *picture;
/// postAttr    文章属性    int
/// 0 默认普通文章；1只含pdf；2 ppt文章；3视频；13表示pdf,视频文章等
/// 本期客户端只处理值为1的情况，此时为文章添加pdf标签；其它值均先忽略
@property(nonatomic, copy, readwrite) NSString *postAttr;
/// themeStatus 专题状态    int
/// 0 非专题；1 专题未上线；2 专题已上线；
/// 当该值为2时，将此文章标识为专题(0,1忽略)，根据下面的themeId字段跳转到专题列表；
@property(nonatomic, copy, readwrite) NSString *themeStatus;
/// themeId 专题ID		int
/// 当themeStatus=2时，标识为专题，此值有意义，根据此id跳转对应专题
@property(nonatomic, copy, readwrite) NSString *themeId;
/// 是否是动态详情页 0 非动态详情页；1 动态详情页
@property(nonatomic, copy, readwrite) NSString *isHTML;
/// 动态详情页url string
@property(nonatomic, copy, readwrite) NSString *url;
/// module  文章模块    int
/// 0.首页 1.病例 2.指南
@property (nonatomic, copy, readwrite) NSString *module;
//小组ID
@property(nonatomic,copy,readwrite)NSString *groupId;
//小组名字
@property(nonatomic,copy,readwrite)NSString *groupName;
//组员权限
@property (nonatomic, copy)NSString *memberGrade;
//文章所在的小组类型
@property(nonatomic,copy)NSString *groupType;

//学科ID
@property (nonatomic, copy) NSString *subjectId;
@property(nonatomic,strong)NSString *type;//0 资讯；1 课程

@end
