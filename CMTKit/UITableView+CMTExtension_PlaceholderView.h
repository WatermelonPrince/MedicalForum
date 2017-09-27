//
//  UITableView+CMTExtension_PlaceholderView.h
//  MedicalForum
//
//  Created by fenglei on 15/6/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 为列表添加空数据提示
@interface UITableView (CMTExtension_PlaceholderView)

/* input */

/// 列表空数据提示
@property (nonatomic, strong) UIView *placeholderView;
/// 列表空数据提示 偏移
@property (nonatomic, copy) NSValue *placeholderViewOffset;   // NSValue of CGPoint

/* output */

/// 列表是否为空
- (BOOL)isTableViewEmpty;

@end
