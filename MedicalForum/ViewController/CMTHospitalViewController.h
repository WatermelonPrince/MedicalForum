//
//  CMTHospitalViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
@interface CMTHospitalViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *mArrHospitals;
@property (strong, nonatomic) UITableView *mHosTableView;
@property (strong, nonatomic) UILabel *mLbHosptical;
@property (strong, nonatomic) CMTCity *mCity;

//搜索
@property (strong, nonatomic) UIView *mBaseView;
@property (strong, nonatomic) UIImageView *mSearchImageView;
/*搜索文本框*/
@property (strong, nonatomic) UITextField *mTfSearch;
/*搜索框左侧图片*/
@property (strong, nonatomic) UIImageView *mTfLeftView;
/*搜索栏右侧按钮*/
@property (strong, nonatomic) UIButton *mSearchBtn;

//记录搜索的状态
@property (assign) BOOL isSearch;
//存储搜索结果的数据集合
@property (strong, nonatomic) NSMutableArray *mArrSearchResult;
//存储指定城市内的医院
@property (strong, nonatomic) NSMutableArray *mAllHosptialCity;
//医院搜索条件
@property (strong, nonatomic) NSString *mStrText;
@property(strong,nonatomic)void(^updateHostpital)(CMTHospital *Hospital);
///右侧搜索按钮关联方法
- (void)searchMethod:(id)sender;


@end
