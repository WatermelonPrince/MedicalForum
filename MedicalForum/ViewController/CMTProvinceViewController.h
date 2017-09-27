//
//  CMTProvinceViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTProvinceViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) UITableView *mProvTableView;
@property (strong, nonatomic) NSMutableArray *mArrProvinces;
@property (strong, nonatomic) NSMutableDictionary *mMubDic;

//搜索
@property (strong, nonatomic) UIView *mBaseView;
@property (strong, nonatomic) UIImageView *mSearchImageView;
/*搜索文本框*/
@property (strong, nonatomic) UITextField *mTfSearch;
/*搜索框左侧图片*/
@property (strong, nonatomic) UIImageView *mTfLeftView;
/*搜索栏右侧按钮*/
@property (strong, nonatomic) UIButton *mSearchBtn;
//记录搜索关键字
@property (strong, nonatomic) NSString *mStrText;


//记录搜索的状态
@property (assign) BOOL isSearch;
//存储搜索结果的数据集合
@property (strong, nonatomic) NSMutableArray *mArrSearchResult;
//存储所有医院(数组存储对象)
@property (strong, nonatomic) NSMutableArray *mArrHosptials;

//存储所有医院数据的字典
@property (strong, nonatomic) NSMutableDictionary *mDicAllHosptials;
@property(strong,nonatomic)void(^updateHostpital)(CMTHospital *Hospital);

///右侧搜索按钮关联方法
- (void)searchMethod:(id)sender;

@end
