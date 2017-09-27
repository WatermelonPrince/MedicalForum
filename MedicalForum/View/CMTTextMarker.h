//
//  CMTTextMarker.h
//  MedicalForum
//
//  Created by FengLei on 15/4/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 文字标注 标注类型
typedef NS_OPTIONS(NSUInteger, CMTTextMarkerType) {
    CMTTextMarkerTypeNone = 0,      // 未指定
    CMTTextMarkerTypeTheme,         // 专题
     CMTTextMarkerTypeTop,          //置顶
};

/// 文字标注
@interface CMTTextMarker : UIView

/* input */

/// 标注类型
@property (nonatomic, assign) CMTTextMarkerType markerType;

/* output */

/// 标注大小
@property (nonatomic, assign, readonly) CGSize markerSize;

@end
