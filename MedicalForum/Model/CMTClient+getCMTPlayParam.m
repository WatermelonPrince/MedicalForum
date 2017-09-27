//
//  CMTClient+getCMTPlayParam.m
//  MedicalForum
//
//  Created by zhaohuan on 16/6/2.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTClient+getCMTPlayParam.h"

@implementation CMTClient (getCMTPlayParam)
//获取直播点播列表更新通知
//
//编号  :  119
- (RACSignal *)getCMTPlayParamIsNew:(NSDictionary *)parameters{
    return [self GET:@"app/live/updatenotif.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
}



- (RACSignal *)getCMTPlayParam:(NSDictionary *)parameters{
    return [self GET:@"app/live/liverooms.json" parameters:parameters resultClass:[CMTPlayAndRecordList class] withStore:NO];
}
- (RACSignal *)getCMTPlayRegistStatus:(NSDictionary *)parameters{
    return [self GET:@"app/live/usersign.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
}

//123 获取直播间状态
- (RACSignal *)CMTGetRoomStatus:(NSDictionary *)parameters{
    return [self GET:@"app/live/getRoomStatus.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
}
//133 获取直播间详情
- (RACSignal *)CMTGetRoomInfo:(NSDictionary *)parameters{
    return [self GET:@"app/live/getroominfo.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
}
//133 获取直播判断是否跳转点播
- (RACSignal *)CMTGetIfLiveJumpOnDemand:(NSDictionary *)parameters{
    return [self GET:@"app/live/getroominfo.json" parameters:parameters resultClass:[CmtLiveOrOnDemand class] withStore:NO];
}

//140 获取录播详情
- (RACSignal *)CMTGetIfRecordedJumpOnDemand:(NSDictionary *)parameters{
    return [self GET:@"app/live/getvideobyid.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
}

- (RACSignal *)CMTGetVideoPlayStatus:(NSDictionary *)parameters{
    return [self GET:@"app/live/getRecordStatus.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];

}
//获取系列详情
- (RACSignal *)CMTGetSeriesDetail:(NSDictionary *)parameters{
    return [self GET:@"app/live/series/detail.json" parameters:parameters resultClass:[CMTSeriesDetails class] withStore:NO];
    
}

//143 获取壹生大学首页信息接口4个部分
- (RACSignal *)CMTGetUniverVediolist:(NSDictionary *)parameters{
    return [self GET:@"/app/live/homepage.json" parameters:parameters resultClass:[CMTPlayAndRecordList class] withStore:NO];
}

//144筛选接口
- (RACSignal *)CMTQueryTypeVideos:(NSDictionary *)parameters{
    return [self CMTGetmoreVideo:parameters];
}

//144 更多视频
- (RACSignal *)CMTGetmoreVideo:(NSDictionary *)parameters{
    return [self GET:@"/app/live/getvideolist.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
   
}

//153课程收藏接口
- (RACSignal *)CMTStoreVideoAction:(NSDictionary *)parameters{
    return [self GET:@"/app/user/roomstore.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];

}

//154 课程收藏列表接口

- (RACSignal *)CMTGetCollectionVideo:(NSDictionary *)parameters{
    return [self GET:@"/app/user/roomstorelist.json" parameters:parameters resultClass:[CMTPlayAndRecordList class] withStore:NO];
    
}

//155删除课程收藏接口
- (RACSignal *)CMTDeleteStoreVideoAction:(NSDictionary *)parameters{
    return [self GET:@"/app/user/delroomstore.json" parameters:parameters resultClass:[CMTPlayAndRecordList class] withStore:NO];
}

//156资讯收藏删除接

- (RACSignal *)CMTDeleteMessageStore:(NSDictionary *)parameters{
    return [self GET:@"/app/user/delpoststore.json" parameters:parameters resultClass:[CMTStore class] withStore:NO];
    
}

//132 录播视频播放量统计接口
- (RACSignal *)CMTGetvideoplaynumber:(NSDictionary *)parameters{
    return [self GET:@"app/live/videoplay.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
}

//146 获取广告
- (RACSignal *)CMTGetAdvert:(NSDictionary *)parameters{
    return [self GET:@"app/live/getAdvers.json" parameters:parameters resultClass:[CMTPlayAndRecordList class] withStore:NO];
}
//139 获取学院详情
- (RACSignal *)CMTGetCollegeDetails:(NSDictionary *)parameters{
    return [self GET:@"app/live/getcollegeinfo.json" parameters:parameters resultClass:[CMTCollegeDetail class] withStore:NO];
    
}


//127获取更多系列
- (RACSignal *)CMTGetmoreSerious:(NSDictionary *)parameters{
    return [self GET:@"app/live/series/list.json" parameters:parameters resultClass:[CMTSeriesDetails class] withStore:NO];
    
}
//135 系列,直播,点播,录播分享
- (RACSignal *)ShareStatisticsCourse:(NSDictionary *)parameters{
    return [self GET:@"app/live/share.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
    
}
//134 用户进入直播间和点播接口
- (RACSignal *)getJoinroomNumber:(NSDictionary *)parameters{
    return [self GET:@"app/live/joinroom.json" parameters:parameters resultClass:[CMTSeriesDetails class] withStore:NO];
    
}
//136 订阅系列课程接口
- (RACSignal *)cmtSubscribeSeriesDetail:(NSDictionary *)parameters{
    return [self GET:@"app/series/follow.json" parameters:parameters resultClass:[CMTSeriesDetails class] withStore:NO];
}

// 141壹生大学搜索接口
- (RACSignal *)CMTSearchColledge:(NSDictionary *)parameters{
    return [self GET:@"app/live/search.json" parameters:parameters resultClass:[CMTPlayAndRecordList class] withStore:NO];
}
//  145 系列课程筛选
- (RACSignal *)CMTColledgeSeriesSelectList:(NSDictionary *)parameters{
    return [self GET:@"app/live/series/selectList.json" parameters:parameters resultClass:[CMTSeriesDetails class] withStore:NO];
}
// 150-用户课程观看时长接口
- (RACSignal *)CMTPersonalLearningRecord:(NSDictionary *)parameters{
    return [self GET:@"app/user/playduration.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}
// 151-获取我的学习记录接口
- (RACSignal *)CMTPersonalLearningList:(NSDictionary *)parameters{
    return [self GET:@"app/user/learnlist.json" parameters:parameters resultClass:[CMTLivesRecord class] withStore:NO];
}
// 152-删除学习记录
- (RACSignal *)CMTDeleteTheLearningRecord:(NSDictionary *)parameters{
    return [self GET:@"app/user/dellearn.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}
@end
