//
//  CMTShareView.h
//  MedicalForum
//
//  Created by Bo Shen on 15/2/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTShareView : UIView
@property (strong, nonatomic) UILabel *lbTitle;

@property (copy, nonatomic) UIButton *mBtnFriend;
@property (copy, nonatomic) UIButton *mBtnSina;
@property (copy, nonatomic) UIButton *mBtnWeix;
@property (copy, nonatomic) UIButton *mBtnMail;
@property (copy, nonatomic) UIButton *cancelBtn;

@property (strong, nonatomic) UILabel *lbFriend;
@property (strong, nonatomic) UILabel *lbSina;
@property (strong, nonatomic) UILabel *lbWeix;
@property (strong, nonatomic) UILabel *lbMail;


///自定义分享视图
+ (instancetype)shareView:(CGRect)frame;

@end
