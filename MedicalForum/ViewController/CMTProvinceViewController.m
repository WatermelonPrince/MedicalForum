//
//  CMTProvinceViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//



#import "CMTProvinceViewController.h"
#import "CMTCityViewController.h"
#import "CMTAddHosptialViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTSettingViewController.h"

#define ROWHEIGHT 50

@interface CMTProvinceViewController ()

@property (strong, nonatomic) CMTCityViewController *mCityVC;
@property (strong, nonatomic) NSString *mProvincesCachePath;
@property (strong, nonatomic) CMTAddHosptialViewController *mAddHosVC;
@property (strong, nonatomic) CMTUpgradeViewController *mUpgradeVC;

@end

@implementation CMTProvinceViewController

#pragma mark  生命周期

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mProvTableView.hidden = YES;
    [self.mProvTableView setContentOffset:CGPointZero animated:YES];
    [self.mArrHosptials removeAllObjects];
    self.mTfSearch.text = @"";
    self.isSearch = NO;
    
    [self getAllProvinces:nil];
    if ([self respondsToSelector:@selector(getHosptialsData:)])
    {
        [self performSelectorInBackground:@selector(getHosptialsData:) withObject:nil];
    }
    
    //通过通知技术 完成数据查询
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(searchResult:) name: UITextFieldTextDidChangeNotification object:self.mTfSearch];
}
//第一版请求获取省事请求接口
- (void)getAllProvinces:(id)sender
{
    [self runAnimationInPosition:self.view.center];
    //第一版请求获取省事请求接口
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:self.mProvincesCachePath])
    {
        self.mArrProvinces = [NSKeyedUnarchiver unarchiveObjectWithFile:self.mProvincesCachePath];
       
        [self stopAnimation];
         self.mProvTableView.hidden = NO;
        [self.mProvTableView reloadData];
    }
    else
    {
        @weakify(self);
        [self.rac_deallocDisposable addDisposable:[[CMTCLIENT getCity]subscribeNext:^(NSArray * array) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            
            self.mArrProvinces = [array mutableCopy];
            BOOL isSucess = [NSKeyedArchiver archiveRootObject:self.mArrProvinces toFile:self.mProvincesCachePath];
            if (isSucess)
            {
                CMTLog(@"cache provinces sucess");
            }
            else
            {
                CMTLog(@"cache provines failed");
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mProvTableView.hidden = NO;
                self.mReloadBaseView.hidden = YES;
                [self.mProvTableView reloadData];
            });
        } error:^(NSError *error) {
            DEALLOC_HANDLE_SUCCESS
            CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mProvTableView.hidden = YES;
                self.mReloadBaseView.hidden = NO;
            });
        } completed:^{
            DEALLOC_HANDLE_SUCCESS
            CMTLog(@"完成");
        }]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.mReloadBaseView.hidden = YES;
    [self getAllProvinces:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleText = @"省份列表";
    //添加搜索相关视图
    [self.view addSubview:self.mBaseView];
    [self.view addSubview:self.mSearchImageView];
    [self.view addSubview:self.mTfSearch];
    [self.view addSubview:self.self.mSearchBtn];
    //添加表
    [self.view addSubview:self.mProvTableView];
    
    [self initViewControllers];
    
    
    
    @weakify(self);
    [self.mTfSearch.rac_textSignal subscribeNext:^(NSString * searchText) {
        @strongify(self);
        
        if (![searchText isEqualToString:self.mStrText])
        {
            [self.mProvTableView setContentOffset:CGPointZero animated:NO];
            if (searchText.length > 0)
            {
                self.isSearch = YES;
                [self.mArrSearchResult removeAllObjects];
                for (CMTDetailHosptial *hos in self.mArrHosptials)
                {
                    //CMTLog(@"hosptialName:%@",hos.hosptialName);
                    NSRange range = [hos.hosptialName rangeOfString:self.mTfSearch.text options:NSCaseInsensitiveSearch];
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
                [self.mProvTableView reloadData];
            });
            
        }
        self.mStrText = searchText;
        
    }];
   
    
}
- (void)getHosptialsData:(id)sender
{
    NSString *hosptial_list = [PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"hosptial_list"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:hosptial_list])
    {
        self.mArrHosptials = [NSKeyedUnarchiver unarchiveObjectWithFile:hosptial_list];
        
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)initViewControllers
{
    self.mCityVC = [[CMTCityViewController alloc]init];
    self.mAddHosVC = [[CMTAddHosptialViewController alloc]init];
}

- (NSString *)mProvincesCachePath
{
    CMTLog(@"%@",PATH_USERS);
    return [PATH_USERS stringByAppendingPathComponent:@"Provinces"];
}

- (NSMutableArray *)mArrProvinces
{
    if (!_mArrProvinces)
    {
        _mArrProvinces = [NSMutableArray array];
    }
    return _mArrProvinces;
}

- (NSMutableDictionary *)mMubDic
{
    if (!_mMubDic)
    {
        _mMubDic = [NSMutableDictionary dictionary];
    }
    return _mMubDic;
}

- (UITableView *)mProvTableView
{
    if (!_mProvTableView)
    {
        _mProvTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+44, SCREEN_WIDTH, SCREEN_HEIGHT-64-44) style:UITableViewStylePlain];
        _mProvTableView.delegate = self;
        _mProvTableView.dataSource = self;
        
    }
    return _mProvTableView;
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
        _mTfSearch.placeholder = @"在全国范围内搜索";
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

- (NSMutableArray *)mArrSearchResult
{
    if (!_mArrSearchResult)
    {
        _mArrSearchResult = [NSMutableArray array];
    }
    return _mArrSearchResult;
}
- (NSMutableArray *)mArrHosptials
{
    if (!_mArrHosptials)
    {
        _mArrHosptials = [NSMutableArray array];
    }
    return _mArrHosptials;
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
    return  ROWHEIGHT;
}

CMTDetailHosptial *detailHos;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row);
    if (self.isSearch == NO)
    {
        CMTProvince *province = [self.mArrProvinces objectAtIndex:indexPath.row];
        self.mCityVC.mProvince = province;
        @weakify(self);
        self.mCityVC.updateHostpital=^(CMTHospital *hospital){
            @strongify(self);
            if(self.updateHostpital!=nil){
                self.updateHostpital(hospital);
            }
        };
        [self.navigationController pushViewController:self.mCityVC animated:YES];
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
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            CMTLog(@"选中医院,跳转到认证确认界面");
            CMTLog(@"indexPath.row:%ld",(long)indexPath.row);
            CMTLog(@"hosptialName:%@:::::hosptialId:%@",cell.textLabel.text,cell.detailTextLabel.text);
            detailHos = [self.mArrSearchResult objectAtIndex:indexPath.row];
            CMTLog(@"detailHos.hosptial:%@,detailHos.hosptialId:%@",detailHos.hosptialName,detailHos.hosptialId);
            @weakify(self);
            if(self.updateHostpital!=nil){
                @strongify(self);
                CMTHospital *hostpital=[[CMTHospital alloc]init];
                hostpital.hospitalId=detailHos.hosptialId;
                hostpital.hospital=detailHos.hosptialName;
                self.updateHostpital(hostpital);
            }
            if(self.mUpgradeVC!=nil){
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
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    
}

#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearch == NO)
    {
        return self.mArrProvinces.count;
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
            CMTProvince *province = [self.mArrProvinces objectAtIndex:indexPath.row];
            pCell.textLabel.text = province.provName;
            pCell.textLabel.textColor = [UIColor blackColor];
            pCell.detailTextLabel.text = @"";
        }
        @catch (NSException *exception) {
            CMTLog(@"no provinces");
        }

    }
    else
    {
        pCell.accessoryType = UITableViewCellAccessoryNone;
        @try {

            if (self.mArrSearchResult.count ==  indexPath.row)
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
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CMTLog(@"%@",textField.text);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.mProvTableView setContentOffset:CGPointZero animated:NO];
    self.isSearch = NO;
    [self.mArrSearchResult removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mArrSearchResult removeAllObjects];
        [self.mProvTableView reloadData];
        [textField resignFirstResponder];
    });
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
