//
//  CMTHospitalViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


#import "CMTHospitalViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTAddHosptialViewController.h"
#import "CMTSettingViewController.h"
#define ROWHEIGHT 50

@interface CMTHospitalViewController ()

@property (strong, nonatomic) CMTUpgradeViewController *mUpgradeVC;
@property (strong, nonatomic) NSString *mCachePathHosptial;
@property (strong, nonatomic) CMTHospital *mHosptial;
//添加医院的控制器
@property (strong, nonatomic) CMTAddHosptialViewController *mAddVC;

@end

@implementation CMTHospitalViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.mHosTableView setContentOffset:CGPointZero animated:NO];
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[CMTUpgradeViewController class]])
        {
            self.mUpgradeVC = (CMTUpgradeViewController *)vc;
            break;
        }
    }
    self.mHosTableView.hidden = YES;

    
    [self requestHosptials];
    [self.mAllHosptialCity removeAllObjects];
    self.mTfSearch.text = @"";
    _mTfSearch.placeholder = [NSString stringWithFormat:@"在%@范围内搜索",self.mCity.cityName];;
    self.isSearch = NO;
    if ([self respondsToSelector:@selector(getProHosptialsData:)])
    {
        [self performSelectorInBackground:@selector(getProHosptialsData:) withObject:nil];
    }
    
    //表格回到最顶端
     [self.mHosTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
}
//网络请求获取城市列表
- (void)requestHosptials
{
    self.mReloadBaseView.hidden = YES;
    [self runAnimationInPosition:self.view.center];
    if ([[NSFileManager defaultManager]fileExistsAtPath:self.mCachePathHosptial])
    {
        self.mArrHospitals = [NSKeyedUnarchiver unarchiveObjectWithFile:self.mCachePathHosptial];
        [self stopAnimation];
        self.mHosTableView.hidden = NO;
    }
    else
    {
        NSDictionary *pDic = @{@"cityCode":self.mCity.cityCode};
        @weakify(self);
        [self.rac_deallocDisposable addDisposable:[[CMTCLIENT getHospital:pDic]subscribeNext:^(NSArray * array) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            self.mArrHospitals = [array mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mHosTableView.hidden = NO;
                self.mReloadBaseView.hidden = YES;
                [self.mHosTableView reloadData];
            });
            
        } error:^(NSError *error) {
            CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mHosTableView.hidden = YES;
                self.mReloadBaseView.hidden = NO;
            });
        } completed:^{
            CMTLog(@"完成");
        }]];
        /*待缓存*/
    }

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self requestHosptials];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleText = @"医院列表";
    //添加搜索相关视图
    [self.view addSubview:self.mBaseView];
    [self.view addSubview:self.mSearchImageView];
    [self.view addSubview:self.mTfSearch];
    [self.view addSubview:self.self.mSearchBtn];
    [self.view addSubview:self.mHosTableView];
    
    
    @weakify(self);
    [self.mTfSearch.rac_textSignal subscribeNext:^(NSString * searchText) {
        @strongify(self);
        
        if (![searchText isEqualToString:self.mStrText])
        {
            [self.mHosTableView setContentOffset:CGPointZero animated:NO];
            if (searchText.length > 0)
            {
                self.isSearch = YES;
                [self.mArrSearchResult removeAllObjects];
                for (CMTDetailHosptial *hos in self.mAllHosptialCity)
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
                [self.mHosTableView reloadData];
            });
            
        }
        self.mStrText = searchText;
        
    }];
}

#pragma mark 后台运行获取搜索数据源方法
- (void)getProHosptialsData:(id)sender
{
    [self.mAllHosptialCity removeAllObjects];
    NSString *hosptial_list = [PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"hosptial_list"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:hosptial_list])
    {
        NSMutableArray *arrHosptial = [NSKeyedUnarchiver unarchiveObjectWithFile:hosptial_list];
        for (CMTDetailHosptial *detailHos in arrHosptial)
        {
            if ([detailHos.cityCode isEqualToString:self.mCity.cityCode])
            {
                [self.mAllHosptialCity addObject:detailHos];
            }
        }
    }
    
}


- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (CMTCity *)mCity
{
    if (!_mCity)
    {
        _mCity = [[CMTCity alloc]init];
    }
    return _mCity;
}
- (NSString *)mCachePathHosptial
{
    NSString *path = [PATH_USERS stringByAppendingPathComponent:self.mCity.cityCode];
    return path;
}

- (NSMutableArray *)mArrHospitals
{
    if (!_mArrHospitals)
    {
        _mArrHospitals = [NSMutableArray array];
    }
    return _mArrHospitals;
}
- (UILabel *)mLbHosptical
{
    if (!_mLbHosptical)
    {
        _mLbHosptical = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200*RATIO, 30)];
        _mLbHosptical.textColor = [UIColor colorWithRed:130.0/255 green:130.0/255 blue:130.0/255 alpha:1.0];
        _mLbHosptical.textAlignment = NSTextAlignmentRight;
    }
    return _mLbHosptical;
}
- (UITableView *)mHosTableView
{
    if (!_mHosTableView)
    {
        _mHosTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+44, SCREEN_WIDTH, SCREEN_HEIGHT-64-44) style:UITableViewStylePlain];
        _mHosTableView.delegate = self;
        _mHosTableView.dataSource = self;
        
    }
    return _mHosTableView;
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

- (CMTAddHosptialViewController *)mAddVC
{
    if (!_mAddVC)
    {
        _mAddVC = [[CMTAddHosptialViewController alloc]initWithNibName:nil bundle:nil];
    }
    return _mAddVC;
}

- (NSMutableArray *)mAllHosptialCity
{
    if (!_mAllHosptialCity)
    {
        _mAllHosptialCity = [NSMutableArray array];
    }
    return _mAllHosptialCity;
}

- (NSMutableArray *)mArrSearchResult
{
    if (!_mArrSearchResult) {
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
    CMTLog(@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row);
    
    if (self.isSearch == NO)
    {
        @try {
            
           
            if (self.mArrHospitals.count == indexPath.row)
            {
                @weakify(self);
                self.mAddVC.updateHostpital=^(CMTHospital *hostpital){
                    @strongify(self);
                    if (self.updateHostpital!=nil) {
                        self.updateHostpital(hostpital);
                    }
                };
                [self.navigationController pushViewController:self.mAddVC animated:YES];
            }
            else
            {
                UITableViewCell *pCell = [tableView cellForRowAtIndexPath:indexPath];
                NSString *pHospital = pCell.textLabel.text;
                self.mLbHosptical.text = pHospital;
                
                CMTHospital *hosptial = [self.mArrHospitals objectAtIndex:indexPath.row];
                if(self.mUpgradeVC==nil){
                    @weakify(self);
                    if(self.updateHostpital!=nil){
                        @strongify(self);
                        self.updateHostpital(hosptial);
                    }
                    NSArray *pArr = self.navigationController.childViewControllers;
                    for (int i = 0; i < pArr.count; i++){
                        UIViewController *pVC = [pArr objectAtIndex:i];
                        if ([pVC isKindOfClass:[CMTSettingViewController class]]){
                            [self.navigationController popToViewController:pVC animated:YES];
                            
                        }
                    }
                    
                }else{
                    self.mUpgradeVC.mHosptioal = hosptial;
                    self.mUpgradeVC.mLbHospital = self.mLbHosptical;
                    self.mUpgradeVC.mStrHospital = hosptial.hospital;
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    UITableViewCell *pRefreshCell = [self.mUpgradeVC.mTableView cellForRowAtIndexPath:newIndexPath];
                    pRefreshCell.accessoryView = self.mLbHosptical;
                     [self.navigationController popToViewController:self.mUpgradeVC animated:YES];
                }
            }
            
        }
        @catch (NSException *exception) {
            CMTLog(@"hosptial error");
        }
    }
    else
    {
        if (indexPath.row == self.mArrSearchResult.count)
        {
            CMTLog(@"跳转到添加医院视图");
            [self.navigationController pushViewController:self.mAddVC animated:YES];
        }
        else
        {
            CMTLog(@"选中医院,跳转到认证确认界面");
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
            }
        }

    }
    
    
}

#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearch == NO)
    {
        return self.mArrHospitals.count+1;
    }
    else
    {
        return self.mArrSearchResult.count+1;
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
        @try {
            if (indexPath.row == self.mArrHospitals.count)
            {
                pCell.textLabel.text = @"+添加我的医院";
                pCell.textLabel.textColor = COLOR(c_4766a8);
                pCell.detailTextLabel.text = @"";
            }
            else
            {
                CMTHospital *hosptial = [self.mArrHospitals objectAtIndex:indexPath.row];
                
                pCell.textLabel.text = hosptial.hospital;
                pCell.textLabel.textColor = [UIColor blackColor];
                pCell.detailTextLabel.text = @"";
            }
        }
        @catch (NSException *exception) {
            CMTLog(@"no hosptials");
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
    //界面跳转，跳转到新界面进行搜索，新界面还未做
    //self.isSearch = YES;
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    if (toBeString.length > 0)
//    {
//        self.isSearch = YES;
//        [self.mArrSearchResult removeAllObjects];
//        for (CMTDetailHosptial *hos in self.mAllHosptialCity)
//        {
//            //CMTLog(@"hosptialName:%@",hos.hosptialName);
//            if ([hos.hosptialName containsString:toBeString])
//            {
//                [self.mArrSearchResult addObject:hos];
//                // CMTLog(@"包含医院的名字:%@,医院ID:%@",hos.hosptialName,hos.hosptialId);
//            }
//        }
//    }
//    else
//    {
//        [self.mArrSearchResult removeAllObjects];
//        self.isSearch = NO;
//       
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.mHosTableView reloadData];
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
     [self.mHosTableView setContentOffset:CGPointZero animated:NO];
    [self.mArrSearchResult removeAllObjects];
    self.isSearch = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mHosTableView reloadData];
        [textField resignFirstResponder];
    });

    return YES;
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
