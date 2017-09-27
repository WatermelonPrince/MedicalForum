//
//  CMTSubDepartmentViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
@interface CMTSubDepartmentViewController : CMTBaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *mArrSubDepartments;
@property (strong, nonatomic) UITableView *mSubDepartTableView;
@property (strong, nonatomic) UILabel *mLbSubDepart;
@property (strong, nonatomic) CMTDepart *mDepart;
@property(nonatomic,copy)void(^updateDepart)(CMTSubDepart *depart);


@end
