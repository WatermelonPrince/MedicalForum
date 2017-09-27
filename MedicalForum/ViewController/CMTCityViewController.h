//
//  CMTCityViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTCityViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) UITableView *mCityTableView;
@property (strong, nonatomic) NSMutableArray *mArrCities;
@property (strong, nonatomic) CMTProvince *mProvince;

//搜索
@property (strong, nonatomic) UIView *mBaseView;
@property (strong, nonatomic) UIImageView *mSearchImageView;
/*搜索文本框*/
@property (strong, nonatomic) UITextField *mTfSearch;
/*搜索框左侧图片*/
@property (strong, nonatomic) UIImageView *mTfLeftView;
/*搜索栏右侧按钮*/
@property (strong, nonatomic) UIButton *mSearchBtn;
//存数对应省份是所有医院
@property (strong, nonatomic) NSMutableArray *mAllHosptils;
//记录搜索关键字
@property (strong, nonatomic) NSString *mStrText;


//记录搜索的状态
@property (assign) BOOL isSearch;
//存储搜索结果的数据集合
@property (strong, nonatomic) NSMutableArray *mArrSearchResult;
@property(strong,nonatomic)void(^updateHostpital)(CMTHospital *Hospital);
///右侧搜索按钮关联方法
- (void)searchMethod:(id)sender;


@end
