//
//  CMTFocusManager.m
//  MedicalForum
//
//  Created by CMT on 15/6/23.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTFocusManager.h"
@interface CMTFocusManager ()
@end
@implementation CMTFocusManager
+(instancetype)sharedManager
{
    static CMTFocusManager *sharedManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[CMTFocusManager alloc] init];
    });
    return sharedManager;
}
- (NSMutableArray *)mArrCollection
{
    if (!_mArrCollection)
    {
        _mArrCollection = [NSMutableArray array];
    }
    return _mArrCollection;
}

- (NSMutableArray *)mArrSubcrption
{
    if (!_mArrSubcrption)
    {
        _mArrSubcrption = [NSMutableArray array];
    }
    return _mArrSubcrption;
}

- (NSMutableArray *)mArrThemes
{
    if (!_mArrThemes) {
        _mArrThemes = [NSMutableArray array];
    }
    return _mArrThemes;
}


/**
 *@brief 取消专题订阅
 *
 */
- (void)asyneTheme:(NSDictionary *)dic
{
    [[[CMTCLIENT fetchTheme:dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTTheme *theme) {
        if ([[dic objectForKey:@"cancelFlag"]intValue]==0)
        {
            CMTLog(@"服务器订阅专题成功");
        }
        else if ([[dic objectForKey:@"cancelFlag"]integerValue]==1)
        {
            CMTLog(@"服务器取消订阅删除成功");
        }
    }error:^(NSError *error) {
        CMTLog(@"error:%@",error);
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            CMTLog(@"errMes = %@",errMes);
        } else {
            CMTLogError(@"addCollection System Error: %@", error);
        }
        
    } ];
}
/**
 *@brief (请求)添加收藏或者删除后调用的同步
 *
 */
- (void)asyneCollection:(NSDictionary *)dic
{
    [[[CMTCLIENT fetchStore:dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTStore * store) {
        CMTLog(@"store:%@",store);
        if ([[dic objectForKey:@"cancelFlag"]intValue]==0) {
            CMTLog(@"服务器收藏成功");
            // 本地收藏时间更新为服务器收藏时间
            NSMutableArray *cachedCollectionPostList = [NSMutableArray arrayWithArray:
                                                        [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST]];
            for (int index = 0; index < cachedCollectionPostList.count; index++) {
                if ([[cachedCollectionPostList objectAtIndex:index] isKindOfClass:[CMTStore class]]) {
                    CMTStore *cachedStore = [cachedCollectionPostList objectAtIndex:index];
                    if ([cachedStore.postId isEqual:dic[@"postId"]]) {
                        cachedStore.opTime = store.opTime;
                        break;
                    }
                }
            }
            [NSKeyedArchiver archiveRootObject:cachedCollectionPostList
                                        toFile:PATH_COLLECTIONLIST];
        }
        else if ([[dic objectForKey:@"cancelFlag"]integerValue]==1) {
            CMTLog(@"服务器删除成功");
        }
    } error:^(NSError *error) {
        CMTLog(@"error:%@",error);
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            CMTLog(@"errMes = %@",errMes);
        } else {
            CMTLogError(@"addCollection System Error: %@", error);
        }
        
    } ];
}

/**
 *@brief 添加/取消收藏 并同步
 *
 */
- (BOOL)handleFavoritePostWithPostId:(NSString *)postId
                          postDetail:(CMTPost *)postDetail
                          cancelFlag:(NSString *)cancelFlag {
    BOOL success = NO;
    
    // 创建新收藏
    CMTStore *store = [[CMTStore alloc] init];
    store.opTime = [NSDate UNIXTimeStampFromNow];
    store.postId = postId;
    store.title = postDetail.title.HTMLUnEscapedString;
    store.postType = postDetail.postType;
    store.smallPic = postDetail.smallPic;
    store.createTime = postDetail.createTime;
    store.author = postDetail.author;
    store.brief = postDetail.brief;
    store.shareUrl = postDetail.shareUrl;
    store.isHTML = postDetail.isHTML;
    store.url = postDetail.url;
    store.module = postDetail.module;
    store.postAttr=postDetail.postAttr;
    
    // 缓存收藏
    BOOL contained = NO;
    NSInteger checkIndex = 0;
    NSMutableArray *cachedCollectionPostList = [NSMutableArray arrayWithArray:
                                                [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST]];
    for (int index = 0; index < cachedCollectionPostList.count; index++) {
        if ([[cachedCollectionPostList objectAtIndex:index] isKindOfClass:[CMTStore class]]) {
            CMTStore *store = [cachedCollectionPostList objectAtIndex:index];
            if ([store.postId isEqual:postId]) {
                checkIndex = index;
                contained = YES;
                break;
            }
        }
    }
    // 缓存列表已包含该收藏
    if (contained == YES) {
        // 添加收藏
        if ([cancelFlag isEqual:@"0"]) {
            // 替换已存在收藏
            [cachedCollectionPostList replaceObjectAtIndex:checkIndex withObject:store];
        }
        // 取消收藏
        else if ([cancelFlag isEqual:@"1"]) {
            // 删除已存在收藏
            [cachedCollectionPostList removeObjectAtIndex:checkIndex];
        }
    }
    // 缓存列表未包含该收藏
    else {
        // 添加收藏
        if ([cancelFlag isEqual:@"0"]) {
            // 添加新收藏
            [cachedCollectionPostList addObject:store];
        }
        // 取消收藏
        else if ([cancelFlag isEqual:@"1"]) {
        }
    }
    
    success = [NSKeyedArchiver archiveRootObject:cachedCollectionPostList
                                          toFile:PATH_COLLECTIONLIST];
    
    // 同步服务器
    if (CMTUSER.login == YES) {
        [self asyneCollection:@{
                                @"userId": CMTUSER.userInfo.userId ?: @"",
                                @"postId": postId ?: @"",
                                @"cancelFlag": cancelFlag ?: @"",
                                }];
    }
    
    return success;
}


/**
 *@brief 登陆已同步收藏信息
 */

- (void)loginToSych:(NSDictionary *)dic
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:PATH_COLLECTIONLIST])
    {
        self.mArrCollection = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_COLLECTIONLIST];
    }
    else
    {
        [self.mArrCollection removeAllObjects];
    }
    @weakify(self);
    [self.rac_deallocDisposable addDisposable:[[[CMTCLIENT syncStore:dic] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray * serverArr)
                                               {
                                                   @strongify(self);
                                                   DEALLOC_HANDLE_FAILURE
                                                   NSMutableArray *pArrServer = [serverArr mutableCopy];
                                                   /*将服务器返回数据插入本地数据库，并做去重操作*/
                                                   for (int i = 0; i < pArrServer.count; i++)
                                                   {
                                                       CMTStore *storeServer = [pArrServer objectAtIndex:i];
                                                       for (int j = 0; j < self.mArrCollection.count; j++)
                                                       {
                                                           CMTStore *storeLocal = [self.mArrCollection objectAtIndex:j];
                                                           
                                                           if ([storeServer.postId isEqualToString:storeLocal.postId])
                                                           {
                                                               if (storeLocal.opTime.integerValue > storeServer.opTime.integerValue)
                                                               {
                                                                   [pArrServer removeObject:storeServer];
                                                               }
                                                               else
                                                               {
                                                                   [self.mArrCollection removeObject:storeLocal];
                                                               }
                                                           }
                                                       }
                                                   }
                                                   /*将去重后的数组放到一个临时数组中*/
                                                   NSMutableArray *pArrSorted = [NSMutableArray array];
                                                   [pArrSorted addObjectsFromArray:pArrServer];
                                                   [pArrSorted addObjectsFromArray:self.mArrCollection];
                                                   /*将原来缓存数组清空*/
                                                   [self.mArrCollection removeAllObjects];
                                                   /*给原来缓存数组重新赋值*/
                                                   [self.mArrCollection addObjectsFromArray:pArrSorted];
                                                   
                                                   BOOL sucess  = [NSKeyedArchiver archiveRootObject:self.mArrCollection toFile:PATH_COLLECTIONLIST];
                                                   
                                                   if (sucess)
                                                   {
                                                       CMTLog(@"合并数据并缓存成功");
                                                       CMTCollectionViewController *pCollectionVC = [[CMTCollectionViewController alloc]init];
                                                       self.delegate = pCollectionVC;
                                                       
                                                       // 数据同步完成， 代理刷新
                                                       [self.delegate dataLoad];
                                                   }
                                                   else
                                                   {
                                                       CMTLog(@"合并数据缓存失败");
                                                   }
                                                   
                                                   /*完成后,再同步到服务器一份*/
                                                   
                                                   NSMutableArray *items = [NSMutableArray array];
                                                   for (CMTStore *store in self.mArrCollection)
                                                   {
                                                       NSDictionary *pDic = @{@"postId":store.postId,@"opTime":store.opTime};
                                                       [items addObject:pDic];
                                                   }
                                                   NSData *pData = [NSJSONSerialization dataWithJSONObject:items options:NSJSONWritingPrettyPrinted error:nil];
                                                   NSString *pStr = [[NSString alloc]initWithData:pData encoding:NSUTF8StringEncoding];
                                                   NSDictionary *pDic2 = @{
                                                                           @"userId":CMTUSER.userInfo.userId,
                                                                           @"items":pStr,
                                                                           };
                                                   
                                                   [self.rac_deallocDisposable addDisposable:[[CMTCLIENT syncStore:pDic2]subscribeNext:^(NSArray * arr) {
                                                       DEALLOC_HANDLE_FAILURE
                                                       CMTLog(@"登陆后,本地数据库重新整理,并同步到服务器成功");
                                                       CMTLog(@"数据如下:%@",arr);
                                                   } error:^(NSError *error) {
                                                       DEALLOC_HANDLE_FAILURE
                                                       CMTLog(@"error:%@",error);
                                                       NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                                                       if ([errorCode integerValue] > 100) {
                                                           NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                                                           CMTLog(@"errMes = %@",errMes);
                                                       } else {
                                                           CMTLogError(@"asyncCollection System Error: %@", error);
                                                       }
                                                       
                                                   }]];
                                               } error:^(NSError *error) {
                                                   DEALLOC_HANDLE_FAILURE
                                                   CMTLog(@"error=%@",error);
                                               }]];
}

/**
 *@brief
 */
- (void)loginToSychThemes:(NSDictionary *)dic
{
    CMTLog(@"调用登陆已同步订阅主题数据");
    if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"focusList"]])
    {
        self.mArrThemes = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
    }
    else
    {
        [self.mArrThemes removeAllObjects];
    }
    NSMutableArray *items = [NSMutableArray array];
    for (CMTTheme *theme in self.mArrThemes)
    {
        NSDictionary *pDic = @{@"themeId":theme.themeId,@"opTime":theme.opTime};
        [items addObject:pDic];
    }
    NSData *pData = [NSJSONSerialization dataWithJSONObject:items options:NSJSONWritingPrettyPrinted error:nil];
    NSString *pStr = [[NSString alloc]initWithData:pData encoding:NSUTF8StringEncoding];
    NSDictionary *pDic3 = @{
                            @"userId":CMTUSER.userInfo.userId,
                            @"items":pStr,
                            };
    
    NSDictionary *dic2 = self.mArrThemes.count > 0?pDic3:dic;
    
    @weakify(self);
    [self.rac_deallocDisposable addDisposable:[[[CMTCLIENT syncTheme:dic2] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray * serverArr)
                                               {
                                                   @strongify(self);
                                                   DEALLOC_HANDLE_FAILURE
                                                   NSMutableArray *pArrServer = [serverArr mutableCopy];
                                                   /*将服务器返回数据插入本地数据库，并做去重操作*/
                                                   for (int i = 0; i < pArrServer.count; i++)
                                                   {
                                                       CMTTheme *themeServer = [pArrServer objectAtIndex:i];
                                                       themeServer.viewTime = themeServer.opTime;
                                                       for (int j = 0; j < self.mArrThemes.count; j++)
                                                       {
                                                           CMTTheme *themeLocal = [self.mArrThemes objectAtIndex:j];
                                                           
                                                           if ([themeServer.themeId isEqualToString:themeLocal.themeId])
                                                           {
                                                               // 将服务器端的订阅时间改为本地缓存的订阅时间
                                                               themeServer.opTime = themeLocal.opTime;
                                                               themeServer.viewTime = themeLocal.viewTime;
                                                               
                                                           }
                                                       }
                                                   }
                                                   // 用服务器数据替换本地数据
                                                   [self.mArrThemes removeAllObjects];
                                                   [self.mArrThemes addObjectsFromArray:pArrServer];
                                                   
                                                   [self.mArrThemes sortUsingComparator:^NSComparisonResult(CMTStore *store1, CMTStore *store2) {
                                                       NSComparisonResult result = [store2.opTime compare:store1.opTime];
                                                       return result;
                                                   }];
                                                   
                                                   BOOL sucess  = [NSKeyedArchiver archiveRootObject:self.mArrThemes toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
                                                   
                                                   if (sucess)
                                                   {
                                                       CMTLog(@"合并数据并缓存成功");
                                                   }
                                                   else
                                                   {
                                                       CMTLog(@"合并数据缓存失败");
                                                   }
                                                                                                } error:^(NSError *error) {
                                                   DEALLOC_HANDLE_FAILURE
                                                   CMTLog(@"error=%@",error);
                                               }]];
}

/**
 *@brief (请求)获取订阅总列表
 *
 */
- (void)subcriptions:(NSDictionary *)par
{
    [self.rac_deallocDisposable addDisposable:[[CMTCLIENT getDepartmentList:@{@"isNew":@"1"}]subscribeNext:^(NSArray *array)
                                               {
                                                   DEALLOC_HANDLE_FAILURE
                                                   BOOL isCacheSucess = [NSKeyedArchiver archiveRootObject:array toFile:PATH_TOTALSUBSCRIPTION];
                                                   CMTLog(@"列表缓存结果:%d",isCacheSucess);
                                                   
                                               } error:^(NSError *error) {
                                                   DEALLOC_HANDLE_FAILURE
                                                   CMTLog(@"error=%@",error);
                                                   NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
                                                   if ([errorCode integerValue] > 100) {
                                                       NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                                                       CMTLog(@"errMes = %@",errMes);
                                                   } else {
                                                       CMTLogError(@"get Subscription System Error: %@", error);
                                                   }
                                                   
                                               } completed:^{
                                                   DEALLOC_HANDLE_FAILURE
                                                   CMTLog(@"完成");
                                               }]];
    
}
//上传服务器已经订阅的学科
-(void)uploadFollows:(BOOL)isLoginOut{
    NSArray *array = @[];
    NSString *userID=@"";
    NSMutableArray *itemArray=[[NSMutableArray alloc]init];
    if (!isLoginOut) {
        userID=CMTUSER.userInfo.userId?:@"0";
        if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscription"]]) {
            array= [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
        }
        for (CMTConcern *concern in array) {
            [itemArray addObject:@{@"subjectId":concern.subjectId,@"subject":concern.subject,@"opTime":concern.opTime}];
        }
    }else{
        userID=@"0";
        [itemArray addObjectsFromArray:array];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *pStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSDictionary *pDic = @{
                           @"userId":userID,
                           @"items":pStr
                           };
    /*同步给服务器一份*/
    [self.rac_deallocDisposable addDisposable:[[CMTCLIENT syncConcern:pDic]subscribeNext:^(NSArray * array)
                                               {
                                                  [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"CMTUploadFollows"];
                                               } error:^(NSError *error)
                                               {
                                                   DEALLOC_HANDLE_FAILURE
                                                   CMTLog(@"error=%@",error);
                                                  [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"CMTUploadFollows"];
                                               } completed:^{
                                                   DEALLOC_HANDLE_FAILURE
                                               }]];
}



/**
 *@brief 获取同步订阅信息
 *
 */
- (void)allCollectionsWithFollows:(NSArray *)follows userId:(NSString *)userIdString
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscription"]]) {
        self.mArrSubcrption = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
    }
    else
    {
        [self.mArrSubcrption removeAllObjects];
        CMTLog(@"没有本地缓存列表");
    }
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"firstLogin_subcrition"]==YES)
        //if (CMTUSER.login == YES)
    {
        // 根据服务器信息 更新本地opTime
        NSArray *pArr = follows;
        NSMutableArray *pTempBackArr = [NSMutableArray array];
        for (CMTFollow *follow in pArr)
        {
            for (CMTConcern *pConcern in self.mArrSubcrption)
            {
                if ([follow.subjectId isEqualToString:pConcern.subjectId] )
                {
                    //设置服务器返回的操作时间
                    pConcern.opTime = follow.opTime;
                    [pTempBackArr addObject:pConcern];
                }
            }
        }
        //去重操作
        for (int i = 0;i < pTempBackArr.count;i++)
        {
            CMTConcern *pConcern = [pTempBackArr objectAtIndex:i];
            for (int j = 0;j < self.mArrSubcrption.count;j++)
            {
                CMTConcern *pConcern2 = [self.mArrSubcrption objectAtIndex:j];
                if ([pConcern.subjectId isEqualToString:pConcern2.subjectId])
                {
                    [self.mArrSubcrption removeObject:pConcern2];
                }
            }
        }
        NSMutableArray *pTotleArray = [NSMutableArray array];
        [pTotleArray addObjectsFromArray:pTempBackArr];
        [pTotleArray addObjectsFromArray:self.mArrSubcrption];
        [self.mArrSubcrption removeAllObjects];
        [self.mArrSubcrption addObjectsFromArray:pTotleArray];
        
        // 服务器数据
        NSMutableArray *userArr = [NSMutableArray array];
        for (CMTFollow *follow in follows)
        {
            CMTConcern *concern = [[CMTConcern alloc]init];
            concern.subject = follow.subject;
            concern.subjectId = follow.subjectId;
            concern.opTime = follow.opTime;
            concern.concernFlag = nil;
            concern.authors = nil;
            //默认添加一个subjectId为0的学科。
            if (concern.subjectId.intValue != 0)
            {
                [userArr addObject:concern];
            }
        }
        // 服务器数据去重
        for (int i = 0;i < self.mArrSubcrption.count;i++)
        {
            CMTConcern *concern1 = [self.mArrSubcrption objectAtIndex:i];
            for (int j = 0;j < userArr.count;j++)
            {
                CMTConcern *concern2 = [userArr objectAtIndex:j];
                if ([concern1.subjectId isEqualToString:concern2.subjectId])
                {
                    [userArr removeObject:concern2];
                }
                
            }
        }
        // 合并服务器数据及本地数据
        NSMutableArray *pTotleArray2 = [NSMutableArray array];
        [pTotleArray2 addObjectsFromArray:self.mArrSubcrption];
        [pTotleArray2 addObjectsFromArray:userArr];
        self.mArrSubcrption = pTotleArray2;
        
        // 将订阅排序
        self.mArrSubcrption = [[self.mArrSubcrption sortedArrayUsingComparator:^NSComparisonResult(CMTConcern* obj1, CMTConcern* obj2) {
            return [obj1.subjectId compare:obj2.subjectId options:NSCaseInsensitiveSearch];
        }]mutableCopy];
        
        // 缓存
        [NSKeyedArchiver archiveRootObject:self.mArrSubcrption toFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
        
        /*将从服务器获取的订阅信息与本地缓存已订阅信息去重后,重新缓存到本地*/
        BOOL suc = [NSKeyedArchiver archiveRootObject:self.mArrSubcrption toFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
        if (suc)
        {
            CMTLog(@"从服务器抓取订阅信息,去重后在写入本地成功");
            
        }
        else
        {
            CMTLog(@"从服务器抓取订阅信息,去重后在写入本地失败");
        }
        NSMutableArray *pTempArr = [NSMutableArray array];
        for (CMTConcern *concer in self.mArrSubcrption)
        {
            NSMutableDictionary *pDic = [NSMutableDictionary dictionary];
            [pDic setObject:concer.subjectId forKey:@"subjectId"];
            
            if (concer.opTime.length > 0)
            {
                long long scannedNumber;
                NSScanner *scanner = [NSScanner scannerWithString:concer.opTime];
                [scanner scanLongLong:&scannedNumber];
                NSNumber *number = [NSNumber numberWithLongLong: scannedNumber];
                [pDic setObject:number forKey:@"opTime"];
            }
            else
            {
                CMTLog(@"缺少时间参数");
            }
            [pTempArr addObject:pDic];
        }
        long long userId;
        NSScanner *scanner2 = [NSScanner scannerWithString:userIdString];
        [scanner2 scanLongLong:&userId];
        NSNumber *number2 = [NSNumber numberWithLongLong:userId];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pTempArr options:NSJSONWritingPrettyPrinted error:nil];
        NSString *pStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        NSDictionary *pDic = @{
                               @"userId":number2,
                               @"items":pStr
                               };
        /*同步给服务器一份*/
        [self.rac_deallocDisposable addDisposable:[[CMTCLIENT syncConcern:pDic]subscribeNext:^(NSArray * array)
                                                   {
                                                       DEALLOC_HANDLE_FAILURE
                                                       CMTLog(@"array=%@",array);
                                                       CMTUSERINFO.follows = array;
                                                       [CMTUSER save];
                                                       CMTUSER.SysSubjectSuccess=YES;
                                                   } error:^(NSError *error)
                                                   {
                                                        CMTUSER.SysSubjectSuccess=NO;
                                                       DEALLOC_HANDLE_FAILURE
                                                       CMTLog(@"error=%@",error);
                                                   } completed:^{
                                                       DEALLOC_HANDLE_FAILURE
                                                   }]];
    }
    else
    {
        CMTLog(@"非第一次登录同步状态");
    }
    
}


//同步已订阅系列课程列表
- (void)asyneSeriesListForUser:(CMTUserInfo *)user{
    if (user.userId && user.userId.integerValue!=0) {
       
        
            NSMutableArray *cachArr = [NSMutableArray array];
        
            if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]]) {
                 cachArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
                NSMutableArray *followItems = [NSMutableArray array];
                for (CMTSeriesDetails *seriesDtl in cachArr) {
                    if (!BEMPTY(seriesDtl.themeUuid) && !BEMPTY(seriesDtl.viewTime)) {

                        [followItems addObject:@{
                                             @"themeUuid": seriesDtl.themeUuid ?: @"",
                                             @"opTime": seriesDtl.opTime ?: TIMESTAMP,
                                             }];
                    }
                }
                NSError *JSError = nil;
                NSData *followItemsJSData = [NSJSONSerialization dataWithJSONObject:followItems options:NSJSONWritingPrettyPrinted error:&JSError];
                if (JSError !=nil) {
                    CMTLogError(@"请求系列课程未读消息列表json串转化error");
                }
                NSString *followItemsStr = [[NSString alloc]initWithData:followItemsJSData encoding:NSUTF8StringEncoding];
                NSDictionary *params = @{
                                         @"userId": user.userId?:@"0",
                                         @"followItems":followItemsStr?:@"",
                                         };
                
                [[[CMTCLIENT cmtgetSubscribeSeriesDetailList:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSMutableArray * x) {
                CMTAPPCONFIG.seriesDtlUnreadNumber = @"0";
                    if (x.count > 0) {
                        for (CMTSeriesDetails *seriesDtl in x) {
                            CMTAPPCONFIG.seriesDtlUnreadNumber = [NSString stringWithFormat:@"%ld",CMTAPPCONFIG.seriesDtlUnreadNumber.integerValue + seriesDtl.newrecordCount.integerValue];
                        }
                        //更新缓存中的消息数
                        for (int i = 0; i < cachArr.count ; i ++) {
                            CMTSeriesDetails *seriesDtl = cachArr[i];
                            for (int j = 0; j < x.count; j ++) {
                                CMTSeriesDetails *seriesDtlj = x[j];
                                if ([seriesDtl.themeUuid isEqual:seriesDtlj.themeUuid]) {
                                    seriesDtlj.viewTime = seriesDtl.viewTime;
                                }
                            }
                        }
                        for (int j = 0; j < x.count; j++) {
                            CMTSeriesDetails* seriesDtlj = x[j];
                            if (seriesDtlj.viewTime == nil) {
                                seriesDtlj.viewTime = user.preActiveTime;
                            }
                        }
                        [NSKeyedArchiver archiveRootObject:x toFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
                    }
                    
                } error:^(NSError *error) {
                    CMTLogError(@"请求订阅系列课程未读消息数错误%@",error);
                    [CMTAPPCONFIG updateSeriesDtlUnreadNumber];
                }];

                
                
            }else{
                NSDictionary *pDic = @{
                                       @"userId":user.userId?:@"0",
                                       };
                [[[CMTCLIENT cmtgetSubscribeSeriesDetailList:pDic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSMutableArray * x) {
                    CMTAPPCONFIG.seriesDtlUnreadNumber = @"0";
                    NSMutableArray *netArr = [x mutableCopy];
                                    if (netArr.count > 0) {
                                        for (id x in netArr) {
                                            if ([x isKindOfClass:[CMTSeriesDetails class]]) {
                                                CMTSeriesDetails *seriesNet = x;
                                                seriesNet.viewTime = user.preActiveTime;
                                                CMTAPPCONFIG.seriesDtlUnreadNumber = [NSString stringWithFormat:@"%ld",CMTAPPCONFIG.seriesDtlUnreadNumber.integerValue + seriesNet.newrecordCount.integerValue];
                                            }
                                        }
                                        BOOL sucess = [NSKeyedArchiver archiveRootObject:netArr toFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
                                        if (sucess) {
                                            CMTLog(@"服务订阅同步到本地成功");
                                        }else{
                                            CMTLogError(@"服务订阅同步到本地失败");
                                            
                                        }
                                    }

                    
                } error:^(NSError *error) {
                    CMTLogError(@"请求订阅系列课程未读消息数错误%@",error);
                    [CMTAPPCONFIG updateSeriesDtlUnreadNumber];
                }];
                

             
            }
            
        
    }else{
        [CMTAPPCONFIG updateSeriesDtlUnreadNumber];
    }
}



- (NSMutableArray *)arrsorted:(NSMutableArray *)arr
{
    [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2] ;
        return  result;
    }];
    return arr;
}
#pragma mark请求全国区域列表
- (void)getAllAreas{
    [self performSelectorInBackground:@selector(getAllAreasList) withObject:nil];
}
- (void)getAllAreasList{
    NSLog(@"+++%@---%@",CMTAPPCONFIG.areaUpdateTime,CMTAPPCONFIG.readCodeObject.areaUpdateTime);
    NSDictionary *pDic = @{
                           @"areaUpdateTime":CMTAPPCONFIG.readCodeObject.areaUpdateTime?: @"0"
                           };
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityLow]schedule:^{
        [[[CMTCLIENT getAllAreas:pDic]deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityLow]]subscribeNext:^(NSArray * areList) {
            if (areList.count > 0) {
                if ([[NSFileManager defaultManager]fileExistsAtPath:[PATH_ALLAREAS stringByAppendingPathComponent:@"areas_list"]]) {
                    NSLog(@"是否存在区域文件夹%d",[[NSFileManager defaultManager]fileExistsAtPath:[PATH_ALLAREAS stringByAppendingPathComponent:@"areas_list"]]);
                    [[NSFileManager defaultManager]removeItemAtPath:[PATH_ALLAREAS stringByAppendingPathComponent:@"areas_list"] error:nil];
                }
                [NSKeyedArchiver archiveRootObject:areList toFile:[PATH_ALLAREAS stringByAppendingPathComponent:@"areas_list"]];
                if (CMTAPPCONFIG.readCodeObject.areaUpdateTime != nil) {
                    CMTAPPCONFIG.areaUpdateTime = CMTAPPCONFIG.readCodeObject.areaUpdateTime;
                }
            }
        } error:^(NSError *error) {
            NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            CMTLog(@"请求医院列表errMes:%@",errMes);
        }];
    }];
}

#pragma mark - 请求医院列表

- (void)getAllHosptials:(id)sender {
    [self performSelectorInBackground:@selector(getAllHosptialList) withObject:nil];
}


- (void)getAllHosptialList {
    CMTLog(@"开始请求医院列表");
    NSDictionary *pDic = @{};
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityLow] schedule:^{
        
        [[[CMTCLIENT getAllHospital:pDic] deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityLow]] subscribeNext:^(NSArray * array) {
            
            NSMutableDictionary *pTotle = [NSMutableDictionary dictionary];
            for (CMTProvince *province in array)
            {
                NSMutableDictionary *dicProvince = [NSMutableDictionary dictionary];
                for (CMTCity *city in province.cities)
                {
                    NSMutableArray *arrCity = [NSMutableArray array];
                    for (CMTDetailHosptial * hosptial in city.hospital_list)
                    {
                        hosptial.provCode = province.provCode;
                        hosptial.provName = province.provName;
                        hosptial.cityCode = city.cityCode;
                        hosptial.cityName = city.cityName;
                        [arrCity addObject:[hosptial copy]];
                        
                    }
                    [dicProvince setObject:arrCity forKey:city.cityCode];
                }
                [pTotle setObject:dicProvince forKey:province.provName];
            }
#pragma mark 缓存字典结构的所有数据 4.1M
            if (![[NSFileManager defaultManager]fileExistsAtPath:[PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"hosptial_list2"]])
            {
                BOOL cacheUnChivere = [NSKeyedArchiver archiveRootObject:pTotle toFile:[PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"hosptial_list2"]];
                if (cacheUnChivere)
                {
                    CMTLog(@"缓存字典结构的医院成功");
                }
                else
                {
                    CMTLog(@"缓存字典结构的医院失败");
                }
            }
#pragma mark  缓存省份列表
            NSArray *allPros = [pTotle allKeys];
            NSString *strAllPros = [PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"allPros"];
            if (![[NSFileManager defaultManager]fileExistsAtPath:strAllPros]) {
                BOOL cacheAllPros = [NSKeyedArchiver archiveRootObject:allPros toFile:strAllPros];
                
                if (cacheAllPros)
                {
                    CMTLog(@"缓存省份列表成功");
                }
                else
                {
                    CMTLog(@"缓存省份列表失败");
                }
            }
#pragma mark  缓存所有医院
            NSMutableArray *arrTotHosptials = [NSMutableArray array];
            for (int i = 0;i < allPros.count;i++)
            {
                NSDictionary *dicPro = [pTotle objectForKey:[allPros objectAtIndex:i]];
                NSArray *allCitys = [dicPro allKeys];
                for (int j = 0; j < allCitys.count; j++)
                {
                    NSArray *cityHosptials = [dicPro objectForKey:[allCitys objectAtIndex:j]];
                    for (CMTDetailHosptial * hos in cityHosptials) {
                        //CMTLog(@"hosptialName:%@",hos.hosptialName);
                        [arrTotHosptials addObject:hos];
                    }
                }
                
            }
            if (![[NSFileManager defaultManager]fileExistsAtPath:[PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"hosptial_list"]])
            {
                BOOL cacheHosptials = [NSKeyedArchiver archiveRootObject:arrTotHosptials toFile:[PATH_ALLHOSPTIALS stringByAppendingPathComponent:@"hosptial_list"]];
                if (cacheHosptials)
                {
                    CMTLog(@"缓存所有医院成功");
                    CMTLog(@"结束请求");
                    
                }
                else
                {
                    CMTLog(@"缓存所有医院失败");
                }
                
            }
            
        } error:^(NSError *error) {
            NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            CMTLog(@"请求医院列表errMes:%@",errMes);
        } completed:^{
            CMTLog(@"请求医院列表完成");
        }];
    }];
}

//同步订阅的疾病标签
-(void)CMTSysFocusDiseaseTag:(NSString*)userID{
    NSMutableArray *foucesDisArray=[[NSMutableArray alloc]init];
    NSMutableArray *disTagArray=[[NSMutableArray alloc]init];
    if([[NSFileManager defaultManager] fileExistsAtPath:PATH_FOUSTAG]){
        foucesDisArray=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG];
    }
    NSMutableArray *itemsArray=[NSMutableArray new];
    for (CMTDisease *dis in foucesDisArray) {
        if (!BEMPTY(dis.diseaseId) && !BEMPTY(dis.opTime)) {
            [itemsArray addObject:@{
                                    @"diseaseId": dis.diseaseId ?: @"",
                                    @"opTime": dis.opTime?:TIMESTAMP,
                                    }];
            
        }
    }
    NSError *JSONSerializationError = nil;
    NSData *itemsJSONData = [NSJSONSerialization dataWithJSONObject:itemsArray options:NSJSONWritingPrettyPrinted error:&JSONSerializationError];
    if (JSONSerializationError != nil) {
        CMTLogError(@"AppConfig Cached Theme Info JSONSerialization Error: %@", JSONSerializationError);
    }
    NSString *itemsJSONString = [[NSString alloc] initWithData:itemsJSONData encoding:NSUTF8StringEncoding];
    NSDictionary *dic=@{@"userId":userID,@"items":itemsJSONString};
    [[[CMTCLIENT SynDiseasecFollowsList:dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *disArray) {
        [disTagArray removeAllObjects];
        [disTagArray addObjectsFromArray:disArray];
        for (CMTDisease *dis in disTagArray) {
                dis.readTime=TIMESTAMP;
                dis.count=@"0";
                dis.caseReadtime=TIMESTAMP;
                dis.postCount=@"0";
                dis.postReadtime=TIMESTAMP;
                dis.caseReadtime=TIMESTAMP;
                dis.caseCout=@"0";
             for (CMTDisease *fouceDis in foucesDisArray) {
                    if ([fouceDis.diseaseId isEqualToString:dis.diseaseId]) {
                        dis.readTime=fouceDis.readTime;
                        dis.count=fouceDis.count;
                        dis.caseReadtime=fouceDis.caseReadtime;
                        dis.postCount=fouceDis.postCount;
                        dis.postReadtime=fouceDis.postReadtime;
                        dis.caseReadtime=fouceDis.caseReadtime;
                        dis.caseCout=fouceDis.caseCout;

                        break;
                    }
                }
        }
         //排序
        [disTagArray sortUsingComparator:^NSComparisonResult(CMTDisease *obj1, CMTDisease *obj2) {
            NSComparisonResult result = [obj1.opTime compare:obj2.opTime] ;
            return  result;
        }];
        [NSKeyedArchiver archiveRootObject:[disTagArray mutableCopy] toFile:PATH_FOUSTAG];
   
    }error:^(NSError *error) {
        CMTLog(@"同步失败");
    } completed:^{
        
    }];
}

#pragma mark - 文章类型

- (NSArray *)getPostTypesByModule:(NSString *)module {
    if (![module isEqual:@"1"]) {
        CMTLogError(@"Get PostTypes By Module Error: 只支持病例模块");
        return nil;
    }
    
    NSArray *postTypes = nil;
    NSString *filePath = [PATH_CACHE_SEARCH stringByAppendingPathComponent:@"allPostTypes"];
    
    void (^getPostTypesBlock)() = ^() {
        [[CMTCLIENT get_post_types_by_module:@{
                                               @"module": module ?: @"1",
                                               }]
         subscribeNext:^(NSArray *tempPostTypes) {
             if (![NSKeyedArchiver archiveRootObject:tempPostTypes toFile:filePath]) {
                 CMTLogError(@"Archive PostTypes Error");
             }
         }
         error:^(NSError *error) {
             CMTLogError(@"Get PostTypes By Module Error: %@", error);
         }];
    };
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        
        /*1.获取文件创建时间.2.判断与当前时间差.3.决定是否请求*/
        NSDictionary * fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        if (fileAttributes != nil) {
            
            NSDate *fileModDate = [fileAttributes objectForKey:NSFileCreationDate];
            NSDate *pCurrentDate = [NSDate date];
            NSTimeInterval interval = [pCurrentDate timeIntervalSinceDate:fileModDate];
            // 超过一周
            if (interval >= (7*24*3600)) {
                getPostTypesBlock();
            }
            // 一周内
            else {
                postTypes = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            }
        }
    }
    else {
        getPostTypesBlock();
    }
    
    return postTypes;
}

@end
