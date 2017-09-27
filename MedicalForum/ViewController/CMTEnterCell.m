//
//  CMTEnterCell.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTEnterCell.h"


@implementation CMTEnterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.mImageLeft];
        [self.contentView addSubview:self.mLabelDes];
        [self.contentView addSubview:self.separatorLine];
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.mImageAccView];
        [self.contentView addSubview:self.badgePoint];
        [self.contentView addSubview:self.badge];

        [self.mImageAccView builtinContainer:self WithLeft:SCREEN_WIDTH-31 Top:(50-21)/2 Width:21 Height:21];
        [self.separatorLine builtinContainer:self WithLeft:0 Top:PIXEL Width:SCREEN_WIDTH Height:PIXEL];
        [self.bottomLine builtinContainer:self WithLeft:0 Top:50-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
    }
    return self;
}

- (UIImageView *)mImageLeft
{
    if (!_mImageLeft)
    {
        _mImageLeft = [[UIImageView alloc]initWithFrame:CGRectMake(10*RATIO,15, 20, 20)];
        _mImageLeft.backgroundColor = [UIColor clearColor];
    }
    return _mImageLeft;
}

- (UILabel *)mLabelDes
{
    if (!_mLabelDes)
    {
        _mLabelDes = [[UILabel alloc]initWithFrame:CGRectMake(10*RATIO+24+10, 0, SCREEN_WIDTH/3*2, 50)];
        _mLabelDes.backgroundColor = [UIColor clearColor];
        _mLabelDes.textAlignment = NSTextAlignmentLeft;
    }
    return _mLabelDes;
}

- (UIView *)separatorLine {
    if (_separatorLine == nil) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _separatorLine;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _bottomLine;
}

- (UIImageView *)mImageAccView
{
    if (!_mImageAccView)
    {
       _mImageAccView = [[UIImageView alloc]initWithImage:IMAGE(@"Guide_forward")];
    }
    return _mImageAccView;
}

- (UIView *)mTopView
{
    if (!_mTopView)
    {
        _mTopView = [[UIView alloc]init];
        _mTopView.backgroundColor = COLOR(c_f5f5f5);
    }
    return _mTopView;
}

- (CMTBadgePoint *)badgePoint {
    if (_badgePoint == nil) {
        _badgePoint = [[CMTBadgePoint alloc] init];
        _badgePoint.frame = CGRectMake(self.mLabelDes.left + 38.0, (50-CMTBadgePointWidth)/2,  CMTBadgePointWidth , CMTBadgePointWidth);
        _badgePoint.hidden = YES;
    }
    
    return _badgePoint;
}
-(CMTBadge *)badge {
    if (_badge == nil) {
        _badge = [[CMTBadge alloc] init];
        _badge.frame = CGRectMake(self.mLabelDes.left + 38.0, (50-kCMTBadgeWidth)/2, kCMTBadgeWidth, kCMTBadgeWidth);
        _badge.hidden = YES;
    }
    
    return _badge;
}


@end
