//
//  CMTNoticeViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTNoticeViewController.h"
#import "CMTNoticeCell.h"
#import "CMTPostDetailCenter.h"

static NSString * const CMTCaseListRequestDefaultPageSize = @"30";
@interface CMTNoticeViewController ()
//小组列表
@property(nonatomic,strong)UITableView *noticeTableView;
//小组数据列表
@property(nonatomic,strong)NSMutableArray *teamlistArray;
@property(nonatomic,assign)BOOL ishaveCache;
@property(nonatomic,strong)NSString *module;
@property(nonatomic,strong)NSString *groupID;
@property(nonatomic,strong)NSString *noticecount;
@property(nonatomic,strong)CMTGroup *mygroup;
@end
@implementation CMTNoticeViewController
-(instancetype)initWithModel:(NSString *)module{
    self=[super init];
    if (self) {
        self.module=module;
        self.groupID=nil;
        self.mygroup=nil;
    }
    return self;
}
-(instancetype)initWithGroup:(CMTGroup *)group{
    self=[super init];
    if (self) {
        self.mygroup=group;
        self.groupID=group.groupId;
        self.module=@"1";
    }
    return self;
}


-(UITableView*)noticeTableView{
    if (_noticeTableView==nil) {
        _noticeTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _noticeTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _noticeTableView.delegate=self;
        _noticeTableView.backgroundColor=COLOR(c_efeff4);
        _noticeTableView.dataSource=self;
    }
    return _noticeTableView;
}
-(NSMutableArray*)teamlistArray{
    if (_teamlistArray==nil) {
        _teamlistArray=[[NSMutableArray alloc]init];
    }
    return _teamlistArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTNoticeViewController Dealloc");
    }];
    self.titleText=@"通知";
    [self.contentBaseView addSubview:self.noticeTableView];
    //跳立方
    [self setContentState:CMTContentStateLoading];
   
    //跳立方
    [self setContentState:CMTContentStateLoading];
    self.contentEmptyView.contentEmptyPrompt=@"没有未读通知";
    [self.noticeTableView reloadData];
  
    if(self.groupID!=nil){
        [self CMTPullToRefreshGroupNoticelist];
        [self CMTnfIniteRefreshGroupNoticelist];
        [self getGroupNoticelistData];
    }else{
        //添加上拉刷新方法
        [self CMTnfIniteRefreshNoticelist];
        //添加下拉翻页方法
        [self CMTPullToRefreshNoticelist];
        //强制刷新列表
        [self getNoticelistData];
    }
    
}

-(void)getNoticelistData{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"module":self.module,
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    @weakify(self);
    [[[CMTCLIENT getCMTNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNoticeData *teamdata) {
        if (self.module.integerValue==0) {
               CMTAPPCONFIG.HomeNoticeNumber=teamdata.noticeCount;
        }
        @strongify(self);
        if ([teamdata.items count]>0) {
            self.teamlistArray=[teamdata.items mutableCopy];
            [self.noticeTableView reloadData];
            
            [self setContentState:CMTContentStateNormal];
            
        }else{
            if(!self.ishaveCache){
                [self setContentState:CMTContentStateEmpty];
                self.contentEmptyView.contentEmptyPrompt=@"没有未读通知";
                
            }else {
                [self setContentState:CMTContentStateNormal];
            }
        }
        [self stopAnimation];
    }error:^(NSError *error) {
        @strongify(self);
            [self setContentState:CMTContentStateReload];
        [self stopAnimation];
    }];
    
}
//获取小组通知
-(void)getGroupNoticelistData{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"groupId":self.groupID,
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    @weakify(self);
    [[[CMTCLIENT getGroupNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNoticeData *teamdata) {
        @strongify(self);
        self.noticecount=teamdata.noticeCount;
        if ([teamdata.items count]>0) {
            self.teamlistArray=[teamdata.items mutableCopy];
            [self.noticeTableView reloadData];
            
            [self setContentState:CMTContentStateNormal];
            
        }else{
            if(!self.ishaveCache){
                [self setContentState:CMTContentStateEmpty];
                self.contentEmptyView.contentEmptyPrompt=@"没有未读通知";
                
            }else {
                [self setContentState:CMTContentStateNormal];
            }
        }
        [self stopAnimation];
    }error:^(NSError *error) {
        @strongify(self);
        [self setContentState:CMTContentStateReload];
        [self stopAnimation];
    }];
    
}

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self getNoticelistData];
}

///下拉刷新数据方法
-(void)CMTPullToRefreshNoticelist{
    @weakify(self);
    [self.noticeTableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTNotice *notice=[self.teamlistArray objectAtIndex:0];
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"incrId":notice.incrId?: @"",
                               @"incrIdFlag":@"0",
                               @"module":self.module,
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getCMTNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNoticeData *teamdata) {
            @strongify(self);
            if (self.module.integerValue==0) {
                CMTAPPCONFIG.HomeNoticeNumber=teamdata.noticeCount;
            }
            if ([teamdata.items count]>0) {
                NSMutableArray *casetableArray=[[NSMutableArray alloc]initWithArray:teamdata.items];
                [casetableArray addObjectsFromArray:[self.teamlistArray copy]];
                self.teamlistArray=[casetableArray mutableCopy];
                NSUInteger pageSize = CMTCaseListRequestDefaultPageSize.integerValue;
                while (self.teamlistArray.count > pageSize) {
                    [self.teamlistArray removeObjectAtIndex:pageSize];
                }
                [self.noticeTableView reloadData];
                [self setContentState:CMTContentStateNormal];
                casetableArray=nil;
            }else{
                [self toastAnimation:@"没有最新的通知消息"];
            }
            [self.noticeTableView.pullToRefreshView stopAnimating];
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.noticeTableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
}
///小组通知下拉刷新数据方法
-(void)CMTPullToRefreshGroupNoticelist{
    @weakify(self);
    [self.noticeTableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTNotice *notice=[self.teamlistArray objectAtIndex:0];
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"incrId":notice.incrId?: @"",
                               @"incrIdFlag":@"0",
                               @"groupId":self.groupID,
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getGroupNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNoticeData *teamdata) {
            @strongify(self);
            self.noticecount=teamdata.noticeCount;
            if ([teamdata.items count]>0) {
                NSMutableArray *casetableArray=[[NSMutableArray alloc]initWithArray:teamdata.items];
                [casetableArray addObjectsFromArray:[self.teamlistArray copy]];
                self.teamlistArray=[casetableArray mutableCopy];
                NSUInteger pageSize = CMTCaseListRequestDefaultPageSize.integerValue;
                while (self.teamlistArray.count > pageSize) {
                    [self.teamlistArray removeObjectAtIndex:pageSize];
                }
                [self.noticeTableView reloadData];
                [self setContentState:CMTContentStateNormal];
                casetableArray=nil;
            }else{
                [self toastAnimation:@"没有最新的通知消息"];
            }
            [self.noticeTableView.pullToRefreshView stopAnimating];
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.noticeTableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
}

//上拉翻页
-(void)CMTnfIniteRefreshNoticelist{
    @weakify(self);
    [self.noticeTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTNotice *notice=self.teamlistArray.lastObject;
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?: @"0",
                               @"incrId":notice.incrId?:@"0",
                               @"incrIdFlag":@"1",
                                @"module":self.module,
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getCMTNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNoticeData *teamdata) {
            @strongify(self);
            if (self.module.integerValue==0) {
                CMTAPPCONFIG.HomeNoticeNumber=teamdata.noticeCount;
            }
            if ([teamdata.items count]>0) {
                [self.teamlistArray addObjectsFromArray:teamdata.items];
                self.teamlistArray=[self.teamlistArray mutableCopy];
                [self.noticeTableView reloadData];
                [self setContentState:CMTContentStateNormal];
                [NSKeyedArchiver archiveRootObject: self.teamlistArray toFile:PATH_CACHE_ALL_TEAM];
            }else{
                [self toastAnimation:@"没有更多通知消息"];
            }
            
            [self.noticeTableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.noticeTableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
    
    
}
//小组通知翻页
-(void)CMTnfIniteRefreshGroupNoticelist{
    @weakify(self);
    [self.noticeTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTNotice *notice=self.teamlistArray.lastObject;
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?: @"0",
                               @"incrId":notice.incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"groupId":self.groupID,
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getGroupNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTNoticeData *teamdata) {
            @strongify(self);
            self.noticecount=teamdata.noticeCount;
            if ([teamdata.items count]>0) {
                [self.teamlistArray addObjectsFromArray:teamdata.items];
                self.teamlistArray=[self.teamlistArray mutableCopy];
                [self.noticeTableView reloadData];
                [self setContentState:CMTContentStateNormal];
                [NSKeyedArchiver archiveRootObject: self.teamlistArray toFile:PATH_CACHE_ALL_TEAM];
            }else{
                [self toastAnimation:@"没有更多通知消息"];
            }
            
            [self.noticeTableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.noticeTableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
    
    
}

#pragma tableView  dataSource代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.teamlistArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const CMTCellTeamCellIdentifier = @"CMTCellListCellTeam";
    CMTNoticeCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellTeamCellIdentifier];
    CMTNotice *notice=[self.teamlistArray objectAtIndex:indexPath.row];
    if(cell==nil){
        cell=[[CMTNoticeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
    }
    if (notice.noticeType.integerValue==11||notice.noticeType.integerValue==12) {
        cell.userInteractionEnabled=NO;
    }else{
         cell.userInteractionEnabled=YES;
    }
    [cell reloadCell:[notice copy]];
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

//点击查看通知文章详情
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTReceivedComment *comment=[[CMTReceivedComment alloc]init];
    CMTNotice *notice=[self.teamlistArray objectAtIndex:indexPath.row];
    comment.noticeId=notice.noticeId;
    comment.commentId=notice.commentId;
    CMTPostDetailCenter *postDetailCenter =nil;
    if ([@[@"1",@"2",@"3",@"5",@"6"]containsObject:notice.noticeType]) {
        if(self.mygroup==nil){
        postDetailCenter =[CMTPostDetailCenter postDetailWithPostId:notice.postId
                                                             isHTML:notice.isHTML
                                                            postURL:notice.url
                                                         postModule:self.module
                                                 toDisplayedComment:comment];
        }else{
            postDetailCenter =[CMTPostDetailCenter postDetailWithPostId:notice.postId
                                                                 isHTML:notice.isHTML
                                                                postURL:notice.url
                                                               group:self.mygroup
                                                             postModule:self.module
                                                     toDisplayedComment:comment];
        }
    }else{
        if (self.mygroup==nil) {
            postDetailCenter =[CMTPostDetailCenter postDetailWithPostId:notice.postId
                                                                 isHTML:notice.isHTML
                                                                postURL:notice.url
                                                             postModule:self.module
                                                         postDetailType:self.module.integerValue==0?CMTPostDetailTypeHomePostList:CMTPostDetailTypeCaseList];
        }else{
            postDetailCenter =[CMTPostDetailCenter postDetailWithPostId:notice.postId
                                                                 isHTML:notice.isHTML
                                                                postURL:notice.url
                                                                group:self.mygroup
                                                             postModule:self.module
                                                           postDetailType:self.module.integerValue==0?CMTPostDetailTypeHomePostList:CMTPostDetailTypeCaseList];
            
        }
       
    }
    
    @weakify(self);
    postDetailCenter.updatePostStatistics=^(CMTPostStatistics *postStatistics) {
        @strongify(self);
        notice.status=@"1";
        [self.noticeTableView reloadData];
    };
    postDetailCenter.ShieldingArticleSucess=^(CMTPost *POST){
        @strongify(self);
        if(self.ShieldingArticleSucess!=nil){
            self.ShieldingArticleSucess(POST);
        }

    };
    postDetailCenter.PlacedTheTopSucess=^(CMTPost *post){
        @strongify(self);
        if(self.PlacedTheTopSucess!=nil){
            self.PlacedTheTopSucess(post);
        }

    };

    [self.navigationController pushViewController:postDetailCenter animated:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
        if (self.updatenoticeNumber!=nil) {
            self.updatenoticeNumber();
        }
    if(self.updatenotice!=nil){
        self.updatenotice(self.noticecount);
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
