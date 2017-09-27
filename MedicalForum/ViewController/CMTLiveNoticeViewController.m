//
//  CMTLiveNoticeViewController.m
//  MedicalForum
//
//  Created by jiahongfei on 15/8/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLiveNoticeViewController.h"
#import "CMTLiveNoticeCell.h"
#import "CMTLiveDetailViewController.h"

static NSString * const CMTCaseListRequestDefaultPageSize = @"30";

@interface CMTLiveNoticeViewController ()

@property(nonatomic,strong)UITableView *noticeTableView;
@property(nonatomic,strong)NSMutableArray *teamlistArray;
@property(nonatomic,assign)BOOL ishaveCache;
@property(nonatomic,strong)NSString *liveBroadcastId;

@end

@implementation CMTLiveNoticeViewController

-(instancetype)initWithLiveId:(NSString *)liveBroadcastId{
    if(self = [super init]){
        self.liveBroadcastId = liveBroadcastId;
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
    self.titleText=@"通知";
    [self.contentBaseView addSubview:self.noticeTableView];
    //跳立方
    [self setContentState:CMTContentStateLoading];
    //跳立方
    [self setContentState:CMTContentStateLoading];
    self.contentEmptyView.contentEmptyPrompt=@"没有未读通知";
    [self.noticeTableView reloadData];
    //强制刷新列表
    [self getLiveNoticeIncrId:@"0" incrIdFlag:@"0"];
    @weakify(self);
    //添加上拉刷新方法
    [self.noticeTableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTNotice *notice=[self.teamlistArray objectAtIndex:0];
        [self getLiveNoticeIncrId:notice.incrId incrIdFlag:@"0"];
    }];
    //添加下拉翻页方法
    [self.noticeTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTNotice *notice=self.teamlistArray.lastObject;
        [self getLiveNoticeIncrId:notice.incrId incrIdFlag:@"1"];

    }];
    
}

-(NSDictionary *)getLiveNoticeParamsIncrId : (NSString *)incrId
                                incrIdFlag : (NSString *)incrIdFlag {
    NSDictionary *params=@{
                           @"incrId":incrId,
                           @"incrIdFlag":incrIdFlag,
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"liveBroadcastId":self.liveBroadcastId,
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    return params;
}

-(void)getLiveNoticeIncrId : (NSString *)incrId
                incrIdFlag : (NSString *)incrIdFlag{
    NSDictionary *params = [self getLiveNoticeParamsIncrId:incrId incrIdFlag:incrIdFlag];
    @weakify(self);
    [[[CMTCLIENT getLiveNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *liveNotice) {
      
        @strongify(self);
        if([incrId isEqualToString:@"0"] && [incrIdFlag isEqualToString:@"0"]){
            //第一次强制刷新
        if ([liveNotice count]>0) {
            self.teamlistArray=[liveNotice mutableCopy];
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
        }else if ([incrIdFlag isEqualToString:@"0"]){
            //下拉
            if ([liveNotice count]>0) {
                NSMutableArray *casetableArray=[[NSMutableArray alloc]initWithArray:liveNotice];
                [casetableArray addObjectsFromArray:[self.teamlistArray copy]];
                self.teamlistArray=[casetableArray mutableCopy];
                [self.noticeTableView reloadData];
                [self setContentState:CMTContentStateNormal];
                casetableArray=nil;
            }else{
                [self toastAnimation:@"没有最新的通知消息"];
            }
            
        }else if ([incrIdFlag isEqualToString:@"1"]){
            //上啦更多
            if ([liveNotice count]>0) {
                [self.teamlistArray addObjectsFromArray:liveNotice];
                self.teamlistArray=[self.teamlistArray mutableCopy];
                [self.noticeTableView reloadData];
                [self setContentState:CMTContentStateNormal];
                [NSKeyedArchiver archiveRootObject: self.teamlistArray toFile:PATH_CACHE_ALL_TEAM];
            }else{
                [self toastAnimation:@"没有更多通知消息"];
            }

        }
        [self.noticeTableView.infiniteScrollingView stopAnimating];
        [self.noticeTableView.pullToRefreshView stopAnimating];
        [self stopAnimation];
    }error:^(NSError *error) {
        @strongify(self);
        [self setContentState:CMTContentStateReload];
        [self stopAnimation];
        [self.noticeTableView.infiniteScrollingView stopAnimating];
        [self.noticeTableView.pullToRefreshView stopAnimating];
    }];

}

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    //强制刷新列表
    [self getLiveNoticeIncrId:@"0" incrIdFlag:@"0"];
}



#pragma tableView  dataSource代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.teamlistArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const CMTCellTeamCellIdentifier = @"CMTCellListCellTeam";
    CMTLiveNoticeCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellTeamCellIdentifier];
    if(cell==nil){
        cell=[[CMTLiveNoticeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
    }
    [cell reloadCell:[[self.teamlistArray objectAtIndex:indexPath.row]copy]];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

//点击查看直播详情
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CMTLiveNotice *cmtLiveNotice = [self.teamlistArray objectAtIndex:indexPath.row];
    CMTLive *cmtLive = [[CMTLive alloc]init];
    cmtLive.liveBroadcastId = cmtLiveNotice.liveBroadcastMessageId;
    CMTLiveDetailViewController *liveDetailViewController = [[CMTLiveDetailViewController alloc] initWithLiveBroadcastMessageId:cmtLive.liveBroadcastId liveDetailType:CMTLiveDetailTypeLiveList];
    @weakify(self);
    liveDetailViewController.updateLiveNoticeStatus = ^() {
        @strongify(self);
        cmtLiveNotice.status = @"1";
        [self.noticeTableView reloadData];
    };
    [self.navigationController pushViewController:liveDetailViewController animated:YES];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.updateNoticeCount != nil) {
        self.updateNoticeCount(@"1");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
