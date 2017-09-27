//
//  CMTAddHosptialViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 15/3/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTAddHosptialViewController : CMTBaseViewController<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *mTfField;
@property (strong, nonatomic) UIBarButtonItem *mLeftItem;
@property (strong, nonatomic) UIBarButtonItem *mRightItem;
@property (strong, nonatomic) UILabel *mLbHosptial;

@property(strong,nonatomic)void(^updateHostpital)(CMTHospital *Hospital);
//取消按钮关联方法
- (void)buttonCancel:(UIBarButtonItem *)item;
//保存按钮关联方法
- (void)buttonSave:(UIBarButtonItem *)item;

@end
