//
//  CMTSearchMemberViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/3/14.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSearchMemberViewController.h"
#import "CMTTextSearchFileld.h"
#import "CMTPartcell.h"

static NSString * const CMTCaseListRequestDefaultPageSize = @"30";

@interface CMTSearchMemberViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UIView *mBaseView;
@property (strong, nonatomic) CMTTextSearchFileld *mTfSearch;/*搜索文本框*/
@property (strong, nonatomic) UITableView *membertableView;
@property (strong, nonatomic) NSMutableArray *sortedmemberArr;//数据源
@property (strong, nonatomic) CMTGroup *mygroup;
@property (strong, nonatomic) NSString *showType;
@property (strong, nonatomic) NSMutableArray *managerListArr;//管理者数据
@property (strong, nonatomic) NSMutableArray *blackListArr;//黑名单
@property (strong, nonatomic) NSMutableArray *parterListArr;//参与者数据
@property (strong, nonatomic) NSMutableArray *deleteArr;//删除数据
@property (strong, nonatomic) UIImageView *mTfLeftView;//搜索左部视图
@property (strong, nonatomic) UIButton *mCancelBtn;//取消按钮
@property (strong, nonatomic) UIView *mSearchImageView;//搜索背景图片
@property (strong, nonatomic) CMTContentEmptyView *contentEmptyView1;//无搜索结果提示图片
@property (assign)NSInteger managerCount;


@end

@implementation CMTSearchMemberViewController

- (instancetype)initWithGroup:(CMTGroup *)group
                 managerCount:(NSInteger)managerCount
                     showType:(NSString *)showType
                  reloadblock:(void (^)(NSString *,CMTParticiPators *))reloadBlock{
            self = [super init];
            if (self) {
                self.mygroup = group;
                self.showType = showType;
                self.managerCount = managerCount;
                self.reloadBlock = reloadBlock;
                
            }
            return self;
}
- (CMTContentEmptyView *)contentEmptyView1 {
    if (_contentEmptyView1 == nil) {
        _contentEmptyView1 = [[CMTContentEmptyView alloc] init];
        _contentEmptyView1.frame = CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT - CMTNavigationBarBottomGuide);
        UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(cancelBtnPressed:)];
        Swipe.numberOfTouchesRequired=1;
        Swipe.direction=UISwipeGestureRecognizerDirectionRight;
        [Swipe setDelaysTouchesBegan:YES];
        [_contentEmptyView1 addGestureRecognizer:Swipe];

        [_contentEmptyView1 setBackgroundColor:COLOR(c_clear)];
        [_contentEmptyView1 setHidden:YES];
        [self.contentBaseView addSubview:_contentEmptyView1];
    }
    
    return _contentEmptyView1;
}
//属性懒加载
- (NSMutableArray *)sortedmemberArr{
    if (_sortedmemberArr ==nil) {
        _sortedmemberArr = [NSMutableArray array];
    }
    return _sortedmemberArr;
}
- (NSMutableArray *)parterListArr{
    if (_parterListArr == nil) {
        _parterListArr = [NSMutableArray array];
    }
    return _parterListArr;
}
- (NSMutableArray *)blackListArr{
    if (_blackListArr == nil) {
        _blackListArr = [NSMutableArray array];
    }
    return _blackListArr;
}
- (NSMutableArray *)deleteArr{
    if (_deleteArr == nil) {
        _deleteArr = [NSMutableArray array];
    }
    return _deleteArr;
}
- (UITableView *)membertableView{
    if (_membertableView == nil) {
        _membertableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(cancelBtnPressed:)];
        Swipe.numberOfTouchesRequired=1;
        Swipe.direction=UISwipeGestureRecognizerDirectionRight;
        [Swipe setDelaysTouchesBegan:YES];
        [_membertableView addGestureRecognizer:Swipe];
        _membertableView.delegate = self;
        _membertableView.dataSource = self;
        _membertableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _membertableView;
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
        [_mCancelBtn setFrame:CGRectMake(275*RATIO, 20, SCREEN_WIDTH-275*RATIO, 44)];
        [_mCancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _mCancelBtn.tag = 100;
    }
    return _mCancelBtn;
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

- (UIImageView *)mTfLeftView
{
    if (!_mTfLeftView)
    {
        _mTfLeftView = [[UIImageView alloc]initWithImage:IMAGE(@"search_leftItem")];
        //_mTfLeftView.backgroundColor = [UIColor greenColor];
        [_mTfLeftView setFrame:CGRectMake(10*RATIO, 6, 18, 18)];
    }
    return _mTfLeftView;
}
/*搜索文本框*/
- (CMTTextSearchFileld *)mTfSearch
{
    if (!_mTfSearch)
    {
        _mTfSearch = [[CMTTextSearchFileld alloc]initWithFrame:CGRectMake(44, 26, 228*RATIO, 30)];
        _mTfSearch.placeholder = @"搜索";
        _mTfSearch.clearButtonMode = UITextFieldViewModeAlways;
        [_mTfSearch setValue:COLOR(c_1515157F) forKeyPath:@"_placeholderLabel.textColor"];
        [_mTfSearch setValue:[UIFont systemFontOfSize:13] forKeyPath:@"_placeholderLabel.font"];
        _mTfSearch.clearsOnBeginEditing = YES;
        _mTfSearch.returnKeyType = UIReturnKeySearch;
        _mTfSearch.delegate = self;
    }
    return _mTfSearch;
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
        _mSearchImageView.frame = CGRectMake(10, 26, 518/2*RATIO, 30);
        [_mSearchImageView addSubview:self.mTfLeftView];
    }
    return _mSearchImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLayout:nil];
    [self.contentBaseView addSubview:self.membertableView];
    [self CMTnfIniteRefreshPartlist];
    if (self.membertableView.contentSize.height>=self.membertableView.height) {
        self.membertableView.showsInfiniteScrolling=YES;
    }else{
        self.membertableView.showsInfiniteScrolling=NO;
        
    }
    // Do any additional setup after loading the view.
}
- (void)initLayout:(id)sender
{
    [self.contentBaseView addSubview:self.mBaseView];
    [self.contentBaseView addSubview:self.mSearchImageView];
    [self.contentBaseView addSubview:self.mTfSearch];
    [self.contentBaseView addSubview:self.mCancelBtn];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)cancelBtnPressed:(UIButton *)sender{
    [self.membertableView setEditing:NO animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma tableView  dataSource代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sortedmemberArr.count;
//    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const CMTCellTeamCellIdentifier = @"CMTCellListCellTeam";
    CMTPartcell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellTeamCellIdentifier];
    if(cell==nil){
        cell=[[CMTPartcell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CMTParticiPators *particiPators = [self.sortedmemberArr objectAtIndex:indexPath.row];
    [cell reloadCell:particiPators];
    //改变关键字颜色
    NSRange range = [cell.partLabel.text rangeOfString:self.mTfSearch.text];
    NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:cell.partLabel.text];
    [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_32c7c2) range:range];
    cell.partLabel.attributedText = pStr;
    return cell;

    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
#pragma mark--  编辑代理方法

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTParticiPators *part = [self.sortedmemberArr objectAtIndex:indexPath.row];
    if (self.mygroup.memberGrade.integerValue == 0) {
        if (part.memberGrade.integerValue == 0) {
            return NO;
        }
        return YES;
    }else if (self.mygroup.memberGrade.integerValue == 1){
        if (part.memberGrade.integerValue == 0 || [CMTUSERINFO.userId isEqualToString:part.userId]) {
            return NO;
        }
        return YES;
    }
    return NO;
}
#pragma mark 设置编辑的样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
#pragma mark 设置处理编辑情况
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTParticiPators *particiPators = [self.sortedmemberArr objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteMembers:particiPators AtIndexPath:indexPath];
        
        // 2. 更新UI
        
    }
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"移除此人";
}


- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTParticiPators *particiPators = [self.sortedmemberArr objectAtIndex:indexPath.row];
    //操作者是群主时
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        if (self.showType.integerValue == 3 && self.mygroup.memberGrade.integerValue != 2) {
            @weakify(self);
            UITableViewRowAction *cancleBlackListAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消拉黑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                @strongify(self);
                [self cancleBlackMembers:particiPators AtIndexPath:indexPath];
                
            }];
            return @[cancleBlackListAction];
        }
        @weakify(self);
        
        //拉黑动作
        UITableViewRowAction *blackListAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"拉黑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            [self blackMembers:particiPators AtIndexPath:indexPath];
            
        }];
        blackListAction.backgroundColor = [UIColor grayColor];
        //移除动作
        UITableViewRowAction *rowActionDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"移除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            [self deleteMembers:particiPators AtIndexPath:indexPath];
            
        }];
        
        //设为组长动作
        UITableViewRowAction *rowAction1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设为组长" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            
            [self changeMemberGradeManager:particiPators AtIndexPath:indexPath];
            rowAction1.backgroundColor = [UIColor orangeColor];
        }];
        rowAction1.backgroundColor = [UIColor colorWithHexString:@"fd9b28"];
        
        //取消组长动作
        UITableViewRowAction *rowAction2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消组长" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            [self revokeGradeManager:particiPators AtIndexPath:indexPath];
            
        }];
        rowAction2.backgroundColor = [UIColor colorWithHexString:@"c7c7cc"];

        
        if (self.mygroup.memberGrade.integerValue == 0) {
            
            
            //组长已满时
            if (_managerCount == 5 && particiPators.memberGrade.integerValue == 2) {
                
                return @[rowActionDelete,blackListAction];
            }
            
          
            UITableViewRowAction *rowActionManager = particiPators.memberGrade.integerValue == 1?rowAction2:rowAction1;
            return @[blackListAction,rowActionDelete,rowActionManager];
        }
        //操作者身份是组长时
        if (self.mygroup.memberGrade.integerValue == 1 ) {
//            if (particiPators.memberGrade.integerValue == 2) {
//                 return @[rowActionDelete,blackListAction];
//            }
            
            //组长已满时
            if (_managerCount == 5 && particiPators.memberGrade.integerValue == 2) {
                
                return @[rowActionDelete,blackListAction];
            }
            
            
            UITableViewRowAction *rowActionManager = particiPators.memberGrade.integerValue == 1?rowAction2:rowAction1;
            return @[blackListAction,rowActionDelete,rowActionManager];
            
           
        }
        return nil;
        
    }else{
        return nil;
    }
    
    
}
//取消拉黑
- (void)cancleBlackMembers:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"",
                            @"groupId":self.mygroup.groupId,
                            @"beUserId":participator.userId,
                            @"flag":@"1",
                            @"userType":@"0",
                            };
    @weakify(self);
    [[[CMTCLIENT cancleBlackListMember:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        [self.sortedmemberArr removeObject:participator];
        [self.blackListArr removeObject:participator];
        [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.reloadBlock(@"取消拉黑",participator);
        
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];
        NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
        if (errcode.integerValue == 1001) {
            self.mLbupload.text = @"暂无操作权限";
        }
      
    }];
    
}

// 拉黑用户

- (void)blackMembers:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"",
                            @"groupId":self.mygroup.groupId,
                            @"beUserId":participator.userId,
                            @"flag":@"0",
                            @"userType":@"0",
                            };
    @weakify(self);
    [[[CMTCLIENT sendBlackListMember:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        
        [self.deleteArr addObject:participator];
        [self.sortedmemberArr removeObject:participator];
        if (self.showType.integerValue == 1) {
            [self.parterListArr removeObject:participator];
        }else{
            [self.managerListArr removeObject:participator];
        }
        [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.reloadBlock(@"拉黑用户",participator);
        
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];
        NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
        if (errcode.integerValue == 1001) {
            self.mLbupload.text = @"暂无操作权限";
        }
      
    }];
}

//移除用户
- (void)deleteMembers:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"",
                            @"groupId":self.mygroup.groupId,
                            @"beUserId":participator.userId,
                            };
    @weakify(self);
    [[[CMTCLIENT sendDeleteMember:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        [self.deleteArr addObject:participator];
        [self.sortedmemberArr removeObject:participator];
        if (self.showType.integerValue == 1) {
            [self.parterListArr removeObject:participator];
        }else{
            [self.managerListArr removeObject:participator];
        }
        [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
       self.reloadBlock(@"移除此人",participator);
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];
        NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
        if (errcode.integerValue == 1001) {
            self.mLbupload.text = @"暂无操作权限";
            return ;
        }
       

    }];
    
    
}
//设为组长
- (void)changeMemberGradeManager:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"",
                             @"groupId":self.mygroup.groupId,
                             @"beUserId":participator.userId,
                             @"memberGrade":@"1"
                             };
    @weakify(self);
    [[[CMTCLIENT sendChangeMemberGrade:params]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (_managerCount < 5) {
            participator.memberGrade = @"1";
            _managerCount = _managerCount + 1;
            
            //            [self memberListDicWithArr:self.sortedmemberArr];
            [self.sortedmemberArr removeObject:participator];
            [self.parterListArr removeObject:participator];
            [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            self.reloadBlock(@"设为组长",participator);
            //self.reloadMark = YES;
        }
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];
        NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
        if (errcode.integerValue == 1001) {
            self.mLbupload.text = @"暂无操作权限";
        }
       

    }];
    
}

//降为组员
- (void)revokeGradeManager:(CMTParticiPators *)participator AtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"",
                             @"groupId":self.mygroup.groupId,
                             @"beUserId":participator.userId,
                             @"memberGrade":@"2"
                             };
    @weakify(self);
    [[[CMTCLIENT revokeGradeManager:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        _managerCount = _managerCount - 1;
        participator.memberGrade = @"2";
        [self.sortedmemberArr removeObject:participator];
        [self.managerListArr removeObject:participator];
        [self.membertableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.reloadBlock(@"取消组长",participator);
        [self.membertableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        [self toastAnimation:error.userInfo[@"errmsg"]];
        NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
        if (errcode.integerValue == 1001) {
            self.mLbupload.text = @"暂无操作权限";
        }
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.mTfSearch.text.length > 0)
    {
        [self.sortedmemberArr removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.membertableView.hidden = YES;
//            self.mNoResultImageView.hidden = YES;
//            self.mLbNoContents.hidden = YES;
//            self.mReloadImgView.hidden = YES;
        });
        
        NSString *pKeyWord = textField.text;//[textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSDictionary*pDic= @{
                             @"groupId":self.mygroup.groupId,
                             @"keyword":pKeyWord,
                             @"showType":self.showType,
                             };
        [self setContentState:CMTContentStateLoading];
        [self getSearchDataWithDic:pDic];
        
//        if([self.mDic objectForKey:@"postTypeId"]==nil){
//            pDic= @{@"keyword":pKeyWord,@"module":[self.mDic objectForKey:@"module"]};
//            
//        }else{
//            pDic=@{@"keyword":self.mTfSearch.text,@"postTypeId":[self.mDic objectForKey:@"postTypeId"]};
//        }
        
        
        //self.mDic = pDic;
        //[self initData:self.mDic];
    }
    else
    {
        CMTLog(@"输入结果为空,什么都不做");
    }
    return YES;
}
//搜索接口
-(void)getSearchDataWithDic:(NSDictionary *)dic{
    @weakify(self);
    [[[CMTCLIENT searchGroupMember:dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray* listdata) {
        @strongify(self);
        if(listdata.count > 0){
            self.contentEmptyView1.hidden = YES;
            if (self.showType.integerValue == 1) {
                self.parterListArr = [listdata mutableCopy];
                self.sortedmemberArr = [listdata mutableCopy];
            }else if (self.showType.integerValue == 2){
                self.managerListArr = [listdata mutableCopy];
                self.sortedmemberArr = [listdata mutableCopy];
            }else{
                self.blackListArr = [listdata mutableCopy];
                self.sortedmemberArr = [listdata mutableCopy];
            }
            [self setContentState:CMTContentStateNormal];
            [self.membertableView reloadData];
            self.membertableView.hidden=NO;
        }else{
            [self setContentState:CMTContentStateNormal];
            self.contentEmptyView1.hidden = NO;
            self.contentEmptyView1.contentEmptyPrompt = @"没有搜索结果";
        }
        
        
        
    }error:^(NSError *error) {
        @strongify(self);
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
            
            [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            
            
        } else {
            [self toastAnimation:@"你的网络不给力"];
            CMTLogError(@"Request verification code System Error: %@", error);
             [self setContentState:CMTContentStateReload moldel:@"1"];
        }
       
        
    }];

}

//上拉加载
-(void)CMTnfIniteRefreshPartlist{
    @weakify(self);
    [self.membertableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        CMTParticiPators *Part;
        switch (self.showType.integerValue) {
            case 1:
                if (self.parterListArr.count > 0) {
                    Part=[self.parterListArr lastObject];
                }
                break;
            case 2:
                if (self.managerListArr.count > 0) {
                    Part=[self.managerListArr lastObject];
                }
                break;
            case 3:
                if (self.blackListArr.count > 0) {
                    Part=[self.blackListArr lastObject];
                }
                break;
            default:
                break;
        }        NSDictionary *params=@{
                                        @"groupId":self.mygroup.groupId?:@"0",
                                        @"incrId":Part.incrId?:@"0",
                                        @"incrIdFlag":@"1",
                                        @"pageSize": CMTCaseListRequestDefaultPageSize ?: @"",
                                        @"keyword":self.mTfSearch.text,
                                        @"showType": self.showType?:@""
                                        };
        @weakify(self);
        [[[CMTCLIENT getMember_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *listdata) {
            @strongify(self);
            if ([listdata count]>0) {
                if (self.showType.integerValue == 1) {
                    [self.parterListArr addObjectsFromArray:listdata];
                    self.sortedmemberArr = [self.parterListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                    
                }else if (self.showType.integerValue == 2){
                    [self.managerListArr addObjectsFromArray:listdata];
                    self.sortedmemberArr = [self.managerListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                    
                }else{
                    [self.blackListArr addObjectsFromArray:listdata];
                    
                    self.sortedmemberArr = [self.blackListArr mutableCopy];
                    [self.membertableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                }
                //                [self.memberListArray addObjectsFromArray:listdata];
                //                self.memberListArray=[self.memberListArray mutableCopy];
                //                self.sortedmemberArr = [NSMutableArray arrayWithArray:self.memberListArray];
                //
                //                //转变成字典
                //                [self memberListDicWithArr:self.sortedmemberArr];
                //                [self.membertableView reloadData];
                //                [self setContentState:CMTContentStateNormal];
            }else{
                [self toastAnimation:@"没有更多小组成员"];
            }
            
            [self.membertableView.infiniteScrollingView stopAnimating];
            
        }error:^(NSError *error) {
            @strongify(self);
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
            if ([errorCode integerValue] > 100) {
                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                [self toastAnimation:errMes];
                CMTLog(@"errMes = %@",errMes);
            } else {
                CMTLogError(@" Error: %@", error);
            }
            
            [self.membertableView.infiniteScrollingView stopAnimating];
            
        }];
    }];
    
    
}




- (void)animationFlash {
    [super animationFlash];
    NSDictionary*pDic= @{
                         @"groupId":self.mygroup.groupId,
                         @"keyword":self.mTfSearch.text,
                         @"showType":self.showType,
                         };
    [self getSearchDataWithDic:pDic];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
