//
//  CMTSubjectPostsViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 15/4/7.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTButton.h"
#import "CMTSubject.h"

static NSString * const CMTPostListSectionPostDateKey = @"PostDate";
static NSString * const CMTPostListSectionPostArrayKey = @"PostArray";

@interface CMTSubjectPostsViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UITableView *mTableViewPostsInSubject;
///筛选排序前所有的数据
@property (strong, nonatomic) NSMutableArray *mArrPosts;
///筛选排序后所有的数据
@property (strong, nonatomic) NSMutableArray *mArrPostsSorted;
///存储每次请求的数据,判断是否跟上次一样，来决定是否放到新的容器中
@property (strong, nonatomic) NSMutableArray *mArrTempPosts;
///已订阅学科
@property (strong, nonatomic) NSMutableArray *mArrSubscription;
///所有学科
@property (strong, nonatomic) NSMutableArray *mArrTotleSubs;
///排序后的所有
@property (strong, nonatomic) NSMutableArray *mArrSorted;
///
@property (strong, nonatomic) NSString *strTotleListCachePath;
@property (strong, nonatomic) NSString *strSubListCachePath;
@property (strong, nonatomic) NSString *strSortedArrCachePath;

@property (strong, nonatomic) UIAlertView *mAlertView;
//
@property (assign) NSInteger row;
//请求的page
@property (assign) NSInteger requestPage;
//上级界面的按钮
@property (strong, nonatomic) CMTButton *mBtnSubListBtn;
//传递过来的subject(学科名,学科id)
@property (strong, nonatomic) CMTSubject *mSubject;
//翻页自增id
@property (copy) NSString *incrId;
/// 控制从上级界面进入当前也请求最新，下级返回，不请求
@property (assign) BOOL requestNewLeast;
@property(nonatomic,strong)UILabel *tipsLable;


///订阅与取消订阅
- (void)addSubcrition:(CMTButton *)btn;
///已经订阅的按钮状态
- (void)subcritonState:(CMTButton *)btn;
///未订阅的按钮状态
- (void)noSubcritionState:(CMTButton *)btn;

// 刷新首页文章统计
@property (nonatomic, copy) void (^refreshList)();

@end
