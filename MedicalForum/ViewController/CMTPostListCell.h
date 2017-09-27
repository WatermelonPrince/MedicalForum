//
//  CMTPostListCell.h
//  MedicalForum
//
//  Created by fenglei on 14/12/19.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 首页(文章列表)cell
@interface CMTPostListCell : UITableViewCell

@property (nonatomic, copy) CMTPost *post;
@property (nonatomic, copy) NSIndexPath *indexPath;

- (void)reloadPost:(CMTPost *)post tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
