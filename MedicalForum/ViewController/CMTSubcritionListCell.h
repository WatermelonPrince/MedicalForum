//
//  CMTSubcritionListCell.h
//  MedicalForum
//  1.8.2 作者列表中的cell
//  Created by Bo Shen on 15/3/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTButton.h"

@interface CMTSubcritionListCell : UITableViewCell

@property (strong, nonatomic) UILabel *mLbSub;
@property (strong, nonatomic) CMTButton *mBtnSub;
@property (strong, nonatomic) UIImageView *mImageAcc;
///分割线
@property (strong, nonatomic) UIView *separatorLine;
///底线
@property (strong, nonatomic) UIView *bottomLine;

@end
