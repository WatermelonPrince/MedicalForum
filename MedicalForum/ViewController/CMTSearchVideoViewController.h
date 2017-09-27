//
//  CMTSearchVideoViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/10/31.
//  Copyright © 2016年 CMT. All rights reserved.
////搜索录播页面

#import "CMTBaseViewController.h"
#import "CMTSearchColledgeDataViewController.h"

@interface CMTSearchVideoViewController : CMTBaseViewController
@property (nonatomic, strong)CMTSearchColledgeDataViewController *parentVC;
@property (nonatomic, strong)NSMutableArray *videoArr;//录像数组

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSString *keyWord;//搜索关键字


@end
