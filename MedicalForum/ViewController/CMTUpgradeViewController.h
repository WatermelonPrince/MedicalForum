//
//  CMTUpgradeViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/25.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTAutPromptView.h"
#import "CMTReadCodeBlindViewController.h"

@interface CMTUpgradeViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *mTableView;
@property (strong, nonatomic) UIImageView *mArrowsImageView1;
@property (strong, nonatomic) UIImageView *mArrowsImageView2;

@property (strong, nonatomic) UIBarButtonItem *mItemSave;
//真实姓名
@property (strong, nonatomic) UILabel *mLbRealy;
//医院
@property (strong, nonatomic) UILabel *mLbHospital;
//科室
@property (strong, nonatomic) UILabel *mLbDepartment;
//级别
@property (strong, nonatomic) UILabel *mLbGrade;
//医师号
@property (strong, nonatomic) UILabel *mLbDoctorNum;

@property (strong, nonatomic) NSString *mStrRealy;
@property (strong, nonatomic) NSString *mStrHospital;
@property (strong, nonatomic) NSString *mStrDepartment;
@property (strong, nonatomic) NSString *mStrDoctorNum;
@property (strong, nonatomic) NSString *mStrGrade;

@property (strong, nonatomic) UILabel *mLbIntroduction;

@property (strong, nonatomic) UILabel *mLbAskFor;
@property (strong, nonatomic) UIButton *mBtnAskFor;

@property (strong, nonatomic) UIImageView *mImageAuthor;

@property (strong, nonatomic) CMTAutPromptView *mPromptView;

@property (strong, nonatomic) CMTHospital *mHosptioal;
@property (strong, nonatomic) CMTDepart *mDepart;
@property (strong, nonatomic) CMTSubDepart *mSubDepart;
//上一级控制器的标识
@property (strong, nonatomic) NSString *lastVC;

@property (assign) NEXTVC nextVC;
//更新按钮状态
@property(nonatomic,strong)void(^updateCreatebuttonState)(NSString *autoSate);
-(instancetype)initWithGroup:(CMTGroup*)group;
@end
