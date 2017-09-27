//
//  LiveTagFilterViewController.m
//  MedicalForum
//
//  Created by jiahongfei on 15/8/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLiveTagFilterViewController.h"
#import "CMTCaseListCell.h"
#import "CMTTableSectionHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "CMTBindingViewController.h"
#import "CMTNoticeViewController.h"
#import "CMTLiveNoticeViewController.h"
#import "CMTSendCaseViewController.h"
#import "CMTLiveDetailViewController.h"
#import "CMTPostProgressView.h"

static  NSString * const CMTCellLiveCellIdentifier = @"CMTCellliveCell";
static NSString * const CMTPostListSectionPostDateKey = @"PostDate";
static NSString * const CMTPostListSectionPostArrayKey = @"PostArray";

@interface CMTLiveTagFilterViewController ()<UITableViewDataSource,UITableViewDelegate,CMTCaseListCellDelegate,UIActionSheetDelegate>

@property(nonatomic,strong)CMTLive *mylive;
@property(nonatomic,strong)NSString *liveBroadcastTagId;
@property(nonatomic,strong)NSString *liveBroadcastTagName;
@property(nonatomic,strong)UIButton *backbutton;//返回
@property(nonatomic,strong)UIButton *sharebutton;//分享
@property(nonatomic,strong)UITableView *livetableView;//列表
@property(nonatomic,strong)NSMutableArray *livedataArray;
@property(nonatomic,strong)NSArray *liveSectionArray;
@property(nonatomic,strong)CMTLive *liveinfo;
@property(nonatomic,strong)CMTLive *topmessage;
@property(nonatomic,strong)NSString *isOfficial;
@property (strong, nonatomic) NSString *shareTitle;                             // 分享title
@property (strong, nonatomic) NSString *shareBrief;                             // 分享brief
@property (strong, nonatomic) NSString *shareUrl;
@property(strong,nonatomic)NSIndexPath *indexpath;

@end

@implementation CMTLiveTagFilterViewController

-(NSMutableArray*)livedataArray{
    if (_livedataArray==nil) {
        _livedataArray=[[NSMutableArray alloc]init];
    }
    return _livedataArray;
}

-(UIButton*)backbutton{
    if (_backbutton==nil) {
        _backbutton=[[UIButton alloc]initWithFrame:CGRectMake(10, 20, 30, 30)];
        [_backbutton setImage:IMAGE(@"liveback") forState:UIControlStateNormal];
        _backbutton.showsTouchWhenHighlighted=NO;
        _backbutton.adjustsImageWhenHighlighted=NO;
        [_backbutton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backbutton;
}
-(UIButton*)sharebutton{
    if (_sharebutton==nil) {
        _sharebutton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-40, 20, 30, 30)];
        [_sharebutton setImage:IMAGE(@"liveShare") forState:UIControlStateNormal];
        [_sharebutton addTarget:self action:@selector(CMTShareAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sharebutton;
}


-(UITableView*)livetableView{
    if (_livetableView==nil) {
        _livetableView=[[UITableView alloc]init];
        _livetableView.backgroundColor = COLOR(c_efeff4);
        _livetableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _livetableView.dataSource = self;
        _livetableView.delegate = self;
        [_livetableView registerClass:[CMTCaseListCell class]forCellReuseIdentifier:CMTCellLiveCellIdentifier];
        [self.contentBaseView addSubview:_livetableView];
        
        
    }
    return _livetableView;
}


#pragma 返回
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(instancetype)initWithlive:(CMTLive*)live
         liveBroadcastTagId:(NSString *)liveBroadcastTagId
       liveBroadcastTagName:(NSString *)liveBroadcastTagName{
    self=[super init];
    if (self) {
        self.mylive=live;
        self.liveBroadcastTagId = liveBroadcastTagId;
        self.liveBroadcastTagName = liveBroadcastTagName;
        self.isOfficial=@"0";
        self.shareBrief=live.shareDesc;
        self.shareTitle=live.name;
        self.shareUrl=live.sharePic.picFilepath;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"LiveList willDeallocSignal");
    }];
    
    self.titleText = self.liveBroadcastTagName;
    
    //绘制导航条
    [self CmtLivePullToRefresh];
    [self CmtLiveIniteRefresh];
    //绘制列表
    self.livetableView.frame=CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide);
    [self.contentBaseView addSubview:self.livetableView];
    //发帖按钮
    
    //跳立方
    [self setContentState:CMTContentStateLoading moldel:@"1"];
    [self CmtGetLiveData];
    
}

-(void)reloadCaselistData:(CMTAddPost*)newCase{

    NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:newCase.liveBroadcastMessage, nil];
    [array addObjectsFromArray:[self.livedataArray copy]];
    self.livedataArray=[array mutableCopy];
    [self setCacheLiveList:[self.livedataArray copy]];
    [self.livetableView reloadData];
}

#pragma 判断发帖按钮是否隐藏
-(BOOL)isHiddenpostbutton{
    BOOL ishidden=NO;
    if (self.mylive.outOfDate.boolValue) {
        ishidden=YES;
    }else if(self.mylive.participationLimit.boolValue){
        if (!CMTUSER.login) {
            ishidden=YES;
        }else if(!self.mylive.isOfficial.boolValue){
            ishidden=YES;
        }
    }
    return ishidden;
}

#pragma 初次加载
-(void)CmtGetLiveData{
    
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"liveBroadcastId":self.mylive.liveBroadcastId ?: @"",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"liveBroadcastTagId":self.liveBroadcastTagId?:@"0",
                           @"pageSize":@"30",
                           @"sortOrder":self.mylive.outOfDate?:@"",
                           @"isOfficial":self.isOfficial?:@"",
                           
                           };
    @weakify(self);
    [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
        @strongify(self);
        self.liveinfo=LiveListData.liveInfo;
        
        self.shareBrief=LiveListData.liveInfo.shareDesc;
        self.shareTitle=LiveListData.liveInfo.name;
        self.shareUrl=LiveListData.liveInfo.sharePic.picFilepath;
        self.isOfficial=LiveListData.liveInfo.isOfficial;
        self.topmessage=LiveListData.topMessage;
        self.livedataArray=[LiveListData.liveMessageList mutableCopy];
        [self setCacheLiveList:[self.livedataArray copy]];
        [self.livetableView reloadData];
        [self setContentState:CMTContentStateNormal];
        [self stopAnimation];
        
        
    }error:^(NSError *error) {
        [self setContentState:CMTContentStateReload moldel:@"1"];
        CMTLog(@"刷新失败");
    }];
    
    
}
#pragma 重新加载
-(void)reloaddata{
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           @"liveBroadcastId":self.mylive.liveBroadcastId ?: @"",
                           @"incrId":@"0",
                           @"incrIdFlag":@"0",
                           @"liveBroadcastTagId":self.liveBroadcastTagId?:@"0",
                           @"pageSize":@"30",
                           @"sortOrder":self.mylive.outOfDate,
                           @"isOfficial":self.isOfficial,
                           
                           };
    @weakify(self);
    [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
        @strongify(self);
        self.liveinfo=LiveListData.liveInfo;
        
        self.shareBrief=LiveListData.liveInfo.shareDesc;
        self.shareTitle=LiveListData.liveInfo.name;
        self.shareUrl=LiveListData.liveInfo.sharePic.picFilepath;
        self.isOfficial=LiveListData.liveInfo.isOfficial;
        self.topmessage=LiveListData.topMessage;
        self.livedataArray=[LiveListData.liveMessageList mutableCopy];
        [self setCacheLiveList:[self.livedataArray copy]];
        [self.livetableView reloadData];
        [self setContentState:CMTContentStateNormal];
        [self stopAnimation];
        
        
    }error:^(NSError *error) {
        
        CMTLog(@"刷新失败");
    }];
    
}

#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self CmtGetLiveData];
}


#pragma 下拉刷新
-(void)CmtLivePullToRefresh{
    @weakify(self);
    [self.livetableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        NSDictionary *dic=[self.liveSectionArray firstObject];
        CMTLive *live=[[CMTLive alloc]init];
        if ([(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count]>0) {
            live=[(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]firstObject];
        }
        
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"liveBroadcastId":self.mylive.liveBroadcastId ?: @"",
                               @"incrId":live.incrId?:@"0",
                               @"incrIdFlag":@"0",
                               @"liveBroadcastTagId":self.liveBroadcastTagId?:@"0",
                               @"pageSize":@"30",
                               @"sortOrder":self.mylive.outOfDate,
                               @"isOfficial":self.isOfficial,
                               
                               };
        
        [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
            @strongify(self);
            if([LiveListData.liveMessageList count]>0){
                self.liveinfo=LiveListData.liveInfo;

                self.topmessage=LiveListData.topMessage;
                NSMutableArray *array=[LiveListData.liveMessageList mutableCopy];
                [array addObjectsFromArray:[self.livedataArray copy]];
                self.livedataArray=array;
                [self setCacheLiveList:[self.livedataArray copy]];
                [self.livetableView reloadData];
            }else{
                self.mToastView.frame=CGRectMake(self.mToastView.left, CMTNavigationBarBottomGuide, self.mToastView.width, self.mToastView.height);
                [self toastAnimation:@"没有最新发帖"];
            }
            [self.livetableView.pullToRefreshView stopAnimating];
            
        }error:^(NSError *error) {
            [self.livetableView.pullToRefreshView stopAnimating];
            CMTLog(@"刷新失败");
        }];
        
        
    }];
    
}
#pragma 上拉翻页
-(void)CmtLiveIniteRefresh{
    @weakify(self);
    [self.livetableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        NSDictionary *dic=[self.liveSectionArray lastObject];
        CMTLive *live=[[CMTLive alloc]init];
        if ([(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count]>0) {
            live=[(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]lastObject];
        }
        
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"liveBroadcastId":self.mylive.liveBroadcastId ?: @"",
                               @"incrId":live.incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"liveBroadcastTagId":self.liveBroadcastTagId?:@"0",
                               @"pageSize":@"30",
                               @"sortOrder":self.mylive.outOfDate,
                               @"isOfficial":self.isOfficial,
                               
                               };
        
        
        [[[CMTCLIENT getLive_info:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLiveListData *LiveListData) {
            @strongify(self);
            if([LiveListData.liveMessageList count]>0){
                [self.livedataArray addObjectsFromArray:LiveListData.liveMessageList];
                [self setCacheLiveList:[self.livedataArray copy]];
                [self.livetableView reloadData];
            }else{
                self.mToastView.frame=CGRectMake(self.mToastView.left, CMTNavigationBarBottomGuide, self.mToastView.width, self.mToastView.height);
                [self toastAnimation:@"没有更多发帖"];
            }
            [self.livetableView.infiniteScrollingView stopAnimating];
        }error:^(NSError *error) {
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", error);
            [self.livetableView.infiniteScrollingView stopAnimating];
            
            CMTLog(@"刷新失败");
        }];
        
        
    }];
    
}
// 直播列表 分组 排序 显示
- (void)setCacheLiveList:(NSArray *)cachePostList {
    
    for (CMTLive *live in self.livedataArray) {
        if(nil != live){
            live.topFlag = @"0";
        }
    }

    @try {
        // 按incrId排序
        // 按创建时间分组
        NSMutableArray *postSections = [NSMutableArray array];
        
        int index = 0;
        for (CMTLive *live in self.livedataArray) {
            // 获取当前条目的创建时间
            NSString *createTime = DATE(live.createTime);
            if (BEMPTY(createTime)) {
                [self handleErrorMessage:@"PostList Group PostList: %@\nError: Empty CreateTime at Index: [%d]", self.livedataArray, index];
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
                [postArray addObject:live];
            }
            // 未找到该分组 则创建新分组
            else {
                NSMutableDictionary *postSection = [NSMutableDictionary dictionary];
                NSMutableArray *postArray = [NSMutableArray array];
                postSection[CMTPostListSectionPostDateKey] = createTime;
                postSection[CMTPostListSectionPostArrayKey] = postArray;
                [postArray addObject:live];
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
            self.liveSectionArray = [NSArray arrayWithArray:postSections];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.topmessage.createUserId==nil) {
        return [self.liveSectionArray count];
    }else{
        return [self.liveSectionArray count]+1;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CMTTableSectionHeader *header = [CMTTableSectionHeader headerWithHeaderWidth:tableView.width
                                                                    headerHeight: 25.0 isneedbuttomLine:NO];
    if (self.topmessage.createUserId!=nil) {
        
        
        header.title = section==0?@"":[[self.liveSectionArray objectAtIndex:section-1]objectForKey:CMTPostListSectionPostDateKey];
        
        
    }else{
        header.title = [[self.liveSectionArray objectAtIndex:section]objectForKey:CMTPostListSectionPostDateKey];
        
    }
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.topmessage.createUserId==nil) {
        return 25.0;
    }else{
        if (section==0) {
            return 0;
        }else{
            return 25.0;
        }
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.topmessage.createUserId==nil) {
        NSDictionary *dic=[self.liveSectionArray objectAtIndex:section];
        return [(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count];
        
    }else{
        if (section==0) {
            return 1;
        }else{
            NSDictionary *dic=[self.liveSectionArray objectAtIndex:section-1];
            return [(NSArray*)[dic objectForKey:CMTPostListSectionPostArrayKey]count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTCaseListCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellLiveCellIdentifier];
    if(cell==nil){
        cell=[[CMTCaseListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
    }
    CMTLive *live=nil;
    if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:indexPath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row];
    }else{
        live=indexPath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexPath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row] ;
    }
    cell.lastController=self;
    cell.delegate=self;
    cell.isShowinteractive = false;
    [cell reloadLiveCell:live index:indexPath];
    return cell;
    
}

#pragma 点击评论
-(void)CMTClickComments:(NSIndexPath*)indexPath{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        CMTLive *live=nil;
        if (self.topmessage.createUserId==nil) {
            live=[[[self.liveSectionArray objectAtIndex:indexPath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row];
        }else{
            live=indexPath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexPath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row] ;
        }
    }
}
#pragma 点赞
-(void)CMTSomePraise:(BOOL)ISCancelPraise index:(NSIndexPath*)indexpath{
    if (!CMTUSER.login ) {
        CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
        loginVC.nextvc = kComment;
        [self.navigationController pushViewController:loginVC animated:YES];
    }else{
        CMTLive *live=nil;
        if (self.topmessage.createUserId==nil) {
            live=[[[self.liveSectionArray objectAtIndex:indexpath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexpath.row];
        }else{
            live=indexpath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexpath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexpath.row] ;
        }
        if (live.isPraise.boolValue) {
            return;
        }
        @weakify(self)
        NSDictionary *params=@{
                               @"userId":CMTUSERINFO.userId ?:@"0",
                               @"liveBroadcastMessageId":live.liveBroadcastMessageId?:@"",
                               };
        
        [[[CMTCLIENT live_message_praise:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            @strongify(self)
            
            [self changepost:live];
            live.isPraise=@"1";
            live.praiseCount=[@"" stringByAppendingFormat:@"%ld", (long)(live.praiseCount.integerValue+1)];
            [self.livetableView reloadData];
            
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
#pragma 更多分享
-(void)CmtLiveMore:(NSIndexPath *)indexPath{
    self.indexpath=indexPath;
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享", @"删除", nil];
    actionSheet.tag = 99;
    [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    CMTLive *live=nil;
    if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:self.indexpath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:self.indexpath.row];
    }else{
        live=self.indexpath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:self.indexpath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:self.indexpath.row] ;
    }
    
    if (buttonIndex==0) {
        self.shareUrl=live.liveBroadcastMessageShareUrl;
        self.shareBrief=live.content;
        [self CMTShareAction:nil];
        
    }else if (buttonIndex==1){
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?:@"0",
                               @"liveBroadcastMessageId":live.liveBroadcastMessageId ?: @"",
                               
                               };
        
        [[[CMTCLIENT deleteLive_message:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            if (self.topmessage.createUserId==nil) {
                [self.livedataArray removeObject:live];
                [self setCacheLiveList:[self.livedataArray copy]];
            }else{
                if (self.indexpath.section==0) {
                    self.topmessage=nil;
                }else{
                    [self.livedataArray removeObject:live];
                    [self setCacheLiveList:[self.livedataArray copy]];
                }
            }
            [self.livetableView reloadData];
            
            
        } error:^(NSError *error) {
            CMTLog(@"删除失败");
            
        } completed:^{
            
        }];
        
    }
}


//改变文章对象
-(void)changepost:(CMTLive*)live{
    CMTParticiPators *part=[[CMTParticiPators alloc]init];
    part.userId=CMTUSER.userInfo.userId;
    part.nickname=CMTUSER.userInfo.nickname;
    part.picture=CMTUSER.userInfo.picture;
    part.opTime=TIMESTAMP;
    NSMutableArray *mutable=[[NSMutableArray alloc]initWithObjects:part, nil];
    NSMutableArray *muale2=[[NSMutableArray alloc ]initWithArray:live.praiseUserList];
    NSMutableArray *partArray=[live.praiseUserList mutableCopy];
    for (int i=0;i<[partArray count];i++) {
        CMTParticiPators *CMTpart=[partArray objectAtIndex:i];
        if ([CMTpart.userId isEqualToString:part.userId]&&CMTpart.userType.integerValue==0) {
            [muale2 removeObject:CMTpart];
        }
    }
    [mutable addObjectsFromArray:muale2];
    live.praiseUserList=mutable;
}


#pragma 分享
-(void)CMTClickShare:(NSIndexPath *)indexPath{
    CMTLive *live=nil;
    if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:indexPath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row];
    }else{
        live=indexPath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexPath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row] ;
    }
    self.shareUrl=live.liveBroadcastMessageShareUrl;
    self.shareBrief=live.content;
    [self CMTShareAction:nil];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CMTLive *live=nil;
    if (self.topmessage.createUserId==nil) {
        live=[[[self.liveSectionArray objectAtIndex:indexPath.section]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row];
    }else{
        live=indexPath.section==0?self.topmessage:[[[self.liveSectionArray objectAtIndex:indexPath.section-1]objectForKey:CMTPostListSectionPostArrayKey]objectAtIndex:indexPath.row] ;
    }
    
    live.liveBroadcastId = self.liveinfo.liveBroadcastId;
    live.outOfDate = self.liveinfo.outOfDate;
    live.liveBroadcastName = self.liveinfo.name;
    live.sharePic = self.liveinfo.sharePic;
    live.userName = self.liveinfo.userName;
    live.userPic = self.liveinfo.userPic;
    CMTLiveDetailViewController *liveDetailViewController = [[CMTLiveDetailViewController alloc] initWithLiveDetail:live
                                                                                                     liveDetailType:CMTLiveDetailTypeLiveList];
    [self.navigationController pushViewController:liveDetailViewController animated:YES];
}
#pragma 视图消失
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
// 分享处理方法 add byguoyuanchao
- (void)CMTShareAction:(UIButton*)sender{
    if (sender!=nil) {
        self.shareBrief=self.liveinfo.shareDesc;
        self.shareTitle=self.liveinfo.name;
        self.shareUrl=self.liveinfo.sharePic.picFilepath;
    }
    [self.mShareView.mBtnFriend addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.cancelBtn addTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    // 自定义分享
    [self shareViewshow:self.mShareView bgView:self.tempView currentViewController:self.navigationController];
}

- (void)showShare:(UIButton *)btn
{
    [self methodShare:btn];
}

///平台按钮关联的分享方法
- (void)methodShare:(UIButton *)btn {
    self.liveinfo.shareModel=@"0";
    self.liveinfo.shareServiceId=self.liveinfo.liveBroadcastId;
    // 没有网络连接
    if (!NET_WIFI && !NET_CELL && btn.tag != 5555) {
        [self toastAnimation:@"你的网络不给力"];
        [self shareViewDisapper];
        return;
    }
    
    NSString *shareType = nil;
    switch (btn.tag)
    {
        case 1111:
        {
            if ([self respondsToSelector:@selector(friendCircleShare)]) {
                [self performSelector:@selector(friendCircleShare) withObject:nil afterDelay:0.20];
            }
            
        }
            break;
        case 2222:
        {
            if ([self respondsToSelector:@selector(weixinShare)]) {
                [self performSelector:@selector(weixinShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 3333:
        {
            shareType = @"3";
            if ([self respondsToSelector:@selector(weiboShare)]) {
                [self performSelector:@selector(weiboShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 4444:
        {
            CMTLog(@"邮件");
            shareType = @"4";
            NSString *pContent = [NSString stringWithFormat:@"#壹生#《%@》%@ <br>来自@壹生 <br>", self.shareTitle , self.shareUrl];
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:self.shareTitle sharetext:pContent sharetype:shareType sharepic:self.mylive.sharePic.picFilepath shareUrl:self.shareUrl StatisticalType:@"getShareLive" shareData:self.liveinfo];
        }
            break;
        case 5555:
            [self shareViewDisapper];
            break;
        default:
            CMTLog(@"其他分享");
            break;
    }
    if ([self respondsToSelector:@selector(removeTargets)]) {
        [self performSelector:@selector(removeTargets) withObject:nil afterDelay:0.2];
    }
    
    [self shareViewDisapper];
}
- (void)removeTargets
{
    [self.mShareView.mBtnFriend removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix removeTarget:self action:@selector(showShare:) forControlEvents:UIControlEventTouchUpInside];
}
/// 朋友圈分享
- (void)friendCircleShare
{
    NSString *shareType = @"1";
    CMTLog(@"朋友圈");
    
    NSString *shareText =self.shareTitle;
   [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.mylive.sharePic.picFilepath shareUrl:self.shareUrl StatisticalType:@"getShareLive" shareData:self.mylive];    
}
/// 微信好友分享
- (void)weixinShare
{
    NSString *shareType = @"2";
    NSString *shareTitle = self.shareTitle;
    NSString *shareText = self.shareBrief;
    NSString *shareURL = self.shareUrl;
    if (BEMPTY(shareText)) {
        shareText =@"壹生文章分享";
    }
    CMTLog(@"微信好友\nshareTitle: %@\nshareText: %@\nshareURL: %@", shareTitle, shareText, shareURL);
   [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.liveinfo.sharePic.picFilepath shareUrl:shareURL StatisticalType:@"getShareLive" shareData:self.liveinfo];}

- (void)weiboShare
{
    NSString *shareType=@"3";
    NSString *shareText = [NSString stringWithFormat:@"#%@# %@。%@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY,self.shareTitle,self.shareUrl];
    
    CMTLog(@"新浪文博\nshareText:%@", shareText);
    [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.liveinfo.sharePic.picFilepath shareUrl:self.shareUrl StatisticalType:@"getShareLive" shareData:self.liveinfo];

}

@end
