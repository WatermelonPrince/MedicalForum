//
//  CMTStore.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTStore : CMTObject

//postId	文章ID
@property(nonatomic, copy, readwrite) NSString *postId;
//title	文章标题		string
@property(nonatomic, copy, readwrite) NSString *title;
//postType	文章类型	类型枚举待定义	int
//@property(nonatomic, copy, readwrite) NSNumber *postType;
@property (nonatomic, copy, readwrite) NSString *postType;
//smallPic	缩略图		url
@property(nonatomic, copy, readwrite) NSString *smallPic;
//opTime	收藏时间	unix时间	long
@property(nonatomic, copy, readwrite) NSString *opTime;
//createTime
@property(nonatomic, copy, readwrite) NSString *createTime;
//author
@property(nonatomic, copy, readwrite) NSString *author;
/// shareUrl
@property(nonatomic, copy, readwrite) NSString *shareUrl;
/// 图片url
@property(nonatomic, copy, readwrite) NSArray *imageUrls;
/// 摘要
@property(nonatomic, copy, readwrite) NSString *brief;

/// 是否是动态详情页 0 非动态详情页；1 动态详情页
@property (nonatomic, copy, readwrite) NSString *isHTML;
/// 动态详情页url string
@property (nonatomic, copy, readwrite) NSString *url;

@property (nonatomic, assign)BOOL isSelected; //编辑状态是否被选中

/// module  文章模块    int
/// 0.首页 1.病例 2.指南
@property (nonatomic, copy, readwrite) NSString *module;
@property(nonatomic,strong)NSString *postAttr;
@property(nonatomic,strong)NSString *groupId;

@end
