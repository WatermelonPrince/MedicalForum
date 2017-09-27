//
//  CmtMoreSeriesVideoViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/27.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
typedef NS_OPTIONS(NSUInteger, CMTOptionType) {
     CMTTAllRecommendedVideo = 0,      // 显示全部推荐视频
     CMTSeriesLabelMoreVideo,         // 显示更多标签视频
     CMTCollCollegeVideo,         // 显示更多学院视频
     CMTCollassortmentVideo,    // 显示更多学院分类视频
};
@interface CmtMoreVideoViewController : CMTBaseViewController
//获取系列更多视频
-(instancetype)initWithSeresParam:(CMTSeriesNavigation*)navgation type:(CMTOptionType)option;
//获取学院视频
-(instancetype)initWithCollege:(CMTCollegeDetail*)College type:(CMTOptionType)option;
//获取全部视频
-(instancetype)initWithType:(CMTOptionType)option;
//更新系列内容
@property(nonatomic,strong)void(^updateseriesContent)(CMTSeriesNavigation* Navigation);
@end
