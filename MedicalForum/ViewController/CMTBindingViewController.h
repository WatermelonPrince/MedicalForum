//
//  CMTBindingViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/22.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


#import "CMTBaseViewController.h"

@interface CMTBindingViewController : CMTBaseViewController<UITextFieldDelegate>

//@property (strong, nonatomic) UILabel *mLbTitle;

@property (strong, nonatomic) UITextField *mTfPhontNum;
@property (strong, nonatomic) UITextField *mTfVerification;

@property (strong, nonatomic) UIButton *mBtnVer;
@property (strong, nonatomic) UIButton *mBtnSure;
/*cd时间*/
@property (assign) NSInteger mSeconds;

@property (strong, nonatomic) NSTimer *mTimer;

@property (strong, nonatomic) NSString *mPhoneNum;

@property (strong, nonatomic) NSMutableArray *mArrSubcrption;

@property (assign) BOOL isLeftVC;
///记录从pop弹回的视图控制器
@property (assign)  NEXTVC nextvc;


/*判断号码合法*/
-(BOOL) isValidateMobile:(NSString *)mobile;

+ (instancetype)shareBindVC;

@end
