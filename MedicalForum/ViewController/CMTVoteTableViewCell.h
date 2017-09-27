//
//  CMTVoteTableViewCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTVoteObject.h"

@interface CMTVoteTableViewCell : UITableViewCell
@property(nonatomic,copy)void(^addAction)(NSIndexPath *);
-(void)reloadCell:(CMTVoteObject*)vote indexPath:(NSIndexPath *)indexpath;
@end
