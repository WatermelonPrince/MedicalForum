//
//  CMTSystemTableViewCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/11/1.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTSystemTableViewCell : UITableViewCell
-(void)reloadCell:(NSString*)info text:(NSString*)text index:(NSIndexPath*)index;
@property(nonatomic,assign)float textWith;

@end
