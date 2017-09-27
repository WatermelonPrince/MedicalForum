//
//  ThemTableViewCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/9/13.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTBaseViewController.h"
@interface ThemTableViewCell : UITableViewCell
@property(nonatomic,weak)CMTBaseViewController * parentController;
//刷新列表
-(void)reloadCell:(CMTTheme*)theme;
@end
