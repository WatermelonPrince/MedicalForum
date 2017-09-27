//
//  CMTMoreCaseCell.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTMoreCaseCell.h"




@implementation CMTMoreCaseCell

- (UIImageView *)mImageView
{
    if (!_mImageView)
    {
        _mImageView = [[UIImageView alloc]initWithFrame:CGRectMake(16, 8, 14, 14)];
        _mImageView.clipsToBounds = YES;
        _mImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _mImageView;
}
- (UILabel *)mLbContents
{
    if (!_mLbContents)
    {
        _mLbContents = [[UILabel alloc]initWithFrame:CGRectMake(16+24, 8, SCREEN_WIDTH-43, 14)];
        [_mLbContents setTextColor:COLOR(c_4766a8)];
        [_mLbContents setFont:[UIFont systemFontOfSize:12.0]];
    }
    return _mLbContents;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.accessoryView.hidden = YES;
        [self addSubview:self.mImageView];
        [self addSubview:self.mLbContents];
        [self addSubview:self.sepLine];
        [self.sepLine builtinContainer:self.contentView WithLeft:0 Top:0 Width:SCREEN_WIDTH Height:PIXEL];
        [self addSubview:self.bottomLine];
        [self.bottomLine builtinContainer:self.contentView WithLeft:0 Top:32-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
    }
    return self;
}
- (UIView *)sepLine
{
    if (!_sepLine)
    {
        _sepLine = [[UIView alloc]init];
        _sepLine.backgroundColor = COLOR(c_eaeaea);
    }
    return _sepLine;
}
- (UIView *)bottomLine
{
    if (!_bottomLine)
    {
        _bottomLine = [[UIView alloc]init];
        _bottomLine.backgroundColor = COLOR(c_eaeaea);
    }
    return _bottomLine;
}


@end
