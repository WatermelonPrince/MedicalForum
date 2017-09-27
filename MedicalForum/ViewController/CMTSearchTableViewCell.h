//
//  CMTSearchTableViewCell.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTSearchTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *mLbTitle;
@property (strong, nonatomic) UILabel *mLbAuthor;
@property (strong, nonatomic) UIImageView *mImageView;
@property (strong, nonatomic) UILabel *mLbDate;

@property (strong, nonatomic) UIView *sepLine;
@property (strong, nonatomic) UIView *bottomLine;

@end
