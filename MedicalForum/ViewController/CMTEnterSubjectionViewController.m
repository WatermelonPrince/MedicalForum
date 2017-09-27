//
//  CMTEnterSubjectionViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/14.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTEnterSubjectionViewController.h"
#import "CMTSubjectListCell.h"
#import "CMTOtherPostListViewController.h"
#import "CMTThemAllSubjectViewController.h"
//焦点图
#import "CMTFocusPageView.h"


#define ROW_HEIGHT (self.view.frame.size.width/16*9)


@interface CMTEnterSubjectionViewController ()
@property (assign) NSInteger lastObj;
@property (nonatomic, retain) UIBarButtonItem *itemAllThemes;

@end

@implementation CMTEnterSubjectionViewController

- (UIBarButtonItem *)itemAllThemes{
    if (!_itemAllThemes) {
        _itemAllThemes = [[UIBarButtonItem alloc]initWithTitle:@"全部专题" style:UIBarButtonItemStylePlain target:self action:@selector(allThemes)];
    }
    return _itemAllThemes;
}
- (void)allThemes{
    CMTLog(@"%s",__func__);
    CMTThemAllSubjectViewController *allThemesVC = [[CMTThemAllSubjectViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:allThemesVC animated:YES];
}

#pragma mark ViewDidLoad


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.titleText = @"我的专题";
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    self.navigationItem.rightBarButtonItem = self.itemAllThemes;
    [self.view addSubview:self.mTableView];
    self.mTableView.hidden = YES;
//    [self.view addSubview:self.mNoCollectionImageView];
    self.mNoCollectionImageView.hidden = YES;
    [self.view addSubview:self.mLbNoCollection];
    self.mLbNoCollection.hidden = YES;
    //上拉加载更多
    @weakify(self);
    [self.mTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        
        [self infinToGetMoreTheme:nil];
        
    }];
}
#pragma mark 上拉关联方法
- (void) infinToGetMoreTheme:(id)sender
{
    CMTLog(@"上拉刷新");
    
    self.mTableView.infiniteScrollingView.hidden = NO;
    CMTLog(@"%@",NSStringFromCGPoint(self.mTableView.contentOffset));
    if(self.mTableView.contentOffset.y < 0)
    {
        //self.mCollectTableView.infiniteScrollingView.hidden = YES;
        [self.mTableView.infiniteScrollingView stopAnimating];
        
    }
    if (self.mTableView.contentOffset.y > 0)
    {
        [self.mTableView.infiniteScrollingView startAnimating];
        if (self.mArrSubjects.count <= 30)
        {
            CMTLog(@"没有更多");
            [self toastAnimation:@"没有更多专题"];
        }
        else
        {
            if (self.mArrShowSubjects.count == self.mArrSubjects.count)
            {
                [self toastAnimation:@"没有更多专题"];
                
            }
            
            for (int i = 0; i < 30; i++)
            {
                if (self.lastObj < self.mArrSubjects.count)
                {
                    [self.mArrShowSubjects addObject:[self.mArrSubjects objectAtIndex:self.lastObj]];
                    self.lastObj++;
                }
                else
                {
                    CMTLog(@"没有更多");
                    break;
                }
            }
            
            @try {
                if([self.mArrShowSubjects respondsToSelector:@selector(sortedArrayUsingComparator:)])
                {
                    [self.mArrShowSubjects sortUsingComparator:^NSComparisonResult(CMTTheme *theme1, CMTTheme *theme2) {
                        NSComparisonResult result = [theme2.opTime compare:theme1.opTime] ;
                        return result;
                    }];
                }
            }
            @catch (NSException *exception) {
                
            }
        }
    }
    [self.mTableView reloadData];
    
    [self.mTableView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1.0];
}
#pragma mark 下拉关联方法
- (void) pullToGetMoreTheme:(id)sender
{
    if([AFNetworkReachabilityManager sharedManager].reachable){
        NSArray *items = @[];
        NSData *pData = [NSJSONSerialization dataWithJSONObject:items options:NSJSONWritingPrettyPrinted error:nil];
        NSString *pStr = [[NSString alloc]initWithData:pData encoding:NSUTF8StringEncoding];
        NSDictionary *pDic = @{
                               @"userId":CMTUSERINFO.userId?:@"",
                               @"items":pStr
                               };
        [[[CMTCLIENT syncTheme:pDic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray * array) {
            NSMutableArray *pArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
            NSMutableArray *pResultArr = [array mutableCopy];
            
            for (int i = 0; i < pResultArr.count; i++) {
                CMTTheme *themeServer = [pResultArr objectAtIndex:i];
                themeServer.viewTime = themeServer.opTime;
                for (int j = 0; j < pArr.count; j++) {
                    CMTTheme *themeLocal = [pArr objectAtIndex:j];
                    if ([themeServer.themeId isEqualToString:themeLocal.themeId]) {
                        // 将服务器端的订阅时间改为本地缓存的订阅时间
                        themeServer.opTime = themeLocal.opTime;
                        themeServer.viewTime = themeLocal.viewTime;
                    }
                }
            }
            //处理登陆无法订阅的问题
            if (!CMTUSER.login) {
                NSMutableArray *themeArray=[[NSMutableArray alloc]init];
                for (int i = 0; i < pResultArr.count; i++) {
                    CMTTheme *themeServer = [pResultArr objectAtIndex:i];
                    themeServer.viewTime = themeServer.opTime;
                    bool flag=NO;
                    for (int j = 0; j < pArr.count; j++) {
                        CMTTheme *themeLocal = [pArr objectAtIndex:j];
                        if ([themeServer.themeId isEqualToString:themeLocal.themeId]) {
                            flag=YES;
                        }
                    }
                    if (!flag) {
                        [themeArray addObject:themeServer];
                    }
                }
                
               [themeArray addObjectsFromArray:[pArr copy]];
                pResultArr=themeArray;
            }
            
            [pResultArr sortUsingComparator:^NSComparisonResult(CMTStore *store1, CMTStore *store2) {
                NSComparisonResult result = [store2.opTime compare:store1.opTime];
                return result;
            }];
            
            BOOL sucess  = [NSKeyedArchiver archiveRootObject:pResultArr toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
            if (sucess) {
                CMTLog(@"同步成功");
                [self getSubjectList:@{}];
            }
            else{
                CMTLog(@"同步失败");
            }
            
            if ([self.mTableView.pullToRefreshView respondsToSelector:@selector(stopAnimating)]) {
                [self.mTableView.infiniteScrollingView stopAnimating];
                [self.mTableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0];
            }
        } error:^(NSError *error) {
            if ([self.mTableView.pullToRefreshView respondsToSelector:@selector(stopAnimating)]) {
                [self.mTableView.infiniteScrollingView stopAnimating];
                [self.mTableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0];
            };
        }];
        
        
    }
    else{
        [self toastAnimation:@"你的网络不给力"];
    }
}


#pragma mark 视图将要出现
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self pullToGetMoreTheme:nil];
    @weakify(self);
    if (CMTUSER.login) {
        [self.mTableView addPullToRefreshWithActionHandler:^{
            @strongify(self);
            [self pullToGetMoreTheme:nil];
        }];
    }
    if (self.isLeftEnter) {
        [self.mTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    self.lastObj = 0;
    [self getSubjectList:@{}];
}
- (void)viewDidAppear:(BOOL)animated
{

    CMTLog(@"%s",__func__);
}

#pragma mark 请求专题列表方法
- (void)getSubjectList:(NSDictionary *)dic
{
    //本地数据
    if([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"focusList"]])
    {
        CMTLog(@"发现收藏列表,从本地加载");
        // 获取到本地数据根据时间排序
        NSMutableArray *pArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
        if ([pArr respondsToSelector:@selector(sortedArrayUsingComparator:)])
        {
            [pArr sortUsingComparator:^NSComparisonResult(CMTStore *store1, CMTStore *store2) {
                NSComparisonResult result = [store2.opTime compare:store1.opTime];
                return result;
            }];
            [self.mArrSubjects removeAllObjects];
            [self.mArrSubjects addObjectsFromArray:pArr];
        }
        BOOL reCache = [NSKeyedArchiver archiveRootObject:self.mArrSubjects toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
        if (reCache) {
            CMTLog(@"根据时间排序后缓存成功");
        }
        else{
            CMTLog(@"根据时间排序后缓存失败");
        }
        
        if (self.mArrSubjects.count <= 30)
        {
            self.lastObj = self.mArrSubjects.count;
            self.mArrShowSubjects = [self.mArrSubjects mutableCopy];
        }
        else
        {
            for (int i = 0 ; i < 30; i++)
            {
                [self.mArrShowSubjects addObject:[self.mArrSubjects objectAtIndex:i]];
            }
            self.lastObj = 30;
        }
        [self stopAnimation];
        [self noCollection:self.mArrSubjects];
        
        if ([self.mTableView respondsToSelector:@selector(reloadData)])
        {
            [self.mTableView performSelector:@selector(reloadData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
        }
    }
    else
    {
        [self stopAnimation];
        CMTLog(@"没有收藏数据");
        self.mNoCollectionImageView.hidden = NO;
        self.mLbNoCollection.hidden = NO;
        self.mTableView.hidden = YES;
    }
    [self noCollection:self.mArrSubjects];
    
}
- (void)noCollection:(NSMutableArray *)array
{
    BOOL anyCollections = array.count > 0 ? YES: NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mTableView.hidden = !anyCollections;
        self.mNoCollectionImageView.hidden = anyCollections;
        self.mLbNoCollection.hidden = anyCollections;
    });
}

- (void)anySubjects
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mTableView.hidden = NO;
        [self.mTableView reloadData];
        self.mNoCollectionImageView.hidden = YES;
        self.mLbNoCollection.hidden = YES;
    });
}
- (void)noSubjects
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mTableView.hidden = YES;
        self.mNoCollectionImageView.hidden = NO;
        self.mLbNoCollection.hidden = NO;
    });
}

#pragma mark 分段数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark 分行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mArrShowSubjects.count;
}
#pragma mark 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CMTFocusPageView heightForWidth:SCREEN_WIDTH]-40.0;
}
#pragma mark cell的渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTSubjectListCell *pCell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!pCell)
    {
        pCell = [[CMTSubjectListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    @try {
        if (self.mArrSubjects.count > 0)
        {
            if ([[self.mArrSubjects objectAtIndex:indexPath.row]isKindOfClass:[CMTTheme class]])
            {
                CMTTheme *theme = [self.mArrSubjects objectAtIndex:indexPath.row];
                //[pCell.mImageBgImage setImageURL:theme.picture placeholderImage:IMAGE(@"focus_default")];
                [pCell.mImageBgImage setLimitedImageURL:theme.picture placeholderImage:IMAGE(@"focus_default")];
                pCell.mLabelSubjectTitle.text = theme.title;
                pCell.lbUpdateDate.text = [NSString stringWithFormat:@"%@ 更新", DATE_BRIEF(theme.opTime)];
            }
        }
        [pCell.mImageBgImage builtinContainer:pCell.contentView WithLeft:0 Top:0 Width:SCREEN_WIDTH Height:ROW_HEIGHT];
        [pCell.mViewBottom builtinContainer:pCell.contentView WithLeft:0 Top:ROW_HEIGHT-40.5 Width:SCREEN_WIDTH Height:40.5];
//        [pCell.mLabelSubjectTitle builtinContainer:pCell.contentView WithLeft:20 Top:ROW_HEIGHT-40.5 Width:SCREEN_WIDTH/3*2+25 Height:40.5];
        [pCell.mLabelSubjectTitle builtinContainer:pCell.contentView WithLeft:19.5 Top:ROW_HEIGHT-40.5 Width:tableView.width - 19.5 - (19.5+95.0) Height:40.5];
         pCell.mLabelSubjectTitle.textAlignment = NSTextAlignmentLeft;
        //显示更新日期的标签 修改了间距 add by guoyuanchao
        [pCell.lbUpdateDate builtinContainer:pCell.contentView WithLeft:tableView.width - 19.5 - 95 Top:ROW_HEIGHT-40.5 Width:95 Height:40.5];
        pCell.lbUpdateDate.textAlignment = NSTextAlignmentRight;
        
        pCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    @catch (NSException *exception) {
        CMTLog(@"从集合中获取专题对象数量失败");
    }
    return pCell;
}

#pragma mark 选中动作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"section:%ld,row:%ld",(long)indexPath.section,(long)indexPath.row);
    NSInteger row  = indexPath.row;
    CMTTheme *theme;
    @try {
        if (self.mArrSubjects > 0)
        {
            theme = [self.mArrSubjects objectAtIndex:row];
            CMTOtherPostListViewController *pOtherVC = [[CMTOtherPostListViewController alloc] initWithThemeId:theme.themeId
                                                                                                        postId:theme.postId
                                                                                                        isHTML:theme.isHTML
                                                                                                       postURL:theme.url];
            pOtherVC.indexPath = indexPath;
            pOtherVC.updateLive=^(CMTLive* live){

                CMTAPPCONFIG.refreshmodel=@"2";
            };
            [self.navigationController pushViewController:pOtherVC animated:YES];
        }
    }
    @catch (NSException *exception) {
        CMTLog(@"跳转到专题页失败");
    }
}



#pragma mark touch 方法
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.mReloadBaseView.hidden == NO)
    {
        [self getSubjectList:@{}];
    }
}


#pragma mark 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark 视图将要消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.needRequest = NO;
    
#pragma mark 清空未读专题文章数
    
    [CMTAPPCONFIG clearThemeUnreadNumber];
}

#pragma mark  ----- 属性列表 -----
- (UITableView *)mTableView
{
    if (!_mTableView)
    {
        _mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mTableView;
}

- (NSMutableArray *)mArrSubjects
{
    if (!_mArrSubjects)
    {
        _mArrSubjects = [NSMutableArray array];
    }
    return _mArrSubjects;
}

- (NSMutableArray *)mArrShowSubjects
{
    if (!_mArrShowSubjects) {
        _mArrShowSubjects = [NSMutableArray array];
    }
    return _mArrShowSubjects;
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
        _mLbNoCollection = [[UILabel alloc]initWithFrame:CGRectMake(100*RATIO, 259, SCREEN_WIDTH-200*RATIO, 30)];
        _mLbNoCollection.textAlignment = NSTextAlignmentCenter;
        _mLbNoCollection.textColor = [UIColor colorWithRed:164.0/255 green:164.0/255 blue:164.0/255 alpha:1.0];
        _mLbNoCollection.centerX = self.view.centerX;
        _mLbNoCollection.text = @"还没有订阅专题";
    }
    return _mLbNoCollection;
}

@end
