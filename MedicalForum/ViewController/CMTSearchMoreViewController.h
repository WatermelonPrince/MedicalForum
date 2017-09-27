//
//  CMTSearchMoreViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 15/1/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTSearchMoreViewController : CMTBaseViewController

@property (strong, nonatomic) NSDictionary *mDic;
@property (strong, nonatomic) NSString *placeHold;
//记录是否需要再次请求
@property (assign) BOOL needRequest;

@end
