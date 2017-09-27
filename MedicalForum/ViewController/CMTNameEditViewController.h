//
//  CMTNameEditViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/25.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"


@interface CMTNameEditViewController : CMTBaseViewController

@property (strong, nonatomic) UITextField *mTfField;

@property (assign, nonatomic) NSInteger row;
@property(nonatomic,strong) NSString *titleString;
@property (strong, nonatomic) UIBarButtonItem *mLeftItem;
@property (strong, nonatomic) UIBarButtonItem *mRightItem;
@property (copy, nonatomic) NSString *lastVCStr;
@property(copy,nonatomic)NSString *type;//是哪一字段
@property(nonatomic,copy)void(^updatRealname)(NSString *realname);
@property (nonatomic,copy)NSString *inputClass;//输入类别




@end
