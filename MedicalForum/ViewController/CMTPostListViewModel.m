//
//  CMTPostListViewModel.m
//  MedicalForum
//
//  Created by fenglei on 14/12/30.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTPostListViewModel.h"
#import "SVPullToRefresh.h"

NSString * const CMTPostListCellIdentifier = @"CMTHomePostListCell";
NSString * const CMTLiveListCellIdentifier = @"CMTHomeLiveListCell";


static const CGFloat CMTPostListSectionHeaderDefaultHeight = 25.0;
static const CGFloat CMTPostListCellDefaultHeight = 87.5;

static NSString * const CMTPostListSectionPostDateKey = @"PostDate";
static NSString * const CMTPostListSectionPostArrayKey = @"PostArray";
static NSString * const CMTPostListRequestDefaultPageSize = @"30";

@interface CMTPostListViewModel ()

// binding
@property (nonatomic, assign, readwrite) BOOL focusListRequestFinish;       // 焦点图列表 请求完成
@property (nonatomic, assign, readwrite) BOOL focusListRequestEmpty;        // 焦点图列表 请求为空
@property (nonatomic, assign, readwrite) BOOL LiveListRequestEmpty;         //直播列表请求为空

@property (nonatomic, assign, readwrite) BOOL launchLoadCacheFinish;                        // 文章列表 启动读取缓存完成
@property (nonatomic, assign, readwrite) BOOL postListRequestFinish;                        // 文章列表 请求完成
@property (nonatomic, copy, readwrite) NSString *postListRequestEmptyMessage;               // 文章列表 请求为空提示
@property (nonatomic, copy, readwrite) NSError *postListRequestNetError;                    // 文章列表 请求网络错误
@property (nonatomic, copy, readwrite) NSString *postListRequestServerErrorMessage;         // 文章列表 请求服务器错误提示
@property (nonatomic, copy, readwrite) NSString *postListRequestSystemErrorMessage;         // 文章列表 请求系统错误提示

// data
@property (nonatomic, copy, readwrite) NSArray *cacheFocusList;         // 焦点图列表 缓存
@property(nonatomic,copy,readwrite)NSArray *caseLivelist ;              //直播列表缓存
@property(nonatomic,copy,readwrite)CMTPost *topArticles;                //置顶文章
@property (nonatomic, copy) NSArray *cachePostList;                     // 文章列表 缓存
@property (nonatomic, copy) NSArray *postSectionList;                   // 文章列表 分组

@end

@implementation CMTPostListViewModel

#pragma mark Initializers

// 请求焦点图列表
- (RACSignal *)requestFocusListSignal {
    @weakify(self);
    
    // 强制刷新
    RACSignal *resetSignal = [RACObserve(self, resetState) ignore:@NO];
    
    // 刷新
    RACSignal *refreshSignal = [RACObserve(self, pullToRefreshState) filter:^BOOL(NSNumber *state) {
        @strongify(self);
        return self.resetState == NO && state.integerValue == SVPullToRefreshStateLoading;
    }];
    
    return [[[RACSignal merge:@[
                                resetSignal,
                                refreshSignal,
                                ]]
             deliverOn:[RACScheduler scheduler]] map:^id(id value) {
        NSString *concernIds = nil;
        @try {
            NSArray *subscriptions = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
            concernIds = [[[subscriptions.rac_sequence map:^id(CMTFollow *follow) {
                if ([follow respondsToSelector:@selector(subjectId)]) return follow.subjectId;
                else return @"";
            }] array] componentsJoinedByString:@","];
        }
        @catch (NSException *exception) {
            concernIds = nil;
            CMTLogError(@"PostList Assemble ConcernID Exception: %@", exception);
        }
        
        return [CMTCLIENT get_live_list_focus:@{
                                         @"userId": CMTUSERINFO.userId ?: @"",
                                         @"concernIds": concernIds ?: @"",
                                         }];
    }];
}

// 请求文章列表
- (RACSignal *)requestPostListSignal {
    @weakify(self);
    
    // 强制刷新
    RACSignal *resetSignal = [[RACObserve(self, resetState) ignore:@NO] map:^id(id value) {
        return @{
                 @"incrId": @"",
                 @"incrIdFlag": @"0",
                 @"mode": [NSNumber numberWithInteger:CMTClientRequestModeReset],
                 };
    }];
    
    // 刷新
    RACSignal *refreshSignal = [[RACObserve(self, pullToRefreshState) filter:^BOOL(NSNumber *state) {
        @strongify(self);
        return self.resetState == NO && state.integerValue == SVPullToRefreshStateLoading;
    }] map:^id(id value) {
        @strongify(self);
        CMTPost *firstPost = self.cachePostList.firstObject;
        return @{
                 @"incrId": firstPost.incrId ?: @"",
                 @"incrIdFlag": @"0",
                 @"mode": [NSNumber numberWithInteger:CMTClientRequestModeRefresh],
                 };
    }];
    
    // 翻页
    RACSignal *loadMoreSignal = [[RACObserve(self, infiniteScrollingState) filter:^BOOL(NSNumber *state) {
        @strongify(self);
        return self.resetState == NO && state.integerValue == SVInfiniteScrollingStateLoading;
    }] map:^id(id value) {
        @strongify(self);
        CMTPost *lastPost = self.cachePostList.lastObject;
        return @{
                 @"incrId": lastPost.incrId ?: @"",
                 @"incrIdFlag": @"1",
                 @"mode": [NSNumber numberWithInteger:CMTClientRequestModeLoadMore],
                 };
    }];
    
    return [[[RACSignal merge:@[
                                resetSignal,
                                refreshSignal,
                                loadMoreSignal,
                                ]]
             deliverOn:[RACScheduler scheduler]] map:^id(NSDictionary *dictionary) {
        @strongify(self);
        return @{
                 @"mode": dictionary[@"mode"],
                 @"signal": [self getPostListWithIncrId:dictionary[@"incrId"] incrIdFlag:dictionary[@"incrIdFlag"]],
                 };
    }];
}

// 请求文章列表接口
- (RACSignal *)getPostListWithIncrId:(NSString *)incrId incrIdFlag:(NSString *)incrIdFlag {
    NSString *concernIds = nil;
    @try {
        NSArray *subscriptions = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
        concernIds = [[[subscriptions.rac_sequence map:^id(CMTFollow *follow) {
            if ([follow respondsToSelector:@selector(subjectId)]) return follow.subjectId;
            else return @"";
        }] array] componentsJoinedByString:@","];
    }
    @catch (NSException *exception) {
        concernIds = nil;
        CMTLogError(@"PostList Assemble ConcernID Exception: %@", exception);
    }
    
    return [CMTCLIENT getPostList:@{
                                    @"userId": CMTUSERINFO.userId ?: @"",
                                    @"concernIds": concernIds ?: @"",
                                    @"incrId": incrId ?: @"",
                                    @"incrIdFlag": incrIdFlag ?: @"",
                                    @"pageSize": CMTPostListRequestDefaultPageSize ?: @"",
                                    @"module": @"0",
                                    }];
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList ViewModel willDeallocSignal");
    }];
    
#pragma mark 请求焦点图列表
    
    [[self requestFocusListSignal] subscribeNext:^(RACSignal *getFocusListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getFocusListSignal subscribeNext:^(CMTLiveListData *focusList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            [self handleFocusList:focusList];
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            @try {
                NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                if ([errorCode integerValue] > 100) {
                    CMTLogError(@"PostList Request Foucs List Error: %@", error);
                } else {
                    CMTLogError(@"PostList Request Foucs List System Error: %@", error);
                }
            }
            @catch (NSException *exception) {
                CMTLogError(@"PostList handleError:%@\nException: %@", error, exception);
            }
        }]];
    }];
    
#pragma mark 请求文章列表
    
    [[self requestPostListSignal] subscribeNext:^(NSDictionary *getPostListSignalDictionary) {
        @strongify(self);
        [MobClick event:@"P_List_Home"];

        CMTClientRequestMode getPostListRequestMode = [getPostListSignalDictionary[@"mode"] integerValue];
        RACSignal *getPostListSignal = getPostListSignalDictionary[@"signal"];
        [self.rac_deallocDisposable addDisposable:
         [getPostListSignal subscribeNext:^(NSArray *postList) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            // 强制刷新
            if (getPostListRequestMode == CMTClientRequestModeReset) {
                [self handleResetPostList:postList];
            }
            // 刷新
            else if (getPostListRequestMode == CMTClientRequestModeRefresh) {
                [self handleRefreshPostList:postList];
            }
            // 翻页
            else if (getPostListRequestMode == CMTClientRequestModeLoadMore) {
                [self handleLoadMorePostList:postList];
            }
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleError:error];
        }]];
    }];
    
#pragma mark 启动进入
    
    // 启动读取缓存
    self.launchLoadCacheState = YES;
    
    // 读取缓存焦点图列表
    [self loadFocusList];
    
    // 读取缓存文章列表
    [self loadPostList];
    
    // 强制刷新
    self.resetState = YES;
    
#pragma 获取通知
    
    [[RACObserve(CMTAPPCONFIG, getNotification) ignore:@NO] subscribeNext:^(id x) {
        @strongify(self);
        
        // 强制刷新
        self.resetState = YES;
    }];
#pragma 学科上传成功
    [[RACObserve(CMTUSER, SysSubjectSuccess) ignore:@NO] subscribeNext:^(id x) {
        @strongify(self);
        
        // 强制刷新
        self.resetState = YES;
        CMTUSER.SysSubjectSuccess=NO;
    }];

#pragma mark 切换用户

    [[RACSignal merge:@[[CMTUSER loginSignal] ?: [RACSignal empty],
                        [CMTUSER logoutSignal] ?: [RACSignal empty]
                        ]]
     subscribeNext:^(id x) {
         @strongify(self);
         if(CMTUSER.login){
         // 强制刷新
             if (CMTUSER.SysSubjectSuccess) {
                 self.resetState = YES;
                  CMTUSER.SysSubjectSuccess=NO;

             }
         }else{
             self.resetState = YES;

         }
         
     }];
    
#pragma mark 修改订阅
    
    // 订阅信息初始没有改动
    self.subscriptionChange = NO;
    [[CMTUSER subscriptionChangeSignal] subscribeNext:^(id x) {
        @strongify(self);
        
        // 订阅信息有改动
        self.subscriptionChange = YES;
    }];
    
    return self;
}

#pragma mark LifeCycle

#pragma mark Handle FocusList

// 焦点图列表 刷新
- (void)handleFocusList:(CMTLiveListData *)focusList {
    @try {
        if(focusList.topArticles.postId!=nil){
            self.topArticles=focusList.topArticles;
            self.topArticles.istop=@"1";
        }else{
            self.topArticles=nil;
        }
        // empty list
        if ([focusList.focusPicList count] == 0) {
            // 焦点图列表 清空缓存
            _cacheFocusList = nil;
            self.focusListRequestEmpty = YES;
            [NSKeyedArchiver archiveRootObject:@[] toFile:PATH_CACHE_FOCUSLIST];
        }
        // not empty
        else {
            self.cacheFocusList = focusList.focusPicList;
        }
        if ([focusList.liveList count]==0) {
            _caseLivelist = nil;
            self.LiveListRequestEmpty = YES;
            [NSKeyedArchiver archiveRootObject:@[] toFile:PATH_CACHE_LIVELIST];
        }else{
            self.caseLivelist=focusList.liveList;
           [NSKeyedArchiver archiveRootObject:self.caseLivelist toFile:PATH_CACHE_LIVELIST];
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"PostList Request NewFocusList Exception: %@", exception);
    }
}

// 加载焦点图列表
- (void)loadFocusList {
    // 读取缓存焦点图列表
    NSArray *unarchivedFocusList = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_FOCUSLIST];
    if ([unarchivedFocusList respondsToSelector:@selector(count)]) {
        if ([unarchivedFocusList count] > 0) {
            self.cacheFocusList = unarchivedFocusList;
        }
    }
    NSArray *unarchivedLiveList = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_LIVELIST];
    if ([unarchivedLiveList respondsToSelector:@selector(count)]) {
        if ([unarchivedLiveList count] > 0) {
            self.caseLivelist = unarchivedLiveList;
        }else{
            self.caseLivelist=nil;
        }
    }

}

// 焦点图列表 显示 缓存
- (void)setCacheFocusList:(NSArray *)cacheFocusList {
    if (_cacheFocusList == cacheFocusList) return;
    
    // 刷新缓存列表
    _cacheFocusList = [cacheFocusList copy];
    // 刷新视图
    self.focusListRequestFinish = YES;
    // 存储
    if (![NSKeyedArchiver archiveRootObject:cacheFocusList toFile:PATH_CACHE_FOCUSLIST]) {
        CMTLogError(@"PostList Archive FocusList:%@\nto Store Error: %@", cacheFocusList, PATH_CACHE_POSTLIST);
    }
}

// 焦点图列表 手动缓存
- (void)saveCacheFocusList {
    @weakify(self);
    [[RACScheduler scheduler] schedule:^{
        @strongify(self);
        // 存储
        if (![NSKeyedArchiver archiveRootObject:self.cacheFocusList toFile:PATH_CACHE_FOCUSLIST]) {
            CMTLogError(@"PostList Archive FocusList:%@\nto Store Error: %@", self.cacheFocusList, PATH_CACHE_FOCUSLIST);
        }
    }];
}

#pragma mark Handle PostList

// 文章列表 强制刷新
- (void)handleResetPostList:(NSArray *)resetPostList {
    @try {
        // empty list
        if ([resetPostList count] == 0) {
            self.postListRequestEmptyMessage = @"没有最新文章";
            return;
        }
        // 覆盖缓存文章列表
        if (![NSKeyedArchiver archiveRootObject:resetPostList toFile:PATH_CACHE_POSTLIST]) {
            CMTLogError(@"PostList Archive ResetPostList:%@\nto Store Error: %@", resetPostList, PATH_CACHE_POSTLIST);
        }
        // 加载文章列表
        [self loadPostList];
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostList Request ResetPostList Exception: %@", exception];
    }
}

// 文章列表 刷新
- (void)handleRefreshPostList:(NSArray *)refreshPostList {
    @try {
        // empty list
        if ([refreshPostList count] == 0) {
            self.postListRequestEmptyMessage = @"没有最新文章";
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:refreshPostList];
        [combindList addObjectsFromArray:self.cachePostList];
        // sort list
        NSMutableArray *sortedList = [NSMutableArray arrayWithArray:[self sortPostList:combindList]];
        // cut short list
        NSUInteger pageSize = CMTPostListRequestDefaultPageSize.integerValue;
        while (sortedList.count > pageSize) {
            [sortedList removeObjectAtIndex:pageSize];
        }
        // 覆盖缓存文章列表
        if (![NSKeyedArchiver archiveRootObject:sortedList toFile:PATH_CACHE_POSTLIST]) {
            CMTLogError(@"PostList Archive RefreshPostList:%@\nto Store Error: %@", sortedList, PATH_CACHE_POSTLIST);
        }
        // 加载文章列表
        [self loadPostList];
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostList Request RefreshPostList Exception: %@", exception];
    }
}

// 文章列表 翻页
- (void)handleLoadMorePostList:(NSArray *)loadMorePostList {
    @try {
        // empty list
        if ([loadMorePostList count] == 0) {
            self.postListRequestEmptyMessage = @"没有更多文章";
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:self.cachePostList];
        [combindList addObjectsFromArray:loadMorePostList];
        // sort list
        NSMutableArray *sortedList = [NSMutableArray arrayWithArray:[self sortPostList:combindList]];
        // 覆盖缓存文章列表
        if (![NSKeyedArchiver archiveRootObject:sortedList toFile:PATH_CACHE_POSTLIST]) {
            CMTLogError(@"PostList Archive LoadMorePostList:%@\nto Store Error: %@", sortedList, PATH_CACHE_POSTLIST);
        }
        // 加载文章列表
        [self loadPostList];
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostList Request loadMorePostList Exception: %@", exception];
    }
}

// 加载文章列表
- (void)loadPostList {
    // 读取缓存文章列表
    NSArray * unarchivedPostList = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_POSTLIST];
    if ([unarchivedPostList respondsToSelector:@selector(count)]) {
        if ([unarchivedPostList count] > 0) {
            self.cachePostList = unarchivedPostList;
        }
        else {
            [self handleErrorMessage:@"PostList LoadPostList Error: UnarchivedPostList is empty array"];
        }
    }
    else {
        if (unarchivedPostList != nil) {
            [self handleErrorMessage:@"PostList LoadPostList Error: UnarchivedPostList is not array"];
        }
    }
}

// 文章列表 按incrId排序
- (NSArray *)sortPostList:(NSArray *)postList {
    return [postList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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

// 文章列表 分组 排序 显示
- (void)setCachePostList:(NSArray *)cachePostList {
    if (_cachePostList == cachePostList) return;
    
    @try {
        // 按incrId排序
        NSArray *sortedPostList = [self sortPostList:cachePostList];
        // 按创建时间分组
        NSMutableArray *postSections = [NSMutableArray array];
        
        int index = 0;
        for (CMTPost *post in sortedPostList) {
            // 获取当前条目的创建时间
            NSString *createTime = DATE(post.createTime);
            if (BEMPTY(createTime)) {
                [self handleErrorMessage:@"PostList Group PostList: %@\nError: Empty CreateTime at Index: [%d]", sortedPostList, index];
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
            _cachePostList = [sortedPostList copy];
            // 刷新分组列表
            self.postSectionList = [NSArray arrayWithArray:postSections];
            // 刷新视图
            if (self.launchLoadCacheState == YES) {
                self.launchLoadCacheState = NO;
                self.launchLoadCacheFinish = YES;
            }
            else {
                self.postListRequestFinish = YES;
            }
        }
        else {
            [self handleErrorMessage:@"PostList Group PostList Error: Empty PostSection"];
        }
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"PostList Group PostList Exception: %@", exception];
    }
}

// 文章列表 手动缓存
- (void)saveCachePostList {
    @weakify(self);
    [[RACScheduler scheduler] schedule:^{
        @strongify(self);
        // 存储
        if (![NSKeyedArchiver archiveRootObject:self.cachePostList toFile:PATH_CACHE_POSTLIST]) {
            CMTLogError(@"PostList Archive PostList:%@\nto Store Error: %@", self.cachePostList, PATH_CACHE_POSTLIST);
        }
    }];
}

// 文章列表 错误提示
- (void)handleError:(NSError *)error {
    // 网络错误
    if ([error.domain isEqual:NSURLErrorDomain]) {
        
        self.postListRequestNetError = error;
    }
    // 服务器返回错误
    else if ([error.domain isEqual:CMTClientServerErrorDomain]) {
        // 业务参数错误
        if ([error.userInfo[CMTClientServerErrorCodeKey] integerValue] > 100) {
            
            self.postListRequestServerErrorMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        }
        // 系统错误/错误代码格式错误
        else {
            
            self.postListRequestSystemErrorMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        }
    }
    // 解析错误/未知错误
    else {
        
        self.postListRequestSystemErrorMessage = error.localizedDescription;
    }
}

// 文章列表 错误信息
- (void)handleErrorMessage:(NSString *)errorMessgae, ... {
    NSString *errorString = nil;
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            errorString = [[NSString alloc] initWithFormat:errorMessgae arguments:args];
            va_end(args);
        }
        self.postListRequestSystemErrorMessage = errorString;
    }
    @catch (NSException *exception) {
        self.postListRequestSystemErrorMessage = [NSString stringWithFormat:@"PostList HandleErrorMessage Exception: %@", exception];
    }
}

#pragma mark TableView

- (NSInteger)numberOfSections {
    NSInteger numberOfSections = 0;
    @try {
        if ([self.caseLivelist count]!=0) {
             numberOfSections =[self.postSectionList count]+1;
        }else{
             numberOfSections =[self.postSectionList count];
        }
       
    }
    @catch (NSException *exception) {
        numberOfSections = 0;
        CMTLogError(@"PostList -numberOfSections Exception: %@", exception);
    }
    
    return numberOfSections;
}

- (NSDictionary *)postSectionInSection:(NSInteger)section {
    NSDictionary *postSection = nil;
    @try {
        postSection = self.postSectionList[section];
    }
    @catch (NSException *exception) {
        postSection = nil;
        CMTLogError(@"PostList -postSectionInSection Exception: %@", exception);
    }
    
    return postSection;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRowsInSection = 0;
    @try {
        if ([self.caseLivelist count]!=0){
            if (section==0) {
                numberOfRowsInSection=[self.caseLivelist count];
            }else{
                NSArray *postArray = [self postSectionInSection:section-1][CMTPostListSectionPostArrayKey];
                numberOfRowsInSection = [postArray count];

            }
        }else{
            NSArray *postArray = [self postSectionInSection:section][CMTPostListSectionPostArrayKey];
            numberOfRowsInSection = [postArray count];

        }

           }
    @catch (NSException *exception) {
        numberOfRowsInSection = 0;
        CMTLogError(@"PostList -numberOfRowsInSection Exception: %@", exception);
    }
    
    return numberOfRowsInSection;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    return CMTPostListSectionHeaderDefaultHeight;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CMTPostListCellDefaultHeight;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSString *titleForHeaderInSection = @"";
    @try {
        if ([self.caseLivelist count]!=0){
            if (section==0) {
                titleForHeaderInSection=@"";
            }else{
                titleForHeaderInSection = [self postSectionInSection:section-1][CMTPostListSectionPostDateKey];
            }
        }else{
            titleForHeaderInSection = [self postSectionInSection:section][CMTPostListSectionPostDateKey];
        }
        
    }
    @catch (NSException *exception) {
        titleForHeaderInSection = @"";
        CMTLogError(@"PostList -titleForHeaderInSection Exception: %@", exception);
    }
    
    return titleForHeaderInSection;
}

- (CMTPost *)postForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTPost *post = nil;
    @try {
        if ([self.caseLivelist count]==0) {
            NSArray *postArray = [self postSectionInSection:indexPath.section][CMTPostListSectionPostArrayKey];
            post = postArray[indexPath.row];
        }else{
            NSArray *postArray = [self postSectionInSection:indexPath.section-1][CMTPostListSectionPostArrayKey];
            post = postArray[indexPath.row];
        }
        
    }
    @catch (NSException *exception) {
        post = nil;
        CMTLogError(@"PostList -postForRowAtIndexPath Exception: %@", exception);
    }
    
    return post;
}
- (CMTLive *)liveForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTLive *live = nil;
    @try {
        NSArray *postArray =self.caseLivelist;
        live = postArray[indexPath.row];
    }
    @catch (NSException *exception) {
        live = nil;
        CMTLogError(@"PostList -postForRowAtIndexPath Exception: %@", exception);
    }
    
    return live;

}

@end
