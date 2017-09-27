//
//  CMTFocusCaption.h
//  MedicalForum
//
//  Created by fenglei on 15/4/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const CGFloat CMTFocusCaptionDefaultHeight;

/// 焦点图说明
@interface CMTFocusCaption : UIView

/* input */

/// 焦点图内容
@property (nonatomic, copy) CMTFocus *focus;

@end
