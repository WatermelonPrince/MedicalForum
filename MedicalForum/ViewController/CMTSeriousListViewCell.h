
//
//  CMTRecordListViewCell.h
//  MedicalForum
//
//  Created by zhaohuan on 16/7/29.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTSeriousListViewCell : UITableViewCell

@property (nonatomic, strong)UILabel *label;


- (void)reloadCellWithModel:(CMTSeriesDetails*)model;

@end
