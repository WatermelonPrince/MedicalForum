//
//  CMTLiveListData.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTLiveListData : CMTObject
@property(nonatomic,strong)NSArray *liveList;//直播列表
@property(nonatomic,strong)NSArray *focusPicList;//焦点图列表
@property(nonatomic,strong)CMTLive *topMessage;
@property(nonatomic,strong)NSArray *liveMessageList;
@property(nonatomic,strong)CMTPost *topArticles;//置顶文章
// 直播间详情
@property(nonatomic,copy,readwrite)CMTLive *liveInfo;


@end
