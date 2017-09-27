//
//  CMTImageMarker.h
//  MedicalForum
//
//  Created by FengLei on 15/4/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 图片标注 标注类型
typedef NS_OPTIONS(NSUInteger, CMTImageMarkerType) {
    CMTImageMarkerTypeNone = 0,     // 未指定
    CMTImageMarkerTypePDF,          // PDF
    CMTImageMarkerTypePPT,          // PPT
    CMTImageMarkerTypeVideo,        // 视频
    CMTImageMarkerTypeAudio,        // 音频
    CMTImageMarkerTypeAnswer,       // 问答
    CMTImageMarkerTypeVote,         // 投票
};

/// 图片标注
@interface CMTImageMarker : UIView

/* input */

/// 标注类型
@property (nonatomic, assign) CMTImageMarkerType markerType;

/* output */

/// 标注大小
@property (nonatomic, assign, readonly) CGSize markerSize;

@end
