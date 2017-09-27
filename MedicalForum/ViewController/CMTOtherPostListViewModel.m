//
//  CMTOtherPostListViewModel.m
//  MedicalForum
//
//  Created by fenglei on 15/1/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTOtherPostListViewModel.h"
#import "SVPullToRefresh.h"

NSString * const CMTOtherPostListCellIdentifier = @"CMTOtherPostListCell";
NSString * const CMTGuidePostListCellIdentifier = @"CMTGuidePostListCell";
NSString * const CMTOtherLiveListCellIdentifier = @"CMTOtherLiveListCell";

static const CGFloat CMTPostListSectionHeaderDefaultHeight = 25.0;
static const CGFloat CMTPostListCellDefaultHeight = 87.5;

static NSString * const CMTPostListSectionPostDateKey = @"PostDate";
static NSString * const CMTPostListSectionPostArrayKey = @"PostArray";
static NSString * const CMTPostListRequestDefaultPageSize = @"30";

@interface CMTOtherPostListViewModel ()

// binding
@property (nonatomic, assign, readwrite) BOOL requestPostFinish;                                // 请求完成
@property (nonatomic, copy, readwrite) NSString *resetPostEmptyString;                          // 强制刷新为空
@property (nonatomic, copy, readwrite) NSString *requestNewPostEmptyString;                     // 请求刷新为空
@property (nonatomic, copy, readwrite) NSString *requestMorePostEmptyString;                    // 请求翻页为空
@property (nonatomic, assign, readwrite) BOOL requestPostNetError;                              // 请求网络错误
@property (nonatomic, copy, readwrite) NSString *requestPostServerErrorMessage;                 // 请求服务器错误消息
@property (nonatomic, copy, readwrite) NSString *requestPostSystemErrorString;                  // 请求系统错误信息

@property (nonatomic, assign, readwrite) BOOL requestThemeSpecifiedPostNotExist;                // 请求专题指定文章不存在

// data
@property (nonatomic, copy, readwrite) NSString *authorId;                                      // 作者Id
@property (nonatomic, copy, readwrite) NSString *postTypeId;                                    // 文章类型Id
@property (nonatomic, copy, readwrite) NSString *disease;                                       // 疾病名
@property (nonatomic, copy, readwrite) NSString *diseaseIds;                                    // 疾病Ids
@property (nonatomic, copy, readwrite) NSString *module;                                        // 文章module
@property (nonatomic, copy, readwrite) NSString *keyWord;                                       // 二级标签
@property (nonatomic, copy, readwrite) NSString *subjectId;                                     // 学科Id
@property (nonatomic, copy, readwrite) NSString *themeId;                                       // 专题Id
@property (nonatomic, copy, readwrite) NSString *themeUuid;                                       // 专题uid
@property (nonatomic, copy, readwrite) NSString *postId;                                        // 文章Id
@property (nonatomic, copy, readwrite) NSString *isHTML;                                        // 是否为动态详情页
@property (nonatomic, copy, readwrite) NSString *postURL;                                       // 动态详情页url

@property (nonatomic, copy, readwrite) CMTTheme *theme;                                         // 专题
@property(nonatomic,copy,readwrite)CMTLive *liveinfo;                                           //直播

@property (nonatomic, assign) BOOL withoutPostSection;                                          // 不按时间分组
@property (nonatomic, assign) BOOL firstFresh;                                                  // 文章列表 首次刷新
@property (nonatomic, copy) NSArray *cachePostList;                                             // 缓存列表
@property (nonatomic, copy) NSArray *postSectionList;                                           // 分组列表

@end

@implementation CMTOtherPostListViewModel

- (NSMutableArray *)arrayTheme {
    if (_arrayTheme == nil) {
        _arrayTheme = [NSMutableArray array];
    }
    
    return _arrayTheme;
}

- (NSMutableArray *)arrayThemeShow {
    if (!_arrayThemeShow) {
        _arrayThemeShow = [NSMutableArray array];
    }
    
    return _arrayThemeShow;
}

#pragma mark 文章列表 Request

// 强制刷新
- (RACSignal *)resetPostListSignal {
    @weakify(self);
    return [[RACObserve(self, resetState) ignore:@NO] map:^id(id value) {
        @strongify(self);
        return [self getPostListWithIncrId:@"0" incrIdFlag:@"0"];
    }];
}

// 刷新
- (RACSignal *)requestNewPostListSignal {
    @weakify(self);
    return [[RACObserve(self, pullToRefreshState)
             filter:^BOOL(NSNumber *state) {
                 return state.integerValue == SVPullToRefreshStateLoading;
             }] map:^id(id value) {
                 @strongify(self);
                 CMTPost *firstPost = self.cachePostList.firstObject;
                 return [self getPostListWithIncrId:firstPost.incrId incrIdFlag:@"0"];
             }];
}

// 翻页
- (RACSignal *)requestMorePostListSignal {
    @weakify(self);
    return [[RACObserve(self, infiniteScrollingState)
             filter:^BOOL(NSNumber *state) {
                 return state.integerValue == SVInfiniteScrollingStateLoading;
             }] map:^id(id value) {
                 @strongify(self);
                 CMTPost *lastPost = self.cachePostList.lastObject;
                 return [self getPostListWithIncrId:lastPost.incrId incrIdFlag:@"1"];
             }];
}

// 请求文章列表
- (RACSignal *)getPostListWithIncrId:(NSString *)incrId incrIdFlag:(NSString *)incrIdFlag {
    // 按作者
    if (self.authorId != nil) {
        return [CMTCLIENT getPostListByAuthor:@{
                                                @"authorId": self.authorId ?: @"",
                                                @"incrId": incrId ?: @"",
                                                @"incrIdFlag": incrIdFlag ?: @"",
                                                @"pageSize": CMTPostListRequestDefaultPageSize ?: @"",
                                                }];
    }
    // 按类型
    else if (self.postTypeId != nil) {
        return [CMTCLIENT searchPostInType:@{
                                             @"postTypeId": self.postTypeId ?: @"",
                                             @"incrId": incrId ?: @"",
                                             @"pageSize": CMTPostListRequestDefaultPageSize ?: @"",
                                             }];
    }
    // 按疾病标签
    else if (self.diseaseIds != nil) {
        CMTPost *lastPost = self.cachePostList.lastObject;
        return [CMTCLIENT getPostListByDisease:@{
                                                 @"userId": CMTUSERINFO.userId ?: @"",
                                                 @"diseaseIds": !BEMPTY(self.diseaseIds) ? self.diseaseIds : @"0",
                                                 @"module": self.module ?: @"",
                                                 @"callbackParam": lastPost.callbackParam ?: @"",
                                                 @"incrId": incrId ?: @"",
                                                 @"incrIdFlag": incrIdFlag ?: @"",
                                                 @"pageSize": CMTPostListRequestDefaultPageSize ?: @"",
                                                 }];
    }
    // 按二级标签
    else if (self.keyWord != nil) {
        return [CMTCLIENT getPostListBySearchKeyword:@{
                                                       @"tag": self.keyWord ?: @"",
                                                       @"module": self.module ?: @"",
                                                       @"incrId": incrId ?: @"",
                                                       @"pageSize": CMTPostListRequestDefaultPageSize ?: @"",
                                                       }];
    }
    // 按学科
    else if (self.subjectId != nil) {
        return [CMTCLIENT getPostListInSubject:@{
                                                 @"userId": CMTUSERINFO.userId ?: @"",
                                                 @"subjectId": self.subjectId ?: @"",
                                                 @"module": self.module ?: @"",
                                                 @"incrId": incrId ?: @"",
                                                 @"incrIdFlag": incrIdFlag ?: @"",
                                                 @"pageSize": CMTPostListRequestDefaultPageSize ?: @"",
                                                 }];
    }
    // 按专题
    else if (self.themeId != nil||self.themeUuid != nil) {
        return [CMTCLIENT getThemePostList:@{
                                             @"userId": CMTUSERINFO.userId ?: @"",
                                             @"themeUUID":self.themeUuid?:@"",
                                             @"themeId": self.themeId ?: @"",
                                             @"postId": self.postId ?: @"",
                                             @"incrId": incrId ?: @"",
                                             @"incrIdFlag": incrIdFlag ?: @"",
                                             @"pageSize": CMTPostListRequestDefaultPageSize ?: @"",
                                             }];
    }
    else {
        
        return nil;
    }
}

#pragma mark Initializers
-(instancetype)initWithThemeUIid:(NSString*)uid{
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    self.withoutPostSection = YES;
    self.themeUuid = uid;
   
    [self initialize];
    return self;
}
// 按作者初始化
- (instancetype)initWithAuthorId:(NSString *)authorId {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    self.withoutPostSection = NO;
    self.authorId = authorId;
    [self initialize];
    
    return self;
}

// 按类型初始化
- (instancetype)initWithPostTypeId:(NSString *)postTypeId {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.postTypeId = postTypeId;
    [self initialize];
    
    return self;
}

// 按疾病标签初始化
- (instancetype)initWithDisease:(NSString *)disease
                     diseaseIds:(NSString *)diseaseIds
                         module:(NSString *)module {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.disease = disease;
    self.diseaseIds = diseaseIds;
    self.module = module;
    self.withoutPostSection = YES;
    [self initialize];
    
    return self;
}

// 按二级标签初始化
- (instancetype)initWithKeyword:(NSString *)keyWord
                         module:(NSString *)module {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.keyWord = keyWord;
    self.module = module;
    [self initialize];
    
    return self;
}

// 按学科初始化
- (instancetype)initWithSubjectId:(NSString *)subjectId
                           module:(NSString *)module {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.subjectId = subjectId;
    self.module = module;
    [self initialize];
    
    return self;
}


// 按专题初始化
- (instancetype)initWithThemeId:(NSString *)themeId
                         postId:(NSString *)postId
                         isHTML:(NSString *)isHTML
                        postURL:(NSString *)postURL {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.themeId = themeId;
    self.postId = postId;
    self.isHTML = isHTML;
    self.postURL = postURL;
    self.withoutPostSection = YES;
    [self initialize];
    
    return self;
}

- (void)initialize {
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"OtherPostList ViewModel willDeallocSignal");
    }];
    
#pragma 学科上传成功
    [[RACObserve(CMTUSER, SysSubjectSuccess) ignore:@NO] subscribeNext:^(id x) {
        @strongify(self);
        
        // 强制刷新
        self.resetState = YES;
        CMTUSER.SysSubjectSuccess=NO;
    }];

#pragma mark 文章列表 initialize
    
    // 处理强制刷新
    [[self resetPostListSignal] subscribeNext:^(RACSignal *getPostListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getPostListSignal subscribeNext:^(id x) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            // 返回专题列表数据
            if ([x isKindOfClass:[CMTThemePostList class]] || [x isKindOfClass:[CMTThemePostOnlyList class]]) {
                [self handleNewThemePostList:x];
            }
            // 返回列表数据或empty
            else {
                [self handleNewList:x];
            }
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleError:error];
        }]];
    }];

    // 处理刷新
    [[self requestNewPostListSignal] subscribeNext:^(RACSignal *getPostListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getPostListSignal subscribeNext:^(id x) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            // 返回专题列表数据
            if ([x isKindOfClass:[CMTThemePostList class]] || [x isKindOfClass:[CMTThemePostOnlyList class]]) {
                [self handleNewThemePostList:x];
            }
            // 返回列表数据或empty
            else {
                [self handleNewList:x];
            }
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleError:error];
        }]];
    }];
    
    // 处理翻页
    [[self requestMorePostListSignal] subscribeNext:^(RACSignal *getPostListSignal) {
        @strongify(self);
        [self.rac_deallocDisposable addDisposable:
         [getPostListSignal subscribeNext:^(id x) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            // 返回专题列表数据
            if ([x isKindOfClass:[CMTThemePostList class]] || [x isKindOfClass:[CMTThemePostOnlyList class]]) {
                [self handleMoreThemePostList:x];
            }
            // 返回列表数据或empty
            else {
                [self handleMoreList:x];
            }
        } error:^(NSError *error) {
            @strongify(self);
            DEALLOC_HANDLE_FAILURE
            [self handleError:error];
        }]];
    }];
    
    // 强制刷新
    self.firstFresh = YES;
    self.resetState = YES;
}


#pragma mark LifeCycle

#pragma mark 文章列表 handle

// 处理刷新专题列表
- (void)handleNewThemePostList:(CMTThemePostList *)themePostList {
    if ([themePostList respondsToSelector:@selector(theme)]) {
        if (themePostList.theme != nil) {
            self.theme = themePostList.theme;
        }
    }
    self.liveinfo=themePostList.liveInfo;
    [self handleNewList:themePostList.items];
}

// 处理翻页专题列表
- (void)handleMoreThemePostList:(CMTThemePostList *)themePostList {
    if ([themePostList respondsToSelector:@selector(theme)]) {
        if (themePostList.theme != nil) {
            self.theme = themePostList.theme;
        }
    }
    self.liveinfo=isEmptyObject(themePostList.liveInfo.liveBroadcastId)?self.liveinfo:themePostList.liveInfo ;
    [self handleMoreList:themePostList.items];
}

// 处理刷新列表
- (void)handleNewList:(NSArray *)newList {
    @try {
        // 强制刷新
        if (self.firstFresh == YES) {
            self.firstFresh = NO;
            // empty list
            if ([newList count] == 0) {
                self.cachePostList = nil;
                self.resetPostEmptyString = @"没有文章";
            }
            else {
                self.cachePostList = newList;
            }
            return;
        }
        // 请求刷新
        // empty list
        if ([newList count] == 0) {
            [self handleNewestListMessage:@"没有最新文章"];
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:newList];
        [combindList addObjectsFromArray:self.cachePostList];
        // cut short list
        NSUInteger pageSize = CMTPostListRequestDefaultPageSize.integerValue;
        while (combindList.count > pageSize) {
            [combindList removeObjectAtIndex:pageSize];
        }
        // group list
        self.cachePostList = combindList;
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"OtherPostList Request New Post List Exception: %@", exception];
    }
}

// 处理翻页列表
- (void)handleMoreList:(NSArray *)moreList {
    @try {
        // empty list
        if ([moreList count] == 0) {
            [self handleNoMoreListMessage:@"没有更多文章"];
            return;
        }
        // combind old list
        NSMutableArray *combindList = [NSMutableArray arrayWithArray:self.cachePostList];
        [combindList addObjectsFromArray:moreList];
        // group list
        self.cachePostList = combindList;
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"OtherPostList Request More Post List Exception: %@", exception];
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

// 列表分组 显示 缓存
- (void)setCachePostList:(NSArray *)cachePostList {
    if (_cachePostList == cachePostList) return;
    
    @try {
        
        // 不按时间分组
        // 无缓存 不按incrId排序
        if (self.withoutPostSection == YES) {
            // 刷新缓存列表
            _cachePostList = [cachePostList copy];
            // 刷新视图
            self.requestPostFinish = YES;
            return;
        }
        
        // 按时间分组
        // 先按incrId排序
        NSArray *sortedPostList = [self sortPostList:cachePostList];
        // 再按创建时间分组
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
            _cachePostList = [cachePostList copy];
            // 刷新分组列表
            self.postSectionList = [NSArray arrayWithArray:postSections];
            // 刷新视图
            self.requestPostFinish = YES;
        } else {
            [self handleErrorMessage:@"OtherPostList Group Post List Error: Empty PostSection"];
        }
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"OtherPostList Group Post List Exception: %@", exception];
    }
}

// 最新
- (void)handleNewestListMessage:(NSString *)message {
    @try {
        if ([self.cachePostList count] > CMTPostListRequestDefaultPageSize.integerValue) {
            // cut short list
            NSMutableArray *cutShortList = [NSMutableArray arrayWithArray:self.cachePostList];
            NSUInteger pageSize = CMTPostListRequestDefaultPageSize.integerValue;
            while (cutShortList.count > pageSize) {
                [cutShortList removeObjectAtIndex:pageSize];
            }
            // group list
            self.cachePostList = cutShortList;
        }
        self.requestNewPostEmptyString = message;
    }
    @catch (NSException *exception) {
        [self handleErrorMessage:@"OtherPostList handle NewestListMessage Exception: %@", exception];
    }
}

// 没有更多
- (void)handleNoMoreListMessage:(NSString *)message {
    self.requestMorePostEmptyString = message;
}

/// '所有疾病标签'文章列表 刷新数据
- (void)updateDiseaseIds:(NSString *)diseaseIds {
    if ([self.diseaseIds isEqual:diseaseIds]) {
        return;
    }
    
    self.diseaseIds = diseaseIds;
    // 强制刷新
    self.firstFresh = YES;
    self.resetState = YES;
}

// 处理错误
- (void)handleError:(NSError *)error {
    // 网络错误
    if ([error.domain isEqual:NSURLErrorDomain]) {
        
        self.requestPostNetError = YES;
    }
    // 服务器返回错误
    else if ([error.domain isEqual:CMTClientServerErrorDomain]) {
        // 业务参数错误
        if ([error.userInfo[CMTClientServerErrorCodeKey] integerValue] > 100) {
            // 专题101错误: 指定文章不在专题中
            if (self.themeId != nil && [error.userInfo[CMTClientServerErrorCodeKey] integerValue] == 101) {
                
                self.requestThemeSpecifiedPostNotExist = YES;
            }
            // 其他业务参数错误
            else {
                self.requestPostServerErrorMessage = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            }
        }
        // 系统错误/错误代码格式错误
        else {
            self.requestPostSystemErrorString = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
        }
    }
    // 解析错误/未知错误
    else {
        self.requestPostSystemErrorString = error.localizedDescription;
    }
}

// 处理错误信息
- (void)handleErrorMessage:(NSString *)errorMessgae, ... {
    NSString *errorString = nil;
    @try {
        va_list args;
        if (errorMessgae) {
            va_start(args, errorMessgae);
            errorString = [[NSString alloc] initWithFormat:errorMessgae arguments:args];
            va_end(args);
        }
        self.requestPostSystemErrorString = errorString;
    }
    @catch (NSException *exception) {
        self.requestPostSystemErrorString = [NSString stringWithFormat:@"OtherPostList HandleErrorMessage Exception: %@", exception];
    }
}

#pragma mark TableView

- (NSInteger)countOfCachePostList {
    return self.cachePostList.count;
}

- (NSInteger)numberOfSections {
    NSInteger numberOfSections = 0;
    @try {
        if (self.liveinfo.liveBroadcastId==nil) {
            if (self.withoutPostSection == YES) {
                
                numberOfSections = 1;
            }
            else {
                
                numberOfSections = [self.postSectionList count];
            }

        }else{
            if (self.withoutPostSection == YES) {
                
                numberOfSections = 2;
            }
            else {
                
                numberOfSections = [self.postSectionList count]+1;
            }

        }
      }
    @catch (NSException *exception) {
        numberOfSections = 0;
        CMTLogError(@"OtherPostList -numberOfSections Exception: %@", exception);
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
        CMTLogError(@"OtherPostList -postSectionInSection Exception: %@", exception);
    }
    
    return postSection;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRowsInSection = 0;
    @try {
        if (self.liveinfo.liveBroadcastId==nil) {
            if (self.withoutPostSection == YES) {
                
                numberOfRowsInSection = [self.cachePostList count];
            }
            else {
                NSArray *postArray = [self postSectionInSection:section][CMTPostListSectionPostArrayKey];
                
                numberOfRowsInSection = [postArray count];
            }

        }else {
            if (section==0) {
                numberOfRowsInSection=1;
            }else{
                if (self.withoutPostSection == YES) {
                    
                    numberOfRowsInSection = [self.cachePostList count];
                 }
                  else {
                    NSArray *postArray = [self postSectionInSection:section-1][CMTPostListSectionPostArrayKey];
                    
                    numberOfRowsInSection = [postArray count];
                  }
            }

        }
           }
    @catch (NSException *exception) {
        numberOfRowsInSection = 0;
        CMTLogError(@"OtherPostList -numberOfRowsInSection Exception: %@", exception);
    }
    
    return numberOfRowsInSection;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    if (self.liveinfo.liveBroadcastId!=nil) {
            if (section==0||section==1) {
                if (section==1) {
                    return 6;
                }
               return 0;
                
            }else{
                if (self.withoutPostSection == YES) {
                    
                    return 0;
                }
                else {
                    
                    return CMTPostListSectionHeaderDefaultHeight;
                }

            }
    }else{
        if (self.withoutPostSection == YES) {
            
            return 0;
        }
        else {
            
            return CMTPostListSectionHeaderDefaultHeight;
        }

    }
   }

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CMTPostListCellDefaultHeight;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSString *titleForHeaderInSection = @"";
    @try {
         if (self.liveinfo.liveBroadcastId!=nil) {
        
            if (self.withoutPostSection == YES||section==0) {
                
                titleForHeaderInSection = @"";
            }
            else {
                
                titleForHeaderInSection = [self postSectionInSection:section-1][CMTPostListSectionPostDateKey];
            }
         }else {
             if (self.withoutPostSection == YES) {
                 
                 titleForHeaderInSection = @"";
             }
             else {
                 
                 titleForHeaderInSection = [self postSectionInSection:section][CMTPostListSectionPostDateKey];
             }

         }
    }
    @catch (NSException *exception) {
        titleForHeaderInSection = @"";
        CMTLogError(@"OtherPostList -titleForHeaderInSection Exception: %@", exception);
    }
    
    return titleForHeaderInSection;
}

- (CMTPost *)postForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTPost *post = nil;
    @try {
        if (self.liveinfo.liveBroadcastId==nil) {
            if (self.withoutPostSection == YES) {
                
                post = self.cachePostList[indexPath.row];
            }
            else {
                NSArray *postArray = [self postSectionInSection:indexPath.section][CMTPostListSectionPostArrayKey];
                
                post = postArray[indexPath.row];
            }

        }else{
            if (self.withoutPostSection == YES) {
                
                post = self.cachePostList[indexPath.row];
            }
            else {
                NSArray *postArray = [self postSectionInSection:indexPath.section-1][CMTPostListSectionPostArrayKey];
                
                post = postArray[indexPath.row];
            }

        }
     }
    @catch (NSException *exception) {
        post = nil;
        CMTLogError(@"OtherPostList -postForRowAtIndexPath Exception: %@", exception);
    }
    
    return post;
}

- (NSIndexPath *)indexPathForRowOfPostId:(NSString *)postId {
    NSIndexPath *indexPath = nil;
    @try {
        if (self.withoutPostSection == YES) {
            for (NSInteger row = 0; row < self.cachePostList.count; row++) {
                CMTPost *post = self.cachePostList[row];
                if ([post.postId isEqual:postId]) {
                    indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    break;
                }
            }
        }
        else {
            
            indexPath = nil;
        }
    }
    @catch (NSException *exception) {
        indexPath = nil;
        CMTLogError(@"OtherPostList -indexPathForRowOfPostId Exception: %@", exception);
    }
    
    return indexPath;
}

@end
