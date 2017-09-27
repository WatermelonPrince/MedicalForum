//
//  CMTSearchLiveViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/10/31.
//  Copyright © 2016年 CMT. All rights reserved.
//
//搜索直播页面
#import "CMTBaseViewController.h"
#import "CMTSearchColledgeDataViewController.h"

@interface CMTSearchLiveViewController : CMTBaseViewController
@property (nonatomic, strong)CMTSearchColledgeDataViewController *parentVC;
@property (nonatomic, strong)NSMutableArray *liveArr;//直播搜索数据

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSString *currentDate;
@property (nonatomic, strong)NSString *keyWord;//搜索关键字






@end
