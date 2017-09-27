//
//  CMTSearchViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/16.
//  Copyright (c) 2014年 CMT. All rights reserved.
//



#import "CMTSearchViewController.h"
#import "CMTSearchTableViewCell.h"
#import "CMTTableSectionHeader.h"
#import "CMTTableSectionFooter.h"
#import "CMTCollectionViewCell.h"
#import "CMTSearchResultViewController.h"
#import "CMTTypeSearchViewController.h"
@interface CMTSearchViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>

/*自定义视图*/
@property (strong, nonatomic) UIView *mBaseView;
@property (strong, nonatomic) UIView *mSearchImageView;
/*搜索文本框*/
@property (strong, nonatomic) CMTTextSearchFileld *mTfSearch;
/*搜索框左侧图片*/
@property (strong, nonatomic) UIImageView *mTfLeftView;
/*搜索栏右侧按钮*/
@property (strong, nonatomic) UIButton *mCancelBtn;
/*显示搜索结果的imageView*/
@property (strong, nonatomic) UIImageView *mNoResultImageView;
/*无搜索结果的label*/
@property (strong, nonatomic) UILabel *mLbNoContents;
/*当前界面使用collection重新布局*/
@property (strong, nonatomic) UICollectionView *mCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *mLayout;

@property (strong, nonatomic) NSMutableArray *mAllPostTypes;
/*缓存文件存放路径*/
@property (strong, nonatomic) NSString *mFilePath;
@end

@implementation CMTSearchViewController
- (void)viewWillAppear:(BOOL)animated
{
    
#pragma mark 隐藏导航栏
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.mCollectionView.hidden = YES;
    [self initData:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = COLOR(c_efeff4);
    [self initLayout:nil];
    [self.view addSubview:self.mCollectionView];
#pragma mark 底部导航栏
}
- (void)initLayout:(id)sender
{
    [self.view addSubview:self.mBaseView];
    [self.view addSubview:self.mSearchImageView];
    [self.view addSubview:self.mTfSearch];
    [self.view addSubview:self.mCancelBtn];
}

- (UIView *)mBaseView
{
    if (!_mBaseView)
    {   _mBaseView = [[UIView alloc]initWithFrame:CGRectMake(-PIXEL, 0,SCREEN_WIDTH+PIXEL*2, 64)];
        _mBaseView.backgroundColor = COLOR(c_efeff4);
        _mBaseView.layer.borderWidth = PIXEL;
        _mBaseView.layer.borderColor = COLOR(c_9e9e9e).CGColor;    return _mBaseView;
    
    }
    return _mBaseView;
}
- (UIView *)mSearchImageView
{
    if (!_mSearchImageView)
    {
        //        _mSearchImageView = [[UIImageView alloc]initWithImage:IMAGE(@"search_imput")];
        _mSearchImageView = [[UIView alloc]init];
        _mSearchImageView.backgroundColor=COLOR(c_ffffff);
        _mSearchImageView.layer.borderWidth=1;
        _mSearchImageView.layer.cornerRadius=3;
        _mSearchImageView.layer.borderColor=(__bridge CGColorRef)COLOR(c_EBEBEE);
        _mSearchImageView.frame = CGRectMake(10, 26,SCREEN_WIDTH-10-16-45, 30);
        [_mSearchImageView addSubview:self.mTfLeftView];
    }
    return _mSearchImageView;
}

- (UIImageView *)mTfLeftView
{
    if (!_mTfLeftView)
    {
        _mTfLeftView = [[UIImageView alloc]initWithImage:IMAGE(@"search_leftItem")];
        [_mTfLeftView setFrame:CGRectMake(10*RATIO, 7, 18, 18)];
    }
    return _mTfLeftView;
}
- (UITextField *)mTfSearch
{
    if (!_mTfSearch)
    {
        _mTfSearch = [[CMTTextSearchFileld alloc]initWithFrame:CGRectMake(44, 26,self.mSearchImageView.right-44, 30)];
        _mTfSearch.placeholder = @"搜索";
        _mTfSearch.clearButtonMode = UITextFieldViewModeAlways;
        _mTfSearch.clearsOnBeginEditing = YES;
        _mTfSearch.returnKeyType = UIReturnKeySearch;
        _mTfSearch.delegate = self;
    }
    return _mTfSearch;
}

- (UIButton *)mCancelBtn
{
    if (!_mCancelBtn)
    {
        _mCancelBtn  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //pBtn.titleLabel.textColor = [UIColor blackColor];//COLOR(c_32c7c2);
        [_mCancelBtn setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        [_mCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        //[_mCancelBtn setFrame:CGRectMake(275*RATIO, 27, 38*RATIO, 28)];
        [_mCancelBtn setFrame:CGRectMake(self.mSearchImageView.right, 20,SCREEN_WIDTH-self.mSearchImageView.right, 44)];
        [_mCancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _mCancelBtn.tag = 100;
    }
    return _mCancelBtn;
}

- (UICollectionViewLayout *)mLayout
{
    if (!_mLayout)
    {
        _mLayout = [[UICollectionViewFlowLayout alloc]init];
    }
    return _mLayout;
}
- (UICollectionView *)mCollectionView
{
    if (!_mCollectionView)
    {
        _mCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64,self.view.frame.size.width, self.view.frame.size.height - 64) collectionViewLayout:self.mLayout];
        _mCollectionView.backgroundColor =[UIColor colorWithRed:252.0/255 green:252.0/255 blue:252.0/255 alpha:1.0];
        _mCollectionView.delegate = self;
        _mCollectionView.dataSource  = self;
        [_mCollectionView registerClass:[CMTCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _mCollectionView;
}
- (NSMutableArray *)mAllPostTypes
{
    if (!_mAllPostTypes)
    {
        _mAllPostTypes = [NSMutableArray array];
    }
    return _mAllPostTypes;
}

//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

//每个分区上的元素个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.mAllPostTypes.count > 0)
    {
        return self.mAllPostTypes.count;
    }
    else
    {
        return 0;
    }
    
}

//设置元素内容
- (UICollectionViewCell *)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CMTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell sizeToFit];
    if (!cell) {
        cell = [[CMTCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, 50*RATIO, 88)];
    }
    CMTType *pType;
    NSInteger row = indexPath.row;
    @try {
        if (self.mAllPostTypes.count > 0)
        {
            if ([[self.mAllPostTypes objectAtIndex:row ] isKindOfClass:[CMTType class]]) {
                pType = [self.mAllPostTypes objectAtIndex:row];
                cell.lbPostType.text = pType.postType;
                [cell.mImageView setImageURL:pType.iconUrl placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(50, 50)];

            }
            else
            {
                CMTLog(@"我是一只小小鸟");
            }
           
        }
        else
        {
            [cell.mImageView setImage:IMAGE(@"ic_default_head")];
            cell.lbPostType.text = @"标签";
        }

    }
    @catch (NSException *exception) {
        CMTLog(@"error");
    }
    
    return cell;
}

//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {30,(self.view.width-53*RATIO)/8,15,(self.view.width-53*RATIO)/8};
    return top;
}

//设置顶部的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size={0,0};
    return size;
}
//设置元素大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(70*RATIO,88);
}

//点击元素触发事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row);
    CMTType *type = [self.mAllPostTypes objectAtIndex:indexPath.row];
    NSNumber *postTypeId = [NSNumber numberWithInt:type.postTypeId.intValue];
    NSDictionary *pDic = @{@"keyword":@"",@"postTypeId":postTypeId};
    CMTLog(@"postType:%@,postTypeId=%@",type.postType,type.postTypeId);
    CMTTypeSearchViewController *pTypeSearchVC = [[CMTTypeSearchViewController alloc]initWithNibName:nil bundle:nil];
    pTypeSearchVC.mDic = pDic;
    pTypeSearchVC.placeHold = type.postType;
    pTypeSearchVC.needRequest = YES;
    [self.navigationController pushViewController:pTypeSearchVC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*完成数据请求*/
- (void)initData:(id)sender
{
    [self runAnimationInPosition:self.view.center];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    self.mFilePath = [PATH_CACHE_SEARCH stringByAppendingPathComponent:@"allPostTypes"];
    NSDictionary *pDic =  @{@"module":@"1"};
    
    if ([fileManger fileExistsAtPath:self.mFilePath])
    {
        /*1.获取文件创建时间.2.判断与当前时间差.3.决定是否请求*/
        NSDictionary * fileAttributes = [fileManger attributesOfItemAtPath:self.mFilePath error:nil];
        if (fileAttributes != nil)
        {
            //NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
            NSDate *fileModDate = [fileAttributes objectForKey:NSFileCreationDate];
            NSDate *pCurrentDate = [NSDate date];
            NSTimeInterval interval = [pCurrentDate timeIntervalSinceDate:fileModDate];
            CMTLog(@"文件已经创建了%.2f秒",interval);
            
            if (interval >= 1800)
            {
                CMTLog(@"文件创建超过1800秒");
                @weakify(self);
                [self.rac_deallocDisposable addDisposable:[[CMTCLIENT get_post_types_by_module:pDic]subscribeNext:^(NSArray * allTypes) {
                    @strongify(self);
                    DEALLOC_HANDLE_SUCCESS
                    CMTLog(@"从新请求成功");
                    self.mAllPostTypes = [allTypes mutableCopy];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self stopAnimation];
                        self.mCollectionView.hidden = NO;
                        [self.mCollectionView reloadData];
                        
                    });
                   BOOL suc = [fileManger removeItemAtPath:self.mFilePath error:nil];
                    if (suc)
                    {
                        CMTLog(@"删除旧文件成功");
                    }
                    BOOL sucess = [NSKeyedArchiver archiveRootObject:self.mAllPostTypes toFile:self.mFilePath];
                    if (sucess)
                    {
                        CMTLog(@"创建新的缓存文件");
                    }
                   
                } error:^(NSError *error) {
                    DEALLOC_HANDLE_SUCCESS
                    NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                    if ([errorCode integerValue] > 100) {
                        NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                        CMTLog(@"errMes = %@",errMes);
                    } else {
                        CMTLogError(@"get allTypes System Error: %@", error);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self stopAnimation];
                        if ([AFNetworkReachabilityManager sharedManager].isReachable) {
                            self.mCollectionView.hidden = YES;
                            self.mReloadBaseView.hidden = NO;
                        }
                        
                    });
                    
                } completed:^{
                    DEALLOC_HANDLE_SUCCESS
                     CMTLog(@"没有数据");
                }]];
            }
            else
            {
                self.mAllPostTypes = [NSKeyedUnarchiver unarchiveObjectWithFile:self.mFilePath];
                CMTLog(@"hdhhdhdhdhdhdhdh%@",self.mAllPostTypes);
                self.mCollectionView.hidden = NO;
                [self.mCollectionView reloadData];
                [self stopAnimation];
            }
            
        }
    }
    else
    {
        @weakify(self);
        [self.rac_deallocDisposable addDisposable:[[CMTCLIENT get_post_types_by_module:pDic]subscribeNext:^(NSArray * allTypes) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            self.mAllPostTypes = [allTypes mutableCopy];
            if (self.mAllPostTypes.count > 0)
            {
                [NSKeyedArchiver archiveRootObject:self.mAllPostTypes toFile:self.mFilePath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mCollectionView.hidden = NO;
                    [self stopAnimation];
                    [self.mCollectionView reloadData];
                });
            }
            
        } error:^(NSError *error) {
            DEALLOC_HANDLE_SUCCESS
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mReloadBaseView.hidden = NO;
                self.mCollectionView.hidden = YES;
            });
            CMTLog(@"获取所有文章类型错误");
            CMTLog(@"errorInfo:%@",error.userInfo);
        } completed:^{
            DEALLOC_HANDLE_SUCCESS
            CMTLog(@"加载所有完成");
        }]];
    }
}

#pragma  mark  UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *pKeyWord = textField.text;//[self.mTfSearch.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *pDic = @{@"keyword":pKeyWord,@"module":@"1"};
    CMTSearchResultViewController *mResultVC=[[CMTSearchResultViewController alloc]init];
    mResultVC.mDic = pDic;
    mResultVC.needRequest = YES;
    [self.view endEditing:YES];
    if (self.mTfSearch.text.length > 0)
    {
        [self.navigationController pushViewController:mResultVC animated:YES];
    }
    else
    {
        CMTLog(@"请保证搜索条件不能为空");
    }
    
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        self.mReloadBaseView.hidden = YES;
        if (self.mCollectionView.hidden == YES)
        {
            [self initData:nil];
        }
    }
}

#pragma mark  cancelButton Pressed
/**
 *@brief 点击取消按钮关联方法
 */
- (void)cancelBtnPressed:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
    [self cancelKeyBoard];
    

}
//关闭键盘方法
-(void)cancelKeyBoard{
    if ([self.mTfSearch isFirstResponder]) {
        [self.mTfSearch resignFirstResponder];
        self.mCancelBtn.hidden=YES;
        self.mTfSearch.frame=CGRectMake(44, 27, SCREEN_WIDTH-20-44, 30);
        self.mSearchImageView.frame=CGRectMake(10, 26, SCREEN_WIDTH-20, 30);
    }

}
//打开键盘
-(void)openKeyBoard{
    
        self.mCancelBtn.hidden=NO;
        self.mTfSearch.frame=CGRectMake(44, 27, SCREEN_WIDTH-20-44-44, 30);
        self.mSearchImageView.frame=CGRectMake(10, 26, SCREEN_WIDTH-64, 30);

}

@end
