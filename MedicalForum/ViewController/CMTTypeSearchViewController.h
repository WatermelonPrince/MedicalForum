//
//  CMTTypeSearchViewController.h
//  MedicalForum
//  点击类型跳入的搜索类
//  Created by Bo Shen on 15/1/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTTypeSearchViewController : CMTBaseViewController

@property (strong, nonatomic) NSDictionary *mDic;
@property (strong, nonatomic) NSString *placeHold;

@property (assign) BOOL needRequest;

@end
