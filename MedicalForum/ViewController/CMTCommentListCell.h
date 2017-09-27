//
//  CMTCommentListCell.h
//  MedicalForum
//
//  Created by fenglei on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
//代理
@protocol CMTCommentListCellPraiseDelegate <NSObject>

-(void)CommentListCellPraise:(CMTComment*)Comment index:(NSIndexPath*)indexpath;
@end

/// 文章详情 评论列表cell
@interface CMTCommentListCell : UITableViewCell

@property (nonatomic, copy, readonly) CMTComment *comment;
@property (nonatomic, copy, readonly) NSIndexPath *indexPath;
@property(nonatomic,weak)id<CMTCommentListCellPraiseDelegate>delegate;

+ (CGFloat)cellHeightFromComment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth;
- (void)reloadComment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth indexPath:(NSIndexPath *)indexPath;

+ (CGFloat)cellHeightFromLiveComment:(CMTLiveComment *)liveComment cellWidth:(CGFloat)cellWidth;
- (void)reloadLiveComment:(CMTLiveComment *)liveComment cellWidth:(CGFloat)cellWidth indexPath:(NSIndexPath *)indexPath;

@end
