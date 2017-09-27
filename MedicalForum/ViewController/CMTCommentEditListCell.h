//
//  CMTCommentEditListCell.h
//  MedicalForum
//
//  Created by fenglei on 14/12/28.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTCommentEditListCellModel.h"

/// 编辑评论cell
@interface CMTCommentEditListCell : UITableViewCell

@property (nonatomic, strong, readonly) CMTCommentEditListCellModel *cellModel;

+ (CGFloat)cellHeightFromComment:(CMTObject *)comment tableView:(UITableView *)tableView;
- (void)reloadComment:(CMTObject *)comment tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
