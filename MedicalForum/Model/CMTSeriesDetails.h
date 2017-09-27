//
//  CMTSeriesDetails.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTSeriesDetails : CMTObject
@property(nonatomic,strong)NSArray *navigations;
@property(nonatomic,strong)NSString *seriesDesc;
@property(nonatomic,strong)NSString *themeUuid;//系统课程uuid
@property(nonatomic,strong)NSString *picUrl;	//课程url
@property(nonatomic,strong)NSString *picAttr;//	w_h
@property(nonatomic,strong)NSString *seriesName;//	系统课程名称
@property(nonatomic,strong)NSString *shareUrl;//分享链接
@property(nonatomic,strong)CMTPicture *sharePic;//分享图片
@property(nonatomic,strong)NSString *shareDesc;//分享简介
@property (nonatomic, strong)NSString *pageOffset;//偏移量
@property (nonatomic, strong)NSString *opTime;//订阅时间
@property (nonatomic, strong)NSString *viewTime;//阅读时间
@property (nonatomic, strong)NSString * newrecordCount;
@property (nonatomic, strong)NSString *type;//1是系列2是直播列表
@property (nonatomic, strong)NSString *totalHeat;//热度
@property (nonatomic, strong)NSString *dateTime;//日期


@end
