//
//  CMTSubscriptionGuideCell.h
//  MedicalForum
//
//  Created by fenglei on 15/3/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTSubscriptionGuideCell : UITableViewCell

- (void)reloadSubscription:(CMTConcern *)subscription tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
