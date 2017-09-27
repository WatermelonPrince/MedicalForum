//
//  CMTSearchTableViewCell.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/18.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTSearchTableViewCell.h"

@implementation CMTSearchTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addSubview:self.mLbTitle];
        [self addSubview:self.mLbAuthor];
        [self addSubview:self.mLbDate];
        [self addSubview:self.mImageView];
        [self.contentView addSubview:self.sepLine];
        [self.contentView addSubview:self.bottomLine];
        self.sepLine.hidden = YES;
        [self.sepLine builtinContainer:self.contentView WithLeft:14 Top:0 Width:SCREEN_WIDTH Height:PIXEL];
        self.bottomLine.hidden = YES;
        [self.bottomLine builtinContainer:self.contentView WithLeft:0 Top:88-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
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
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc]init];
        _bottomLine.backgroundColor = COLOR(c_eaeaea);
    }
    return _bottomLine;
}

- (UILabel *)mLbTitle
{
    if (!_mLbTitle)
    {
        CGFloat titleWidth =SCREEN_WIDTH-14.0-100-14.0;
        _mLbTitle = [[UILabel alloc]initWithFrame:CGRectMake(14.0, 10, titleWidth, 42.0)];
        _mLbTitle.numberOfLines = 2;
        _mLbTitle.textColor = COLOR(c_151515);
        _mLbTitle.backgroundColor = COLOR(c_clear);
        _mLbTitle.textColor = COLOR(c_151515);
        _mLbTitle.font = FONT(17.0);
        
    }
    return _mLbTitle;
}
- (UILabel *)mLbAuthor
{
    if (!_mLbAuthor)
    {
        _mLbAuthor = [[UILabel alloc]initWithFrame:CGRectMake(15, 61, self.mLbTitle.width-74.0, 14)];
        _mLbAuthor.font = FONT(12.0);
        _mLbAuthor.textColor = COLOR(c_9e9e9e);
    }
    return _mLbAuthor;
}

- (UILabel *)mLbDate
{
    if (!_mLbDate)
    {
        _mLbDate = [[UILabel alloc]initWithFrame:CGRectMake(self.mLbTitle.right-74.0, 61, 74.0, 13)];
        _mLbDate.font = FONT(12.0);
        _mLbDate.textAlignment = NSTextAlignmentRight;
        _mLbDate.textColor = COLOR(c_9e9e9e);
    }
    return _mLbDate;
}

- (UIImageView *)mImageView
{
    if (!_mImageView)
    {
        _mImageView = [[UIImageView alloc]initWithImage:nil];
        [_mImageView setFrame:CGRectMake(self.mLbTitle.right+20, 13.5, 80, 60)];
        _mImageView.clipsToBounds = YES;
        _mImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _mImageView;
}


@end
