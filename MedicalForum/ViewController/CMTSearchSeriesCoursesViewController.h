//
//  CMTSearchSeriesCoursesViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/10/31.
//  Copyright © 2016年 CMT. All rights reserved.
//搜索系列课程页面


#import "CMTBaseViewController.h"
#import "CMTSearchColledgeDataViewController.h"

@interface CMTSearchSeriesCoursesViewController : CMTBaseViewController
@property (nonatomic, strong)CMTSearchColledgeDataViewController *parentVC;
@property (nonatomic, strong)NSMutableArray *seriesArr;//系列课程

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSString *keyWord;//搜索关键字






@end
