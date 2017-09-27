//
//  CMTPersonalCell.m
//  MedicalForum
//
//  Created by zhaohuan on 2017/4/12.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTPersonalCell.h"

@implementation CMTPersonalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc]init];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.layer.cornerRadius = 25;
        _headImageView.clipsToBounds = YES;
    }
    return _headImageView;
}
- (UILabel *)leftLabel{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc]init];
        _leftLabel.font = FONT(16);
        _leftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftLabel;
}
- (UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc]init];
        _rightLabel.font = FONT(15);
        _rightLabel.textAlignment = NSTextAlignmentRight;
        
        _rightLabel.textColor = COLOR(c_ababab);
    }
    return _rightLabel;
}
- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = ColorWithHexStringIndex(c_f5f5f5);
    }
    return _lineView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.leftLabel];
        [self.contentView addSubview:self.rightLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)reloadWithLeftString:(NSString *)lString
                 rightString:(NSString *)rString
                   WithImage:(BOOL)haveImage{
    if (haveImage) {
        self.leftLabel.hidden = YES;
        self.leftLabel.hidden = NO;
        self.headImageView.frame = CGRectMake(20, 10, 50, 50);
        if( CMTUSER.login == YES && [[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]] == NO)
        {
            [self.headImageView setImageURL:CMTUSERINFO.picture placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(48.0, 48.0)];
        }
        else if (CMTUSER.login == YES && [[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]])
        {
            UIImage *pImage = [UIImage imageWithContentsOfFile:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]];
            self.headImageView.image = pImage;
        }
        else
        {
            //获取设置头像
            UIImage *pImage = IMAGE(@"ic_default_head");
            self.headImageView.image = pImage;
        }
        self.rightLabel.frame = CGRectMake(SCREEN_WIDTH - 40 - 120, 20, 120, 30);
        self.rightLabel.text = rString;
        self.lineView.frame = CGRectMake(0, 69, SCREEN_WIDTH, 1);
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 70);
    }else{
        float width = [CMTGetStringWith_Height CMTGetLableTitleWith:lString fontSize:16];
        self.leftLabel.frame = CGRectMake(20,0, width, 30);
        float height = [CMTGetStringWith_Height getTextheight:rString fontsize:15 width:SCREEN_WIDTH-40-self.leftLabel.right - 50];
        if (height > 30) {
            self.rightLabel.frame = CGRectMake(self.leftLabel.right + 50, 10, SCREEN_WIDTH-40-self.leftLabel.right - 50, height);
            self.leftLabel.frame = CGRectMake(20,0, width, 30);
            self.leftLabel.centerY = self.rightLabel.centerY;
            self.lineView.frame = CGRectMake(0, height + 19, SCREEN_WIDTH, 1);
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, height + 20);

        }else{
            self.leftLabel.frame = CGRectMake(20, 10, width, 30);
            self.rightLabel.frame = CGRectMake(self.leftLabel.right + 50, 10, SCREEN_WIDTH-40-self.leftLabel.right - 50, 30);
            self.lineView.frame = CGRectMake(0, 49, SCREEN_WIDTH, 1);
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        }
        self.rightLabel.numberOfLines = 0;
        self.leftLabel.text = lString;
        self.rightLabel.text = rString;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
