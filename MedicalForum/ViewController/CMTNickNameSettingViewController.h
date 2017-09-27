//
//  CMTNickNameSettingViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 15/1/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTNickNameSettingViewController : CMTBaseViewController

@property (strong, nonatomic) UITextField *mTfField;

@property (retain, nonatomic) NSString *mCurrentName;

@property (strong, nonatomic) UIBarButtonItem *mLeftItem;
@property (strong, nonatomic) UIBarButtonItem *mRightItem;

@end
