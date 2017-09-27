//
//  CMTMySubcribeCell.m
//  MedicalForum
//
//  Created by zhaohuan on 16/9/19.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTMySubcribeCell.h"


@interface CMTMySubcribeCell ()


@end

@implementation CMTMySubcribeCell

- (UIImageView *)iconImage{
    if (!_iconImage) {
        _iconImage = [[UIImageView alloc]init];
        _iconImage.frame = CGRectMake(10, 10, 140/3, 140/3);
        _iconImage.contentMode = UIViewContentModeScaleAspectFill;
        _iconImage.layer.masksToBounds = YES;
    }
    return _iconImage;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.frame = CGRectMake(0, 202/3 - 1, SCREEN_WIDTH, 1);
        _lineView.backgroundColor = ColorWithHexStringIndex(c_f6f6f6);
    }
    return _lineView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = FONT(17);
        _titleLabel.frame = CGRectMake(self.iconImage.right + 15, self.iconImage.top, SCREEN_WIDTH - 132/3 - self.iconImage.right - 30,self.iconImage.height);
        _titleLabel.numberOfLines=2;
        _titleLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        _titleLabel.textColor = ColorWithHexStringIndex(c_151515);
//        _titleLabel.backgroundColor = [UIColor redColor];
    }
    return _titleLabel;
}
- (UILabel *)readCountLabel{
    if (!_readCountLabel) {
        _readCountLabel = [[UILabel alloc]init];
        _readCountLabel.frame = CGRectMake(SCREEN_WIDTH - 132/3, (202/3 - 42/3)/2, 132/3-10, 42/3);
        _readCountLabel.textColor = [UIColor colorWithHexString:@"dadada"];
        _readCountLabel.textAlignment = NSTextAlignmentRight;
//        _readCountLabel.backgroundColor = [UIColor cyanColor];
    }
    return _readCountLabel;
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconImage];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.readCountLabel];
        [self.contentView addSubview:self.lineView];

        
    }
    return self;
}


- (void)reloadCellWithData:(CMTSeriesDetails *)data{
//    self.iconImage.image =
    if (data) {
        [self.iconImage setImageURL:data.picUrl placeholderImage:IMAGE(@"Placeholderdefault") contentSize:self.iconImage.size];
        float height=ceilf([CMTGetStringWith_Height getTextheight:@"中国" fontsize:17 width: self.titleLabel.width]);
        float height2=ceilf([CMTGetStringWith_Height getTextheight:data.seriesName fontsize:17 width: self.titleLabel.width]);
        self.titleLabel.height=height*2+10>height2+10?height2+10:height*2+10;
        self.titleLabel.text = data.seriesName;
        if (data.newrecordCount.integerValue > 999) {
            //当消息数大于999的时候 显示999+

            self.readCountLabel.text = @"999+";
        }else{
            //当消息数为0的时候 不显示
            if (data.newrecordCount.integerValue == 0) {
                self.readCountLabel.text = @"";
            }else{
                self.readCountLabel.text = data.newrecordCount;
            }
        }
    }

}

@end
