//
//  CMTSetRemindPeopleViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/23.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTSetRemindPeopleViewController.h"
#import "CMTPartcell.h"
static NSString * const CMTCaseListRequestDefaultPageSize = @"30";

@interface CMTSetRemindPeopleViewController ()<UITableViewDataSource,UITableViewDelegate>
//参与者列表
@property(nonatomic,strong)UITableView *membertableView;
//参与者属数组
@property(nonatomic,strong)NSMutableArray *memberListArray;
@property(nonatomic,strong)NSMutableArray *SelectListArray;
//我的文章
@property(nonatomic,strong)NSString *groupID;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;                          // 取消按钮
@property (nonatomic, strong) UIBarButtonItem *sendItem;                            // 确定按钮
//从什么地方进来
@property(nonatomic,strong)NSString *model;

@end

@implementation CMTSetRemindPeopleViewController
- (UIBarButtonItem *)cancelItem {
    if (_cancelItem == nil) {
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    return _cancelItem;
}

- (UIBarButtonItem *)sendItem {
    if (_sendItem == nil) {
        _sendItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    return _sendItem;
}
-(NSMutableArray*)SelectListArray{
    if (_SelectListArray==nil) {
        _SelectListArray=[[NSMutableArray alloc]init];
    }
    return _SelectListArray;
}

-(instancetype)initWithGroupID:(NSString*)groupID{
    self=[super init];
    if(self){
        self.groupID=groupID;
        if (CMTAPPCONFIG.addGroupPostData.userinfoArray.count>0) {
            [self.SelectListArray addObjectsFromArray:CMTAPPCONFIG.addGroupPostData.userinfoArray];
        }

    }
    return self;
}
-(instancetype)initWithGroupID:(NSString*)groupID remindArray:(NSArray*)array model:(NSString*)model{
    
    self=[super init];
    if(self){
        self.model=model;
        self.groupID=groupID;
        self.SelectListArray=[[NSMutableArray alloc]init];
        [self.SelectListArray addObjectsFromArray:array];
    }
    return self;
}

-(NSMutableArray*)memberListArray{
    if (_memberListArray==nil) {
        _memberListArray=[[NSMutableArray alloc]init];
    }
    return _memberListArray;
}
-(UITableView*)membertableView{
    if (_membertableView==nil) {
        _membertableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _membertableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _membertableView.delegate=self;
        _membertableView.backgroundColor=COLOR(c_efeff4);
        _membertableView.dataSource=self;
    }
    return _membertableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTGroupMembersViewController willDeallocSignal");
    }];
    self.navigationItem.leftBarButtonItem=self.cancelItem;
    self.navigationItem.rightBarButtonItem=self.sendItem;
    [self.contentBaseView addSubview:self.membertableView];
    self.titleText=@"小组成员";
       //跳立方
    [self setContentState:CMTContentStateLoading];
    [self CMTnfIniteRefreshPartlist];
//    [self CMTPullToRefreshPartlist];
    [self getpartlistData];
    self.cancelItem.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal empty];
    }];
    self.sendItem.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        if (![self.model isEqualToString:@"0"]) {
            CMTAPPCONFIG.addGroupPostData.userinfoArray=[self.SelectListArray copy];
        }
        if (self.updatedata!=nil) {
            self.updatedata();
        }
        if (self.updateRemind!=nil) {
            self.updateRemind([self.SelectListArray copy]);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal empty];
    }];

}

//第一次获取小组数据
-(void)getpartlistData{
    NSDictionary *params=@{
                           @"groupId":self.groupID?:@"0",
                           @"userId":CMTUSERINFO.userId?:@"0",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"excludeMe":@"1",
                           @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                           };
    @weakify(self);
    [[[CMTCLIENT getMember_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamArray) {
        @strongify(self);
        if ([teamArray count]>0) {
            self.memberListArray=[teamArray mutableCopy];
            [self.membertableView reloadData];
            [self setContentState:CMTContentStateNormal];
            if(self.membertableView.contentSize.height<self.membertableView.height){
                self.membertableView.showsInfiniteScrolling=NO;
            }else{
                self.membertableView.showsInfiniteScrolling=YES;

            }
            
        }else {
            [self setContentState:CMTContentStateEmpty];
            self.contentEmptyView.contentEmptyPrompt=@"没有可提醒的成员";
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
    [self.membertableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        CMTParticiPators *Part=[self.memberListArray objectAtIndex:0];
        NSDictionary *params=@{
                               @"groupId":self.groupID?:@"0",
                               @"incrId":Part.incrId?: @"",
                               @"incrIdFlag":@"0",
                               @"excludeMe":@"1",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getParticipatorsList:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *teamdata) {
            @strongify(self);
            if ([teamdata count]>0) {
                NSMutableArray *casetableArray=[[NSMutableArray alloc]initWithArray:teamdata];
                [casetableArray addObjectsFromArray:[self.memberListArray copy]];
                self.memberListArray=[casetableArray mutableCopy];
                [self.membertableView reloadData];
                [self setContentState:CMTContentStateNormal];
                casetableArray=nil;
            }else{
                [self toastAnimation:@"没有新加入的成员"];
            }
            [self.membertableView.pullToRefreshView stopAnimating];
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.membertableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
}

//上拉翻页
-(void)CMTnfIniteRefreshPartlist{
    @weakify(self);
    [self.membertableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTParticiPators *Part=self.memberListArray.lastObject;
        NSDictionary *params=@{
                               @"groupId":self.groupID?:@"0",
                               @"incrId":Part.incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"excludeMe":@"1",
                               @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                               };
        @weakify(self);
        [[[CMTCLIENT getMember_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *listdata) {
            @strongify(self);
            if ([listdata count]>0) {
                [self.memberListArray addObjectsFromArray:listdata];
                self.memberListArray=[self.memberListArray mutableCopy];
                [self.membertableView reloadData];
                [self setContentState:CMTContentStateNormal];
            }else{
                [self toastAnimation:@"没有更多小组成员"];
            }
            
            [self.membertableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.membertableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
    
    
}
#pragma tableView  dataSource代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.memberListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const CMTCellTeamCellIdentifier = @"CMTCellListCellTeam";
    CMTPartcell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellTeamCellIdentifier];
    if(cell==nil){
        cell=[[CMTPartcell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
    }
    cell.isMulti_select=YES;
   
    [cell reloadCell:[self.memberListArray objectAtIndex:indexPath.row]];
    if ([self.SelectListArray containsObject:[self.memberListArray objectAtIndex:indexPath.row]]) {
        cell.rightimage.hidden=NO;
    }else{
        cell.rightimage.hidden=YES;

    }
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTPartcell *cell=[tableView cellForRowAtIndexPath:indexPath];
    CMTParticiPators *parts=[self.memberListArray objectAtIndex:indexPath.row];
    if ([self.SelectListArray containsObject:parts]) {
        cell.rightimage.hidden=YES;
        [self.SelectListArray removeObject:parts];
    }else{
        if (self.SelectListArray.count>=5) {
            [self toastAnimation:@"最多只能提醒5个人"];
        }else if([parts.userId isEqualToString:CMTUSERINFO.userId]){
            [self toastAnimation:@"自己不能提醒自己"];
        }else{
           cell.rightimage.hidden=NO;
          [self.SelectListArray addObject:parts];
        }
    }
}
@end

