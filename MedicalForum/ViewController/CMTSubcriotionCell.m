//
//  CMTSubcriotionCell.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSubcriotionCell.h"

@implementation CMTSubcriotionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
      
        [self.contentView addSubview:self.mImageView];
        [self.contentView addSubview:self.mTextLabel];
        [self.contentView addSubview:self.mDetailTextLabel];
        //[self.contentView addSubview:self.mImageAccView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.imageView.hidden = YES;
        self.accessoryView.hidden = YES;
        //后期版本更新,增加新的分割线
        self.separatorLine.hidden = YES;
        self.bottomLine.hidden = YES;
        [self.separatorLine builtinContainer:self WithLeft:0 Top:0 Width:SCREEN_WIDTH Height:PIXEL];
        [self.bottomLine builtinContainer:self WithLeft:0 Top:self.contentView.frame.size.height+PIXEL+5 Width:SCREEN_WIDTH Height:PIXEL];
        [self.contentView addSubview:self.leftColorView];
        [self.contentView addSubview:self.bottomView];
        [self.contentView addSubview:self.mImageViewPostView];
        [self.contentView addSubview:self.mLbPostsCount];
        
        [self.contentView addSubview:self.mImageBottom];
       
    }
    return self;
}

- (UIImageView *)mImageView
{
    if (!_mImageView)
    {
        _mImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 47, 47)];
        _mImageView.layer.masksToBounds = YES;
        _mImageView.layer.cornerRadius = _mImageView.frame.size.height/2;
        [_mImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_mImageView setClipsToBounds:YES];
    }
    return _mImageView;
}

- (UILabel *)mTextLabel
{
    if (!_mTextLabel)
    {
        _mTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 13, SCREEN_WIDTH-75-26*RATIO, 19)];
        _mTextLabel.font = [UIFont systemFontOfSize:17.0];
    }
    return _mTextLabel;
}

- (UILabel *)mDetailTextLabel
{
    if (!_mDetailTextLabel)
    {
        _mDetailTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 27, SCREEN_WIDTH-75-26*RATIO, 26)];
        _mDetailTextLabel.textColor = COLOR(c_ababab);
        _mDetailTextLabel.font = [UIFont systemFontOfSize:12.0];
        //_mDetailTextLabel.adjustsFontSizeToFitWidth = YES;
        _mDetailTextLabel.numberOfLines = 0;
    }
    return _mDetailTextLabel;
}

- (UIImageView *)mImageAccView
{
    if (!_mImageAccView)
    {
        _mImageAccView = [[UIImageView alloc]initWithFrame:CGRectMake(299*RATIO, 18, 11, 18)];
        _mImageAccView.image = IMAGE(@"acc");
    }
    return _mImageAccView;
}
- (UIView *)leftColorView
{
    if (!_leftColorView)
    {
        _leftColorView = [[UIView alloc]init];
        _leftColorView.backgroundColor = [UIColor redColor];
    }
    return _leftColorView;
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
- (UIImageView *)mImageViewPostView
{
    if (!_mImageViewPostView)
    {
        _mImageViewPostView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 14.0, 14.0)];
        _mImageViewPostView.backgroundColor = [UIColor clearColor];
        
    }
    return _mImageViewPostView;
}
- (UILabel *)mLbPostsCount
{
    if (!_mLbPostsCount)
    {
        _mLbPostsCount = [[UILabel alloc]init];
        _mLbPostsCount.textAlignment = NSTextAlignmentLeft;
        _mLbPostsCount.backgroundColor = [UIColor clearColor];
        _mLbPostsCount.font = [UIFont systemFontOfSize:10.0];
        _mLbPostsCount.textColor = COLOR(c_ababab);
    }
    return _mLbPostsCount;
}


- (UIView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    }
    return _bottomView;
}
- (UIImageView *)mImageBottom
{
    if (!_mImageBottom)
    {
        _mImageBottom = [[UIImageView alloc]init];
        _mImageBottom.backgroundColor = [UIColor clearColor];
    }
    return _mImageBottom;
}

@end
