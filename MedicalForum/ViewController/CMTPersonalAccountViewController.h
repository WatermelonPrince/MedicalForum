//
//  CMTPersonalAccountViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/24.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTPersonalAccountViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>
/*列表*/
@property (strong, nonatomic) UITableView *mTableView;
/*头像*/
@property (strong, nonatomic) UIImageView *mHeadImageView;
/*昵称*/
@property (strong, nonatomic) UILabel *mLbNickName;
/*订阅科室标签*/
@property (strong, nonatomic) UILabel *mLbSubscription;
/*标识*/
//@property (copy, nonatomic) UIImageView *mIdentifyImageView;

@property (strong, nonatomic) UILabel *mLbLayout;
///警告框
@property (strong, nonatomic) UIActionSheet *pActionSheetView;

//- (void)popViewController;

- (void)setNickName:(NSString *)nickName;

@end
