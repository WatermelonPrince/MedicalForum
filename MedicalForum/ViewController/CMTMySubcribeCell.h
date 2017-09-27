//
//  CMTMySubcribeCell.h
//  MedicalForum
//
//  Created by zhaohuan on 16/9/19.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTMySubcribeCell : UITableViewCell

@property (nonatomic, strong)UIImageView *iconImage;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *readCountLabel;
@property (nonatomic, strong)UIView *lineView;


- (void)reloadCellWithData:(CMTSeriesDetails *)data;

@end
