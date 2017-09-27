//
//  CMTPostDetailViewController.h
//  MedicalForum
//
//  Created by fenglei on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTPostDetailCenter.h"
#import <AVFoundation/AVFoundation.h>
/// 文章详情
@interface CMTPostDetailViewController : CMTPostDetailCenter

/* init */

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

@end
