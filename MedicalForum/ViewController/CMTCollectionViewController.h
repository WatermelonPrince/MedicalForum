//
//  CMTCollectionViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/27.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "UIPopoverListView.h"
#import "CMTCollectionDelegate.h"
@class CMTShareView;

@interface CMTCollectionViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate,UIPopoverListViewDataSource, UIPopoverListViewDelegate,CMTCollectionDelegate>

@property (strong, nonatomic) UITableView *mCollectTableView;
/*收藏的信息*/
@property (strong, nonatomic) NSMutableArray *mArrCollections;

@property (strong, nonatomic) NSMutableArray *mArrShowConllections;

@property (strong, nonatomic) NSMutableArray *mArrVideos;

@property (assign) BOOL isLeftEnter;

/*无收藏展示视图*/

@property (strong, nonatomic) UIImageView *mNoCollectionImageView;
@property (strong, nonatomic) UILabel *mLbNoCollection;
@property (strong, nonatomic) CMTStore *mShareStore;


@end
