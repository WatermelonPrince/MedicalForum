//
//  CMTSettingViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/22.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


#import "CMTBaseViewController.h"
#import "CMTUserInfo.h"


@interface CMTSettingViewController : CMTBaseViewController<UITextFieldDelegate>

@property (strong, nonatomic) UIBarButtonItem * mFinishItem;
@property (strong, nonatomic) UIView *mHeadView;
@property (strong, nonatomic) UIView *mNickNameView;
@property (strong, nonatomic) UILabel *lbHead;
@property (strong, nonatomic) UILabel *lbNickName;
@property (strong, nonatomic) UIImageView *mImageViewHead;
@property (strong, nonatomic) UITextField *mTfNickName;
@property (strong, nonatomic) UIActionSheet *mActionSheet;
@property (strong, nonatomic) UITextField *mTextView;


@property (strong , nonatomic) CMTUserInfo *mUserInfo;

@property (assign) BOOL hasChosImage;

@property (assign)  NEXTVC nextvc;
/*导航栏右侧按钮关联方法*/
- (void)btnFinishSetting:(id)sender;


@end
