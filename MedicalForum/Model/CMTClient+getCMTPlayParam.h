//
//  CMTClient+getCMTPlayParam.h
//  MedicalForum
//
//  Created by zhaohuan on 16/6/2.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTClient.h"

@interface CMTClient (getCMTPlayParam)
//119
- (RACSignal *)getCMTPlayParamIsNew:(NSDictionary *)parameters;
//120
- (RACSignal *)getCMTPlayParam:(NSDictionary *)parameters;

//118 报名
- (RACSignal *)getCMTPlayRegistStatus:(NSDictionary *)parameters;
//123 判断直播间是否结束
- (RACSignal *)CMTGetRoomStatus:(NSDictionary *)parameters;
//124 判断点播间是否删除
- (RACSignal *)CMTGetVideoPlayStatus:(NSDictionary *)parameters;
// 128 系列课程详情接口
- (RACSignal *)CMTGetSeriesDetail:(NSDictionary *)parameters;
//130 获取壹生大学首页信息接口4个部分
- (RACSignal *)CMTGetUniverVediolist:(NSDictionary *)parameters;
- (RACSignal *)CMTGetmoreVideo:(NSDictionary *)parameters;
- (RACSignal *)CMTGetRoomInfo:(NSDictionary *)parameters;
- (RACSignal *)CMTGetIfLiveJumpOnDemand:(NSDictionary *)parameters;
//139 获取学院详情
- (RACSignal *)CMTGetCollegeDetails:(NSDictionary *)parameters;
//140 获取录播详情
- (RACSignal *)CMTGetIfRecordedJumpOnDemand:(NSDictionary *)parameters;
//127获取更多系列
- (RACSignal *)CMTGetmoreSerious:(NSDictionary *)parameters;

- (RACSignal *)CMTGetvideoplaynumber:(NSDictionary *)parameters;
//统计点播,直播观看人数
- (RACSignal *)getJoinroomNumber:(NSDictionary *)parameters;
// 135 系列 直播 分享统计
- (RACSignal *)ShareStatisticsCourse:(NSDictionary *)parameters;
//136 订阅系列课程接口
- (RACSignal *)cmtSubscribeSeriesDetail:(NSDictionary *)parameters;
//壹生大学搜索接口
- (RACSignal *)CMTSearchColledge:(NSDictionary *)parameters;
//144筛选接口
- (RACSignal *)CMTQueryTypeVideos:(NSDictionary *)parameters;
//145 系列课程筛选
- (RACSignal *)CMTColledgeSeriesSelectList:(NSDictionary *)parameters;

//153课程收藏接口
- (RACSignal *)CMTStoreVideoAction:(NSDictionary *)parameters;
//155删除课程收藏接口
- (RACSignal *)CMTDeleteStoreVideoAction:(NSDictionary *)parameters;


//154 课程收藏列表接口

- (RACSignal *)CMTGetCollectionVideo:(NSDictionary *)parameters;

// 150-用户课程观看时长接口
- (RACSignal *)CMTPersonalLearningRecord:(NSDictionary *)parameters;
// 151-获取我的学习记录接口
- (RACSignal *)CMTPersonalLearningList:(NSDictionary *)parameters;
// 152-删除学习记录
- (RACSignal *)CMTDeleteTheLearningRecord:(NSDictionary *)parameters;
//156资讯收藏删除接

- (RACSignal *)CMTDeleteMessageStore:(NSDictionary *)parameters;
//146 获取广告
- (RACSignal *)CMTGetAdvert:(NSDictionary *)parameters;

@end
