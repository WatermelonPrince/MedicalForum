//
//  CMTTypeSearchViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTTypeSearchViewController.h"
#import "CMTSearchTableViewCell.h"
#import "CMTTableSectionHeader.h"
#import "CMTTableSectionFooter.h"
#import "CMTTypeMoreViewController.h"
#import "CMTPostDetailCenter.h"
#import "CMTMoreCaseCell.h"
#import "CMTTextSearchFileld.h"


@interface CMTTypeSearchViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
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

@property (assign, nonatomic) BOOL searcyType;

@end

@implementation CMTTypeSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setContentState:CMTContentStateNormal];
    [self initLayout:nil];
   
    [self.contentBaseView addSubview:self.mTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.mTableView.hidden = YES;
    self.mTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    NSString *placeHolder = [NSString stringWithFormat:@"在%@中搜索",self.placeHold];
    self.mTfSearch.placeholder = placeHolder;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mTableView.hidden = NO;
            [self.mTableView reloadData];
        });
    }
}
- (void)initData:(NSDictionary *)dic
{
    [self runAnimationInPosition:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)];
    @weakify(self);
    [self.rac_deallocDisposable addDisposable:[[CMTCLIENT getPostByDepart:dic]subscribeNext:^(NSArray * postByType) {
        @strongify(self);
        DEALLOC_HANDLE_SUCCESS
        /*返回数据根据订阅信息排序*/
        
        NSMutableArray *pSubArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
        if([pSubArr respondsToSelector:@selector(sortedArrayUsingComparator:)])
        {
            [pSubArr sortUsingComparator:^NSComparisonResult(CMTConcern *concern1, CMTConcern *concern2) {
                NSComparisonResult result = [concern1.subjectId compare:concern2.subjectId] ;
                return result;
            }];
        }
        
        NSMutableArray *tempArr = [postByType mutableCopy];
        for (int i = 0; i < pSubArr.count; i++)
        {
            CMTConcern *concern = [pSubArr objectAtIndex:i];
            for (int j = 0; j < postByType.count; j++)
            {
                CMTPostByDepart *depart = [postByType objectAtIndex:j];
                if ([concern.subject isEqualToString:depart.subject])
                {
                    //[self.mArrResult insertObject:depart atIndex:0];
                    [self.mArrResult addObject:depart];
                    [tempArr removeObject:depart];
                }
                
            }
        }
        [self.mArrResult addObjectsFromArray:tempArr];
        
        if (self.mArrResult.count > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mReloadBaseView.hidden = YES;
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
        
    }]];
    
}
- (void)initLayout:(id)sender
{
    [self.contentBaseView addSubview:self.mBaseView];
    [self.contentBaseView addSubview:self.mSearchImageView];
    [self.contentBaseView addSubview:self.mTfSearch];
    [self.contentBaseView addSubview:self.mCancelBtn];
    [self.contentBaseView addSubview:self.mNoResultImageView];
    [self.contentBaseView addSubview:self.mLbNoContents];
    self.mNoResultImageView.hidden = YES;
    self.mLbNoContents.hidden = YES;
}

- (UIView *)mBaseView
{
    if (!_mBaseView)
    {
        _mBaseView = [[UIView alloc]initWithFrame:CGRectMake(-PIXEL, 0,SCREEN_WIDTH+PIXEL*2, 64)];
        _mBaseView.backgroundColor = COLOR(c_efeff4);
        _mBaseView.layer.borderWidth = PIXEL;
        _mBaseView.layer.borderColor = COLOR(c_9e9e9e).CGColor;
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
        //_mNoResultImageView.image = IMAGE(@"search_NoResult");
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        return 32;
    }
    else
    {
        return 88;
    }
}

/*设置页眉视图*/
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CMTTableSectionHeader *pHeaderView = [CMTTableSectionHeader headerWithHeaderWidth:tableView.width headerHeight:33.0 inSection:section];
    pHeaderView.backgroundColor = self.mTableView.backgroundColor;
    if (self.mArrResult.count > section)
    {
        if ([[self.mArrResult objectAtIndex:section] isKindOfClass:[CMTPostByDepart class]])
        {
            CMTPostByDepart *pType = [self.mArrResult objectAtIndex:section];
            pHeaderView.title = pType.subject;
        }
        else if([[self.mArrResult objectAtIndex:section]isKindOfClass:[CMTPostByType class]])
        {
           
            CMTPostByType *pType = [self.mArrResult objectAtIndex:section];
            pHeaderView.title = pType.postType;

        }
        
    }
    else
    {
        pHeaderView.title = @"暂时未获取到数据";
    }
    
    return pHeaderView;
}

/*点击footerView上的更多按钮关联方法*/
- (void)moreInformation:(UIButton *)btn
{
    NSInteger section = btn.tag;
    CMTPostByDepart *pType = [self.mArrResult objectAtIndex:section];
    
    NSString *keyword = self.placeHold;
    NSNumber *subjectId = [NSNumber numberWithInt:pType.subjectId.intValue];
    NSString *subject = pType.subject;
    NSNumber * incrId = [NSNumber numberWithInt:0];
    NSNumber * pageSize = [NSNumber numberWithInt:30];
    NSDictionary *pDic = @{@"keyword":@"",@"subjectId":subjectId,@"incrId":incrId,@"pageSize":pageSize,@"module":[self.mDic objectForKey:@"module"]};
    CMTTypeMoreViewController *pTypeMoreVC  = [[CMTTypeMoreViewController alloc]initWithNibName:nil bundle:nil];
    pTypeMoreVC.mDic = pDic;
    pTypeMoreVC.needRequest = YES;
    pTypeMoreVC.placeHold = [NSString stringWithFormat:@"在%@&%@中搜索",keyword,subject];
    CMTLog(@"搜索%@",pTypeMoreVC.placeHold);
    
    [self.navigationController pushViewController:pTypeMoreVC animated:YES];
    
}

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
        
        CMTPostByDepart *pPostByDepart = [self.mArrResult objectAtIndex:indexPath.section];
        CMTPost *post = [pPostByDepart.items objectAtIndex:indexPath.row];
        CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                   isHTML:post.isHTML
                                                                                  postURL:post.url
                                                                               postModule:post.module
                                                                           postDetailType:CMTPostDetailTypeSearchPostList];
        
        if (indexPath.row == 3)
        {
            NSString *keyword = self.placeHold;
            NSNumber *subjectId = [NSNumber numberWithInt:pPostByDepart.subjectId.intValue];
            NSString *subject = pPostByDepart.subject;
            NSNumber * incrId = [NSNumber numberWithInt:0];
            NSNumber * pageSize = [NSNumber numberWithInt:30];
            NSDictionary*pDic=nil;
            if([self.mDic objectForKey:@"postTypeId"]==nil){
         pDic=@{@"keyword":self.mTfSearch.text,@"subjectId":subjectId,@"incrId":incrId,@"pageSize":pageSize,@"module":[self.mDic objectForKey:@"module"]};
                
            }else{
                pDic=@{@"keyword":self.mTfSearch.text,@"subjectId":subjectId,@"incrId":incrId,@"pageSize":pageSize,@"postTypeId":[self.mDic objectForKey:@"postTypeId"]};
            }

            CMTTypeMoreViewController *pTypeMoreVC  = [[CMTTypeMoreViewController alloc]initWithNibName:nil bundle:nil];
            pTypeMoreVC.mDic = pDic;
            pTypeMoreVC.needRequest = YES;
            pTypeMoreVC.placeHold = [NSString stringWithFormat:@"在%@的%@中搜索",subject,keyword];

            [self.navigationController pushViewController:pTypeMoreVC animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:postDetailCenter animated:YES];
        }
        
    }
    @catch (NSException *exception) {
        CMTLog(@"self.mArrResult.object is not kind of CMTPostByType");
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
        pLastCell = [[CMTMoreCaseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer2];
        pLastCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(self.mArrResult.count > 0)
    {
        if ([[self.mArrResult objectAtIndex:indexPath.section ]isKindOfClass:[CMTPostByDepart class]])
        {
            CMTPostByDepart *postDepart = [self.mArrResult objectAtIndex:indexPath.section];
            CMTPost *post = [postDepart.items objectAtIndex:indexPath.row];
        
            if (indexPath.row == 3)
            {
                [pLastCell.mImageView setImage:IMAGE(@"more")];
                pLastCell.mLbContents.text = [NSString stringWithFormat:@"更多%@的%@",postDepart.subject,self.placeHold];
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
                pCell.mLbAuthor.text = ![(NSString *)self.mDic[@"module"] isPostModuleGuide] ? post.author : post.issuingAgency;
                pCell.mLbDate.text = DATE(post.createTime);
                [pCell.mImageView setImageURL:post.smallPic placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(80.0, 60.0)];
                if (indexPath.row == 0)
                {
                    pCell.sepLine.hidden = YES;
                }
                else
                {
                    pCell.sepLine.hidden = NO;
                }
                
                if (postDepart.items.count - 1 == indexPath.row)
                {
                    pCell.bottomLine.hidden = NO;
                }
                else
                {
                    pCell.bottomLine.hidden = YES;
                }
                
                return pCell;
            }
            return pCell;
        }
    }
    else
    {
        return pCell;
    }
    return pCell;
    
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
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.mArrResult.count > 0)
    {
        CMTPostByDepart *postType = [self.mArrResult objectAtIndex:section];
        if (postType.items.count > 3)
        {
            return 4;
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
    if (self.mTfSearch.text.length > 0)
    {
        [self.mArrResult removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mTableView.hidden = YES;
            self.mNoResultImageView.hidden = YES;
            self.mLbNoContents.hidden = YES;
            self.mReloadImgView.hidden = YES;
        });

        NSString *pKeyWord = textField.text;//[textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSDictionary*pDic=nil;
        if([self.mDic objectForKey:@"postTypeId"]==nil){
            pDic= @{@"keyword":pKeyWord,@"module":[self.mDic objectForKey:@"module"]};
            
        }else{
            pDic=@{@"keyword":self.mTfSearch.text,@"postTypeId":[self.mDic objectForKey:@"postTypeId"]};
        }

        self.mDic = pDic;
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.mReloadBaseView.isHidden)
    {
        self.mReloadBaseView.hidden = YES;
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view];
        if (point.y > 65)
        {
            [self initData:self.mDic];
        }

    }
}

@end
