//
//  CMTBarButtonItem.h
//  MedicalForum
//
//  Created by fenglei on 15/2/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 导航按钮
@interface CMTBarButtonItem : UIBarButtonItem

/* init */

+ (instancetype)itemWithImage:(UIImage *)image imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;
+ (instancetype)itemWithImage:(UIImage *)image badge:(UIView *)badge imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;
//带有数字的红色气泡按钮
+ (instancetype)itemWithImage:(UIImage *)image badgeValue:(UILabel *)badgeValue imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;
//带有红色气泡和数字气泡的按钮
+ (instancetype)itemWithImage:(UIImage *)image badge:(UIView *)badge badgeValue:(UILabel *)badgeValue imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;

/* output */

/// 点击按钮
@property (nonatomic, strong, readonly) RACSignal *touchSignal;
/// 标记
@property (nonatomic, strong, readonly) UIView *badge;
@property(nonatomic,strong,readwrite) UILabel *badgeValue;

@property (nonatomic,strong)UIButton *customButton;



@end
