//
//  CMTLivesRecord.h
//  MedicalForum
//
//  Created by zhaohuan on 16/6/2.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTCollegeInfo : CMTObject
@property (nonatomic, strong)NSString *collegeId;
@property (nonatomic, strong)NSString *collegeName;

@end
//系列课程专题信息
@interface CMTThemeInfo : CMTObject
@property (nonatomic, strong)NSString *themeUuid;//系列课程uuid
@property (nonatomic, strong)NSString *picUrl;//小图标u
@property(nonatomic,strong) NSString*markName;
@end
@interface CMTLivesRecord : CMTObject
@property (nonatomic, copy)NSString *classRoomId;//直播课程id
@property (nonatomic, copy)NSString *title;//直播间标题
@property (nonatomic, copy)NSString *studentClientToken;//客户端登陆密码
@property (nonatomic, copy)NSString *startDate;//开始日期 时间戳
@property (nonatomic, copy)NSString *roomPic;//房间默认图片
@property (nonatomic, copy)NSString *studentJoinUrl;//录播或点播的播放地址
@property (nonatomic, copy)NSString *roomId;//实时课堂id（thirdToken）
@property (nonatomic, copy)NSString *serviceType;//直播类型
@property (nonatomic, copy)NSString *number;//房间号
@property (nonatomic, copy)NSString *endDate;//结束时间 时间戳
@property (nonatomic, copy)NSString *pageOffset;//偏移量
@property (nonatomic, copy)NSString *roomPicAttr;//w_h
@property (nonatomic, copy)NSString *subDepartment;//科室名称 取子科室名
@property (nonatomic, copy)NSString *hospital;//医院名称
@property (nonatomic, copy)NSString *userPic;//用户图片
@property (nonatomic, copy)NSString *userName;//用户姓名
@property (nonatomic, copy)NSString *level;//职称级别
@property (nonatomic, copy)NSString *userPicAttr;//w_h
@property(nonatomic, strong)NSString *sysDate;
@property(nonatomic,strong)NSString *flag;
@property(nonatomic,strong)NSString *isJoin;//是否报名 	0：报名 1：未报名
@property(nonatomic,strong)NSString *desUrl;//详情链接
@property(nonatomic,strong)NSString *liveUuid;//直播标识
@property(nonatomic,strong)NSString *status;//直播间状态
@property(nonatomic,strong)NSString *coursewareId;//点播课件id或录播视频id
@property(nonatomic,strong)NSString *iswarmup;//是否有暖场 0:无，1：有
@property(nonatomic,strong)NSString *warmupStime;//暖场开始时间

@property(nonatomic,strong)NSString *qaswitch;//是否有问答 0:关，1:开
@property(nonatomic,strong)NSString *shareUrl;//分享链接
@property(nonatomic,strong)CMTPicture *sharePic;//分享图片
@property(nonatomic,strong)NSString *shareDesc;//分享简介
@property(nonatomic,strong)NSString*type;//点播类型
@property(nonatomic,strong)NSString*liveType ;//课程类型	int		1：点播 2:录播
@property(nonatomic,strong)NSString*playVideoUrl;//	录播播放地址	string
@property (nonatomic, copy)NSString *users;//观看人数;
@property(nonatomic,copy)NSString *incrIdFlag;//翻页标志
@property(nonatomic,copy)CMTPicture *videoPic;//视频默认图片
@property(nonatomic,strong)NSString *classRoomType;//1：直播，2：点播 3：录播 4：系列课程
@property(nonatomic,strong)NSString *displayType;//播放界面优先显示	1:PPT 2:视频
@property(nonatomic,strong)NSString *createdTime;//创建时间
@property (nonatomic,strong)CMTThemeInfo *themeInfo;
@property (nonatomic, strong)CMTCollegeInfo *collegeInfo;//所属学院信息
@property(nonatomic,strong)NSString *playDuration;//播放时长
@property(nonatomic,strong)NSString *playstatus;//是否播放完成 1 是播放完成 0 播放未完成
@property(nonatomic,strong)NSString *islearn;//是否在学习记录中 0 是不在 1 是在
@property(nonatomic,strong)NSString *isvideoFristLoad;//视频是否第一次加载
@property (nonatomic, assign)BOOL isSelected;//编辑状态是否被选中
@property (nonatomic, strong)NSString *isStore;//是否被收藏;
@property(nonatomic,strong)NSString *dataId;//用于记录删除
@property(nonatomic,assign)BOOL isrefresh;//收藏列表进入取消收藏
@property(nonatomic,assign)long fileSize;//数据大小
@property(nonatomic,strong)NSData *downData;//已经下载的缓存
@property(nonatomic,assign)long haveDownLength;//已经下载的长度
@property(nonatomic,assign)float downloadProgress;//下载进度
@property(nonatomic,strong)NSString *strDownloadID;
@property(nonatomic,assign)long Downstate;//0 等待 1 下载，2 已暂停 3，正在连接 4 下载失败，5，已经取消下载，6 当前 非 wifi
//视频直播开始时间和结束时间拼接
- (NSString *)startDateAndEndDateformattNSString;

//倒计时拼接字符串

- (NSString *)toStartTimeformattNSStringWithCurrentTime:(NSString *)time;

@end
@interface CmtLiveOrOnDemand : CMTObject
@property(nonatomic,strong)CMTLivesRecord *roominfo;
@property(nonatomic,strong)CMTLivesRecord *videoinfo;
@end
