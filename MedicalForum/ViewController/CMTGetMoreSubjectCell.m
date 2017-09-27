//
//  CMTGetMoreSubjectCell.m
//  MedicalForum
//
//  Created by Bo Shen on 15/4/7.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTGetMoreSubjectCell.h"

@implementation CMTGetMoreSubjectCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.mLbGerMore];
        [self.contentView addSubview:self.separatorLine];
        [self.contentView addSubview:self.bottomLine];
        self.separatorLine.hidden = YES;
        self.bottomLine.hidden = NO;
        [self.separatorLine builtinContainer:self WithLeft:0 Top:0 Width:SCREEN_WIDTH Height:PIXEL];
        //[self.bottomLine builtinContainer:self WithLeft:0 Top:self.contentView.frame.size.height+PIXEL Width:SCREEN_WIDTH Height:PIXEL];
    }
    return self;
}

- (UILabel *)mLbGerMore
{
    if (!_mLbGerMore)
    {
        _mLbGerMore = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        _mLbGerMore.textAlignment = NSTextAlignmentCenter;
        _mLbGerMore.font = [UIFont systemFontOfSize:14.0];
        _mLbGerMore.textColor = COLOR(c_4766a8);
        [_mLbGerMore addSubview:self.bottomLine];
        
         [self.bottomLine builtinContainer:_mLbGerMore WithLeft:0 Top:30-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
    }
    return _mLbGerMore;
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


@end
