//
//  ChartTableViewCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/6/6.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PlayerSDK/PlayerSDK.h>
#import "NSDate+CMTExtension.h"
#import "CMTGetStringWith_Height.h"
@interface ChartTableViewCell : UITableViewCell
-(void)reloadCell:(GSPQaData*)live;
@end
