//
//  CMTSearchMoreViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSearchMoreViewController.h"
#import "CMTTableSectionHeader.h"
#import "CMTTableSectionFooter.h"
#import "CMTSearchTableViewCell.h"
#import "CMTPostDetailCenter.h"
#import "CMTTextSearchFileld.h"


@interface CMTSearchMoreViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
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

/*记录当前翻页*/
@property (assign) NSInteger incrId;
/*记录是否可继续请求*/
@property (assign) BOOL isMore;

- (void)cancelBtnPressed:(UIButton *)btn;

@end

@implementation CMTSearchMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initLayout:nil];
    self.incrId = 1;
    @weakify(self);
    [self.mTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        [self pullToGetMore:nil];
    }];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.mTfSearch.text = [self.mDic objectForKey:@"keyword"];
    self.mTfSearch.placeholder = [NSString stringWithFormat:@"在%@中搜索",self.placeHold];
    if (self.needRequest)
    {
        self.mTableView.hidden = YES;
        [self initData:self.mDic];
    }
    else
    {
        self.mTableView.hidden = NO;
    }
}

- (void)initData:(NSDictionary *)dic
{
    [self runAnimationInPosition:self.view.center];
    @weakify(self);
    [self.rac_deallocDisposable addDisposable:[[CMTCLIENT searchPostInType:dic]subscribeNext:^(NSArray * result) {
        @strongify(self);
        DEALLOC_HANDLE_SUCCESS
        if (result.count > 0)
        {
            self.mArrResult = [result mutableCopy];
            if (result.count < 30)
            {
                self.isMore = NO;
                CMTLog(@"新加载%lu条文章",(unsigned long)result.count);;
            }
            else
            {
                self.isMore = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                
                self.mNoResultImageView.hidden = YES;
                self.mLbNoContents.hidden = YES;
                [self.mTableView reloadData];
                self.mTableView.hidden = NO;
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mNoResultImageView.hidden = NO;
                self.mLbNoContents.hidden = NO;
                self.mTableView.hidden = YES;
            });
        }
        self.mReloadBaseView.hidden = YES;
        
    } error:^(NSError *error) {
        DEALLOC_HANDLE_SUCCESS
        CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAnimation];
            self.mTableView.hidden = YES;
            self.mReloadBaseView.hidden = NO;
        });
    } completed:^{
        DEALLOC_HANDLE_SUCCESS
    }]];
}

- (void)pullToGetMore:(id)sender
{
    NSMutableDictionary *pDic = [self.mDic mutableCopy];
    [pDic removeObjectForKey:@"incrId"];
    CMTPost *post = [self.mArrResult lastObject];
    NSString *incrId = post.incrId;
    if (incrId.length > 0)
    {
        [pDic setObject:incrId?:@"" forKey:@"idcrId"];
    }
    
    if (self.isMore)
    {
        @weakify(self);
         [self.rac_deallocDisposable addDisposable:[[CMTCLIENT searchPostInType:pDic]subscribeNext:^(NSArray * more) {
             @strongify(self);
             DEALLOC_HANDLE_SUCCESS
             CMTLog(@"%@",more);
             if (more.count > 0 && more.count < 30)
             {
                 [self.mArrResult addObjectsFromArray:more];
                 self.isMore = NO;
                  //CMTLog(@"没有更多");
                 CMTLog(@"已加载所有文章");
             }
             else
             {
                 [self.mArrResult addObjectsFromArray:more];
                 self.isMore = YES;
                 self.incrId++;
                 //CMTLog(@"加载更多");
                 
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                [self.mTableView reloadData];
                [self.mTableView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1.0];
             });
         } error:^(NSError *error) {
             DEALLOC_HANDLE_SUCCESS
             CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
         } completed:^{
             DEALLOC_HANDLE_SUCCESS
         }]];
    }
    else
    {
        [self.mTableView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1.0];
        /*弹出提示,没有更多*/
        CMTLog(@"没有更多");
        self.mToastView.mLbContent.text = @"没有更多文章";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:self.mToastView];
            [self hidden:self.mToastView];
        });
    }
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
    [self.view addSubview:self.mTableView];
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



#pragma mark  UITableViewDelegate


#pragma mark  cancelButton Pressed
/**
 *@brief 点击取消按钮关联方法
 */
- (void)cancelBtnPressed:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        CMTPost *post = [self.mArrResult objectAtIndex:indexPath.section];
        CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                   isHTML:post.isHTML
                                                                                  postURL:post.url
                                                                               postModule:post.module
                                                                           postDetailType:CMTPostDetailTypeSearchPostList];
        [self.navigationController pushViewController:postDetailCenter animated:YES];
    }
    @catch (NSException *exception) {
        CMTLog(@"self.mArrResult. object is not kind of CMTPost");
    }
    
}
#pragma  mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *keyword = [self.mDic objectForKey:@"keyword"];
    static NSString *identifer  = @"cell";
    CMTSearchTableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!pCell)
    {
        pCell = [[CMTSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        pCell.selectionStyle = UITableViewCellSelectionStyleNone;
       
    }
    if ([self.mArrResult objectAtIndex:indexPath.section]!= nil)
    {
        CMTPost *post = [self.mArrResult objectAtIndex:indexPath.section];
        pCell.mLbTitle.text = post.title;
        /*关键字修改颜色*/
        NSRange range = [pCell.mLbTitle.text rangeOfString:keyword];
        NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:pCell.mLbTitle.text];
        [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_32c7c2) range:range];
        pCell.mLbTitle.attributedText = pStr;
        pCell.mLbAuthor.text = post.author;
        
        pCell.mLbDate.text = DATE(post.createTime);
        [pCell.mImageView setImageURL:post.smallPic placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(80.0, 60.0)];
        pCell.sepLine.hidden = NO;
        [pCell.sepLine builtinContainer:pCell.contentView WithLeft:0 Top:0 Width:SCREEN_WIDTH Height:PIXEL];
        if (self.mArrResult.count - 1 == indexPath.section)
        {
            pCell.bottomLine.backgroundColor = COLOR(c_eaeaea);
            pCell.bottomLine.hidden = NO;
        }
        else
        {
            pCell.bottomLine.hidden = YES;
        }
    }
 
    return pCell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.mArrResult.count;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (point.y > 65)
    {
        [self initData:self.mDic];
    }

    [self.view endEditing:YES];
}


#pragma mark  UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    if (textField.text.length > 0)
    {
        [self.mArrResult removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mTableView.hidden = YES;
            self.mNoResultImageView.hidden = YES;
            self.mLbNoContents.hidden = YES;
            self.mReloadImgView.hidden = YES;
        });
        NSString *pKeyWord = textField.text;
        NSMutableDictionary *pDic = [self.mDic mutableCopy];
        [pDic removeObjectForKey:@"keyword"];
        [pDic setObject:pKeyWord?:@"" forKey:@"keyword"];
        self.mDic = [pDic copy];
        
        [self initData:self.mDic];
    }
    else
    {
        CMTLog(@"输入结果为空,什么都不做");
    }
   
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.incrId = 1;
    self.needRequest = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
