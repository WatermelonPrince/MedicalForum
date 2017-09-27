//
//  CMTCaseDetailViewController.h
//  MedicalForum
//
//  Created by fenglei on 15/7/30.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTPostDetailCenter.h"


/// 病例详情
@interface CMTCaseDetailViewController : CMTPostDetailCenter



/* init */
@property(nonatomic,assign)BOOL iscanShare;
/// designated initializer
- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                    postModule:(NSString *)postModule
                postDetailType:(CMTPostDetailType)postDetailType;

/// 发出评论中的初始化方法
- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment;
/**
 *  组内文章初始化方法
 *
 *  @param postId         文章ID
 *  @param isHTML         是否是动态详情页
 *  @param postURL        页面地址
 *  @param group          小组
 *  @param postModule     是否是组内文章
 *  @param postDetailType 键盘弹出方式
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                         group:(CMTGroup*)group
                    postModule:(NSString *)postModule
                postDetailType:(CMTPostDetailType)postDetailType;
/**
 *  
 *
 *  @param postId         文章ID
 *  @param isHTML         是否是动态详情页
 *  @param postURL        页面地址
 *  @param group          小组
 *  @param postModule     是否是组内文章
 *  @param toDisplayedComment 滚动到评论
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithPostId:(NSString *)postId
                        isHTML:(NSString *)isHTML
                       postURL:(NSString *)postURL
                         group:(CMTGroup *)group
                    postModule:(NSString *)postModule
            toDisplayedComment:(CMTObject *)toDisplayedComment;

@end
