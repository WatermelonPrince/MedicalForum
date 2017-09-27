//
//  CMTModel.h
//  MedicalForum
//
//  Created by fenglei on 14/12/4.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTUserInfo.h"
#import "CMTPicture.h"
#import "CMTClient+LoginInterface.h"
#import "CMTHospitalInformation.h"
#import "CMTClient+HospitalInterface.h"
// 11. 订阅学科接口
#import "CMTClient+Concern.h"
#import "CMTConcern.h"

// 12. 同步订阅学科接口
#import "CMTClient+SyncConcern.h"

// 13. 收藏文章接口
#import "CMTClient+Store.h"
#import "CMTStore.h"

// 14. 同步收藏文章接口
#import "CMTClient+SyncStore.h"

// 15. 订阅列表接口
#import "CMTClient+GetDepartmentList.h"

// 16. 查看作者文章列表接口
// 17. 首页/病例文章列表接口
// 28. 指定类型搜索接口
// 45. 某学科文章列表接口
// 48. 按普通二级标签搜索接口
// 50. 根据疾病获取文章列表接口
#import "CMTClient+GetPostList.h"
#import "CMTPost.h"

// 18. 查看文章详情接口
#import "CMTClient+GetPostDetail.h"
#import "CMTPdf.h"
#import "CMTDiseaseTag.h"

// 19. 文章评论列表接口
#import "CMTClient+GetCommentList.h"
#import "CMTComment.h"

// 20. 评论文章接口
#import "CMTClient+SendComment.h"

// 21. 回复评论接口
#import "CMTClient+ReplyComment.h"

// 22. 收到的新评论数接口
#import "CMTClient+GetNewCommentCount.h"
#import "CMTCommentCount.h"

// 23. 收到的评论列表接口
#import "CMTClient+ReceivedList.h"
#import "CMTReceivedComment.h"

// 24. 发出的评论列表接口
#import "CMTClient+SendCommentList.h"
#import "CMTSendComment.h"

// 26. 分享文章接口
#import "CMTClient+SharePost.h"

// 27. 按类型分组搜索接口
#import "CMTClient+GetPostByType.h"
#import "CMTPostByType.h"

// 29. 按科室分组在类型下搜索接口
#import "CMTClient+GetPostByDepart.h"
#import "CMTPostByDepart.h"

// 30. 指定科室在类型下搜索接口
#import "CMTClient+SearchPostInDepart.h"

// 31. 获取所有文章类型
#import "CMTClient+GetAllType.h"
#import "CMTType.h"

// 32. 删除文章评论接口
#import "CMTClient+DeleteComment.h"

// 33. 删除评论回复接口
#import "CMTClient+DeleteReply.h"

// 34. 获取文章统计数接口
// 39. 获取简单文章详情字段接口
#import "CMTClient+Statistics.h"
#import "CMTPostStatistics.h"
// 37. 获取订阅列表接口
#import "CMTClient+GetSubjectList.h"

// 38. 获取作者列表接口
#import "CMTClient+GetAuthorList.h"

// 40. 专题订阅与取消订阅接口
#import "CMTTheme.h"
#import "CMTClient+theme.h"

// 41. 同步订阅专题列表接口
#import "CMTClient+SyncTheme.h"

// 42. 查看专题文章列表接口
#import "CMTClient+GetThemePostList.h"
#import "CMTThemePostList.h"

// 43. 分享专题接口
#import "CMTClient+shareTheme.h"

// 44. 首页焦点图列表接口
#import "CMTClient+GetFocusList.h"
#import "CMTFocus.h"

// 46. 获取未读专题列表接口
#import "CMTClient+GetThemeUnreadNotice.h"

// 47. 获取某学科专题列表接口(未实现)

// 49.获取疾病列表
#import "CMTDisease.h"
#import "CMTClient+GetDiseaseList.h"

// 51. 病例订阅注接口
#import "CMTClient+FollowDisease.h"

// 52. 疾病同步订阅接口
#import "CMTClient+syncDiseaseFollow.h"

// 53. 指南我需要
#import "CMTClient+GuideRequire.h"

// 54. 获取模块未读指南接口
#import "CMTClient+GuideunReadNotice.h"

// 55. 个推初始化以及开关接口
#import "CMTClient+PushInit.h"


//57 全部公开小组
#import "CMTGroupLogo.h"
#import "CMTGroup.h"
#import "CMTClinet+getOpenGroupList.h"

//58 加入退出小组
#import "CMTClient+addTeam.h"

//59 小组成员列表接口
#import "CMTClient+getMember_list.h"

//60小组详情接口
#import "CMTClient+getGroupDetails.h"

//62 病例参与互动用户列表
#import "CMTParticiPators.h"
#import "CMTClient+getParticipators.h"

//64 病例筛选接口
#import "CMTCaseLIstData.h"
#import "CMTGroupMem.h"
#import "CMTClient+getCasePostLIst.h"

// 63. 追加描述/添加结论接口
// 65. 发表病例接口
#import "CMTAddPost.h"
#import "CMTClient+AddPost.h"

//66 对文章，评论，子评论点赞
#import "CMTClient+Praise.h"

// 67 收到点赞和评论通知接口
#import "CMTNotice.h"
#import "CMTNoticeData.h"
#import "CMTClient+getCMTNotice.h"

//68 收到的通知数目
#import"CMTClient+getnoticeCount.h"

//69 我加入的小组接口
#import"CMTClient+getMyTeams.h"

//72分享小组接口
#import "CMTClient+groupShare.h"

//74 疾病类型
#import"CMTSendCaseType.h"
#import "CMTClient+get_post_types_by_module.h"

///获取积分列表
#import "CMTScore.h"
#import "CMTClient+GetScoreList.h"

//获取积分总数接口
#import "ScoreCount.h"
#import "CMTClient+ScoreCount.h"

// 75 首页直播列表和焦点图列表接口
#import "CMTLiveListData.h"
#import "CMTLive.h"
#import "CMTClient+get_live_list_focus.h"
#import "CMTClient+getLive_info.h"

#import "CardCellModel.h"

// 77 直播消息详情接口
#import "CMTClient+GetLiveDetail.h"

// 78  直播分享
#import "CMTClient+getShareLive.h"

//79 直播点赞参与成员列表
#import "CMTClient+get_live_message_praiser_list.h"

// 80 直播消息的评论列表接口
#import "CMTLiveComment.h"
#import "CMTClient+GetLiveCommentList.h"

// 83 活动列表
#import "CMTActivities.h"
#import "CMTClient+getActivities.h"

// 84 评论直播动态和回复评论接口
#import "CMTClient+SendLiveComment.h"

// 85 直播消息点赞
#import "CMTClient+live_message_praise.h"

// 86 直播通知数目
#import "CMTClient+getLiveNoticeCount.h"

// 87 直播通知
#import "CMTLiveNotice.h"
#import "CMTClient+getLiveNotice.h"

// 88 删除直播评论接口
#import "CMTClient+DeleteLiveComment.h"

// 89 删除直播消息
#import "CMTClient+deleteLive_message.h"

// 90 直播标签列表
#import "CMTLiveTag.h"
#import "CMTClient+getLiveTagList.h"
//91 小组筛选接口
#import "CMTClient+getGroupCaseFilter.h"
//92 小组通知
#import "CMTClient+getGroupNotice.h"

//78. 业务分享接口
#import "CMTClient+CommonShare.h"
//摇一摇接口

#import "CMTshakeobject.h"
//投票对象
#import "CMTVoteObject.h"
//病例系统通知队象
#import "CMTCaseSystemNoticeModel.h"
//初始化类
#import "CMTInitObject.h"
#import "CMTAPPinit.h"

//102 数字报学科接口
#import "CMTDigitalObject.h"
#import "CMTGetDigitalSubject.h"
//103 绑定阅读码
#import "CMTBlindReadCodeResult.h"
//115 调研接口
#import "CMTSurvey.h"
#import "CMTClient+Survey.h"
//搜索小组对象
#import "CMTSearchGroupObject.h"

//创建小组验证名字重复
#import "CMTGroupCeatedCheckName.h"
//壹生大学
//所属系列课程信息
#import "CMTLivesRecord.h"
#import "CMTPlayAndRecordList.h"
#import "CMTClient+getCMTPlayParam.h"
#import "CMTCollegeDetail.h"
#import "CMTAssortments.h"

//系列
#import "CMTSeriesDetails.h"
#import "CMTSeriesNavigation.h"
//订阅系列课程列表
#import "CMTSeriesFollowed.h"
#import "CMTClient+getSeriesFollows.h"
//广告
#import "CMTAdvert.h"
#import "CMTArea.h"



