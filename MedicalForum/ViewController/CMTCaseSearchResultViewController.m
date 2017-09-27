//
//  CMTCaseSearchResultViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/14.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTCaseSearchResultViewController.h"
#import "CMTCaseGroupTableViewCell.h"
#import "CMTCaseListCell.h"
#import "CMTBindingViewController.h"
#import "CMTGroupInfoViewController.h"
#import "CMTUpgradeViewController.h"
@interface CMTCaseSearchResultViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CMTCaseListCellDelegate>
@property(nonatomic,strong)NSString *searchkey;
@property(nonatomic,assign)NSInteger searchType;
@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)NSMutableArray *JoinTeamArray;
@property(nonatomic,strong)UITableView *searchTableView;
@property(nonatomic,strong)UIView *searchView;
@property(nonatomic,strong) UITextField *searchField;
/*显示搜索结果的imageView*/
@property (strong, nonatomic) UIImageView *mNoResultImageView;
/*无搜索结果的label*/
@property (strong, nonatomic) UILabel *mLbNoContents;
@end
NSString * const CMTCaseSearchIdentifier = @"CMTCellListCell";
static NSString * const CMTsearchListRequestDefaultPageSize = @"30";
@implementation CMTCaseSearchResultViewController
-(instancetype)initWithSearchKey:(NSString*)key type:(NSString*)type{
    self=[super init];
    if (self) {
        self.searchType=type.integerValue;
        self.searchkey=key;
    }
    return self;
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
        _mLbNoContents.text =self.searchType==0?@"没有找到相关小组":@"没有找到相关帖子";
    }
    return _mLbNoContents;
}

-(UITableView*)searchTableView{
    if (_searchTableView==nil) {
        _searchTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, self.contentBaseView.height-CMTNavigationBarBottomGuide)];
        _searchTableView.backgroundColor = COLOR(c_efeff4);
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTableView.dataSource = self;
        _searchTableView.delegate = self;
        if (self.searchType==0) {
              [_searchTableView registerClass:[CMTCaseGroupTableViewCell class]forCellReuseIdentifier:CMTCaseSearchIdentifier];
        }else{
              [_searchTableView registerClass:[CMTCaseListCell class]forCellReuseIdentifier:CMTCaseSearchIdentifier];
        }
      
        [self.contentBaseView addSubview:_searchTableView];
    }
    return _searchTableView;
}
-(UIView*)searchView{
    if (_searchView==nil) {
        _searchView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 64)];
        _searchView.backgroundColor=ColorWithHexStringIndex(c_f5f6f6);
        UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(10,27,SCREEN_WIDTH-75,30)];
        bgView.backgroundColor=ColorWithHexStringIndex(c_ffffff);
        bgView.layer.borderWidth=1;
        bgView.layer.cornerRadius=5;
        bgView.layer.borderColor=ColorWithHexStringIndex(c_F7F7F7).CGColor;
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 20, 20)];
        imageView.image=IMAGE(@"search_leftItem");
        [bgView addSubview:imageView];
        self.searchField=[[UITextField alloc]initWithFrame:CGRectMake(imageView.right+5, 0, bgView.width-imageView.right-10, 30)];
        self.searchField.delegate=self;
        self.searchField.text=self.searchkey;
        self.searchField.placeholder=@"搜索";
        self.searchField.returnKeyType=UIReturnKeySearch;
        self.searchField.clearButtonMode=UITextFieldViewModeWhileEditing;
        
        [bgView addSubview:self.searchField];
        [_searchView addSubview:bgView];
        
        UIButton *cancelbutton=[[UIButton alloc]initWithFrame:CGRectMake(bgView.right+10, 27, 44, 30)];
        [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelbutton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        cancelbutton.titleLabel.font=[UIFont systemFontOfSize:17];
        [cancelbutton addTarget:self action:@selector(gobackTolastController) forControlEvents:UIControlEventTouchUpInside];
        [_searchView addSubview:cancelbutton];
    }
    return _searchView;
}
-(NSMutableArray*)dataSource{
    if (_dataSource==nil) {
        _dataSource=[[NSMutableArray alloc]init];
    }
    return _dataSource;
}
-(NSMutableArray*)JoinTeamArray{
    if (_JoinTeamArray==nil) {
        _JoinTeamArray=[[NSMutableArray alloc]init];
    }
    return _JoinTeamArray;
}

#pragma mark 返回上以页面
-(void)gobackTolastController{
    [self.navigationController popViewControllerAnimated:YES];
  
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTCaseSearchResultViewController Dealloc");
    }];
    [self setContentState:CMTContentStateLoading moldel:@"1"];
    [self.contentBaseView addSubview:self.mNoResultImageView];
    [self.contentBaseView addSubview:self.mLbNoContents];
    [self.contentBaseView addSubview:self.searchView];
    self.mReloadBaseView.frame=CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    self.contentEmptyView.frame=CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    [self getlistdata];
    //翻页
    [self CMTnfSearchIniteRefresh];
}
#pragma  mark 获取搜索数据
-(void)getlistdata{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"pageOffset":@"0",
                           @"incrIdFlag":@"0",
                           @"keyword":self.searchkey?:@"",
                           @"type":@"0",
                           @"pageSize": CMTsearchListRequestDefaultPageSize ?: @"",
                           };
    NSDictionary *params1=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"keyword":self.searchkey?:@"",
                           @"pageSize": CMTsearchListRequestDefaultPageSize ?: @"",
                           };

    @weakify(self);
    if(self.searchType==0){
     [[[CMTCLIENT searchTeam:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTSearchGroupObject *searchobject) {
        @strongify(self);
         [self.dataSource removeAllObjects];
         [self.JoinTeamArray removeAllObjects];
         if (searchobject.inGroups.count>0||searchobject.unInGroups.count>0) {
             self.dataSource=[searchobject.unInGroups mutableCopy];
             self.JoinTeamArray=[searchobject.inGroups mutableCopy];
             [self.searchTableView reloadData];
             [self.searchTableView setContentOffset:CGPointMake(0, 0)];
             [self setContentState:CMTContentStateNormal moldel:@"1"];
             self.mNoResultImageView.hidden=YES;
             self.mLbNoContents.hidden=YES;
             self.searchTableView.hidden=NO;
        }else{
            self.mNoResultImageView.hidden=NO;
            self.mLbNoContents.hidden=NO;
            self.searchTableView.hidden=YES;
        }
        [self stopAnimation];
    }error:^(NSError *error) {
        @strongify(self);
        [self setContentState:CMTContentStateReload moldel:@"1"];
        
        [self stopAnimation];
    }];
    }else{
        [[[CMTCLIENT search_post:params1]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *searchArray) {
            @strongify(self);
            if ([searchArray count]>0) {
                self.dataSource=[searchArray mutableCopy];
                [self.searchTableView reloadData];
                 [self.searchTableView setContentOffset:CGPointMake(0, 0)];
                [self setContentState:CMTContentStateNormal moldel:@"1"];
                self.mNoResultImageView.hidden=YES;
                self.mLbNoContents.hidden=YES;
                self.searchTableView.hidden=NO;
                
                
            }else{
                self.mNoResultImageView.hidden=NO;
                self.mLbNoContents.hidden=NO;
                self.searchTableView.hidden=YES;
            }
            [self stopAnimation];
        }error:^(NSError *error) {
            @strongify(self);
            [self setContentState:CMTContentStateReload moldel:@"1"];
            
            [self stopAnimation];
        }];

        
    }
    
}
//上拉翻页
-(void)CMTnfSearchIniteRefresh{
    @weakify(self);
    [self.searchTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        
        NSString *incrId=self.searchType==0?((CMTGroup*)self.dataSource.lastObject).pageOffset:((CMTPost*)self.dataSource.lastObject).pageOffset;
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"pageOffset":incrId?:@"0",
                               @"incrIdFlag":@"1",
                                @"type":@"2",
                               @"keyword":self.searchkey?:@"",
                               @"pageSize": CMTsearchListRequestDefaultPageSize ?: @"",
                               };

          NSDictionary *params1=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"pageOffset":incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"keyword":self.searchkey?:@"",
                               @"pageSize": CMTsearchListRequestDefaultPageSize ?: @"",
                               };
           @weakify(self);
        if (self.searchType==0) {
            [[[CMTCLIENT searchTeam:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTSearchGroupObject *searchobject) {
                @strongify(self);
                if ([searchobject.unInGroups count]>0) {
                    [self.dataSource addObjectsFromArray:searchobject.unInGroups];
                    [self.searchTableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                }else{
                    [self toastAnimation:@"没有更多小组"];
                }
                
                [self.searchTableView.infiniteScrollingView stopAnimating];
                
            }error:^(NSError *error) {
                CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
                [self.searchTableView.infiniteScrollingView stopAnimating];
                
            }];
      
        }else{
            [[[CMTCLIENT search_post:params1]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *listdata) {
                @strongify(self);
                if ([listdata count]>0) {
                    [self.dataSource addObjectsFromArray:listdata];
                    [self.searchTableView reloadData];
                    [self setContentState:CMTContentStateNormal];
                }else{
                    [self toastAnimation:@"没有更多文章"];
                }
                
                [self.searchTableView.infiniteScrollingView stopAnimating];
                
            }error:^(NSError *error) {
                CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
                [self.searchTableView.infiniteScrollingView stopAnimating];
                
            }];
            

            
        }
       }];
    }

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self getlistdata];

   
}
#pragma mark 搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
     [self setContentState:CMTContentStateLoading moldel:@"1"];
    self.searchkey=self.searchField.text;
    [self getlistdata];
    return YES;
}
//UItableView 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.JoinTeamArray.count>0&&self.dataSource.count>0) {
        return 2;
    }
     return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.searchType==0) {
          return 30;
    }
    return 0;
  
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView  *view=nil;
    if(self.searchType==0){
        view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        view.backgroundColor=COLOR(c_efeff4);
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, view.width-10, 30)];
       
        lable.font=[UIFont systemFontOfSize:14];
        lable.textAlignment=NSTextAlignmentLeft;
        lable.textColor=[UIColor colorWithHexString:@"#ADADAD"];
        [view addSubview:lable];

        if(section==0){
            if (self.JoinTeamArray.count==0) {
               lable.text=@"其他小组";
            }else{
                lable.text=@"我的小组";
            }
        }else{
            lable.text=@"其他小组";
        }
    }
    return view;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.searchType==0){
     if(section==0){
        if (self.JoinTeamArray.count==0) {
           return  self.dataSource.count;
        }else{
             return  self.JoinTeamArray.count;
        }
     }else{
         return self.dataSource.count;
     }
    }
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.searchType==0) {
        CMTCaseGroupTableViewCell *TableViewCell=[tableView dequeueReusableCellWithIdentifier:CMTCaseSearchIdentifier];
        if (TableViewCell==nil) {
            TableViewCell=[[CMTCaseGroupTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CMTCaseSearchIdentifier];
        }
         CMTGroup *group=nil;
        if(indexPath.section==0){
            if (self.JoinTeamArray.count==0) {
                group=[self.dataSource objectAtIndex:indexPath.row];
            }else{
                group=[self.JoinTeamArray objectAtIndex:indexPath.row];
            }
        }else{
             group=[self.dataSource objectAtIndex:indexPath.row];
        }
        TableViewCell.isSearch=YES;
        TableViewCell.searchkey=self.searchkey;
        [TableViewCell reloadCell:group];
        return TableViewCell;
    }else{
        CMTCaseListCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCaseSearchIdentifier];
        if(cell==nil){
            cell=[[CMTCaseListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
        }
        CMTPost *post=[[self.dataSource mutableCopy] objectAtIndex:indexPath.row];
        cell.ishaveSectionHeadView=NO;
        cell.lastController=self;
        cell.isSearch=YES;
        cell.searchkey=self.searchkey;
        cell.ISCanShowBigImage=YES;
        cell.delegate=self;
        [cell reloadCaseCell:post index:indexPath];
        
        //设置选中颜色区域
        if (cell.selectedBackgroundView.tag==1000) {
            cell.selectedBackgroundView.frame=cell.frame;
            [cell.selectedBackgroundView viewWithTag:10001].frame=CGRectMake(cell.insets.left, cell.insets.top, cell.frame.size.width-cell.insets.left-cell.insets.right, cell.frame.size.height-cell.insets.top-cell.insets.bottom);
        }else{
            UIView *view=[[UIView alloc]initWithFrame:cell.frame];
            view.tag=1000;
            UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(cell.insets.left, cell.insets.top, cell.frame.size.width-cell.insets.left-cell.insets.right, cell.frame.size.height-cell.insets.top-cell.insets.bottom)];
            backView.tag=10001;
            backView.backgroundColor=[UIColor colorWithHexString:@"#d9d9d9"];
            [view addSubview:backView];
            cell.selectedBackgroundView=view;
        }
        return cell;

    }
  
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.searchType==0) {
        CMTGroup *group=nil;
        if(indexPath.section==0){
            if (self.JoinTeamArray.count==0) {
                group=[self.dataSource objectAtIndex:indexPath.row];
            }else{
                group=[self.JoinTeamArray objectAtIndex:indexPath.row];
            }
        }else{
            group=[self.dataSource objectAtIndex:indexPath.row];
        }

        if (group.groupType.integerValue>0) {
            if (!CMTUSER.login) {
                CMTBindingViewController *bing=[CMTBindingViewController shareBindVC];
                bing.nextvc=kComment;
                [self.navigationController pushViewController:bing animated:YES];
                return;
            }
            if (CMTUSERINFO.roleId.integerValue==0) {
                if (group.isJoinIn.integerValue==0&&!(CMTUSERINFO.authStatus.integerValue==1||CMTUSERINFO.authStatus.integerValue>=4)) {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"该小组已设置加入权限\n完善信息后可申请加入" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去完善信息",nil];
                    [alert show];
                    [[alert.rac_buttonClickedSignal deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber  *x) {
                        CMTUpgradeViewController *upgrade=[[CMTUpgradeViewController alloc]init];
                        upgrade.lastVC = @"CMTReadCodeBlind";
                        [self.navigationController pushViewController:upgrade animated:YES];
                        
                    } error:^(NSError *error) {
                        
                    } completed:^{
                        
                    }];
                    return;
                }
            }
        }
        @weakify(self);
        CMTGroupInfoViewController *groupInfo=[[CMTGroupInfoViewController alloc]initWithGroup:[group copy]];
        groupInfo.updateGroup=^(CMTGroup *group1){
            @strongify(self);
            if (CMTUSER.login) {
                if (![group.isJoinIn isEqualToString:group1.isJoinIn]) {
                    if (CMTAPPCONFIG.isrefreahCase.integerValue!=1) {
                        CMTAPPCONFIG.isrefreahCase=@"1";
                    }
                 }
                [self.searchTableView reloadData];
            }
            
        };
        
        
        [self.navigationController pushViewController:groupInfo animated:YES];
        

    }else{
    //病例详情
    CMTPostDetailCenter *postDetailCenter=nil;
    CMTPost *post = [self.dataSource objectAtIndex:indexPath.row];
        CMTGroup *group=[[CMTGroup alloc]init];
        group.memberGrade=post.memberGrade;
        group.groupType=post.groupType;
        group.groupId=post.groupId;
        group.groupName=post.groupName;
     postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                               isHTML:post.isHTML
                                                                              postURL:post.url
                                                                                group:group
                                                                           postModule:post.module
                                                                       postDetailType:CMTPostDetailTypeCaseGroup];
    @weakify(self);
    postDetailCenter.updatePostStatistics = ^(CMTPostStatistics *postStatistics) {
        @strongify(self);
        [self updatePost:post withPostStatistics:postStatistics];
    };
        postDetailCenter.ShieldingArticleSucess=^(CMTPost *post){
             @strongify(self);
            [self setContentState:CMTContentStateLoading moldel:@"1"];
            [self getlistdata];
        };
        [self.navigationController pushViewController:postDetailCenter animated:YES];
    }
    
}

//点击赞的操作
-(void)CMTSomePraise:(BOOL)ISCancelPraise index:(NSIndexPath*)indexpath{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        CMTPost *post=[self.dataSource objectAtIndex:indexpath.row];
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
                post.praiseCount=[@"" stringByAppendingFormat:@"%ld", (long)(post.praiseCount.integerValue+1)];
            }else{
                post.isPraise=@"0";
                post.praiseCount=[@"" stringByAppendingFormat:@"%ld", (long)(post.praiseCount.integerValue-1>0?post.praiseCount.integerValue-1:0)];
                
            }
            [self.searchTableView reloadData];
            
            
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
        CMTPost *post=[self.dataSource objectAtIndex:indexPath.row];
        CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                   isHTML:post.isHTML
                                                                                  postURL:post.url
                                                                               postModule:post.module
                                                                           postDetailType:(post.commentCount.integerValue>0?CMTPostDetailTypeCaseListSeeReply:CMTPostDetailTypeCaseListWithReply)];
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
    NSMutableArray *partArray=[post.participators mutableCopy];
    for (int i=0;i<[partArray count];i++) {
        CMTParticiPators *CMTpart=[partArray objectAtIndex:i];
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
    [self.searchTableView reloadData];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
