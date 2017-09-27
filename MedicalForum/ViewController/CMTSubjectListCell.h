//
//  CMTSubjectListCell.h
//  MedicalForum
//
//  Created by Bo Shen on 15/4/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTSubjectListCell : UITableViewCell

@property (strong, nonatomic) UIImageView *mImageBgImage;
@property (strong, nonatomic, readonly) UIView *mViewBottom;
@property (strong, nonatomic) UILabel *mLabelSubjectTitle;
@property (strong, nonatomic) UIImageView *mImageSubjectType;
@property (strong, nonatomic) UIView *mViewBottomLine;
@property (strong, nonatomic) UILabel *lbUpdateDate;

@end
