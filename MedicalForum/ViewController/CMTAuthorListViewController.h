//
//  CMTAuthorListViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 15/4/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTSubject.h"

@interface CMTAuthorListViewController : CMTBaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) CMTSubject *mSubject;

@property (strong, nonatomic) NSMutableArray *mArrAuthors;

@property (strong, nonatomic) UITableView *mTableViewAuthor;

//请求的page
@property (assign) NSInteger requestPage;

@property (assign) BOOL needRequest;

@end
