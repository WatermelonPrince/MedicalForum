//
//  CMTSubjectPostsViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/7.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSubjectPostsViewController.h"
#import "CMTEnterCell.h"
#import "CMTPostListCell.h"
#import "CMTTableSectionHeader.h"
#import "CMTAuthorListViewController.h"
#import "CMTPostDetailCenter.h"
#import "UITableView+CMTExtension_PlaceholderView.h"

CMTButton *rightButton;
@implementation CMTSubjectPostsViewController


- (UITableView *)mTableViewPostsInSubject
{
    if (!_mTableViewPostsInSubject)
    {
        _mTableViewPostsInSubject = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _mTableViewPostsInSubject.delegate = self;
        _mTableViewPostsInSubject.dataSource = self;
        _mTableViewPostsInSubject.separatorStyle = UITableViewCellSelectionStyleNone;
        [_mTableViewPostsInSubject registerClass:[CMTPostListCell class] forCellReuseIdentifier:@"CMTSubjectPostListCell"];
    }
    return _mTableViewPostsInSubject;
}
- (NSMutableArray *)mArrPosts
{
    if (!_mArrPosts)
    {
        _mArrPosts = [NSMutableArray array];
    }
    return _mArrPosts;
}
- (NSMutableArray *)mArrPostsSorted
{
    if (!_mArrPostsSorted)
    {
        _mArrPostsSorted = [NSMutableArray array];
    }
    return _mArrPostsSorted;
}
- (NSMutableArray *)mArrTempPosts
{
    if (!_mArrTempPosts)
    {
        _mArrTempPosts = [NSMutableArray array];
    }
    return _mArrTempPosts;
}
- (UIAlertView *)mAlertView
{
    if (!_mAlertView)
    {
        _mAlertView = [[UIAlertView alloc]initWithTitle:@"确定不再订阅该学科吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
    return _mAlertView;
}
-(UILabel*)tipsLable{
    _tipsLable=[[UILabel alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-60-64-50)/2, SCREEN_WIDTH, 60)];
    _tipsLable.text=@"该学科下没有病例文章";
    _tipsLable.textAlignment=NSTextAlignmentCenter;
    _tipsLable.textColor=COLOR(c_d2d2d2);
    _tipsLable.font=[UIFont boldSystemFontOfSize:18.0];;
    return _tipsLable;
}


#pragma mark 视图将要出现
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.titleText = self.mSubject.subject;

    
    rightButton = [CMTButton buttonWithType:UIButtonTypeRoundedRect];
    [rightButton setFrame:CGRectMake(0, 0, 72.0, 28.0)];
    
    NSArray *pArr = [NSKeyedUnarchiver unarchiveObjectWithFile:self.strSubListCachePath];
    for (CMTConcern *concern in pArr)
    {
        if ([concern.subject isEqualToString: self.mSubject.subject])
        {
           [self subcritonState:rightButton];
            break;
        }
        else
        {
            [self noSubcritionState:rightButton];
        }
    }
    if (pArr.count <= 0)
    {
        [self noSubcritionState:rightButton];
    }
    
    [rightButton addTarget:self action:@selector(addSubcrition:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = [self creatRightItem];
    //获取最新文章列表
    if (self.requestNewLeast)
    {
        [self runAnimationInPosition:self.view.center];
        [self firstRequest];
    }

}
#pragma mark 第一次请求
- (void)firstRequest
{
    NSString *subjectId =self.mSubject.subjectId;
    [[CMTCLIENT getPostListInSubject:@{
                                       @"userId": CMTUSERINFO.userId ?: @"0",
                                       @"subjectId": subjectId ?: @"",
                                       @"module": APPDELEGATE.tabBarController.selectedIndex == 1 ? @"1" : @"0",
                                       @"incrId": @"0"
                                       }]subscribeNext:^(NSArray * posts) {
        
        
        @try {
            if (self.mArrPosts.count <= 0) {
                [self.mArrPosts addObjectsFromArray:posts];
            }
            if (posts.count > 0)
            {
                CMTPost *post = [posts firstObject];
                self.incrId = post.incrId;
            }
            [self postsSorted:[posts mutableCopy]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mReloadBaseView.hidden = YES;
                if ([posts count]==0) {
                     [self.mTableViewPostsInSubject addSubview:self.tipsLable];
                }else{
                  [self.mTableViewPostsInSubject reloadData];
                }
                
                [self stopAnimation];
                [self stopRefashView:self.mTableViewPostsInSubject.pullToRefreshView];
            });
        }
        @catch (NSException *exception) {
            CMTLog(@"firstObject maybe is nil");
        }
        
        
    } error:^(NSError *error) {
        CMTLog(@"error:%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAnimation];
            
            self.mReloadBaseView.hidden = NO;
            
            [self stopRefashView:self.mTableViewPostsInSubject.pullToRefreshView];
        });
    }];
}

#pragma mark 请求最新的文章
- (void)getNewLeastPosts
{
        NSNumber *incrIdFlag = [NSNumber numberWithInt:0];
        NSString *subjectId =self.mSubject.subjectId;
        [[CMTCLIENT getPostListInSubject:@{
                                           @"userId": CMTUSERINFO.userId ?: @"0",
                                           @"subjectId": subjectId ?: @"",
                                           @"module": APPDELEGATE.tabBarController.selectedIndex == 1 ? @"1" : @"0",
                                           @"incrId": self.incrId ?: @"",
                                           @"incrIdFlag":incrIdFlag
                                           }]subscribeNext:^(NSArray * posts) {
            @try {
                if (posts.count <= 0) {
                    [self toastAnimation:@"没有最新文章"];
                }
                else{
                    NSArray *pTempArr = [self.mArrPosts copy];
                    [self.mArrPosts removeAllObjects];
                    [self.mArrPosts addObjectsFromArray:posts];
                    [self.mArrPosts addObjectsFromArray:pTempArr];
                    
                    CMTPost *post = [posts firstObject];
                    self.incrId = post.incrId;
                    [self postsSorted:[self.mArrPosts mutableCopy]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mReloadBaseView.hidden = YES;
                    [self.mTableViewPostsInSubject reloadData];
                    [self stopAnimation];
                    [self stopRefashView:self.mTableViewPostsInSubject.pullToRefreshView];
                });
            }
            @catch (NSException *exception) {
                CMTLog(@"firstObject maybe is nil");
            }
        } error:^(NSError *error) {
            CMTLog(@"error:%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                    [self toastAnimation:@"你的网络不给力"];
                }else{
//<<<<<<< HEAD
                    if(error.code == NSURLErrorCannotConnectToHost){
                        [self toastAnimation:@"你的网络不给力"];
//=======
//                    if((0-error.code)>1001&&(0-error.code)<1010){
//                        [self toastAnimation:@"您的网络不给力"];
//>>>>>>> 13b0ad5f57265a39d8bd7553071f4134ab5841f4
                    }else{
                         [self toastAnimation:error.userInfo[@"errmsg"]];
                    }
                }
                [self.mTableViewPostsInSubject.pullToRefreshView stopAnimating];

            });
        }];
}

#pragma mark 获取学科下文章列表数据

- (void)getPostList
{
        CMTPost *post = [self.mArrTempPosts lastObject];
        NSString *subjectId = self.mSubject.subjectId;
        NSString *incrId = post.incrId;
        [[CMTCLIENT getPostListInSubject:@{
                                           @"userId": CMTUSERINFO.userId ?: @"0",
                                           @"subjectId": subjectId ?: @"",
                                           @"module": APPDELEGATE.tabBarController.selectedIndex == 1 ? @"1" : @"0",
                                           @"incrId": incrId ?: @"",
                                           @"incrIdFlag":@"1"
                                           }]subscribeNext:^(NSArray * posts) {
            [self.mArrPosts addObjectsFromArray:posts];
            [self postsSorted:self.mArrPosts];
            [self stopRefashView:self.mTableViewPostsInSubject.infiniteScrollingView];
            if (posts.count <= 0)
            {
                [self toastAnimation:@"没有更多文章"];
            }
        } error:^(NSError *error) {
            CMTLog(@"error:%@",error);
            if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                [self toastAnimation:error.userInfo[@"errmsg"]];
            }

            [self stopRefashView:self.mTableViewPostsInSubject.infiniteScrollingView];
        }];
 }
- (void)stopRefashView:(id)SVview
{
    if ([SVview respondsToSelector:@selector(stopAnimating)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVview stopAnimating];
        });
    }
   
}

#pragma mark 数据排序方法

// 文章列表 按incrId排序
- (NSArray *)sortPostList:(NSArray *)postList {
    return [postList sortedArrayUsingComparator:^NSComparisonResult(CMTPost *obj1, CMTPost *obj2) {
        NSString *incrId1, *incrId2;
        
        if ([obj1 respondsToSelector:@selector(incrId)]) {
            incrId1 = [obj1 incrId];
        }
        if ([obj2 respondsToSelector:@selector(incrId)]) {
            incrId2 = [obj2 incrId];
        }
        
        if (incrId1 && incrId2) {
            // incrId大的在前
            return [incrId2 compare:incrId1];
        }
        else {
            // 默认保持不变
            return NSOrderedAscending;
        }
    }];
}


- (void)postsSorted:(NSMutableArray *)cachePostList
{
    @try {
        // 先按incrId排序
        NSArray *sortedPostList = [self sortPostList:cachePostList];
        // 再按创建时间分组
        NSMutableArray *postSections = [NSMutableArray array];
        
        int index = 0;
        for (CMTPost *post in sortedPostList) {
            // 获取当前条目的创建时间
            NSString *createTime = DATE(post.createTime);
            if (BEMPTY(createTime)) {
                CMTLogError(@"SubjectPostList Group PostList: %@\nError: Empty CreateTime at Index: [%d]", sortedPostList, index);
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
            // 刷新缓存列表
            self.mArrTempPosts = [cachePostList copy];
            // 刷新分组列表
            self.mArrPostsSorted = [[NSArray arrayWithArray:postSections]mutableCopy];
            // 刷新表格
            if ([AFNetworkReachabilityManager sharedManager].isReachable) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mTableViewPostsInSubject.hidden = NO;
                    [self.mTableViewPostsInSubject reloadData];
                });
            }
        } else {
            CMTLog(@"OtherPostList Group Post List Error: Empty PostSection");
        }
    }
    @catch (NSException *exception) {
        CMTLog(@"OtherPostList Group Post List Error: Empty PostSection");
    }
   
}

#pragma mark 生成rightItem
- (NSArray *)creatRightItem
{
   
//    if ([self.mBtnSubListBtn.titleLabel.text isEqualToString:@"+ 订阅"])
//    {
//        CMTLog(@"当前按钮的标题为+ 订阅");
//        [self noSubcritionState:rightButton];
//    }
//    else
//    {
//        CMTLog(@"当前按钮的标题为已订阅");
//        [self subcritonState:rightButton];
//    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    UIBarButtonItem *rightFixdSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightFixdSpace.width = -6;//+ (RATIO - 1)*(CGFloat)12;
    
    return @[rightFixdSpace,rightItem];
}
#pragma mark 视图已经出现
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     CMTLog(@"%s",__func__);
}

#pragma mark 警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    CMTLog(@"%s",__func__);
}

#pragma mark 视图将要消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    CMTLog(@"%s",__func__);
    self.requestNewLeast = NO;
    
    if (self.refreshList != nil) {
        self.refreshList();
    }
}


#pragma mark viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    [self.contentBaseView addSubview:self.mTableViewPostsInSubject];
     CMTLog(@"%s",__func__);
    @weakify(self);
    [self.mTableViewPostsInSubject addPullToRefreshWithActionHandler:^{
        @strongify(self);
        [self getNewLeastPosts];
    }];
    [self.mTableViewPostsInSubject addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        [self getPostList];
    }];
}
#pragma mark 重写视图弹回方法
- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 绘制cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"enderCell";
    static NSString *idenfifer2 = @"CMTSubjectPostListCell";
    CMTEnterCell *enterCell = [tableView dequeueReusableCellWithIdentifier:identifer];
   
    if (!enterCell)
    {
        enterCell = [[CMTEnterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    if (indexPath.section == 0)
    {
        enterCell.mImageLeft.image = IMAGE(@"authorFlock");
        enterCell.mLabelDes.text = @"查看作者排行榜";
        enterCell.separatorLine.hidden = NO;
        enterCell.separatorLine.height = PIXEL;
        enterCell.separatorLine.backgroundColor = COLOR(c_9e9e9e);
        return enterCell;
    }
    else
    {
         CMTPostListCell *postCell = [self.mTableViewPostsInSubject dequeueReusableCellWithIdentifier:idenfifer2 forIndexPath:indexPath];
        
        postCell.selectionStyle = UITableViewCellSelectionStyleNone;
        @try {
            //从指定数据源区数据
            if (self.mArrPostsSorted.count > 0)
            {
                NSDictionary *pDic = [self.mArrPostsSorted objectAtIndex:indexPath.section-1];
                NSArray *pArr = pDic[CMTPostListSectionPostArrayKey];
                if (pArr.count > 0)
                {
                    CMTPost *post = [pArr objectAtIndex:indexPath.row];
                    post.themeStatus = @"0";
                    [postCell reloadPost:post tableView:tableView indexPath:indexPath];
                }
            }
        }
        @catch (NSException *exception) {
            CMTLog(@"cell的取值错误");
        }
       
        return postCell;
    }
}
#pragma mark 分行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @try {
        if (section == 0)
        {
            return 1;
        }
        else
        {
            if (self.mArrPostsSorted.count > 0)
            {
                id pDic = [self.mArrPostsSorted objectAtIndex:section-1];
                CMTLog(@"pDicpDicpDicpDic:%@",pDic);
                NSArray *pArr = pDic[CMTPostListSectionPostArrayKey];
                if (pArr.count > 0)
                {
                    return pArr.count;
                }
            }
        }
    }
    @catch (NSException *exception) {
        CMTLog(@"返回分行错误");
    }
    
    
}
#pragma mark 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 50;
    }
    else
    {
        return 87;
    }
}
#pragma mark  分段数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.mArrPostsSorted.count + 1;
}

#pragma mark 选中某行

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"row:%ld,section:%ld",(long)indexPath.row,(long)indexPath.section);
    @try {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                switch (self.mSubject.subjectId.integerValue) {
                    case 1:
                        [MobClick event:@"B_AuthorRank_Tumour"];
                        break;
                    case 2:
                        [MobClick event:@"B_AuthorRank_Cardio"];
                        break;
                    case 3:
                        [MobClick event:@"B_AuthorRank_Endocrine"];
                        break;
                    case 4:
                        [MobClick event:@"B_AuthorRank_Digestion"];
                        break;
                    case 5:
                        [MobClick event:@"B_AuthorRank_Nerve"];
                        break;
                    case 6:
                        [MobClick event:@"B_AuthorRank_General"];
                        break;
                    case 7:
                        [MobClick event:@"B_AuthorRank_Dental"];
                        break;
                    case 8:
                        [MobClick event:@"B_AuthorRank_JAMA"];
                        break;
                    case 9:
                        [MobClick event:@"B_AuthorRank_Culture"];
                        break;
                        
                    default:
                        break;
                }
                
                CMTAuthorListViewController *  autharListVC = [[CMTAuthorListViewController alloc]init];
                autharListVC.mSubject = self.mSubject;
                autharListVC.needRequest = YES;
                [self.navigationController pushViewController: autharListVC animated:YES];
            }
        }
        else
        {
            NSDictionary *pDic = [self.mArrPostsSorted objectAtIndex:indexPath.section-1];
            
            NSArray *pArr = pDic[CMTPostListSectionPostArrayKey];
            if (pArr.count > indexPath.row)
            {
                CMTPost *post = [pArr objectAtIndex:indexPath.row];
                if (!isEmptyString(post.groupId) && post.groupId.integerValue != 0) {
                    CMTGroup *group = [[CMTGroup alloc]init];
                    group.groupId = post.groupId;
                    CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId isHTML:post.isHTML postURL:post.url group:group postModule:post.module postDetailType:CMTPostDetailTypeUnDefind];
                    [self.navigationController pushViewController:postDetailCenter animated:YES];
                }else{
                    CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:post.postId
                                                                                               isHTML:post.isHTML
                                                                                              postURL:post.url
                                                                                           postModule:post.module
                                                                                       postDetailType:CMTPostDetailTypeAuthorPostList];
                    [self.navigationController pushViewController:postDetailCenter animated:YES];
                }
                
            }
        }

    }
    @catch (NSException *exception) {
        CMTLog(@"界面跳转出错");
    }
    
}

#pragma mark 页眉高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else
    {
        return 25;
    }
}
#pragma mark 页眉视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        pView.backgroundColor = COLOR(c_f5f5f5);
        return pView;
    }
    else
    {
        CMTTableSectionHeader *header = [CMTTableSectionHeader headerWithHeaderWidth:tableView.width
                                                                        headerHeight:25.0 inSection:section];
        if (section != 0) {
            UIView *headerLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, header.height, PIXEL)];
            headerLine.backgroundColor = COLOR(c_9e9e9e);
            [header addSubview:headerLine];
        }
        header.backgroundColor = COLOR(c_f5f5f5);
        @try {
            if (self.mArrPostsSorted.count > 0)
            {
                NSDictionary *pDic = [self.mArrPostsSorted objectAtIndex:section-1];
                header.title = pDic[CMTPostListSectionPostDateKey];
            }
            else
            {
                header.title = @"";
            }
        }
        @catch (NSException *exception) {
            CMTLog(@"页眉标题设置错误");
        }
        return header;
    }
}
- (void)subcrition1:(CMTButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [btn setTitle:@"已订阅" forState:UIControlStateNormal];
        [btn setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
        [btn setBackgroundColor:COLOR(c_dfdfdf)];
        btn.layer.borderColor = COLOR(c_ababab).CGColor;
        btn.layer.borderWidth = PIXEL;
        btn.userInteractionEnabled = NO;
    });
}

- (void)addSubcrition:(CMTButton *)btn
{
    CMTLog(@"%s",__func__);
    
    CMTLog(@"title=%@",btn.titleLabel.text);
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        if ([btn.titleLabel.text isEqualToString:@"+ 订阅"])
        {
            [self subcritonState:btn];
            CMTLog(@"self.mBtnSubListBtn.address=%p",self.mBtnSubListBtn);
            [self subcrition1:self.mBtnSubListBtn];
            //网络请求
            CMTConcern *concern = [[CMTConcern alloc]init];
            concern.subject = self.mSubject.subject;
            concern.subjectId = self.mSubject.subjectId;
            concern.opTime = [NSDate UNIXTimeStampFromNow];
            
            //统计事件
            if ([concern.subject isEqualToString:@"肿瘤"])
            {
                [MobClick event:@"B_Tumour"];
            }
            else if ([concern.subject isEqualToString:@"消化"])
            {
                [MobClick event:@"B_Digestion"];
            }
            else if ([concern.subject isEqualToString:@"全科"])
            {
                [MobClick event:@"B_General"];
            }
            else if ([concern.subject isEqualToString:@"心血管"])
            {
                [MobClick event:@"B_Angiocarpy"];
            }
            else if ([concern.subject isEqualToString:@"内分泌"])
            {
                [MobClick event:@"B_Incretion"];
            }
            else if ([concern.subject isEqualToString:@"神经"])
            {
                [MobClick event:@"B_Nerve"];
            }
            else if ([concern.subject isEqualToString:@"口腔"])
            {
                [MobClick event:@"B_Stomatology"];
            }
            else if ([concern.subject isEqualToString:@"JAMA"])
            {
                [MobClick event:@"B_JAMA"];
            }
            else if ([concern.subject isEqualToString:@"科研"])
            {
                [MobClick event:@"B_Scientific"];
            }
            else if ([concern.subject isEqualToString:@"人文"])
            {
                [MobClick event:@"B_Humanity"];
            }
            
            [self.mArrSubscription addObject:concern];
            
            CMTUserInfo *info = CMTUSERINFO;
            NSString *subjectId = concern.subjectId;
            CMTUser *pUser = CMTUSER;
            //if([[NSUserDefaults standardUserDefaults]boolForKey:@"firstLogin"] == YES)
            if (pUser.login)
            {
                // 登录状态的添加订阅学科接口
                NSDictionary *pDic = @{@"userId":info.userId?:@"0",@"subjectId":subjectId?:@"",@"cancelFlag":[NSNumber numberWithInt:0]?:@""};
                @weakify(self);
                [self.rac_deallocDisposable addDisposable:[[CMTCLIENT fetchConcern:pDic] subscribeNext:^(CMTConcern * pConcern) {
                    @strongify(self);
                    DEALLOC_HANDLE_SUCCESS
                    BOOL isArchSucess = [NSKeyedArchiver archiveRootObject:self.mArrSubscription toFile:self.strSubListCachePath];
                    if (isArchSucess)
                    {
                        CMTLog(@"新增订阅项缓存到本地成功");
                    }
                    else
                    {
                        CMTLog(@"新增订阅项缓存到本地失败");
                    }
                    CMTLog(@"新增订阅项同步到服务器端成功");
                    CMTUSERINFO.follows = self.mArrSubscription;
                    CMTAPPCONFIG.isrefreahCase=@"1";
                    CMTAPPCONFIG.refreshmodel=@"2";
                    
                    [CMTUSER save];
                } error:^(NSError *error) {
                    DEALLOC_HANDLE_SUCCESS
                    CMTLog(@"%@",error);
                    NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                    if ([errorCode integerValue] > 100) {
                        NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                        CMTLog(@"errMes = %@",errMes);
                    } else {
                        CMTLogError(@"add subcription System Error: %@", error);
                    }
                }]];
            }
            else
            {
                BOOL isArchSucess = [NSKeyedArchiver archiveRootObject:self.mArrSubscription toFile:self.strSubListCachePath];
                
                if (isArchSucess)
                {
                    CMTLog(@"新增订阅项缓存到本地成功");
                }
                else
                {
                    CMTLog(@"新增订阅项缓存到本地失败");
                }
                info.follows = [self.mArrSubscription copy];
                
                // 未登录状态的添加订阅学科接口
                NSDictionary *pDic = @{@"userId":@"0",@"subjectId":subjectId?:@"0",@"cancelFlag":[NSNumber numberWithInt:0]?:@""};
                [[CMTCLIENT fetchConcern:pDic] subscribeNext:^(CMTConcern * pConcern) {
                    
                    CMTAPPCONFIG.isrefreahCase=@"1";
                    CMTAPPCONFIG.refreshmodel=@"2";
                    CMTLog(@"未登录状态的添加订阅学科接口 成功:\n%@", pConcern);
                } error:^(NSError *error) {
                    DEALLOC_HANDLE_SUCCESS
                    CMTLog(@"未登录状态的添加订阅学科接口 失败:\n%@", error);
                }];
            }
        }
        else
        {
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mAlertView show];
            });
        }
    }
    else{
        [self toastAnimation:@"你的网络不给力"];
    }
}
#pragma mark  点击警告框上的按钮


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable){
        switch (buttonIndex)
        {
            case 0:
            {
                CMTLog(@"取消取消订阅");
            }
                break;
            case 1:
            {
                CMTLog(@"确认取消订阅");
                if ([AFNetworkReachabilityManager sharedManager].isReachable) {
                    if (CMTUSER.login)
                    {
                        // 登录状态的取消订阅学科接口
                        CMTLog(@"服务器端删除");
                        NSDictionary *pDic =@{
                                              @"userId":CMTUSERINFO.userId ?: @"0",
                                              @"subjectId":self.mSubject.subjectId ?: @"",
                                              @"cancelFlag":[NSNumber numberWithInt:1]
                                              };
                        [self.rac_deallocDisposable addDisposable:[[CMTCLIENT fetchConcern:pDic] subscribeNext:^(CMTConcern * pConcern) {
                            DEALLOC_HANDLE_SUCCESS
                            
                            //页面刷新
                            CMTAPPCONFIG.isrefreahCase=@"1";
                            CMTAPPCONFIG.refreshmodel=@"2";
                            CMTLog(@"服务端取消订阅%@成功",self.mSubject.subject);
                            
                        } error:^(NSError *error) {
                            DEALLOC_HANDLE_SUCCESS
                            CMTLog(@"%@",error);
                            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                            if ([errorCode integerValue] > 100) {
                                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                                CMTLog(@"errMes = %@",errMes);
                            } else {
                                CMTLogError(@"delete Subscription System Error: %@", error);
                            }
                            
                        } ]];
                        
                    }
                    else {
                        // 未登录状态的取消订阅学科接口
                        NSDictionary *pDic = @{@"userId":@"0",@"subjectId":self.mSubject.subjectId?:@"0",@"cancelFlag":[NSNumber numberWithInt:1]?:@""};
                        [[CMTCLIENT fetchConcern:pDic] subscribeNext:^(CMTConcern * pConcern) {
                            CMTAPPCONFIG.isrefreahCase=@"1";
                            CMTAPPCONFIG.refreshmodel=@"2";
                            
                            CMTLog(@"未登录状态的取消订阅学科接口 成功:\n%@", pConcern);
                          
                        } error:^(NSError *error) {
                            DEALLOC_HANDLE_SUCCESS
                            CMTLog(@"未登录状态的取消订阅学科接口 失败:\n%@", error);
                        }];

                    }
                    //本地删除
                    for (CMTConcern *concern in self.mArrSubscription)
                    {
                        if ([concern.subjectId isEqualToString:self.mSubject.subjectId])
                        {
                            [self.mArrSubscription removeObject:concern];
                            break;
                        }
                    }
                    
                    BOOL cache = [NSKeyedArchiver archiveRootObject:self.mArrSubscription toFile:self.strSubListCachePath];
                    if (cache)
                    {
                        CMTLog(@"本地取消订阅%@成功",self.mSubject.subject);
                        [self noSubcritionState:rightButton];
                    }
                    else
                    {
                        CMTLog(@"本地取消订阅%@失败",self.mSubject.subject);
                    }
                }
                else
                {
                    [self toastAnimation:@"你的网络不给力"];
                }
            }
                break;
                
            default:
                break;
        }
        CMTUSERINFO.follows = self.mArrSubscription;
        [CMTUSER save];
    }
    else{
        [self toastAnimation:@"你的网络不给力"];
    }
    
}

///已经订阅的按钮状态
- (void)subcritonState:(CMTButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        btn.layer.borderColor = COLOR(c_9e9e9e).CGColor;
        btn.layer.borderWidth = PIXEL;
        btn.layer.cornerRadius = 6.0;
        [btn setTitle:@"取消订阅" forState:UIControlStateNormal];
        [btn setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
    });
}
///未订阅的按钮状态
- (void)noSubcritionState:(CMTButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        btn.layer.borderColor = COLOR(c_32c7c2).CGColor;
        btn.layer.borderWidth = PIXEL;
        btn.layer.cornerRadius = 6.0;
        [btn setTitle:@"+ 订阅" forState:UIControlStateNormal];
        [btn setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //CMTLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
    if (scrollView.contentOffset.y < -SCREEN_HEIGHT/3)
    {
        //上拉刷新
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.mReloadBaseView.hidden == NO)
    {
        [self runAnimationInPosition:self.view.center];
        self.mTableViewPostsInSubject.hidden = YES;
        self.mReloadBaseView.hidden = YES;
        [self firstRequest];
    }
}
@end
