//
//  CMTshakeobject.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/13.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTshakeobject : CMTObject
//类型
@property(nonatomic, copy, readwrite) NSString *type;
//结果id
@property(nonatomic, copy, readwrite) NSString *id;
//参数
@property(nonatomic, copy, readwrite) CMTshakeobject *param;
//描述
@property(nonatomic, copy, readwrite) NSString *describe;
//是否可摇标志
@property(nonatomic, copy, readwrite) NSString *shakeFlag;
//专题ID
@property(nonatomic, copy, readwrite) NSString *themeId;
//文章ID
@property(nonatomic, copy, readwrite) NSString *postId;

//小组ID
@property(nonatomic, copy, readwrite) NSString *groupId;
//疾病ID
@property(nonatomic, copy, readwrite) NSString *diseaseId;
//活动链接
@property(nonatomic, copy, readwrite) NSString *url;
//摇一摇返回ID 作为拼接字符串继续请求数据用
@property(nonatomic, copy, readwrite) NSString *resultId;
//是否是html页面
@property(nonatomic, copy, readwrite) NSString *isHTML;
//返回通知数目
@property(nonatomic, copy, readwrite) NSString *noticeCount;
//返回状态 status =2 时  摇一摇无活动

@property(nonatomic, copy, readwrite) NSString *status;
//小组名字
@property(nonatomic, copy, readwrite)NSString *groupName;


@end
