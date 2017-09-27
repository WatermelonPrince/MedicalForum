//
//  CMTSubjectListCell.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSubjectListCell.h"

@interface CMTSubjectListCell ()
@property (strong, nonatomic, readwrite) UIView *mViewBottom;

@end

@implementation CMTSubjectListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mImageBgImage];
        [self addSubview:self.mViewBottom];
        [self addSubview:self.mLabelSubjectTitle];
        //[self addSubview:self.mImageSubjectType];
        [self addSubview:self.lbUpdateDate];
        [self addSubview:self.mViewBottomLine];
    }
    return self;
    
}

- (UIImageView *)mImageBgImage
{
    if (!_mImageBgImage)
    {
        _mImageBgImage = [[UIImageView alloc]init];
        _mImageBgImage.backgroundColor = [UIColor clearColor];
    }
    return _mImageBgImage;
}

- (UIView *)mViewBottom
{
    if (!_mViewBottom)
    {
        _mViewBottom = [[UIView alloc]init];
        _mViewBottom.backgroundColor = [UIColor blackColor];
        _mViewBottom.alpha = 0.3;
    }
    return _mViewBottom;
}

- (UILabel *)mLabelSubjectTitle
{
    if (!_mLabelSubjectTitle)
    {
        _mLabelSubjectTitle = [[UILabel alloc]init];
        _mLabelSubjectTitle.backgroundColor = [UIColor clearColor];
        _mLabelSubjectTitle.textColor = [UIColor whiteColor];
        _mLabelSubjectTitle.font = [UIFont systemFontOfSize:12.0];
    }
    return _mLabelSubjectTitle;
}

- (UIImageView *)mImageSubjectType
{
    if (!_mImageSubjectType)
    {
        _mImageSubjectType = [[UIImageView alloc]init];
        _mImageSubjectType.backgroundColor = [UIColor clearColor];
    }
    return _mImageSubjectType;
}

- (UIView *)mViewBottomLine
{
    if (!_mViewBottomLine)
    {
        _mViewBottomLine = [[UIView alloc]init];
        _mViewBottomLine.backgroundColor = [UIColor whiteColor];
    }
    return _mViewBottomLine;
}

- (UILabel *)lbUpdateDate{
    if (!_lbUpdateDate) {
        _lbUpdateDate = [[UILabel alloc]init];
        _lbUpdateDate.font = [UIFont systemFontOfSize:12.0];
        _lbUpdateDate.backgroundColor = [UIColor clearColor];
        _lbUpdateDate.textColor = [UIColor whiteColor];
    }
    return _lbUpdateDate;
}


@end
