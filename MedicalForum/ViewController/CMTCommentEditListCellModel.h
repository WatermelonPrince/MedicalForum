//
//  CMTCommentEditListCellModel.h
//  MedicalForum
//
//  Created by fenglei on 15/1/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTViewModel.h"

/// 编辑评论列表cell数据
@interface CMTCommentEditListCellModel : CMTViewModel

- (instancetype)initWithComment:(CMTObject *)comment indexPath:(NSIndexPath *)indexPath;
- (void)reloadComment:(CMTObject *)comment indexPath:(NSIndexPath *)indexPath;

/* output */

@property (nonatomic, copy, readonly) CMTObject *comment;
@property (nonatomic, copy, readonly) NSIndexPath *indexPath;

@property(nonatomic, copy, readonly) NSString *nickname;
@property(nonatomic, copy, readonly) NSString *picture;
@property(nonatomic, copy, readonly) NSString *content;
@property(nonatomic, copy, readonly) NSString *postTitle;
@property(nonatomic, copy, readonly) NSString *createTime;


@end
