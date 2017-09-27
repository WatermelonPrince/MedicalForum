//
//  CMTTabBarItem.h
//  MedicalForum
//
//  Created by fenglei on 15/5/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 底部导航栏条目
@interface CMTTabBarItem : UIView

/* init */
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage index:(NSInteger)index;
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;

/* input */

/// 标记值
@property (nonatomic, copy) NSString *badgeValue;

/* control */

/// 选中状态
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property(nonatomic,assign)BOOL isShowBagde;
@property(nonatomic,assign)NSInteger index;

@end
