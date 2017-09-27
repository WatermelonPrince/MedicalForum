//
//  CMTSendCaseType.h
//  MedicalForum
//
//  Created by fenglei on 15/8/6.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

//#import "CMTSendCaseType.h"

#ifndef MedicalForum_CMTSendCaseType_h
#define MedicalForum_CMTSendCaseType_h

/// 发帖类型
typedef NS_ENUM(NSInteger, CMTSendCaseType) {
    CMTSendCaseTypeUnDefined = 0,
    CMTSendCaseTypeAddPost,                     // 广场发帖
    CMTSendCaseTypeAddGroupPost,                // 小组发帖
    CMTSendCaseTypeAddPostDescribe,             // 追加描述
    CMTSendCaseTypeAddPostConclusion,           // 追加结论
    CmtSendLiveTypeAddpost,                     //直播追加帖子
};

#endif
