//
//  CMTSubcritionListCell.m
//  MedicalForum
//
//  Created by Bo Shen on 15/3/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSubcritionListCell.h"

@implementation CMTSubcritionListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.mLbSub];
        [self.contentView addSubview:self.mBtnSub];
        [self.contentView addSubview:self.mImageAcc];
        [self.mLbSub builtinContainer:self WithLeft:12.0 Top:16.0 Width:120.0 Height:16.0];
        [self.mBtnSub builtinContainer:self WithLeft:SCREEN_WIDTH*2.0/3.0-80 Top:11.0 Width:72.0 Height:28.0];
        [self.mImageAcc builtinContainer:self WithLeft:SCREEN_WIDTH*2.0/3.0-20.0 Top:15.0 Width:10.0 Height:20];
        [self.contentView addSubview:self.separatorLine];
        [self.contentView addSubview:self.bottomLine];
        self.separatorLine.hidden = YES;
        self.bottomLine.hidden = YES;
        [self.separatorLine builtinContainer:self WithLeft:12.0 Top:0 Width:SCREEN_WIDTH*2.0/3.0-24.0 Height:PIXEL];
        [self.bottomLine builtinContainer:self WithLeft:0 Top:self.contentView.frame.size.height+PIXEL+5 Width:SCREEN_WIDTH*2.0/3.0 Height:PIXEL];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (UILabel *)mLbSub
{
    if (!_mLbSub)
    {
        _mLbSub = [[UILabel alloc]init];
    }
    return _mLbSub;
}

- (CMTButton *)mBtnSub
{
    if (!_mBtnSub)
    {
        _mBtnSub = [CMTButton buttonWithType:UIButtonTypeRoundedRect];
        _mBtnSub.layer.borderColor = COLOR(c_32c7c2).CGColor;
        _mBtnSub.layer.borderWidth = PIXEL;
        _mBtnSub.layer.cornerRadius = 6.0;
        [_mBtnSub setTitle:@"+ 订阅" forState:UIControlStateNormal];
        [_mBtnSub setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        _mBtnSub.isTaped = NO;
    }
    return _mBtnSub;
}
- (UIImageView *)mImageAcc
{
    if (!_mImageAcc)
    {
        _mImageAcc = [[UIImageView alloc]initWithImage:IMAGE(@"enter")];
    }
    return _mImageAcc;
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
