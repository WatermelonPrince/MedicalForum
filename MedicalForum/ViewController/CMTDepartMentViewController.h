//
//  CMTDepartMentViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
@interface CMTDepartMentViewController : CMTBaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *mArrDepartments;
@property (strong, nonatomic) UITableView *mDepartTableView;
@property(nonatomic,copy)void(^updateDepart)(CMTSubDepart *depart);
@end
