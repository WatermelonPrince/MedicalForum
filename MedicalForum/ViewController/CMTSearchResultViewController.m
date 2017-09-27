//
//  CMTSearchResultViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSearchResultViewController.h"
#import "CMTTableSectionHeader.h"
#import "CMTTableSectionFooter.h"
#import "CMTSearchTableViewCell.h"
#import "CMTSearchMoreViewController.h"
#import "CMTPostDetailCenter.h"
#import "CMTMoreCaseCell.h"
#import "CMTTextSearchFileld.h"

@interface CMTSearchResultViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

/*自定义视图*/
@property (strong, nonatomic) UIView *mBaseView;
@property (strong, nonatomic) UIView *mSearchImageView;
/*搜索文本框*/
@property (strong, nonatomic) CMTTextSearchFileld *mTfSearch;
/*搜索框左侧图片*/
@property (strong, nonatomic) UIImageView *mTfLeftView;
/*搜索栏右侧按钮*/
@property (strong, nonatomic) UIButton *mCancelBtn;
/*显示搜索结果的列表*/
@property (strong, nonatomic) UITableView *mTableView;
/*显示搜索结果的imageView*/
@property (strong, nonatomic) UIImageView *mNoResultImageView;
/*无搜索结果的label*/
@property (strong, nonatomic) UILabel *mLbNoContents;
/*从服务器返回的搜索数据*/
@property (strong, nonatomic) NSMutableArray *mArrResult;


@property (strong, nonatomic) NSMutableArray *mArrStore;



@end

@implementation CMTSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initLayout:nil];
    [self.view addSubview:self.mTableView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mTableView.contentInset = UIEdgeInsetsMake(0, 0, -14, 0);
    self.mTableView.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    NSString *placeHolder = [self.mDic objectForKey:@"keyword"];
    self.mTfSearch.text = placeHolder;
    if (self.needRequest)
    {
        [self initData:self.mDic];
    }
    if (self.mArrResult.count <= 0)
    {
        self.mTableView.hidden = YES;
    }
    else
    {
           self.mTableView.hidden = NO;
           [self.mTableView reloadData];
    }
    
}
- (void)initData:(NSDictionary *)dic
{
    [self runAnimationInPosition:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)];
       @weakify(self);
    [[[CMTCLIENT getPostByType:dic] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray * postByType) {
        @strongify(self);
        DEALLOC_HANDLE_SUCCESS
        self.mArrResult = [postByType mutableCopy];
        if (self.mArrResult.count > 0)
        {

                [self stopAnimation];
                self.mReloadBaseView.hidden = YES;
                self.mNoResultImageView.hidden = YES;
                self.mLbNoContents.hidden = YES;
                [self.mTableView reloadData];
                self.mTableView.hidden = NO;
        }
        else{
        
                [self stopAnimation];
                self.mNoResultImageView.hidden = NO;
                self.mLbNoContents.hidden = NO;
                self.mTableView.hidden = YES;
        }
        self.mReloadBaseView.hidden = YES;
    } error:^(NSError *error) {
        @strongify(self);
        DEALLOC_HANDLE_SUCCESS
        CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
            [self stopAnimation];
            self.mTableView.hidden = YES;
            self.mReloadBaseView.hidden = NO;
    } completed:^{
        
    }];
}
- (void)initLayout:(id)sender
{
    [self.view addSubview:self.mBaseView];
    [self.view addSubview:self.mSearchImageView];
    [self.view addSubview:self.mTfSearch];
    [self.view addSubview:self.mCancelBtn];
    [self.view addSubview:self.mNoResultImageView];
    [self.view addSubview:self.mLbNoContents];
    self.mNoResultImageView.hidden = YES;
    self.mLbNoContents.hidden = YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.mReloadBaseView.isHidden)
    {
        self.mReloadBaseView.hidden = YES;
        
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view];
        if (point.y > 65)
        {
           [self initData:nil];
        }

    }
}

- (UIView *)mBaseView
{
    if (!_mBaseView)
    {
        _mBaseView = [[UIView alloc]initWithFrame:CGRectMake(-1, 0,SCREEN_WIDTH+2, 64)];
        _mBaseView.backgroundColor = COLOR(c_efeff4);
        _mBaseView.layer.borderWidth = 0.3;
        _mBaseView.layer.borderColor = [UIColor colorWithRed:181.0/255 green:181.0/255 blue:181.0/255 alpha:1.0].CGColor;
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
        //_mTfLeftView.backgroundColor = [UIColor greenColor];
        [_mTfLeftView setFrame:CGRectMake(10, 8, 18, 18)];
    }
    return _mTfLeftView;
}
- (CMTTextSearchFileld *)mTfSearch
{
    if (!_mTfSearch)
    {
        _mTfSearch = [[CMTTextSearchFileld alloc]initWithFrame:CGRectMake(44, 26,self.mSearchImageView.right-44, 30)];
        _mTfSearch.placeholder = @"搜索";
        _mTfSearch.clearButtonMode = UITextFieldViewModeAlways;
        _mTfSearch.clearsOnBeginEditing = YES;
        [_mTfSearch setValue:COLOR(c_1515157F) forKeyPath:@"_placeholderLabel.textColor"];
        [_mTfSearch setValue:[UIFont systemFontOfSize:13] forKeyPath:@"_placeholderLabel.font"];
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


- (UITableView *)mTableView
{
    if (!_mTableView)
    {
        _mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 320*RATIO, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.backgroundColor=COLOR(c_efeff4);
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mTableView;
}
- (UIImageView *)mNoResultImageView
{
    if (!_mNoResultImageView)
    {
        _mNoResultImageView = [[UIImageView alloc]initWithImage:IMAGE(@"search_NoResult")];
        _mNoResultImageView.center = self.view.center;
    }
    return _mNoResultImageView;
}
- (UILabel *)mLbNoContents
{
    if (!_mLbNoContents)
    {
        _mLbNoContents = [[UILabel alloc]initWithFrame:CGRectMake(60*RATIO, self.view.centerY + 50, SCREEN_WIDTH-120*RATIO, 15)];
        _mLbNoContents.textAlignment = NSTextAlignmentCenter;
        _mLbNoContents.textColor = [UIColor colorWithRed:172.0/255 green:172.0/255 blue:172.0/255 alpha:1.0];
        _mLbNoContents.text = @"没有找到相关内容";
    }
    return _mLbNoContents;
}

- (NSMutableArray *)mArrResult
{
    if (!_mArrResult)
    {
        _mArrResult = [NSMutableArray array];
    }
    return _mArrResult;
}

- (NSDictionary *)mDic
{
    if (!_mDic)
    {
        _mDic = [NSDictionary dictionary];
    }
    return _mDic;
}
- (NSMutableArray *)mArrStore
{
    if (!_mArrStore)
    {
        _mArrStore = [NSMutableArray array];
    }
    return _mArrStore;
}


#pragma mark  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        CMTPostByType *pType = [self.mArrResult objectAtIndex:indexPath.section];
        if (indexPath.row == 3 && ![pType.postType isEqualToString:@"收藏"])
        {
            return 32;
        }
        else
        {
            return 88;
        }
    }
    @catch (NSException *exception) {
        CMTLog(@"set row height error");
    }
    
    
}

/*设置页眉视图*/
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CMTTableSectionHeader *pHeaderView = [CMTTableSectionHeader headerWithHeaderWidth:tableView.width headerHeight:33.0 inSection:section];
    pHeaderView.backgroundColor = self.mTableView.backgroundColor;
    if (self.mArrResult.count > 0)
    {
        CMTPostByType *pType = [self.mArrResult objectAtIndex:section];
        pHeaderView.title = pType.postType;
    }
    else
    {
        return nil;
        //pHeaderView.title = @"暂时未获取到数据";
    }
    
    return pHeaderView;
}

#pragma mark  cancelButton Pressed
/**
 *@brief 点击取消按钮关联方法
 */
- (void)cancelBtnPressed:(UIButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mTableView.hidden = YES;
        [self.mArrStore removeAllObjects];
        [self.mArrResult removeAllObjects];
    });
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        CMTPostByType *postType = [self.mArrResult objectAtIndex:indexPath.section];
        CMTPost *post = [postType.items objectAtIndex:indexPath.row];
        CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                   isHTML:post.isHTML
                                                                                  postURL:post.url
                                                                               postModule:post.module
                                                                           postDetailType:CMTPostDetailTypeSearchPostList];
        
        CMTSearchMoreViewController *mSearchMoreVC = [[CMTSearchMoreViewController alloc]initWithNibName:nil bundle:nil];
        if (indexPath.row == 3)
        {
            NSString *pStr = postType.postTypeId;
            NSMutableDictionary *pMutableDic = [self.mDic mutableCopy];
            [pMutableDic setObject:[NSNumber numberWithInt:0]?:@"" forKey:@"incrId"];
            [pMutableDic setObject:[NSNumber numberWithInt:30]?:@"" forKey:@"pageSize"];
            [pMutableDic setObject:pStr?:@"" forKey:@"postTypeId"];
             NSDictionary *pDic = [pMutableDic copy];
            mSearchMoreVC.mDic = pDic;
            mSearchMoreVC.placeHold = postType.postType;
            mSearchMoreVC.needRequest = YES;
            [self.navigationController pushViewController:mSearchMoreVC animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:postDetailCenter animated:YES];
        }
        
    }
    @catch (NSException *exception) {
        CMTLog(@"postType is not kind of CMTPostType");
    }
}
#pragma  mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *keyword = [self.mDic objectForKey:@"keyword"];
    static NSString *identifer  = @"cell";
    static NSString *identifer2  = @"cell2";
    CMTSearchTableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:identifer];
    CMTMoreCaseCell *pLastCell = [tableView dequeueReusableCellWithIdentifier:identifer2];
    
    if (!pCell)
    {
        pCell = [[CMTSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        pCell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    if (!pLastCell)
    {
        pLastCell = [[CMTMoreCaseCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer2];
        pLastCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    @try {
        if(self.mArrResult.count > 0)
        {
            CMTPostByType *postType = [self.mArrResult objectAtIndex:indexPath.section];
            CMTPost *post = [postType.items objectAtIndex:indexPath.row];
            if (indexPath.row == 3 && ![postType.postType isEqualToString:@"收藏"])
            {
                [pLastCell.mImageView setImage:IMAGE(@"more")];
                pLastCell.mLbContents.text = [NSString stringWithFormat:@"更多相关%@",postType.postType];
                return pLastCell;
            }
            else
            {
                pCell.mLbTitle.text = post.title;
                /*关键字修改颜色*/
                NSRange range = [pCell.mLbTitle.text rangeOfString:keyword];
                NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:pCell.mLbTitle.text];
                [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_32c7c2) range:range];
                pCell.mLbTitle.attributedText = pStr;
                pCell.mLbAuthor.text = post.author;
                pCell.mLbDate.text = DATE(post.createTime);
                [pCell.mImageView setImageURL:post.smallPic placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(80.0, 60.0)];
                
                if (postType.items.count - 1 == indexPath.row)
                {
                    pCell.bottomLine.hidden = NO;
                }
                else
                {
                    pCell.bottomLine.hidden = YES;
                }
                if (indexPath.row == 0)
                {
                    pCell.sepLine.hidden = YES;
                }
                else
                {
                    pCell.sepLine.hidden = NO;
                }
                
                return pCell;
            }
        }
        else
        {
            return nil;
        }
    }
    @catch (NSException *exception) {
        CMTLog(@"分行错误");
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.mArrResult.count > 0)
    {
        return self.mArrResult.count;
    }
    else
    {
        return 0;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.mArrResult.count > 0)
    {
        CMTPostByType *postType = [self.mArrResult objectAtIndex:section];
        if (postType.items.count > 3)
        {
            if (section == self.mArrResult.count-1)
            {
                CMTLog(@"postType=%@",postType.postType);
               return postType.items.count;
            }
            else
            {
                return 4;
            }
            
        }
        else
        {
            return postType.items.count;
        }
    }
    else
    {
         return 0;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    if (textField.text.length > 0)
    {
        [self.mArrStore removeAllObjects];
        [self.mArrResult removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mTableView.hidden = YES;
            self.mNoResultImageView.hidden = YES;
            self.mLbNoContents.hidden = YES;
            self.mReloadImgView.hidden = YES;
        });
        
        NSString *pKeyWord = textField.text;
        NSDictionary *pDic = @{@"keyword":pKeyWord,@"module":[self.mDic objectForKey:@"module"]};
        self.mDic = pDic;
        self.mTfSearch.text = pKeyWord;
        
        [self initData:self.mDic];
    }
    else
    {
        CMTLog(@"输入结果为空,什么都不做");
    }

    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];

    self.mTableView.hidden = YES;
    self.mNoResultImageView.hidden = YES;
    self.mLbNoContents.hidden = YES;
    self.mReloadImgView.hidden = YES;
    self.mTfSearch.text = nil;
    self.needRequest = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
