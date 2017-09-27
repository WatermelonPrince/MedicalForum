//
//  CMTContentEmptyView.h
//  MedicalForum
//
//  Created by fenglei on 15/2/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 空内容提示
@interface CMTContentEmptyView : UIView

/* input */

/// 提示
@property (nonatomic, copy) NSString *contentEmptyPrompt;
// view
@property (nonatomic, strong) UILabel *promptLabel;                 // 提示Label

@end
