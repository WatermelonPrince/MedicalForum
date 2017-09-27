//
//  CMTEnterSubjectionViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 15/4/14.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

static NSString *const identifer = @"CMTSubjectListCell";

@interface CMTEnterSubjectionViewController : CMTBaseViewController <UITableViewDelegate, UITableViewDataSource>

/// 控制但从上个界面进入的时候请求一次
@property (assign)BOOL needRequest;

/// 列表
@property (strong, nonatomic) UITableView *mTableView;

/// 返回数据
@property (strong, nonatomic) NSMutableArray *mArrSubjects;

@property (strong, nonatomic) NSMutableArray *mArrShowSubjects;

@property (assign) BOOL isLeftEnter;

/// 下级界面取消订阅(通过indexPath) 从本列表中移除对应数据
@property (strong, nonatomic) NSIndexPath *mIndexPath;

/*无专题展示*/
@property (strong, nonatomic) UIImageView *mNoCollectionImageView;
@property (strong, nonatomic) UILabel *mLbNoCollection;

/// 获取已订阅专题列表数据
- (void)getSubjectList:(NSDictionary *)dic;

@end
