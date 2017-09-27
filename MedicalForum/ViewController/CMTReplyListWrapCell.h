//
//  CMTReplyListWrapCell.h
//  MedicalForum
//
//  Created by fenglei on 15/1/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const CGFloat kCMTReplyListWrapCellVerticalGap;

@class CMTReplyListWrapCell;

@protocol CMTReplyListWrapCellDelegate <NSObject>
- (void)replyListWrapCell:(CMTReplyListWrapCell *)cell didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
 -(void)replyListPraise:(CMTReply*)reply index:(NSIndexPath*)indexpath;
@end

/// 文章详情 评论列表 回复列表cell外层
@interface CMTReplyListWrapCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy, readonly) CMTReply *reply;
@property (nonatomic, copy, readonly) CMTComment *comment;
@property (nonatomic, copy, readonly) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) BOOL last;

@property (nonatomic, weak) id <CMTReplyListWrapCellDelegate> delegate;

+ (CGFloat)cellHeightFromReply:(CMTReply *)reply comment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth last:(BOOL)last;
- (void)reloadReply:(CMTReply *)reply comment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth indexPath:(NSIndexPath *)indexPath last:(BOOL)last;

@end
