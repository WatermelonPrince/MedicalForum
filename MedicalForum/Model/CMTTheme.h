//
//  CMTTheme.h
//  MedicalForum
//
//  Created by Bo Shen on 15/4/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTTheme : CMTObject

/// postId 文章Id    int
@property (copy, nonatomic, readwrite) NSString *postId;
/// themeId 专题Id    int
@property (copy, nonatomic, readwrite) NSString *themeId;
/// title   专题标题    string
@property (copy, nonatomic, readwrite) NSString *title;
/// description 专题简介    string
@property(nonatomic, copy, readwrite) NSString *descriptionString;
/// picture 专题图片    string
@property(nonatomic, copy, readwrite) NSString *picture;
/// shareUrl    分享url   string
@property(nonatomic, copy, readwrite) NSString *shareUrl;
/// opTime  专题关注时间  unix时间  long
@property(nonatomic, copy, readwrite) NSString *opTime;
/// viewTime    专题浏览时间  unix时间  long
@property(nonatomic, copy, readwrite) NSString *viewTime;
/// 是否是动态详情页 0 非动态详情页；1 动态详情页
@property (nonatomic, copy, readwrite) NSString *isHTML;
/// 动态详情页url string
@property (nonatomic, copy, readwrite) NSString *url;
//图片分享链接
@property(nonatomic,strong)CMTPicture *sharePic;

@end
