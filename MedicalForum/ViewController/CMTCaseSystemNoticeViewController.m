//
//  CMTCaseSystemNoticeViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 15/11/25.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTCaseSystemNoticeViewController.h"
#import "CMTApplyNoticeCell.h"
#import "CMTSystemNoticeCell.h"
#import "CMTGroup.h"

@interface CMTCaseSystemNoticeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *CaseSystemNoticeTableView;//系统通知列表
@property (nonatomic, assign)BOOL allowParticipateSuccess; // 同意申请成功；
//data
@property (nonatomic, strong)CMTCaseSystemNoticeModel *rowModel;//数据模型
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, strong)NSMutableArray *modelArray;//要显示在tableView上的数组
@property (nonatomic, strong)NSIndexPath *indexPath;




@end

@implementation CMTCaseSystemNoticeViewController

- (NSMutableArray *)modelArray{
    if (_modelArray == nil) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}



//系统通知列表的懒加载

- (UITableView *)CaseSystemNoticeTableView{
    if (_CaseSystemNoticeTableView == nil) {
        _CaseSystemNoticeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT - CMTNavigationBarBottomGuide) style:UITableViewStylePlain];
        _CaseSystemNoticeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _CaseSystemNoticeTableView.delegate = self;
        _CaseSystemNoticeTableView.dataSource = self;
        [self.CaseSystemNoticeTableView registerClass:[CMTApplyNoticeCell class] forCellReuseIdentifier:@"cell2"];
        [self.CaseSystemNoticeTableView registerClass:[CMTSystemNoticeCell class] forCellReuseIdentifier:@"cell1"];
        [self.contentBaseView addSubview:_CaseSystemNoticeTableView];
    }
    return _CaseSystemNoticeTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CaseSystemNoticeViewController willDeallocSignal");
    }];
    self.titleText = @"通知";
    [self.contentBaseView addSubview:self.CaseSystemNoticeTableView];
    [self setContentState:CMTContentStateLoading];
    [self getDataFromNet];
    [self CMTPullToRefreshNoticelist];
    [self CMTPullToGetMoreNoticeList];
    
    //监视同意申请成功时触发的方法
    RACSignal *allowParticipateFinish = [RACObserve(self, self.allowParticipateSuccess) ignore:@NO];
    [[allowParticipateFinish deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        [self.CaseSystemNoticeTableView reloadData];
    }];
    //将列表添加到根View上

    // Do any additional setup after loading the view.
}

///#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self getDataFromNet];
}

#pragma mark--第一次数据请求
- (void)getDataFromNet{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"",
                             @"incrId":@"0",
                             @"incrIdFlag":@"0",
                             @"pageSize":@"30",
                             @"noticeRange":@"9"
                             };
    
    @weakify(self);
    [[[CMTCLIENT getCaseSystemNotice:params]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *noticeData) {
        @strongify(self);
        [self setContentState:CMTContentStateNormal];
        [self.modelArray removeAllObjects];
        if (noticeData.count > 0) {
            [self setContentState:CMTContentStateNormal];
            self.modelArray  = [noticeData  mutableCopy];
            
            [self.CaseSystemNoticeTableView reloadData];
        }else{
            [self toastAnimation:@"没有最新的通知消息"];
        }
        [self stopAnimation];
        
    } error:^(NSError *error) {
        @strongify(self);
        [self setContentState:CMTContentStateReload];
        CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
        //[self.CaseSystemNoticeTableView.pullToRefreshView stopAnimating];
        //[self toastAnimation:error.userInfo[@"errmsg"]];
        [self stopAnimation];
        
    }];
}
//下拉刷新
-(void)CMTPullToRefreshNoticelist{
    @weakify(self);
    [self.CaseSystemNoticeTableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        [self setContentState:CMTContentStateNormal];
        
        CMTCaseSystemNoticeModel *notice = self.modelArray.count > 0?self.modelArray[0]:@"";

        
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?: @"0",
                               @"incrId":notice.incrId ?: @"",
                               @"incrIdFlag":@"0",
                               @"pageSize": @"30",
                               @"noticeRange":@"9"
                               };
        @weakify(self);
        [[[CMTCLIENT getCaseSystemNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *noticeData) {
            @strongify(self);
            if ([noticeData count]>0) {
                NSMutableArray *casetableArray=[[NSMutableArray alloc]initWithArray:noticeData];
                [casetableArray addObjectsFromArray:self.modelArray];
                self.modelArray = [casetableArray mutableCopy];
                [self.CaseSystemNoticeTableView reloadData];
            }else{
                [self toastAnimation:@"没有最新的通知消息"];
            }
            [self.CaseSystemNoticeTableView.pullToRefreshView stopAnimating];
            [self stopAnimation];
        }error:^(NSError *error) {
            @strongify(self);
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.CaseSystemNoticeTableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
}
//上拉加载
- (void)CMTPullToGetMoreNoticeList{
    @weakify(self);
    [self.CaseSystemNoticeTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        [self setContentState:CMTContentStateNormal];
        CMTCaseSystemNoticeModel *notice = [self.modelArray lastObject];
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?: @"0",
                               @"incrId":notice.incrId ?: @"",
                               @"incrIdFlag":@"1",
                               @"pageSize": @"30",
                               @"noticeRange":@"9"
                               };
        @weakify(self);
        [[[CMTCLIENT getCaseSystemNotice:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *noticeData) {
            @strongify(self);
            if (noticeData) {
                [self.modelArray addObjectsFromArray:noticeData];
            }else{
                [self toastAnimation:@"没有更多消息"];
            }
            [self.CaseSystemNoticeTableView.infiniteScrollingView stopAnimating];
            
        } error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.CaseSystemNoticeTableView.infiniteScrollingView stopAnimating];
            
        }];
        

    }];
}



#pragma mark--通过或拒绝申请发送的数据
//同意
- (void)aceeptApplycation:(UIButton *)button{
    CMTApplyNoticeCell *cell = (CMTApplyNoticeCell *)[[button superview]superview];
    __block NSIndexPath *indexPath = [self.CaseSystemNoticeTableView indexPathForCell:cell];
    __block CMTCaseSystemNoticeModel *model = self.modelArray[indexPath.row];
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"",
                             @"flag":@"1",
                             @"groupId":model.groupId,
                             @"noticeId":model.noticeId,
                             @"beUserId":model.sendUserId,
                             };
  
    
    @weakify(self);
    [[[CMTCLIENT allowOrRefuseEnterGroup:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTCaseSystemNoticeModel *noticeModel){
        @strongify(self);
        [self.modelArray replaceObjectAtIndex:indexPath.row withObject:noticeModel];
        [self.CaseSystemNoticeTableView reloadData];
        
    } error:^(NSError *error) {
        [self toastAnimation:error.userInfo[@"errmsg"]];
    }];
}
//拒绝
- (void)refuseApplycation:(UIButton *)button{
    CMTApplyNoticeCell *cell = (CMTApplyNoticeCell *)[[button superview]superview];
    __block NSIndexPath *indexPath = [self.CaseSystemNoticeTableView indexPathForCell:cell];
    __block CMTCaseSystemNoticeModel *model = self.modelArray[indexPath.row];
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"",
                             @"flag":@"2",
                             @"groupId":model.groupId,
                             @"noticeId":model.noticeId,
                             @"beUserId":model.sendUserId,
                             };
    @weakify(self)
    [[[CMTCLIENT allowOrRefuseEnterGroup:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTCaseSystemNoticeModel *noticeModel) {
        @strongify(self);
        [self.modelArray replaceObjectAtIndex:indexPath.row withObject:noticeModel];
        [self.CaseSystemNoticeTableView reloadData];
        
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];
    }];
    
}


#pragma mark--tableView代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTCaseSystemNoticeModel *noticeModel = self.modelArray[indexPath.row];
    //消息类型为1
    if (noticeModel.noticeType.integerValue == 1 && noticeModel.step.integerValue == 0) {
        CMTApplyNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        [cell configureCellWithModel:noticeModel];
        [cell.aceeptButton addTarget:self action:@selector(aceeptApplycation:) forControlEvents:UIControlEventTouchUpInside];
        [cell.refuseButton addTarget:self action:@selector(refuseApplycation:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
       }
    //消息类型为2,3,4,5,6
    
        CMTSystemNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        [cell configureCellWithModel:noticeModel];
        return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTCaseSystemNoticeModel *model = self.modelArray[indexPath.row];
    if (model.noticeType.integerValue == 1 && model.step.integerValue == 0 && model.groupLimit.integerValue ==3 ) {
        return 650/3;

    }else if (model.noticeType.integerValue == 1 && model.step.integerValue == 0 ){
        return 120;
    }else if (model.noticeType.integerValue == 9){
        if (model.message.length == 0) {
            return 220/3;
        }
        CGFloat messageHeight = [CMTSystemNoticeCell getTextheight:model.message fontsize:12 width:SCREEN_WIDTH - 60];
        return 220/3 + messageHeight + 20;
        
    }else{
       return 220/3;
    }
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    if (self.updateNoticeCount!=nil) {
        self.updateNoticeCount();
    }
    
}
@end
