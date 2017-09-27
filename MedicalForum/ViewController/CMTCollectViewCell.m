//
//  CMTCollectViewCell.m
//  MedicalForum
//
//  Created by Bo Shen on 15/2/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCollectViewCell.h"

@implementation CMTCollectViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UIView *)tapSlectedView{
    if (!_tapSlectedView) {
        _tapSlectedView = [[UIView alloc]init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSelectedAction:)];
        [_tapSlectedView addGestureRecognizer:tapGesture];
    }
    return _tapSlectedView;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.mLbAuthor];
        [self.contentView addSubview:self.mImageView];
        [self.contentView addSubview:self.mLbTitle];
        [self.contentView addSubview:self.separatorLine];
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.imageViewStatus];
        [self.contentView addSubview:self.tapSlectedView];
        [self.contentView addSubview:self.mLbDate];

        self.separatorLine.hidden = YES;
        self.bottomLine.hidden = YES;
        [self.separatorLine builtinContainer:self WithLeft:0 Top:0 Width:SCREEN_WIDTH Height:PIXEL];
        [self.bottomLine builtinContainer:self WithLeft:0 Top:87-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
        
    }
    return self;
}


- (UILabel *)mLbTitle
{
    if (!_mLbTitle)
    {
        _mLbTitle = [[UILabel alloc]initWithFrame:CGRectMake(15.0*RATIO, 10, SCREEN_WIDTH-35*RATIO - self.mImageView.width, 42.0)];
        _mLbTitle.numberOfLines = 2;
        //        _mLbTitle.lineBreakMode = NSLineBreakByCharWrapping;
        //        _mLbTitle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
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
        _mLbAuthor = [[UILabel alloc]initWithFrame:CGRectMake(15*RATIO, 61, 134*RATIO, 13)];
        _mLbAuthor.font = FONT(11.0);
        _mLbAuthor.textColor = COLOR(c_9e9e9e);
    }
    return _mLbAuthor;
}

- (UILabel *)mLbDate
{
    if (!_mLbDate)
    {
        _mLbDate = [[UILabel alloc]initWithFrame:CGRectMake(self.mImageView.left - 74 - 20, 61, 74.0, 13)];
        _mLbDate.font = FONT(11.0);
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
        //[_mImageView setFrame:CGRectMake(232.0*RATIO + 73.0*(RATIO - 1), 13.5, 73.0, 60.5)];
        [_mImageView setFrame:CGRectMake(229.0*RATIO + 80.0*(RATIO - 1), 13.5, 80, 60)];
        _mImageView.clipsToBounds = YES;
        _mImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _mImageView;
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

- (UIImageView *)imageViewStatus{
    if (!_imageViewStatus) {
        _imageViewStatus = [[UIImageView alloc]initWithFrame:CGRectMake(-30, 0, 20, 20)];
    }
    return _imageViewStatus;
}

- (void)reloadCellWithModel:(CMTStore *)model
                NsIndexPath:(NSIndexPath *)indexPath{
    self.model = model;
    self.indexPath = indexPath;
    self.mLbTitle.text = model.title;
    self.mLbAuthor.text =!model.module.isPostModuleCase?model.postType:@"";
    self.mLbDate.text = DATE(model.createTime);
    CMTLog(@"smallPic = %@",model.smallPic);
    [self.mImageView setImageURL:model.smallPic placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(80.0, 60.0)];
    _imageViewStatus.image = model.isSelected ? [UIImage imageNamed:@"ic_checkbox_pressed"] : [UIImage imageNamed:@"ic_checkbox_normal"];
    _imageViewStatus.centerY = _mImageView.centerY;
    self.tapSlectedView.frame = self.contentView.frame;
}

- (void)tapSelectedAction:(UITapGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapSelectedAction:NsIndexPath:)]) {
        [self.delegate tapSelectedAction:self.model NsIndexPath:self.indexPath];
    }
}



@end
