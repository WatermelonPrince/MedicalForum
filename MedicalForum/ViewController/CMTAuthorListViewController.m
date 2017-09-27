//
//  CMTAuthorListViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTAuthorListViewController.h"
#import "CMTSubcriotionCell.h"
#import "CMTAuthor.h"
#import "CMTOtherPostListViewController.h"
#import "CMTBadgePoint.h"
#import "CMTBarButtonItem.h"

@interface CMTAuthorListViewController ()

@end

@implementation CMTAuthorListViewController



- (NSMutableArray *)mArrAuthors
{
    if (!_mArrAuthors)
    {
        _mArrAuthors = [NSMutableArray array];
    }
    return _mArrAuthors;
}
- (UITableView *)mTableViewAuthor
{
    if (!_mTableViewAuthor)
    {
        _mTableViewAuthor = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _mTableViewAuthor.delegate = self;
        _mTableViewAuthor.dataSource = self;
        _mTableViewAuthor.separatorStyle = UITableViewCellSeparatorStyleNone;
       
    }
    return _mTableViewAuthor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNumber *userId = [NSNumber numberWithInt:0];
//    NSNumber *subjectId = [NSNumber numberWithInt:self.mSubject.subjectId];
    NSNumber *pageSize = [NSNumber numberWithInt:9];
    NSNumber *pageOffset = [NSNumber numberWithInt:0];
    NSDictionary *pDic = @{
                           @"userId":userId,
                           @"subjectId":self.mSubject.subjectId,
                           @"pageOffset":pageOffset,
                           @"pageSize":pageSize
                           };
    if (self.needRequest == YES)
    {
        [self getAuthores:pDic];
    }
    else
    {
        CMTLog(@"从下级界面返回，不需要重新请求");
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CMTLog(@"%s",__func__);
    CMTLog(@"tableView.frame:%@",NSStringFromCGSize(self.mTableViewAuthor.contentSize));
    CMTLog(@"screenHight-64:%.2f",SCREEN_HEIGHT-64.0);
    
}
#pragma mark  获取作者列表
///获取作者列表
- (void)getAuthores:(NSDictionary *)dic
{
    self.mTableViewAuthor.hidden = YES;
    [self runAnimationInPosition:self.view.center];
    self.mReloadBaseView.hidden = YES;
    @weakify(self);
    [[CMTCLIENT getAuthorList:dic]subscribeNext:^(NSArray * authorList) {
        DEALLOC_HANDLE_SUCCESS;
        @strongify(self);
        if (authorList.count > 0) {
            self.mArrAuthors = [authorList mutableCopy];
            if(!self.mTableViewAuthor.contentSize.height <= SCREEN_HEIGHT-64)
            {
#pragma mark 上拉请求更多
                @weakify(self);
                [self.mTableViewAuthor addInfiniteScrollingWithActionHandler:^{
                    @strongify(self);
                    self.requestPage++;
                    NSNumber *userId = [NSNumber numberWithInt:0];
//                    NSNumber *subjectId = [NSNumber numberWithInt:self.mSubject.subjectId];
                    NSNumber *pageSize = [NSNumber numberWithInt:9];
                    NSNumber *pageOffset = [NSNumber numberWithInt:(int)(self.requestPage*9)];
                    NSDictionary *pDic = @{
                                           @"userId":userId,
                                           @"subjectId":self.mSubject.subjectId,
                                           @"pageOffset":pageOffset,
                                           @"pageSize":pageSize
                                           };
                    //        [self getAuthores:pDic];
                    [self getMoreAuthor:pDic];
                    
                }];
                
            }
            else{
                CMTLog(@"没有上拉加载更多");
            }
        }
        else
        {
            self.mTableViewAuthor.scrollEnabled = NO;
        }
        //self.authorSubject = authorSubject;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAnimation];
            self.mTableViewAuthor.hidden = NO;
            [self.mTableViewAuthor reloadData];
            self.mReloadBaseView.hidden = YES;
        });
    } error:^(NSError *error) {
        CMTLog(@"errorMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAnimation];
            self.mTableViewAuthor.hidden = YES;
            self.mReloadBaseView.hidden = NO;
        });
    }];
}
#pragma mark 加载更多作者的方法
- (void)getMoreAuthor:(NSDictionary *)dic
{
    @weakify(self);
    
    [[CMTCLIENT getAuthorList:dic]subscribeNext:^(NSArray * authorList) {
        DEALLOC_HANDLE_SUCCESS;
        @strongify(self);
        if (authorList.count > 0) {
            
            [self.mArrAuthors addObjectsFromArray:authorList];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mTableViewAuthor.infiniteScrollingView stopAnimating];
                [self.mTableViewAuthor reloadData];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mTableViewAuthor.infiniteScrollingView stopAnimating];
            });
            [self toastAnimation:@"没有更多作者"];
        }
        
        
    } error:^(NSError *error) {
        CMTLog(@"errorMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mTableViewAuthor.infiniteScrollingView stopAnimating];
        });
    } ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    self.titleText = @"作者排行";
    [self.view addSubview:self.mTableViewAuthor];
    self.requestPage = 0;
    @weakify(self);
    [[[RACObserve(self, mArrAuthors)ignore:nil]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray* x) {
        @strongify(self);
        //作者列表是否可拖拽
        if(x.count <= 3)
        {
            self.mTableViewAuthor.scrollEnabled = NO;
        }
        else
        {
            self.mTableViewAuthor.scrollEnabled = YES;
        }
    } error:^(NSError *error) {
        CMTLog(@"失败");
    }];
}
#pragma mark 导航返回
- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 分行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mArrAuthors.count;
}
#pragma mark 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float rowHeight = 0;
    @try {
        if (self.mArrAuthors.count > 0)
        {
            CMTAuthor *pAuthor = [self.mArrAuthors objectAtIndex:indexPath.row];
            
            NSString *authorDes = pAuthor.authorDescription;
            UILabel *pLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-75-26*RATIO, 0)];
            pLabel.numberOfLines = 0;
            pLabel.lineBreakMode = NSLineBreakByWordWrapping;
            UIFont *font = [UIFont systemFontOfSize:12];
            CGSize size = CGSizeMake(210*RATIO,2000);
            CGSize labelsize = [authorDes boundingRectWithSize:size
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:font}
                                                       context:nil].size;
            CGFloat labelHeight = ceil(labelsize.height);
            [pLabel setFrame:CGRectMake(75, 35, SCREEN_WIDTH-75-26*RATIO, labelHeight)];
            //CMTLog(@"labelSize:%@",NSStringFromCGSize(labelsize));
            
            if (labelHeight > 26)
            {
                rowHeight = (labelHeight+13+19+48);
            }
            else
            {
                rowHeight = 108;
            }
        }
        
    }
    @catch (NSException *exception) {
        CMTLog(@"数组取值错误");
    }
    
    return rowHeight;
}
#pragma mark 行的渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"cell";
    CMTSubcriotionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    
    if (!cell)
    {
        cell = [[CMTSubcriotionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    CMTAuthor *author;
    //内容
    
    @try {
        if (self.self.mArrAuthors.count > 0)
        {
            author = [self.mArrAuthors objectAtIndex:[indexPath row]];
        }
        //[cell.mImageView setImageURL:author.picture placeholderImage:IMAGE(@"ic_default_head")];
        [cell.mImageView setImageURL:author.picture placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(47, 47)];
        cell.mTextLabel.text = author.nickname;
        cell.mDetailTextLabel.text = author.authorDescription;
        
        NSString *authorDes = author.authorDescription;
        UILabel *pLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH - 75*RATIO, 0)];
        pLabel.numberOfLines = 0;
        pLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        CGSize size = CGSizeMake(210*RATIO,2000);
        CGSize labelsize = [authorDes boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:cell.mDetailTextLabel.font}
                                                   context:nil].size;
        CGFloat labelHeight = ceil(labelsize.height);
        [pLabel setFrame:CGRectMake(75, 35, SCREEN_WIDTH-75-26*RATIO, labelHeight)];
        
        float cellHeight = 0;
        if (labelHeight > 26)
        {
            cell.mDetailTextLabel.frame = pLabel.frame;
            cellHeight = 13+19+labelHeight+48;
        }
        else
        {
            cell.mDetailTextLabel.frame = CGRectMake(75, 35, SCREEN_WIDTH-75-26*RATIO, 19);
            cellHeight = 108.0;
        }
        [cell.leftColorView builtinContainer:cell WithLeft:0 Top:0 Width:4.0 Height:cellHeight-4.0];
        [cell.bottomView builtinContainer:cell WithLeft:0 Top:cellHeight-8.0 Width:SCREEN_WIDTH Height:8.0];
        cell.separatorLine.hidden = NO;
        // 底部阴影需要换
        [cell.mImageBottom setImage:IMAGE(@"shadow_bottom")];
        [cell.mImageBottom builtinContainer:cell WithLeft:0 Top:cellHeight-8.0 Width:SCREEN_WIDTH Height:5*PIXEL];
        
        [cell.mImageViewPostView builtinContainer:cell WithLeft:75 Top:cellHeight - 35.0 Width:14.0 Height:14.0];
        cell.mImageViewPostView.image = IMAGE(@"authorPost");
        [cell.mLbPostsCount builtinContainer:cell WithLeft:75+14.0+10.0 Top:cellHeight - 35.0 Width:30.0 Height:16.0];
        cell.mLbPostsCount.text = [NSString stringWithFormat:@"%d篇",author.postCount];
    }
    @catch (NSException *exception) {
        CMTLog(@"authorList.cout <= 0");
    }

    switch (indexPath.row)
    {
        case 0:
        {
            cell.leftColorView.backgroundColor = COLOR(c_d84315);
        }
            break;
        case 1:
        {
            cell.leftColorView.backgroundColor = COLOR(c_ffca28);
        }
            break;
        case 2:
        {
            cell.leftColorView.backgroundColor = COLOR(c_cddc39);
        }
            break;
            
        default:
        {
            cell.leftColorView.backgroundColor = [UIColor clearColor];
        }
            break;
    }
    return cell;
    
}

#pragma mark 选中行的事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"%s",__func__);
    CMTAuthor *pAuthor = [self.mArrAuthors objectAtIndex:indexPath.row];
    
    CMTOtherPostListViewController *pOtherVC = [[CMTOtherPostListViewController alloc]initWithAuthor:pAuthor.nickname authorId:pAuthor.authorId];
    [self.navigationController pushViewController:pOtherVC animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.needRequest = NO;
}

#pragma mark touch方法
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.mReloadBaseView.hidden == NO)
    {
        [self runAnimationInPosition:self.view.center];
        self.mTableViewAuthor.hidden = YES;
        self.mReloadBaseView.hidden = YES;
        NSNumber *userId = [NSNumber numberWithInt:0];
//        NSNumber *subjectId = [NSNumber numberWithInt:self.mSubject.subjectId];
        NSNumber *pageSize = [NSNumber numberWithInt:9];
        NSNumber *pageOffset = [NSNumber numberWithInt:(int)(self.requestPage*9)];
        NSDictionary *pDic = @{
                               @"userId":userId,
                               @"subjectId":self.mSubject.subjectId,
                               @"pageOffset":pageOffset,
                               @"pageSize":pageSize
                               };
        [self getAuthores:pDic];

    }
}

@end
