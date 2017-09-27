//
//  CMTCityViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTCityViewController.h"
#import "CMTHospitalViewController.h"
#import "CMTAddHosptialViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTSettingViewController.h"

#define ROWHEIGHT 50

@interface CMTCityViewController ()

@property (strong, nonatomic) CMTHospitalViewController *mHosptialVC;
@property (strong, nonatomic) CMTAddHosptialViewController *mAddHosVC;
@property (strong, nonatomic) CMTUpgradeViewController *mUpgradeVC;

@end


@implementation CMTCityViewController

#pragma mark  生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.mCityTableView setContentOffset:CGPointZero animated:NO];
    [self.mAllHosptils removeAllObjects];
    self.mTfSearch.text = @"";
    self.isSearch = NO;
    self.mTfSearch.placeholder = [NSString stringWithFormat:@"在%@范围内搜索",self.mProvince.provName];
    self.mCityTableView.hidden = YES;
    [self runAnimationInPosition:self.view.center];
    self.mArrCities = [self.mProvince.cities mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopAnimation];
        self.mCityTableView.hidden = NO;
        [self.mCityTableView reloadData];
    });
    if ([self respondsToSelector:@selector(getProHosptialsData:)])
    {
        [self performSelectorInBackground:@selector(getProHosptialsData:) withObject:nil];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.titleText = @"城市列表";
    //添加搜索相关视图
    [self.view addSubview:self.mBaseView];
    [self.view addSubview:self.mSearchImageView];
    [self.view addSubview:self.mTfSearch];
    [self.view addSubview:self.self.mSearchBtn];
    [self.view addSubview:self.mCityTableView];
    [self initViewControllers];
    //RAC方法实现搜索
    @weakify(self);
    [self.mTfSearch.rac_textSignal subscribeNext:^(NSString * searchText) {
        @strongify(self);
      
        if (![searchText isEqualToString:self.mStrText])
        {
            [self.mCityTableView setContentOffset:CGPointZero animated:NO];
            if (searchText.length > 0)
            {
                self.isSearch = YES;
                [self.mArrSearchResult removeAllObjects];
                for (CMTDetailHosptial *hos in self.mAllHosptils)
                {
                    //CMTLog(@"hosptialName:%@",hos.hosptialName);
                    NSRange range = [hos.hosptialName rangeOfString:self.mTfSearch.text];
                    if (range.length > 0)
                    {
                        [self.mArrSearchResult addObject:hos];
                        //CMTLog(@"包含医院的名字:%@,医院ID:%@",hos.hosptialName,hos.hosptialId);
                    }
                }
                CMTLog(@"一共查找到%lu家医院",(unsigned long)self.mArrSearchResult.count);
            }
            else
            {
                self.isSearch = NO;
                [self.mArrSearchResult removeAllObjects];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mCityTableView reloadData];
            });
            
        }
        self.mStrText = searchText;
        
    }];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
#pragma mark 后台运行获取搜索数据源方法
- (void)getProHosptialsData:(id)sender
{
    [self.mAllHosptils removeAllObjects];
    NSString *hosptial_list = [PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"hosptial_list"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:hosptial_list])
    {
        NSMutableArray *arrHosptial = [NSKeyedUnarchiver unarchiveObjectWithFile:hosptial_list];
        for (CMTDetailHosptial *detailHos in arrHosptial)
        {
            if ([detailHos.provName isEqualToString:self.mProvince.provName])
            {
                [self.mAllHosptils addObject:detailHos];
            }
        }
    }
    
}

- (void)initViewControllers
{
    self.mHosptialVC = [[CMTHospitalViewController alloc]init];
    self.mAddHosVC = [[CMTAddHosptialViewController alloc]init];
}
#pragma mark  属性列表
- (CMTProvince *)mProvince
{
    if (!_mProvince)
    {
        _mProvince = [[CMTProvince alloc]init];
    }
    return _mProvince;
}

- (NSMutableArray *)mArrCities
{
    if (!_mArrCities)
    {
        _mArrCities = [NSMutableArray array];
    }
    return _mArrCities;
}

- (UITableView *)mCityTableView
{
    if (!_mCityTableView)
    {
        _mCityTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+44, SCREEN_WIDTH, SCREEN_HEIGHT-64-44) style:UITableViewStylePlain];
        _mCityTableView.delegate = self;
        _mCityTableView.dataSource = self;
        
    }
    return _mCityTableView;
}

//搜索

- (UIView *)mBaseView
{
    if (!_mBaseView)
    {
        _mBaseView = [[UIView alloc]initWithFrame:CGRectMake(-1, 64,SCREEN_WIDTH+2, 44)];
        _mBaseView.backgroundColor = COLOR(c_f5f5f5);
        _mBaseView.layer.borderWidth = 0.3;
        _mBaseView.layer.borderColor = [UIColor colorWithRed:181.0/255 green:181.0/255 blue:181.0/255 alpha:1.0].CGColor;
    }
    return _mBaseView;
}
- (UIImageView *)mSearchImageView
{
    if (!_mSearchImageView)
    {
        _mSearchImageView = [[UIImageView alloc]initWithImage:IMAGE(@"search_imput")];
        _mSearchImageView.frame = CGRectMake(10, 26+44, 518/2*RATIO, 30);
        [_mSearchImageView addSubview:self.mTfLeftView];
    }
    return _mSearchImageView;
}

- (UIImageView *)mTfLeftView
{
    if (!_mTfLeftView)
    {
        _mTfLeftView = [[UIImageView alloc]initWithImage:IMAGE(@"search_leftItem")];
        //_mTfLeftView.backgroundColor = [UIColor greenColor];
        [_mTfLeftView setFrame:CGRectMake(10*RATIO, 8, 18, 18)];
    }
    return _mTfLeftView;
}
- (UITextField *)mTfSearch
{
    if (!_mTfSearch)
    {
        _mTfSearch = [[UITextField alloc]initWithFrame:CGRectMake(44, 27+44, 228*RATIO, 30)];
        _mTfSearch.clearButtonMode = UITextFieldViewModeAlways;
        _mTfSearch.clearsOnBeginEditing = NO;
        _mTfSearch.returnKeyType = UIReturnKeySearch;
        _mTfSearch.delegate = self;
    }
    return _mTfSearch;
}

- (UIButton *)mSearchBtn
{
    if (!_mSearchBtn)
    {
        _mSearchBtn  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //pBtn.titleLabel.textColor = [UIColor blackColor];//COLOR(c_32c7c2);
        [_mSearchBtn setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        [_mSearchBtn setTitle:@"搜索" forState:UIControlStateNormal];
        //[_mCancelBtn setFrame:CGRectMake(275*RATIO, 27, 38*RATIO, 28)];
        [_mSearchBtn setFrame:CGRectMake(275*RATIO, 20+44, SCREEN_WIDTH-275*RATIO, 44)];
        [_mSearchBtn addTarget:self action:@selector(searchMethod:) forControlEvents:UIControlEventTouchUpInside];
        _mSearchBtn.tag = 100;
    }
    return _mSearchBtn;
}
- (NSMutableArray *)mAllHosptils
{
    if (!_mAllHosptils)
    {
        _mAllHosptils = [NSMutableArray array];
    }
    return _mAllHosptils;
}
- (NSMutableArray *)mArrSearchResult
{
    if (!_mArrSearchResult)
    {
        _mArrSearchResult = [NSMutableArray array];
    }
    return _mArrSearchResult;
}

#pragma mark  搜索方法
- (void)searchMethod:(id)sender
{
    CMTLog(@"%s",__func__);
    [self.view endEditing:YES];
}

#pragma mark  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROWHEIGHT;
}
CMTDetailHosptial *detailHos;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearch == NO)
    {
        CMTLog(@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row);
        @weakify(self);
        self.mHosptialVC.updateHostpital=^(CMTHospital *hospital){
            @strongify(self);
            if(self.updateHostpital!=nil){
                self.updateHostpital(hospital);
            }
        };

        CMTCity *city = [self.mArrCities objectAtIndex:indexPath.row];
        self.mHosptialVC.mCity = city;
        
        [self.navigationController pushViewController:self.mHosptialVC animated:YES];
    }
    else
    {
        if (indexPath.row == self.mArrSearchResult.count)
        {
            CMTLog(@"跳转到添加医院界面");
            @weakify(self);
            self.mAddHosVC.updateHostpital=^(CMTHospital *hospital){
                @strongify(self);
                if(self.updateHostpital!=nil){
                    self.updateHostpital(hospital);
                }
            };

            [self.navigationController pushViewController:self.mAddHosVC animated:YES];
        }
        else
        {
          
            CMTLog(@"选中医院,跳转到认证确认界面");
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            CMTLog(@"选中医院,跳转到认证确认界面");
            CMTLog(@"indexPath.row:%ld",(long)indexPath.row);
            CMTLog(@"hosptialName:%@:::::hosptialId:%@",cell.textLabel.text,cell.detailTextLabel.text);
            detailHos = [self.mArrSearchResult objectAtIndex:indexPath.row];
            CMTLog(@"detailHos.hosptial:%@,detailHos.hosptialId:%@",detailHos.hosptialName,detailHos.hosptialId);
            if(self.mUpgradeVC==nil){
                 @weakify(self);
                if(self.updateHostpital!=nil){
                    @strongify(self);
                    CMTHospital *hostpital=[[CMTHospital alloc]init];
                    hostpital.hospitalId=detailHos.hosptialId;
                    hostpital.hospital=detailHos.hosptialName;
                    self.updateHostpital(hostpital);
                }
                NSArray *pArr = self.navigationController.childViewControllers;
                for (int i = 0; i < pArr.count; i++){
                    UIViewController *pVC = [pArr objectAtIndex:i];
                    if ([pVC isKindOfClass:[CMTSettingViewController class]]){
                        [self.navigationController popToViewController:pVC animated:YES];
                        
                    }
                }

            }else{
                    NSArray *viewContrlllers = [self.navigationController childViewControllers];
                    for (int i = 0; i < viewContrlllers.count; i++)
                    {
                        UIViewController *pVC =[viewContrlllers objectAtIndex:i];
                        if ([pVC isKindOfClass:[CMTUpgradeViewController class]])
                        {
                            self.mUpgradeVC = (CMTUpgradeViewController *)pVC;
                            self.mUpgradeVC.mStrHospital = detailHos.hosptialName;
                            self.mUpgradeVC.mHosptioal.hospital = detailHos.hosptialName;
                            self.mUpgradeVC.mHosptioal.hospitalId = detailHos.hosptialId;
                            break;
                        }
                    }
                    [self.navigationController popToViewController:self.mUpgradeVC animated:YES];
                  }
          }
    }
   
}

#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearch == NO)
    {
        return self.mArrCities.count;
    }
    else
    {
        return self.mArrSearchResult.count + 1;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (!pCell)
    {
        pCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifer];
        pCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.isSearch == NO)
    {
        pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        @try {
            CMTCity *city = [self.mArrCities objectAtIndex:indexPath.row];
            pCell.textLabel.text = city.cityName;
            pCell.textLabel.textColor = [UIColor blackColor];
            pCell.detailTextLabel.text = @"";
        }
        @catch (NSException *exception) {
            CMTLog(@"city error");
        }
    }
    else
    {
        pCell.accessoryType = UITableViewCellAccessoryNone;
        @try {
            
            if (indexPath.row == self.mArrSearchResult.count)
            {
                pCell.textLabel.text = @"+添加我的医院";
                pCell.textLabel.textColor = COLOR(c_4766a8);
                pCell.detailTextLabel.text = @"";
            }
            else
            {
                CMTDetailHosptial *pDetailHosptial;
                if (self.mArrSearchResult.count >= 1)
                {
                    pDetailHosptial = [self.mArrSearchResult objectAtIndex:indexPath.row];
                    pCell.textLabel.text = pDetailHosptial.hosptialName;
                    pCell.textLabel.textColor = [UIColor blackColor];
                    pCell.detailTextLabel.text = [NSString stringWithFormat:@"%@    %@",pDetailHosptial.provName,pDetailHosptial.cityName];
                }
                else
                {
                    CMTLog(@"数组长度为0");
                }
            }
        }
        @catch (NSException *exception) {
            CMTLog(@"没有元素");
        }
    }
   
    return pCell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return PIXEL;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *pView = [[UIView alloc]init];
    pView.frame = CGRectMake(0, 0, SCREEN_WIDTH, PIXEL);
    pView.backgroundColor = COLOR(c_ababab);
    return pView;
}
#pragma mark  UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    if (toBeString.length > 0)
//    {
//        self.isSearch = YES;
//        [self.mArrSearchResult removeAllObjects];
//        for (CMTDetailHosptial *hos in self.mAllHosptils)
//        {
//            //CMTLog(@"hosptialName:%@",hos.hosptialName);
//            if ([hos.hosptialName containsString:toBeString])
//            {
//                [self.mArrSearchResult addObject:hos];
//               // CMTLog(@"包含医院的名字:%@,医院ID:%@",hos.hosptialName,hos.hosptialId);
//            }
//        }
//    }
//    else
//    {
//        [self.mArrSearchResult removeAllObjects];
//        self.isSearch = NO;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.mCityTableView reloadData];
//    });
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.mCityTableView setContentOffset:CGPointZero animated:NO];
    [self.mArrSearchResult removeAllObjects];
    self.isSearch = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mCityTableView reloadData];
        [textField resignFirstResponder];
    });
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
}
#pragma mark  滑动列表 弹回键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.mTfSearch.isFirstResponder)
    {
        [self.mTfSearch resignFirstResponder];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
