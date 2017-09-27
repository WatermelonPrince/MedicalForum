//
//  CMTFocusManager.h
//  MedicalForum
//
//  Created by CMT on 15/6/23.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTFocusManager.h"
#import "CMTCollectionViewController.h"
#import "CMTPost.h"

@interface CMTFocusManager : NSObject
@property (strong, nonatomic) NSMutableArray *mArrCollection;
@property (strong, nonatomic) NSMutableArray *mArrSubcrption;
@property (strong, nonatomic) NSMutableArray *mArrThemes;
@property (assign) id<CMTCollectionDelegate>delegate;

//初始化单例类
+ (instancetype)sharedManager;

/**
 *@brief 取消专题订阅
 *
 */
- (void)asyneTheme:(NSDictionary *)dic;

/**
 *@brief (请求)添加收藏或者删除后调用的同步
 *
 */
- (void)asyneCollection:(NSDictionary *)dic;

/**
 *@brief 添加/取消收藏 并同步
 *
 */
- (BOOL)handleFavoritePostWithPostId:(NSString *)postId
                          postDetail:(CMTPost *)postDetail
                          cancelFlag:(NSString *)cancelFlag;

/**
 *@brief 登陆已同步收藏信息
 */

- (void)loginToSych:(NSDictionary *)dic;

/**
 *@brief 登陆同步主题
 */
- (void)loginToSychThemes:(NSDictionary *)dic;

/**
 *@brief 获取同步订阅信息
 *
 */
- (void)allCollectionsWithFollows:(NSArray *)follows userId:(NSString *)userIdString;

//上传已经订阅的学科 用于个推初始化

-(void)uploadFollows:(BOOL)isLoginOut;
/**
 *@brief (请求)获取订阅总列表
 *
 */
- (void)subcriptions:(NSDictionary *)par;

#pragma mark 请求医院列表

- (void)getAllHosptials:(id)sender;
#pragma mark请求全国区域
- (void)getAllAreas;

//同步订阅疾病标签
-(void)CMTSysFocusDiseaseTag:(NSString*)userID;

#pragma mark 文章类型

- (NSArray *)getPostTypesByModule:(NSString *)module;

//同步订阅系列课程
- (void)asyneSeriesListForUser:(CMTUserInfo *)user;

@end
