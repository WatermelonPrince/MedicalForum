//
//  CMTThemePostList.h
//  MedicalForum
//
//  Created by fenglei on 15/4/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"
@class CMTTheme;
@class CMTLive;

@interface CMTThemePostList : CMTObject

/// theme   专题  object
/// 为节省传输流量，incrId=0时，该对象返回专题信息；翻页时incrId!=0时，该对象可能为空
@property (nonatomic, copy, readonly) CMTTheme *theme;
/// items   专题文章列表  list
@property (nonatomic, copy, readonly) NSArray *items;
//直播
@property(nonatomic,copy,readonly)CMTLive *liveInfo;
@end

@interface CMTThemePostOnlyList : CMTObject

/// items   专题文章列表  list
@property (nonatomic, copy, readonly) NSArray *items;
//直播
@property(nonatomic,copy,readonly)CMTLive *liveInfo;

@end
