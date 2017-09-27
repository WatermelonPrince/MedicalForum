//
//  CMTCollectionViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/27.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


#import "CMTCollectionViewController.h"
#import "CMTSearchTableViewCell.h"
#import "CMTPostDetailCenter.h"
#import "CMTCollectViewCell.h"
#import "CMTVideoCollectionViewCell.h"
///下拉刷新收藏同步
#import "CMTBindingViewController.h"
#import "CMTLightVideoViewController.h"
#import "CMTRecordedViewController.h"
#import "CMTDeleteView.h"

///自定义分享视图
#import "CMTShareView.h"
#import "CMTBaseViewController+CMTExtension.h"

@interface CMTCollectionViewController ()<UIAlertViewDelegate,UIGestureRecognizerDelegate,CMTCollectViewCellDelegate>

@property (nonatomic, strong)UIView *switchBgView;
@property (nonatomic, strong)UIButton *videoButton;
@property (nonatomic, strong)UIButton *messageButton;
@property (nonatomic, strong)UIView *lineView;


@property (strong, nonatomic) UILongPressGestureRecognizer *mLongPressGesture;
@property (strong, nonatomic) UIAlertView *mAlertView;

@property (assign) NSInteger mDelObjIndex;
@property (assign) NSInteger lastObj;
@property (strong, nonatomic) UIButton *mBtnLogin;

@property (strong, nonatomic) NSArray *mArrAllCollections;


@property (assign) int pullCount;

@property (nonatomic, assign) BOOL animationShown;

@property (assign)BOOL isVideo;

@property (nonatomic, strong)UIBarButtonItem *rightItem;

@property (nonatomic, strong)UIView *footerView;
@property (nonatomic,assign)BOOL isCheckAll;
@property (nonatomic, copy)NSString *totalNum;//视频收藏总数
@property (nonatomic, strong)CMTDeleteView *deleteView;

@property (nonatomic, assign)NSInteger deleteCount;//批量删除数目


@end

@implementation CMTCollectionViewController

-(CMTDeleteView*)deleteView{
    if(_deleteView==nil){
        _deleteView=[[CMTDeleteView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
        _deleteView.backgroundColor = ColorWithHexStringIndex(c_ffffff);
        _deleteView.layer.shadowOffset = CGSizeMake(0, -1);
        _deleteView.layer.shadowColor = ColorWithHexStringIndex(c_32c7c2).CGColor;
        _deleteView.layer.shadowOpacity = 0.5;
        _deleteView.hidden=YES;
        [_deleteView.deleteButton addTarget:self action:@selector(selectDelete:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteView.checkAllButton addTarget:self action:@selector(selectAll:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentBaseView addSubview:_deleteView];
    }
    return _deleteView;
}


- (void)configureFooterView{
    [self.contentBaseView addSubview:self.deleteView];
    
}
- (UIBarButtonItem *)rightItem{
    if (!_rightItem) {
        _rightItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editTableView:)];
    }
    return _rightItem;
}

- (UIButton *)mBtnLogin
{
    if (!_mBtnLogin)
    {
        _mBtnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        _mBtnLogin.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50);
        _mBtnLogin.backgroundColor = COLOR(c_32c7c2);
        [_mBtnLogin setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        _mBtnLogin.titleLabel.font = FONT(18);
        [_mBtnLogin setTitle:@"登录，同步收藏信息" forState:UIControlStateNormal];
        [_mBtnLogin addTarget:self action:@selector(synchronizationStore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mBtnLogin;
}
- (NSArray *)mArrAllCollections{
    if (!_mArrAllCollections) {
        _mArrAllCollections = [NSArray array];
    }
    return _mArrAllCollections;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    self.navigationItem.rightBarButtonItem = self.rightItem;
    [self.navigationItem.rightBarButtonItem setTintColor:ColorWithHexStringIndex(c_32c7c2)];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CollectionViewController willDeallocSignal");
    }];
    
    [self.mShareView.mBtnFriend addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnSina addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnWeix addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.mBtnMail addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.mShareView.cancelBtn addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentBaseView addSubview:self.switchBgView];
    [self.switchBgView addSubview:self.videoButton];
    [self.switchBgView addSubview:self.messageButton];
    [self.switchBgView addSubview:self.lineView];
    self.isVideo = YES;
    self.pullCount = 0;
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    self.titleText = @"我的收藏";
    
    [self.mLbNoCollection setText:@"还没有添加收藏"];
    [self.contentBaseView addSubview:self.mLbNoCollection];
    // 1.8.5版本开始 不显示无收藏图标
//    [self.view addSubview:self.mNoCollectionImageView];
     [self.contentBaseView addSubview:self.mCollectTableView];
    //同步按钮
    [self.view addSubview:self.mBtnLogin];
    /*添加手势*/
    //[self.mCollectTableView addGestureRecognizer:self.mLongPressGesture];
    
    //配置footView;
    [self configureFooterView];
    [self getVideoCollectionList];
    @weakify(self);
    [self.mCollectTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        if (self.isVideo) {
            [self videoinfinToGetMore];
        }else{
            [self infinToGetMore:nil];
 
        }
        
    }];
}
#pragma mark __计算要删除的收藏个数
- (void)getDeletNumber{
    self.deleteCount = 0;
    if (_isVideo){
        for (CMTLivesRecord *obj in self.mArrVideos) {
            if (obj.isSelected) {
                self.deleteCount++;
            }
        }
    }else{
        for (CMTStore *obj in self.mArrShowConllections) {
            if (obj.isSelected) {
                self.deleteCount++;
            }
        }
    }
}

- (void) videoinfinToGetMore{
    CMTLivesRecord *Record=[[CMTLivesRecord alloc]init];
    Record.pageOffset=@"0";
    if(self.mArrVideos.count>0){
        Record=self.mArrVideos.lastObject;
    }
    NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                          @"pageOffset":Record.pageOffset,
                          @"pageSize":@"30",
                          @"incrIdFlag":@"1",
                          };
    @weakify(self);
    [[[CMTCLIENT CMTGetCollectionVideo:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList* data) {
        @strongify(self);
        NSArray *arr = [data.storeData mutableCopy];
        if (arr.count==0) {
            [self toastAnimation:@"没有更多课程"];
        }else{
            [self.mArrVideos addObjectsFromArray:arr];
            self.totalNum = data.totalNum;
            if (_isCheckAll) {
                for (CMTLivesRecord *obj in self.mArrVideos) {
                    obj.isSelected = YES;
                }
                //重新统计删除后面的数据
                NSString *title = [NSString stringWithFormat:@"删除（%ld）",data.totalNum.integerValue];
                [self.deleteView.deleteButton setTitle:title forState:UIControlStateNormal];
            }
        }
         [self.mCollectTableView reloadData];
        [self.mCollectTableView.infiniteScrollingView stopAnimating];
        
    } error:^(NSError *error) {
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            @strongify(self);
            [self toastAnimation:@"你的网络不给力"];
            
        }else{
            @strongify(self);
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
        [self.mCollectTableView.infiniteScrollingView stopAnimating];
        
    } completed:^{
        NSLog(@"完成");
    }];
}

- (void) infinToGetMore:(id)sender
{
    CMTLog(@"上拉刷新");
    
     self.mCollectTableView.infiniteScrollingView.hidden = NO;
    CMTLog(@"%@",NSStringFromCGPoint(self.mCollectTableView.contentOffset));
    if(self.mCollectTableView.contentOffset.y < 0)
    {
        //self.mCollectTableView.infiniteScrollingView.hidden = YES;
        [self.mCollectTableView.infiniteScrollingView stopAnimating];
        
    }
    if (self.mCollectTableView.contentOffset.y > 0)
    {
        [self.mCollectTableView.infiniteScrollingView startAnimating];
        if (self.mArrCollections.count <= 30)
        {
            CMTLog(@"没有更多");
            [self toastAnimation:@"没有更多收藏"];
        }
        else
        {
            if (self.mArrShowConllections.count == self.mArrCollections.count)
            {
                [self toastAnimation:@"没有更多收藏"];
                
            }
            
            for (int i = 0; i < 30; i++)
            {
                if (self.lastObj < self.mArrCollections.count)
                {
                    [self.mArrShowConllections addObject:[self.mArrCollections objectAtIndex:self.lastObj]];
                    self.lastObj++;
                }
                else
                {
                    CMTLog(@"没有更多");
                    break;
                }
            }
            if (_isCheckAll) {
                for (CMTStore *obj in self.mArrShowConllections) {
                    obj.isSelected = YES;
                }
                //重新统计删除后面的数据
                NSString *title = [NSString stringWithFormat:@"删除（%ld）",self.mArrCollections.count];
                [self.deleteView.deleteButton setTitle:title forState:UIControlStateNormal];
            }
           
            
            
            @try {
                if([self.mArrShowConllections respondsToSelector:@selector(sortedArrayUsingComparator:)])
                {
                    [self.mArrShowConllections sortUsingComparator:^NSComparisonResult(CMTStore *store1, CMTStore *store2) {
                        NSComparisonResult result = [store2.opTime compare:store1.opTime] ;
                        return result;
                    }];
                }
            }
            @catch (NSException *exception) {
                
            }
            
        }
       
    }
    [self.mCollectTableView reloadData];
    
    [self.mCollectTableView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1.0];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.lastObj = 0;
    [super viewWillAppear:animated];
    if (self.isLeftEnter || [[NSUserDefaults standardUserDefaults]boolForKey:@"firstLogin_collection"])
    {
        self.mCollectTableView.hidden = YES;
        @try {
            if (self.mArrCollections.count > 0)
            {
                [self.mArrCollections removeAllObjects];
            }
            if (self.mArrShowConllections.count > 0)
            {
                [self.mArrShowConllections removeAllObjects];
            }
            
        }
        @catch (NSException *exception) {
            CMTLog(@"remove self.mArrCollections error");
        }
        
        NSArray *tempCacheCollection = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST];
        if ([tempCacheCollection respondsToSelector:@selector(count)] && tempCacheCollection.count > 0) {
            if (self.animationShown == NO) {
                self.animationShown = YES;
//                [self runAnimationInPosition:self.view.center];
            }
        }
        else {
            self.animationShown = NO;
        }
    }
    self.mBtnLogin.hidden = YES;
    self.mArrAllCollections = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST];    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self stopAnimation];
    if (self.isLeftEnter == YES || [[NSUserDefaults standardUserDefaults]boolForKey:@"firstLogin_collection"])
    {
        // 列表滚动到列表顶部
        [self.mCollectTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [self dataLoad];
    }
}

- (void)dataLoad
{
    //本地数据
    if([[NSFileManager defaultManager]fileExistsAtPath:PATH_COLLECTIONLIST])
    {
        CMTLog(@"发现收藏列表,从本地加载");
        // 获取到本地数据根据时间排序
        NSMutableArray *pArr = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST];
        if ([pArr respondsToSelector:@selector(sortedArrayUsingComparator:)])
        {
            [pArr sortUsingComparator:^NSComparisonResult(CMTStore *store1, CMTStore *store2) {
                NSComparisonResult result = [store2.opTime compare:store1.opTime];
                return result;
            }];
            [self.mArrCollections removeAllObjects];
            [self.mArrCollections addObjectsFromArray:pArr];
        }
        if (self.mArrCollections.count <= 30)
        {
            self.lastObj = self.mArrCollections.count;
            self.mArrShowConllections = [self.mArrCollections mutableCopy];
        }
        else
        {
            for (int i = 0 ; i < 30; i++)
            {
                [self.mArrShowConllections addObject:[self.mArrCollections objectAtIndex:i]];
            }
            self.lastObj = 30;
        }

        if ([self.mCollectTableView respondsToSelector:@selector(reloadData)])
        {
            [self.mCollectTableView performSelector:@selector(reloadData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
        }
    }
    else
    {
        CMTLog(@"没有收藏数据");
        self.mNoCollectionImageView.hidden = NO;
//        self.mLbNoCollection.hidden = NO;
//        self.mCollectTableView.hidden = YES;
    }
}


- (void)popViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (UIImageView *)mNoCollectionImageView
{
    if (!_mNoCollectionImageView)
    {
        _mNoCollectionImageView = [[UIImageView alloc]initWithImage:IMAGE(@"collection")];
        [_mNoCollectionImageView setFrame:CGRectMake(138*RATIO, 190, 45, 45)];
        _mNoCollectionImageView.centerX = self.view.centerX;
    }
    return _mNoCollectionImageView;
}
- (UILabel *)mLbNoCollection
{
    if (!_mLbNoCollection)
    {
        _mLbNoCollection = [[UILabel alloc]initWithFrame:CGRectMake(0, 259, SCREEN_WIDTH, 30)];
        _mLbNoCollection.textAlignment = NSTextAlignmentCenter;
        _mLbNoCollection.centerX = self.view.centerX;
        [ _mLbNoCollection setTextColor:[UIColor colorWithHexString:@"#c8c8c8"]];
        [ _mLbNoCollection setFont:[UIFont systemFontOfSize:20]];
    }
    return _mLbNoCollection;
}

- (NSMutableArray *)mArrCollections
{
    if (!_mArrCollections)
    {
        _mArrCollections = [[NSMutableArray alloc]init];
    }
    return _mArrCollections;
}

- (NSMutableArray *)mArrVideos{
    if (!_mArrVideos) {
        _mArrVideos = [NSMutableArray array];
    }
    return _mArrVideos;
}

- (NSMutableArray *)mArrShowConllections
{
    if (!_mArrShowConllections)
    {
        _mArrShowConllections = [NSMutableArray array];
    }
    return _mArrShowConllections;
}


- (UIView *)switchBgView{
    if (!_switchBgView) {
        _switchBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 46)];
        _switchBgView.backgroundColor = COLOR(c_f5f5f5);
    }
    return _switchBgView;
}
- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = ColorWithHexStringIndex(c_32c7c2);
        _lineView.frame = CGRectMake(0, self.videoButton.bottom, SCREEN_WIDTH/2, 2);
    }
    return _lineView;
}

- (UIButton *)videoButton{
    if (!_videoButton) {
        _videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoButton.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, 44);
        [_videoButton setTitle:@"课程" forState:UIControlStateNormal];
        _videoButton.titleLabel.font=FONT(15);
        [_videoButton setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateSelected];
        [_videoButton setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
        [_videoButton addTarget:self action:@selector(switchVideo) forControlEvents:UIControlEventTouchUpInside];
        _videoButton.selected = YES;
        [MobClick event:@"B_MIne_Collection"];
        
    }
    return _videoButton;
}

- (UIButton *)messageButton{
    if (!_messageButton) {
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _messageButton.frame = CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 44);
        [_messageButton setTitle:@"资讯" forState:UIControlStateNormal];
        _messageButton.titleLabel.font=FONT(15);
        [_messageButton setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateSelected];
        [_messageButton setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
        [_messageButton addTarget:self action:@selector(switchMessage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageButton;
}

- (void)switchVideo{
    [MobClick event:@"B_MIne_Collection"];
    _lineView.frame = CGRectMake(0, self.videoButton.bottom, SCREEN_WIDTH/2, 2);
    self.videoButton.selected = YES;
    self.messageButton.selected = NO;
    self.isVideo = YES;
    [self noCollection:self.mArrVideos];
    [self.mCollectTableView reloadData];
   
}
- (void)switchMessage{
    //收藏
    [MobClick event:@"B_Favorite_MN"];
    _lineView.frame = CGRectMake(SCREEN_WIDTH/2, self.videoButton.bottom, SCREEN_WIDTH/2, 2);
    self.videoButton.selected = NO;
    self.messageButton.selected = YES;
    self.isVideo = NO;
    [self noCollection:self.mArrCollections];
    [self.mCollectTableView reloadData];
}


- (UITableView *)mCollectTableView
{
    if (!_mCollectTableView)
    {
        _mCollectTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.switchBgView.bottom, SCREEN_WIDTH, self.view.frame.size.height-self.switchBgView.bottom) style:UITableViewStylePlain];
        _mCollectTableView.delegate = self;
        _mCollectTableView.dataSource = self;
        _mCollectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction)];
                Swipe.numberOfTouchesRequired=1;
                Swipe.direction=UISwipeGestureRecognizerDirectionRight;
                [Swipe setDelaysTouchesBegan:YES];
                Swipe.delegate=self;
             [_mCollectTableView addGestureRecognizer:Swipe];
        _mCollectTableView.placeholderView=[self tableViewPlaceholderView:_mCollectTableView text:@"还没有添加收藏"];


    }
    return _mCollectTableView;
}

- (UIView *)tableViewPlaceholderView:(UITableView*)tableView text:(NSString*)text {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,tableView.width, tableView.height)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 145, SCREEN_WIDTH, 30)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = [UIColor colorWithHexString:@"#c8c8c8"];
    placeholderLabel.font = FONT(20);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text =text;
    
    [placeholderView addSubview:placeholderLabel];
    
    
    return placeholderView;
}
#pragma mark 返回
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UILongPressGestureRecognizer *)mLongPressGesture
{
    if (!_mLongPressGesture)
    {
        _mLongPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesturePressed:)];
    }
    return _mLongPressGesture;
}

- (UIAlertView *)mAlertView
{
    if (!_mAlertView)
    {
//        _mAlertView =[[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"删除" otherButtonTitles:@"提示",@"转发", nil];
        _mAlertView =[[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"转发",@"删除",@"取消", nil];
    }
    return _mAlertView;
}

#pragma mark初次加载请求课程收藏列表
//初次加载
- (void)getVideoCollectionList{
    [self setContentState:CMTContentStateLoading moldel:@"1" height:64];
    NSDictionary *params=@{
                           @"userId": CMTUSERINFO.userId ?:@"0",
                           
                           };
    @weakify(self);
    [[[CMTCLIENT CMTGetCollectionVideo:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList *data) {
        @strongify(self);
        [self.mArrVideos removeAllObjects];
        
        if (data.totalNum.integerValue > 0) {
            self.mArrVideos = [data.storeData mutableCopy];
            self.totalNum = data.totalNum;
        }
        if (self.isVideo) {
            [self noCollection:self.mArrVideos];
        }
        
        [self.mCollectTableView reloadData];
        [self setContentState:CMTContentStateNormal];
    }error:^(NSError *error) {
        [self setContentState:CMTContentStateReload];
//        [self setContentState:CMTContentStateNormal];

        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"无法连接到网络，请检查网络设置"];
        }else{
            [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
        }
        
    }];
}

- (void)animationFlash{
    [self getVideoCollectionList];
}


#pragma 登陆同步

- (void)synchronizationStore:(UIButton *)btn
{
    /*数据同步逻辑,界面跳转*/
    CMTBindingViewController *pBindVC = [CMTBindingViewController shareBindVC];
    [self.navigationController pushViewController:pBindVC animated:YES];
}


#pragma mark  long press

- (void)longPressGesturePressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.mCollectTableView];
        NSIndexPath *indexPath = [self.mCollectTableView indexPathForRowAtPoint:point];
        CMTLog(@"长按的分段为:%ld,长按的分行为；%ld",(long)indexPath.section,(long)indexPath.row);
        if(indexPath != nil)
        {
            self.mDelObjIndex = indexPath.row;
            id obj = [self.mArrCollections objectAtIndex:self.mDelObjIndex];
            CMTLog(@"%@",obj);
            /*删除或者分享数组中对应的元素*/
            [self.mAlertView show];
            /*自定义popView
            CGFloat xWidth = self.view.bounds.size.width - 20.0f;
            CGFloat yHeight = 272.0f;
            CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
            UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
            poplistview.delegate = self;
            poplistview.datasource = self;
            poplistview.listView.scrollEnabled = FALSE;
            //[poplistview setTitle:@"Share to"];
            [poplistview show];
             */
           
        }
    }
}

#pragma mark  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isVideo) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        __block CMTLivesRecord *Record=[self.mArrVideos objectAtIndex:indexPath.row];
        if([self getNetworkReachabilityStatus].integerValue==0){
            
            [self toastAnimation:@"无法连接到网络，请检查网络设置"];
            return;
        }else{
            if (Record.type.integerValue==1) {
                CMTLightVideoViewController *lightVideoViewController = [[CMTLightVideoViewController alloc]init];
                //  播放网络
                lightVideoViewController.myliveParam = Record;
                [lightVideoViewController setUpdateReadNumber:^(CMTLivesRecord *record) {
                    if (record == nil) {
                        NSMutableArray *arr = [NSMutableArray array];
                        [arr addObject:Record.dataId];
                        
                        [self DeleteVideoStoreWithArr:arr];

                    }else{
                        if (record.isrefresh) {
                            [self.mArrVideos removeObjectAtIndex:indexPath.row];
                            [self.mCollectTableView reloadData];
                        }
                      
                    }
                                    }];
                [self.navigationController pushViewController:lightVideoViewController animated:YES];
                
            }else{
                CMTRecordedViewController *recordView=[[CMTRecordedViewController alloc]initWithRecordedParam:[Record copy]];
                [recordView setUpdateReadNumber:^(CMTLivesRecord *record) {
                    if (record == nil) {
                        NSMutableArray *arr = [NSMutableArray array];
                        [arr addObject:Record.dataId];
                        
                        [self DeleteVideoStoreWithArr:arr];
                        
                    }else{
                        if (record.isrefresh) {
                            [self.mArrVideos removeObjectAtIndex:indexPath.row];
                            [self.mCollectTableView reloadData];
                        }
                        
                    }
                }];
                [self.navigationController pushViewController:recordView animated:YES];
                
            }
        }
        
    }else{
        NSInteger row = indexPath.row;
        @try {
            CMTStore *store = [self.mArrCollections objectAtIndex:row];
            if (!isEmptyString(store.groupId) && store.groupId != 0) {
                CMTGroup *group = [[CMTGroup alloc]init];
                group.groupId = store.groupId;
                CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:store.postId isHTML:store.isHTML postURL:store.url postModule:store.module group:group iscanShare:((store.postAttr.integerValue&32)==32) postDetailType:CMTPostDetailTypeFavoraites];
                postDetailCenter.path = indexPath;
                [self.navigationController pushViewController:postDetailCenter animated:YES];
            }else{
                CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:store.postId isHTML:store.isHTML postURL:store.url postModule:store.module group:nil iscanShare:((store.postAttr.integerValue&32)==32) postDetailType:CMTPostDetailTypeFavoraites];
                postDetailCenter.path = indexPath;
                [self.navigationController pushViewController:postDetailCenter animated:YES];
            }
            
        }
        @catch (NSException *exception) {
            CMTLog(@"no store  in self.mArrCollections");
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 87;
}
#pragma  mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isVideo) {
        static NSString *identifer  = @"videoCell";
        CMTVideoCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (!cell) {
            cell = [[CMTVideoCollectionViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
           
            
        }
        //视频删除单选
        @weakify(self);
        cell.updateSelectState=^(CMTLivesRecord *record){
            @strongify(self);
            if (_isCheckAll) {
                _isCheckAll = NO;
                self.deleteView.checkAllButton.selected = NO;
            }
            NSInteger count = 0;
            CMTLivesRecord *obj = record;
            obj.isSelected = !obj.isSelected;
            for (CMTLivesRecord *obj in self.mArrVideos) {
                if (obj.isSelected) {
                    count ++;
                }
            }
            if (count > 0) {
                if (count == self.mArrVideos.count) {
                    self.isCheckAll = YES;
                    self.deleteView.checkAllButton.selected = YES;
                }
                NSString *deleteTitle = [NSString stringWithFormat:@"删除（%ld）",count];
                [self.deleteView.deleteButton setTitle:deleteTitle forState:UIControlStateNormal];
            }else{
                [self.deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
                
            }
            
//            [self.mCollectTableView reloadData];
            [self.mCollectTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        };
            CMTLivesRecord *record = self.mArrVideos[indexPath.row];
            [cell reloadCellWithdate:@"0" model:record];
          cell.tapSlectedView.hidden = !self.mCollectTableView.editing;
        
        return cell;
    }else{
        static NSString *identifer  = @"cell";
        CMTCollectViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (!pCell)
        {
            pCell = [[CMTCollectViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        }
        pCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.mArrCollections.count > 0 && indexPath.row < self.mArrCollections.count)
        {
            if ([[self.mArrCollections objectAtIndex:indexPath.row]isKindOfClass:[CMTStore class]])
            {
                CMTStore *pStore = [self.mArrCollections objectAtIndex:indexPath.row];
                [pCell reloadCellWithModel:pStore NsIndexPath:indexPath];
                pCell.tag = indexPath.row;
                pCell.delegate = self;
               pCell.tapSlectedView.hidden = !tableView.editing;
                
            }
            pCell.separatorLine.hidden = NO;
            if (indexPath.row == self.mArrCollections.count - 1) {
                pCell.bottomLine.hidden = NO;
            }
            else
            {
                pCell.bottomLine.hidden = YES;
            }
        }
        
        return pCell;
    }
    
}

//删除视频
-(void)DeleteVideoStoreWithArr:(NSMutableArray *)arr{
    @weakify(self);
    [self setContentState:CMTContentStateLoading moldel:@"1" height:CMTNavigationBarBottomGuide];
    NSError *JSONSerializationError = nil;
    NSData *itemsJSONData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&JSONSerializationError];
    if (JSONSerializationError != nil) {
        CMTLogError(@"AppConfig Cached Theme Info JSONSerialization Error: %@", JSONSerializationError);
    }
    NSString *itemsJSONString = [[NSString alloc] initWithData:itemsJSONData encoding:NSUTF8StringEncoding];
    NSDictionary *param=@{ @"userId":CMTUSER.userInfo.userId?:@"0",
                           @"items":itemsJSONString?:@"",
                           @"isNeedReturnData":self.mArrVideos.count<30?@"30":@"0",
                           @"delType":self.isCheckAll?@"1":@"0"
                           };
    [[[CMTCLIENT CMTDeleteStoreVideoAction:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList *x) {
        @strongify(self);
        NSMutableArray *deleteArr = [NSMutableArray array];
        for (NSString *dataId in arr) {
            for (CMTLivesRecord *record in self.mArrVideos) {
                if ([record.dataId isEqualToString:dataId]) {
                    [deleteArr addObject:record];
                }
            }
            
        }
        [self.mArrVideos removeObjectsInArray:deleteArr];
        [self setContentState:CMTContentStateNormal];
        self.totalNum = x.totalNum;
        if (x.storeData.count > 0) {
            [self.mArrVideos addObjectsFromArray:[x.storeData mutableCopy]];
        }
        [self.mCollectTableView reloadData];
        if (self.mCollectTableView.editing) {
            //如果是编辑状态，关闭编辑状态
            [self editTableView:self.rightItem];
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力"];
        }else{
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
        [self.mCollectTableView reloadData];
        [self setContentState:CMTContentStateNormal];
    }];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isVideo) {
        return self.mArrVideos.count;
    }else{
        return self.mArrShowConllections.count;

    }
}

#pragma mark 删除

- (void)editTableView:(UIBarButtonItem *)button

{
    
//修改editing属性的值，进入或退出编辑模式
    
    [self setEditing:!self.mCollectTableView.editing animated:YES];
    
     if(self.mCollectTableView.editing){
        
       button.title = @"取消";
         self.videoButton.enabled = NO;
         self.messageButton.enabled = NO;
        
          }else{
        
       button.title = @"编辑";
       self.videoButton.enabled = YES;
       self.messageButton.enabled = YES;
        
    }
    
}


//编辑模式
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.mCollectTableView setEditing:editing animated:animated];
    if (self.mCollectTableView.editing) {
       
            self.deleteView.hidden = NO;
            self.mCollectTableView.height = self.mCollectTableView.height - 50;
        [self.mCollectTableView reloadData];

    } else {
            self.isCheckAll = NO;
            self.deleteView.hidden = YES;
            self.mCollectTableView.height = self.mCollectTableView.height + 50;
            [self.mCollectTableView reloadData];
        self.deleteView.checkAllButton.selected = NO;


        for (UITableViewCell *cell in self.mCollectTableView.visibleCells) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        for (CMTStore *obj in self.mArrCollections) {
            obj.isSelected = NO;
        }
        for ( CMTLivesRecord *obj in self.mArrVideos) {
            obj.isSelected = NO;
        }
        [self performSelector:@selector(EditEndRefresh) withObject:nil afterDelay:0.3f];
        [self.deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    }
}

- (void)EditEndRefresh {
    [self.mCollectTableView reloadData];
}

//cell代理
//单选

- (void)tapSelectedAction:(CMTStore *)model NsIndexPath:(NSIndexPath *)indexPath{
    if (_isCheckAll) {
        _isCheckAll = NO;
       self.deleteView.checkAllButton.selected = NO;
    }
    NSInteger count = 0;
    CMTStore *obj = model;
    obj.isSelected = !obj.isSelected;
    for (CMTStore *obj in self.mArrCollections) {
        if (obj.isSelected) {
            count ++;
        }
    }
    if (count > 0) {
        if (count == self.mArrCollections.count) {
            self.isCheckAll = YES;
            self.deleteView.checkAllButton.selected = YES;
        }
        NSString *deleteTitle = [NSString stringWithFormat:@"删除（%ld）",count];
        [self.deleteView.deleteButton setTitle:deleteTitle forState:UIControlStateNormal];
    }else{
        [self.deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        
    }
    
    [self.mCollectTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

}

- (void)selectAll:(UIButton *)sender{
    self.deleteView.checkAllButton.selected = !self.deleteView.checkAllButton.isSelected;
    _isCheckAll = !_isCheckAll;
    if (_isVideo) {
       
        for (CMTLivesRecord *obj in self.mArrVideos) {
            obj.isSelected = _isCheckAll;
        }
        if (_isCheckAll) {
            NSString *deleteTitle = [NSString stringWithFormat:@"删除（%@）",self.totalNum];
            [self.deleteView.deleteButton setTitle:deleteTitle forState:UIControlStateNormal];
            if (self.totalNum.integerValue == 0) {
                [self.deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
                
            }
        }else{
             [self.deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        }
        
    }else{
       
        for (CMTStore *obj in self.mArrShowConllections) {
            obj.isSelected = _isCheckAll;
        }
        
        if (_isCheckAll) {
            NSString *deleteTitle = [NSString stringWithFormat:@"删除（%ld）",self.mArrCollections.count];
            [self.deleteView.deleteButton setTitle:deleteTitle forState:UIControlStateNormal];
            if (self.mArrCollections.count == 0) {
                [self.deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];

            }
          
           
        }else{
              [self.deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        }
    }
    
    
    [self.mCollectTableView reloadData];
}
//删除
- (void)selectDelete:(UIButton *)sender{
    UIAlertView *deleteStoreAlert;
    NSString *alertStr;
    [self getDeletNumber];
    if (_isVideo) {
        alertStr = [NSString stringWithFormat:@"确定不再收藏该%ld个课程吗",self.deleteCount];
    }else{
        alertStr = [NSString stringWithFormat:@"确定不再收藏该%ld条资讯吗",self.deleteCount];
    }
    
    
    
    deleteStoreAlert=[[UIAlertView alloc]initWithTitle:alertStr message:nil delegate:nil
                                                  cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    if (self.deleteCount == 0) {
        return;
    }
    [deleteStoreAlert show];
    @weakify(self)
    [[[deleteStoreAlert rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
        @strongify(self);
        if ([index integerValue] == 1) {
            if (!_isVideo) {
                NSMutableArray *deletearr = [NSMutableArray array];
                for (CMTStore *obj in self.mArrShowConllections) {
                    if (obj.isSelected) {
                        [deletearr addObject:obj.postId];
                    }
                }
                NSError *JSError = nil;
                NSData *pData = [NSJSONSerialization dataWithJSONObject:deletearr options:NSJSONWritingPrettyPrinted error:&JSError];
                NSString *pStr = [[NSString alloc]initWithData:pData encoding:NSUTF8StringEncoding];
                if(CMTUSER.login == YES)
                {
                    /*有无网络*/
                    BOOL netState = NET_CELL||NET_WIFI;
                    if (netState)
                    {
                        CMTLog(@"有网络,服务端可以删除");
                        
                        /*调用删除接口,完成与服务器同步*/
                        NSDictionary *pDic = @{
                                               @"userId":CMTUSER.userInfo.userId?:@"0",
                                               @"postIdList":self.isCheckAll?@"":pStr,
                                               @"delType":self.isCheckAll?@"1":@"0",
                                               };
                        [[[CMTCLIENT CMTDeleteMessageStore:pDic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTObject * x) {
                            CMTLog(@"网络删除成功");
                            
                            
                        } error:^(NSError *error) {
                            CMTLog(@"error:%@",error);
                            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                            if ([errorCode integerValue] > 100) {
                                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                                CMTLog(@"errMes = %@",errMes);
                            } else {
                                CMTLogError(@"DeleteCollection System Error: %@", error);
                            }
                        }];
                        
                        
                    }
                }
                else
                {
                }
                
                for (int i = 0;i < deletearr.count;i++)
                {
                    NSString *postId = [deletearr objectAtIndex:i];
                    for (int j = 0;j < self.mArrCollections.count;j++)
                    {
                        CMTStore *concern2 = [self.mArrCollections objectAtIndex:j];
                        if ([postId isEqualToString:concern2.postId])
                        {
                            [self.mArrCollections removeObject:concern2];
                        }
                        
                    }
                }
                
                for (int i = 0;i < deletearr.count;i++)
                {
                    NSString *postId = [deletearr objectAtIndex:i];
                    for (int j = 0;j < self.mArrShowConllections.count;j++)
                    {
                        CMTStore *concern2 = [self.mArrShowConllections objectAtIndex:j];
                        if ([postId isEqualToString:concern2.postId])
                        {
                            [self.mArrShowConllections removeObject:concern2];
                        }
                        
                    }
                }
                if (self.isCheckAll) {
                    [self.mArrCollections removeAllObjects];
                }
                BOOL sucess = [NSKeyedArchiver archiveRootObject:self.mArrCollections toFile:PATH_COLLECTIONLIST];
                if (sucess)
                {
                    CMTLog(@"本地删除成功");
                    if (!_isVideo) {
                        [self noCollection:self.mArrCollections];
                        
                    }
                    [self.mCollectTableView reloadData];
                }
                else
                {
                    CMTLog(@"本地删除失败");
                }
                [self editTableView:self.rightItem];
                
                //            NSDictionary *params = @{
                //                                     @"userId":CMTUSERINFO.userId?:@"0",
                //                                     @"postIdList":
                //                                     };
                
            }else{
                NSMutableArray *deletearr = [NSMutableArray array];
                for (CMTLivesRecord *obj in self.mArrVideos) {
                    if (obj.isSelected) {
                        [deletearr addObject:obj.dataId];
                    }
                }
                
                [self DeleteVideoStoreWithArr:deletearr];
            }
            
        }
    }];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mCollectTableView.editing) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;

}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (self.isVideo) {
            //调删除接口，成功删除数组数据，不成功弹窗
            CMTLivesRecord *Record=self.mArrVideos[indexPath.row];
            NSMutableArray *deleteArr =[@[Record.dataId] mutableCopy];
            [self DeleteVideoStoreWithArr:deleteArr];
        }else{
            self.mDelObjIndex = indexPath.row;
            @try {
                
                CMTLog(@"提示标题");
                if(CMTUSER.login == YES)
                {
                    /*有无网络*/
                    BOOL netState = NET_CELL||NET_WIFI;
                    if (netState)
                    {
                        CMTLog(@"有网络,服务端可以删除");
                        /*获取该对象*/
                        if ([[self.mArrCollections objectAtIndex:self.mDelObjIndex]isKindOfClass:[CMTStore class]])
                        {
                            CMTStore * store = [self.mArrCollections objectAtIndex:self.mDelObjIndex];
                            /*调用删除接口,完成与服务器同步*/
                            NSDictionary *pDic = @{
                                                   @"userId":CMTUSER.userInfo.userId?:@"",
                                                   @"postId":store.postId,
                                                   @"cancelFlag":[NSNumber numberWithInt:1],
                                                   };
                            [CMTFOCUSMANAGER asyneCollection:pDic];
                        }
                    }
                }
                else
                {
                }
                if (self.mArrCollections.count >= self.mDelObjIndex)
                {
                    [self.mArrCollections removeObjectAtIndex:self.mDelObjIndex];
                    [self.mArrShowConllections removeObjectAtIndex:self.mDelObjIndex];
                    BOOL sucess = [NSKeyedArchiver archiveRootObject:self.mArrCollections toFile:PATH_COLLECTIONLIST];
                    if (sucess)
                    {
                        CMTLog(@"本地删除成功");
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.mDelObjIndex inSection:0];
                        [self.mCollectTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                        [self noCollection:self.mArrCollections];
                        [self.mCollectTableView reloadData];
                    }
                    else
                    {
                        CMTLog(@"本地删除失败");
                    }
                }
                
            }
            @catch (NSException *exception) {
                CMTLog(@"左划删除失败");
            }
        }
       
        
    }
}
#pragma mark  UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CMTLog(@"buttonIndex = %ld",(long)buttonIndex);
    CMTLog(@"title:%@",[alertView buttonTitleAtIndex:buttonIndex]);
    
    switch (buttonIndex) {
        case 0:
        {
            CMTStore *store;
            CMTLog(@"转发");
            CMTLog(@"调用转发");
            @try {
                store = [self.mArrCollections objectAtIndex:self.mDelObjIndex];
                self.mShareStore = store;
            }
            @catch (NSException *exception) {
                CMTLog(@"store is nil");
            }
            
            
            // 点击分享(正文中的图片[store.imageUrls firstObject])
            NSString *content = store.brief;
            if (BEMPTY(content)) {
                content = store.title;
            }
            //[[CMTSocial shareInstance] presentSnsIconSheetView:self sharePostId:store.postId shareTitle:store.title shareContent:content shareImageURL:nil shareLink:store.shareUrl delegate:nil];
            //自定义分享视图
            [self shareViewshow:self.mShareView bgView:self.tempView];
        }
            break;
        case 1:
        {
            CMTLog(@"提示标题");
            if(CMTUSER.login == YES)
            {
                /*有无网络*/
                BOOL netState = NET_CELL||NET_WIFI;
                if (netState)
                {
                    CMTLog(@"有网络,服务端可以删除");
                    /*获取该对象*/
                    if ([[self.mArrCollections objectAtIndex:self.mDelObjIndex]isKindOfClass:[CMTStore class]])
                    {
                        CMTStore * store = [self.mArrCollections objectAtIndex:self.mDelObjIndex];
                        /*调用删除接口,完成与服务器同步*/
                        NSDictionary *pDic = @{
                                               @"userId":CMTUSER.userInfo.userId?:@"",
                                               @"postId":store.postId,
                                               @"cancelFlag":[NSNumber numberWithInt:1],
                                               };
                        [CMTFOCUSMANAGER asyneCollection:pDic];
                    }
                }
            }
            else
            {
            }
            if (self.mArrCollections.count >= self.mDelObjIndex)
            {
                [self.mArrCollections removeObjectAtIndex:self.mDelObjIndex];
                [self.mArrShowConllections removeObjectAtIndex:self.mDelObjIndex];
                BOOL sucess = [NSKeyedArchiver archiveRootObject:self.mArrCollections toFile:PATH_COLLECTIONLIST];
                if (sucess)
                {
                    CMTLog(@"本地删除成功");
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.mDelObjIndex inSection:0];
                    [self.mCollectTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self noCollection:self.mArrCollections];
                    [self.mCollectTableView reloadData];
                }
                else
                {
                    CMTLog(@"本地删除失败");
                }
            }
        }
            break;
        case 2:
        {
            CMTLog(@"取消");
        }
            break;
            
        default:
            break;
    }
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];

    self.isLeftEnter = NO;
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLogin_collection"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    self.pullCount = 0;
//    [MobClick endLogPageView:@"P_Favoraites"];
    
    
}
#pragma mark  shareMethod
///平台按钮关联的分享方法
- (void)methodShare:(UIButton *)btn
{
    NSString *shareType = nil;
    switch (btn.tag)
    {
        case 1111:
        {
            CMTLog(@"朋友圈");
            shareType = @"1";
            NSString *shareText = self.mShareStore.title;
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.mShareStore.smallPic shareUrl:self.mShareStore.shareUrl StatisticalType:@"sharePost" shareData: self.mShareStore];        }
            break;
        case 2222:
        {
            shareType = @"2";
            CMTLog(@"微信好友");
            NSString *shareText = self.mShareStore.brief;
            NSString *shareTitle = self.mShareStore.title;
            CMTLog(@"brief:%@",shareText);
             [self shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.mShareStore.smallPic shareUrl:self.mShareStore.shareUrl StatisticalType:@"sharePost" shareData: self.mShareStore];
        }
            break;
        case 3333:
        {
            CMTLog(@"新浪微博分享");
             shareType = @"3";
            NSString *shareText = [NSString stringWithFormat:@"#%@# %@。%@ 来自@壹生_CMTopDr", APP_BUNDLE_DISPLAY, self.mShareStore.title,self.mShareStore.shareUrl];
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.mShareStore.smallPic shareUrl:self.mShareStore.shareUrl StatisticalType:@"sharePost" shareData: self.mShareStore];
        }
            break;
        case 4444:
        {
            CMTLog(@"邮件分享");
            shareType = @"4";
            [self shareImageAndTextToPlatformType:UMSocialPlatformType_Email shareTitle:[NSString stringWithFormat:@"【分享】%@", self.mShareStore.title] sharetext:[NSString stringWithFormat:@"#壹生#《%@》\n%@ 来自@壹生", self.mShareStore.title, self.mShareStore.shareUrl] sharetype:shareType sharepic:self.mShareStore.smallPic shareUrl:self.mShareStore.shareUrl StatisticalType:@"sharePost" shareData: self.mShareStore];
        }
            break;
        case 5555:
            [self shareViewDisapper];
            break;
        default:
            CMTLog(@"其他分享");
            break;
    }
    [self shareViewDisapper];
}



#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:identifier];
    
    NSInteger row = indexPath.row;
    
    if(row == 0){
        UILabel *label = [[UILabel alloc]initWithFrame:cell.frame];
        label.center = cell.center;
        label.textColor = COLOR(c_000000);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"提示";
        [cell addSubview:label];
        
    }else if (row == 1){
        cell.textLabel.text = @"Twitter";
        //cell.imageView.image = [UIImage imageNamed:@"ic_twitter.png"];
    }else if (row == 2){
        cell.textLabel.text = @"Google Plus";
        //cell.imageView.image = [UIImage imageNamed:@"ic_google_plus.png"];
    }
    
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"%s : %ld", __func__, (long)indexPath.row);
    // your code here
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
#pragma mark 收藏结果 界面设置
- (void)noCollection:(NSMutableArray *)array
{
    BOOL anyCollections = array.count > 0 ? YES: NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mCollectTableView.hidden = !anyCollections;
        self.mNoCollectionImageView.hidden = anyCollections;
        self.mLbNoCollection.hidden = anyCollections;
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
