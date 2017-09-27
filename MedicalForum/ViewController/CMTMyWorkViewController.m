//
//  CMTMyWorkViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/30.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTMyWorkViewController.h"
#import "UITableView+CMTExtension_PlaceholderView.h"
#import "CMTCaseListCell.h"
#import "CMTPostListCell.h"
#import "CMTBindingViewController.h"
#import "CMTTableSectionHeader.h"
static NSString * const CMTPostListSectionPostDateKey = @"PostDate";
static NSString * const CMTPostListSectionPostArrayKey = @"PostArray";
static NSString * const CMTCaseListRequestDefaultPageSize = @"30";
@interface CMTMyWorkViewController ()<CMTCaseListCellDelegate>
@property(nonatomic,retain)UITableView *postTableView;//文章列表
@property(nonatomic,retain)UITableView *caseTableView;//病例列表
@property(nonatomic,retain)NSMutableArray *postListArray;//文章数组
@property(nonatomic,retain)NSMutableArray *caseListArray;//病例数组
@property(nonatomic,strong)UIButton *postButton;//文章按钮
@property(nonatomic,strong)UIButton *caseButton;//病例按钮
@property(nonatomic,strong)UIView *buttonView;
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIView *ListEmptyBgView; //列表视图数据为空时的提示;
@property(nonatomic,strong)UILabel *EmptyLable;
@property (nonatomic,strong) NSArray *postSectionList;

@end

@implementation CMTMyWorkViewController
-(NSMutableArray*)postListArray{
    if (_postListArray==nil) {
        _postListArray=[[NSMutableArray alloc]init];
    }
    return _postListArray;
}
-(NSMutableArray*)caseListArray{
    if (_caseListArray==nil) {
        _caseListArray=[[NSMutableArray alloc]init];
    }
    return _caseListArray;
}

-(UITableView*)postTableView{
    if (_postTableView==nil) {
        _postTableView=[[UITableView alloc]init];
        _postTableView.delegate=self;
        _postTableView.dataSource=self;
         _postTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return _postTableView;
}
-(UITableView*)caseTableView{
    if (_caseTableView==nil) {
        _caseTableView=[[UITableView alloc]init];
        _caseTableView.delegate=self;
        _caseTableView.dataSource=self;
        _caseTableView.hidden=YES;
        _caseTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return _caseTableView;
}
-(UIView*)buttonView{
    if (_buttonView==nil) {
        _buttonView=[[UIView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, 40)];
        [_buttonView setBackgroundColor:COLOR(c_ffffff)];
        _postButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, _buttonView.height-1)];
        [_postButton setTitle:@"文章" forState:UIControlStateNormal];
        [_postButton setTitleColor:[UIColor colorWithHexString:@"00C1BA"] forState:UIControlStateNormal];
        [_postButton addTarget:self action:@selector(changeModel:) forControlEvents:UIControlEventTouchUpInside];
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(0, _postButton.height, SCREEN_WIDTH/2, 1)];
        _lineView.backgroundColor=[UIColor colorWithHexString:@"00C1BA"];
        [_buttonView addSubview:_postButton];
        
        _caseButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, _buttonView.height-1)];
        [_caseButton setTitle:@"病例" forState:UIControlStateNormal];
        [_caseButton setTitleColor:COLOR(c_000000) forState:UIControlStateNormal];
        [_caseButton addTarget:self action:@selector(changeModel:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:_caseButton];
        UIView *buttomline=[[UIView alloc]initWithFrame:CGRectMake(0, _caseButton.bottom, SCREEN_WIDTH, 1)];
        buttomline.backgroundColor=[UIColor colorWithHexString:@"F8F8F8"];
        [_buttonView addSubview:buttomline];
        [_buttonView addSubview:_lineView];

        
        
    }
    return _buttonView;
}
-(UIView*)ListEmptyBgView{
    if (_ListEmptyBgView==nil) {
        _ListEmptyBgView=[[UIView alloc]init];
        _ListEmptyBgView.hidden=NO;
        [_ListEmptyBgView setBackgroundColor:COLOR(c_ffffff)];
        self.EmptyLable=[[UILabel alloc]initWithFrame:CGRectMake(0,(SCREEN_WIDTH-35)/2, SCREEN_WIDTH, 35)];
        [ self.EmptyLable setTextColor:[UIColor colorWithHexString:@"#c8c8c8"]];
        [ self.EmptyLable setFont:[UIFont systemFontOfSize:20]];
        [ self.EmptyLable setTextAlignment:NSTextAlignmentCenter];
        [ self.EmptyLable setText:[@[@"2",@"3",@"4"]containsObject:CMTUSERINFO.roleId]?@"还没有发表过文章":@"还没有发表过病例文章"];
        [_ListEmptyBgView addSubview: self.EmptyLable];
    }
    return _ListEmptyBgView;
}

//改变模式
-(void)changeModel:(UIButton*)sender{
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
         @strongify(self);
        self.lineView.frame=CGRectMake(sender.frame.origin.x, self.lineView.top, self.lineView.width, self.lineView.height);
        
    } completion:^(BOOL finished) {
         @strongify(self);
        if (sender==self.postButton) {
            [self.postButton setTitleColor:[UIColor colorWithHexString:@"00C1BA"] forState:UIControlStateNormal];
            [self.caseButton setTitleColor:COLOR(c_000000) forState:UIControlStateNormal];
            if(self.postListArray.count>0){
                self.postTableView.hidden=NO;
                self.caseTableView.hidden=YES;
            }else{
                self.postTableView.hidden=YES;
                self.caseTableView.hidden=YES;
                [self.EmptyLable setText:@"还没有发表过文章"];
            }
        }else{
            [self.caseButton setTitleColor:[UIColor colorWithHexString:@"00C1BA"] forState:UIControlStateNormal];
            [self.postButton setTitleColor:COLOR(c_000000) forState:UIControlStateNormal];
            if(self.caseListArray.count>0){
                self.postTableView.hidden=YES;
                self.caseTableView.hidden=NO;
            }else{
                self.caseTableView.hidden=YES;
                self.postTableView.hidden=YES;
                [self.EmptyLable setText:@"还没有发表过病例文章"];
            }
        }

    }];

      }
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTMyTeamViewController  willDeallocSignal");
    }];
    self.titleText=@"我的作品";
    //设置跳立方
    [self setContentState:CMTContentStateLoading];
    [self CMTnfIniteRefreshMyWorkslist];
     [self.ListEmptyBgView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0 Bottom:0 Right:0];
    if ([@[@"2",@"3",@"4"]containsObject:CMTUSERINFO.roleId] ) {
        [self.contentBaseView addSubview:self.buttonView];
        self.postTableView.frame=CGRectMake(0, self.buttonView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT- self.buttonView.bottom);
        [self.contentBaseView addSubview:self.postTableView];
        self.caseTableView.frame=CGRectMake(0, self.buttonView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT- self.buttonView.bottom);
        [self.contentBaseView addSubview:self.caseTableView];
      
        //获取文章数据
        [self getPOSTLISTata];
        //获取病例数据
        [self getcaseData];
       

    }else{
        self.caseTableView.frame=CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT- CMTNavigationBarBottomGuide);
        [self.contentBaseView addSubview:self.caseTableView];
        self.caseTableView.hidden=NO;
        [self getcaseData];
    }
}
//获取文章数据
-(void)getPOSTLISTata{
    @weakify(self);
    NSDictionary *param=@{
                          @"authorId": CMTUSERINFO.userId?: @"0",
                          @"incrId":@"0",
                          @"incrIdFlag": @"0",
                          @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                          @"module":@"0",
                          };
    [[[CMTCLIENT getPostListByAuthor:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray* array){
         @strongify(self);
        self.postListArray=[array mutableCopy];
        if([self.postListArray count]==0){
           [self setCachePostList:self.postListArray];
           [self.postTableView reloadData];
            self.postTableView.hidden=YES;
            self.postTableView.showsInfiniteScrolling=NO;
        }else{
           [self setCachePostList:self.postListArray];
            [self.postTableView reloadData];
            if (self.postTableView.contentSize.height>self.postTableView.frame.size.height) {
                self.postTableView.showsInfiniteScrolling=YES;

            }else{
                self.postTableView.showsInfiniteScrolling=NO;
            }

        }
        [self setContentState:CMTContentStateNormal];

        
    } error:^(NSError *error) {
        @strongify(self);
            [self setContentState:CMTContentStateReload];
    }];

}
//获取病例数据
-(void)getcaseData{
    @weakify(self);

    NSDictionary *param=@{
                          @"authorId": CMTUSERINFO.userId?: @"0",
                          @"incrId":@"0",
                          @"incrIdFlag": @"0",
                          @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                          @"module":@"1",
                          };
    [[[CMTCLIENT getPostListByAuthor:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray* array){
         @strongify(self);
        self.caseListArray=[array mutableCopy];
        if([self.caseListArray count]==0){
             self.caseTableView.hidden=YES;
            [self.caseTableView reloadData];
            self.caseTableView.showsInfiniteScrolling=NO;
          
        }else{
             if (![@[@"2",@"3",@"4"]containsObject:CMTUSERINFO.roleId] ) {
                 self.caseTableView.hidden=NO;

             }
            [self.caseTableView reloadData];
            if (self.caseTableView.contentSize.height>self.caseTableView.frame.size.height) {
                self.caseTableView.showsInfiniteScrolling=YES;
                
            }else{
                self.caseTableView.showsInfiniteScrolling=NO;
            }

         }
    [self setContentState:CMTContentStateNormal];
        
    } error:^(NSError *error) {
         @strongify(self);
         [self setContentState:CMTContentStateReload];
    }];

    
}
#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    if ([@[@"2",@"3",@"4"]containsObject:CMTUSERINFO.roleId]) {
        [self getPOSTLISTata];
        [self getcaseData];
    }else{
        [self getcaseData];

    }
}

//上拉翻页
-(void)CMTnfIniteRefreshMyWorkslist{
    @weakify(self);
    [self.postTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        NSDictionary *dic=[self.postSectionList lastObject];
        CMTPost *post=[(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]lastObject];
        NSDictionary *params1=@{
                               @"authorId": CMTUSERINFO.userId?: @"0",
                               @"incrId":post.incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"module":@"0",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getPostListByAuthor:params1]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *listdata) {
            @strongify(self);
            if ([listdata count]>0) {
                [self.postListArray addObjectsFromArray:listdata];
                 [self setCachePostList:self.postListArray];
                [self.postTableView reloadData];
                [self setContentState:CMTContentStateNormal];
            }else{
                [self toastAnimation:@"没有更多文章"];
            }
            
            [self.postTableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.postTableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
    
    //    病例
    [self.caseTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTPost *group=self.caseListArray.lastObject;
        NSDictionary *params=@{
                               @"authorId": CMTUSERINFO.userId?: @"0",
                               @"incrId":group.incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"module":@"1",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getPostListByAuthor:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *listdata) {
            @strongify(self);
            if ([listdata count]>0) {
                [self.caseListArray addObjectsFromArray:listdata];
                [self.caseTableView reloadData];
                [self setContentState:CMTContentStateNormal];
            }else{
                [self toastAnimation:@"没有更多病例"];
            }
            
            [self.caseTableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.caseTableView.infiniteScrollingView stopAnimating];
            
        }];
    }];

    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView==self.postTableView) {
        return [self.postSectionList count];
    }
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CMTTableSectionHeader *header = [CMTTableSectionHeader headerWithHeaderWidth:tableView.width
                                                                    headerHeight: 25.0 ];
    header.title = [[self.postSectionList objectAtIndex:section]objectForKey:CMTPostListSectionPostDateKey];
    
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.postTableView==tableView) {
        return 25.0;

    }
    return 0;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.postTableView) {
        NSDictionary *dic=[self.postSectionList objectAtIndex:section];
        return [(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count];
    } else if (tableView == self.caseTableView) {
        return [self.caseListArray count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.postTableView) {
        return 87.5;
    }
    else if (tableView == self.caseTableView) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.postTableView) {
        CMTPostListCell *cell=[tableView dequeueReusableCellWithIdentifier:@"POSTcell"];
        if(cell==nil){
            cell=[[CMTPostListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
        }
        NSDictionary *dic=[self.postSectionList objectAtIndex:indexPath.section];
        CMTPost *post=[(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey] objectAtIndex:indexPath.row];
        [cell reloadPost:post tableView:tableView indexPath:indexPath];
        
        return cell;
    } else if (tableView == self.caseTableView) {
        CMTCaseListCell *cell=[tableView dequeueReusableCellWithIdentifier:@"casecell"];
        if(cell==nil){
            cell=[[CMTCaseListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
        }
        CMTPost *post=[self.caseListArray objectAtIndex:indexPath.row];
        post.groupId=nil;
        cell.isShowinteractive=NO;
        cell.ishaveSectionHeadView=NO;
        cell.lastController=self;
        cell.delegate=self;
        [cell reloadCaseCell:post index:indexPath];
        return cell;

    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CMTPost *post=nil;
        if (tableView == self.postTableView) {
        NSDictionary *dic=[self.postSectionList objectAtIndex:indexPath.section];
          post=[(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey] objectAtIndex:indexPath.row];
        }
        else if (tableView == self.caseTableView) {
         post=[self.caseListArray objectAtIndex:indexPath.row];
            
        }
     CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                               isHTML:post.isHTML
                                                                              postURL:post.url
                                                                           postModule:post.module
                                                                           group:nil
                                                                           iscanShare:((post.postAttr.integerValue&32)==32)
                                                                       postDetailType:CMTPostDetailTypeAuthorPostList];
    [self.navigationController pushViewController:postDetailCenter animated:YES];
}

//点击赞的操作
-(void)CMTSomePraise:(BOOL)ISCancelPraise index:(NSIndexPath*)indexpath{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        CMTPost *post=[self.caseListArray objectAtIndex:indexpath.row];
        @weakify(self)
        NSDictionary *params=@{
                               @"userId":CMTUSERINFO.userId ?:@"0",
                               @"praiseType":@"4",
                               @"postId":post.postId,
                               @"cancelFlag":!post.isPraise.boolValue?@"0":@"1"
                               };
        
        [[[CMTCLIENT Praise:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            @strongify(self)
            [self changepost:post];
            if (ISCancelPraise) {
                post.isPraise=@"1";
                post.praiseCount=[@"" stringByAppendingFormat:@"%ld",(long)(post.praiseCount.integerValue+1)];
            }else{
                post.isPraise=@"0";
                post.praiseCount=[@"" stringByAppendingFormat:@"%ld",(long)(post.praiseCount.integerValue-1>0?post.praiseCount.integerValue-1:0)];
                
            }
            [self.caseTableView reloadData];
            
        } error:^(NSError *error) {
            if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                [self toastAnimation:@"服务器错误"];
            }
            
        }completed:^{
            
        }];
        
        
    }
}
//点击评论
-(void)CMTClickComments:(NSIndexPath*)indexPath{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        CMTPost *post=[self.caseListArray objectAtIndex:indexPath.row];
        CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                   isHTML:post.isHTML
                                                                                  postURL:post.url
                                                                               postModule:post.module
                                                                              postDetailType: CMTPostDetailTypeAuthorPostList];
        @weakify(self);
        postDetailCenter.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
            @strongify(self);
            
            [self updatePost:post withPostStatistics:postStatistics];
        };
        
        [self.navigationController pushViewController:postDetailCenter animated:YES];
    }
}
//改变文章对象
-(void)changepost:(CMTPost*)post{
    CMTParticiPators *part=[[CMTParticiPators alloc]init];
    part.userId=CMTUSER.userInfo.userId;
    part.nickname=CMTUSER.userInfo.nickname;
    part.picture=CMTUSER.userInfo.picture;
    part.opTime=TIMESTAMP;
    NSMutableArray *mutable=[[NSMutableArray alloc]initWithObjects:part, nil];
    NSMutableArray *muale2=[[NSMutableArray alloc ]initWithArray:post.participators];
    for (CMTParticiPators *CMTpart in [muale2 copy]) {
        if ([CMTpart.userId isEqualToString:part.userId]&&CMTpart.userType.integerValue==0) {
            [muale2 removeObject:CMTpart];
        }
    }
    [mutable addObjectsFromArray:muale2];
    post.participators=mutable;
}
- (void)updatePost:(CMTPost *)post withPostStatistics:(CMTPostStatistics *)postStatistics {
    
    // 刷新文章
    post.heat = postStatistics.heat;
    post.postAttr = postStatistics.postAttr;
    post.themeStatus = postStatistics.themeStatus;
    post.themeId = postStatistics.themeId;
    post.commentCount=postStatistics.commentCount;
    post.praiseCount=postStatistics.praiseCount;
    post.isPraise=postStatistics.isPraise;
    if([postStatistics.commentModified boolValue]){
        [self changepost:post];
    }
    
    // 刷新文章列表
    [self.caseTableView reloadData];
    
   
}
// 文章列表 分组 排序 显示
- (void)setCachePostList:(NSArray *)cachePostList {
    @try {
        // 按incrId排序
        // 按创建时间分组
        NSMutableArray *postSections = [NSMutableArray array];
        
        int index = 0;
        for (CMTPost *post in self.postListArray) {
            // 获取当前条目的创建时间
            NSString *createTime = DATE(post.createTime);
            if (BEMPTY(createTime)) {
                [self handleErrorMessage:@"PostList Group PostList: %@\nError: Empty CreateTime at Index: [%d]",  self.postListArray, index];
                return;
            }
            
            // 查找该创建时间的分组
            NSMutableDictionary *targetPostSection = nil;
            for (NSMutableDictionary *postSection in postSections) {
                if ([postSection[CMTPostListSectionPostDateKey] isEqual:createTime]) {
                    targetPostSection = postSection;
                    break;
                }
            }
            
            // 找到该分组
            if (targetPostSection != nil) {
                // 当前条目加入该分组
                NSMutableArray *postArray = targetPostSection[CMTPostListSectionPostArrayKey];
                [postArray addObject:post];
            }
            // 未找到该分组 则创建新分组
            else {
                NSMutableDictionary *postSection = [NSMutableDictionary dictionary];
                NSMutableArray *postArray = [NSMutableArray array];
                postSection[CMTPostListSectionPostDateKey] = createTime;
                postSection[CMTPostListSectionPostArrayKey] = postArray;
                [postArray addObject:post];
                [postSections addObject:postSection];
            }
            index++;
        }
        
        // 分组按创建时间排序
        [postSections sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *createTime1, *createTime2;
            if ([obj1 respondsToSelector:@selector(objectForKey:)]) {
                createTime1 = [obj1 objectForKey:CMTPostListSectionPostDateKey];
            }
            if ([obj2 respondsToSelector:@selector(objectForKey:)]) {
                createTime2 = [obj2 objectForKey:CMTPostListSectionPostDateKey];
            }
            
            if (createTime1 && createTime2) {
                // 创建时间大的在前
                return [createTime2 compare:createTime1];
            }
            else {
                // 默认保持不变
                return NSOrderedAscending;
            }
        }];
        
        // 分组成功
        if ([postSections count] > 0) {
            // 刷新分组列表
            self.postSectionList = [NSArray arrayWithArray:postSections];
        }
        else {
            [self handleErrorMessage:@"PostList Group PostList Error: Empty PostSection"];
        }
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostList Group PostList Exception: %@", exception];
    }
}

// 处理错误信息
- (void)handleErrorMessage:(NSString *)errorMessgae, ... {
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            CMTLogError(@"%@", [[NSString alloc] initWithFormat:errorMessgae arguments:args]);
            va_end(args);
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostDetail Comment List HandleErrorMessage Exception: %@", exception);
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
