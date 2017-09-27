//
//  CMTReplyListCell.h
//  MedicalForum
//
//  Created by fenglei on 14/12/25.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
//代理
@protocol CMTReplyListCellPraiseDelegate <NSObject>

-(void)ReplyListCellPraise:(CMTReply*)reply ;
@end

/// 文章详情 评论列表 回复列表cell
@interface CMTReplyListCell : UITableViewCell
@property(nonatomic,weak)id<CMTReplyListCellPraiseDelegate>delegate;
+ (CGFloat)cellHeightFromReply:(CMTReply *)reply comment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth;
- (void)reloadReply:(CMTReply *)reply comment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight last:(BOOL)last;

@end
