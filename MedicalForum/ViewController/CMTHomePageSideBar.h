//
//  CMTHomePageSideBar.h
//  MedicalForum
//
//  Created by fenglei on 15/5/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSideBar.h"
#import "CMTButton.h"
@class CMTSubcritionListCell;
#import "CMTSubject.h"

//刷新代理
@protocol CMTHomePageSideBarDelegte <NSObject>
- (void)refreshListdata;

@end
@interface CMTHomePageSideBar : CMTSideBar

///表格
@property (strong, nonatomic) UITableView *mSubscriptionTableView;
///可变字典,存储按钮
@property (strong, nonatomic) NSMutableDictionary *mBtnDic;
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
///传递到下个界面的订阅学科对象
@property (strong, nonatomic) CMTSubject *subject;

@property (assign) BOOL needRequest;
///用来控制行数
@property (assign) BOOL isLeftEnter;
///用来控制是否显示footer
@property (assign) BOOL isFootShow;

@property (strong, nonatomic) UIButton *mBtnLogin;
//排序后的数据集合做为数据源
@property (strong, nonatomic) NSMutableArray *mArrSortedTot;
///1.8.2
@property (assign) BOOL isShow;                             ///记录是否展示未订阅栏信息
@property (assign) BOOL isNextLeftVC;
@property(nonatomic,weak)id<CMTHomePageSideBarDelegte>delegete;

//初始化侧边栏
-(instancetype)initWithModel:(NSString *)model;

/// 通过缓存数据刷新列表
-(void)refreshFormCache;

///已订阅状态
- (void)subcrition:(UIButton *)btn;

///未订阅状态
- (void)noSubcition:(UIButton *)btn;

///订阅、取消订阅关联方法
- (void)addSubcrition:(CMTButton *)btn;

///根据已订阅选项,去重，排序
- (void)subcritonSort:(id)sender;
@end

