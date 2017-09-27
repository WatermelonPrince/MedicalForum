//
//  CMTParticiViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTParticiViewController.h"
static NSString * const CMTCaseListRequestDefaultPageSize = @"30";

@interface CMTParticiViewController ()
//参与者列表
@property(nonatomic,strong)UITableView *parttableView;
//参与者属数组
@property(nonatomic,strong)NSMutableArray *partListArray;
//我的文章
@property(nonatomic,strong)NSString *cellId;
@end
@implementation CMTParticiViewController
-(instancetype)initWithId:(NSString*)cellId{
    self=[super init];
    if(self){
        self.cellId=cellId;
    }
    return self;
}
-(NSMutableArray*)partListArray{
    if (_partListArray==nil) {
        _partListArray=[[NSMutableArray alloc]init];
    }
    return _partListArray;
}
-(UITableView*)parttableView{
    if (_parttableView==nil) {
        _parttableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _parttableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _parttableView.delegate=self;
        _parttableView.backgroundColor=COLOR(c_efeff4);
         [_parttableView setAllowsSelection:NO];
        _parttableView.dataSource=self;
    }
    return _parttableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleText=@"参与成员";
    [self.contentBaseView addSubview:self.parttableView];
    [self CMTPullToRefreshPartlist];
    [self CMTnfIniteRefreshPartlist];
    [self getpartlistData];
    
}

//第一次获取小组数据
-(void)getpartlistData{
    NSDictionary *params=@{
                           @"postId":self.cellId?:@"0",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    @weakify(self);
    [[[CMTCLIENT getParticipatorsList:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamArray) {
        @strongify(self);
        if ([teamArray count]>0) {
            self.partListArray=[teamArray mutableCopy];
            [self.parttableView reloadData];
            
            [self setContentState:CMTContentStateNormal];
            
        }else {
            [self setContentState:CMTContentStateEmpty];
            self.contentEmptyView.contentEmptyPrompt=@"没有参与成员";
        }
    }error:^(NSError *error) {
        @strongify(self);
        [self setContentState:CMTContentStateReload];
        [self stopAnimation];
    }];
    
}
#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self getpartlistData];
}
//下拉刷新数据方法
-(void)CMTPullToRefreshPartlist{
    @weakify(self);
    [self.parttableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTParticiPators *Part=[self.partListArray objectAtIndex:0];
        NSDictionary *params=@{
                              @"postId":self.cellId?:@"0",
                               @"incrId":Part.incrId?: @"",
                               @"incrIdFlag":@"0",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getParticipatorsList:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamdata) {
            @strongify(self);
            if ([teamdata count]>0) {
                NSMutableArray *casetableArray=[[NSMutableArray alloc]initWithArray:teamdata];
                [casetableArray addObjectsFromArray:[self.partListArray copy]];
                self.partListArray=[casetableArray mutableCopy];
                NSUInteger pageSize = CMTCaseListRequestDefaultPageSize.integerValue;
                while (self.partListArray.count > pageSize) {
                    [self.partListArray removeObjectAtIndex:pageSize];
                }
                [self.parttableView reloadData];
                [self setContentState:CMTContentStateNormal];
                casetableArray=nil;
            }else{
                [self toastAnimation:@"没有最新参与人员"];
            }
            [self.parttableView.pullToRefreshView stopAnimating];
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.parttableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
}

//上拉翻页
-(void)CMTnfIniteRefreshPartlist{
    @weakify(self);
    [self.parttableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTParticiPators *Part=self.partListArray.lastObject;
        NSDictionary *params=@{
                              @"postId":self.cellId?:@"0",
                               @"incrId":Part.incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getParticipatorsList:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *listdata) {
            @strongify(self);
            if ([listdata count]>0) {
                [self.partListArray addObjectsFromArray:listdata];
                self.partListArray=[self.partListArray mutableCopy];
                [self.parttableView reloadData];
                [self setContentState:CMTContentStateNormal];
              }else{
                [self toastAnimation:@"没有更多参与者"];
            }
            
            [self.parttableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.parttableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
    
    
}
#pragma tableView  dataSource代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.partListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const CMTCellTeamCellIdentifier = @"CMTCellListCellTeam";
    CMTPartcell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellTeamCellIdentifier];
    if(cell==nil){
        cell=[[CMTPartcell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
    }
    [cell reloadCell:[self.partListArray objectAtIndex:indexPath.row]];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
