//
//  CMTSearchColledgeDataCell.m
//  MedicalForum
//
//  Created by zhaohuan on 16/10/28.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSearchColledgeDataCell.h"

@implementation CMTSearchColledgeDataCell

- (UIImageView *)iconImage{
    if (_iconImage == nil) {
        _iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16 - 0.8,24, 24)];
        _iconImage.image =[UIImage imageNamed:@"searchCellIcon"];
    }
    return _iconImage;
}

- (UILabel *)searchLabel{
    if (_searchLabel == nil) {
        _searchLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.iconImage.right + 10, 0, SCREEN_WIDTH -self.deleteButton.width-20-self.iconImage.right-10, 60- 0.8)];
        _searchLabel.textColor = [UIColor colorWithHexString:@"737373"];
        _searchLabel.font = FONT(18);
    }
    return _searchLabel;
}

- (UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(SCREEN_WIDTH-60, 5- 0.8, 50,50);

        [_deleteButton setImage:[UIImage imageNamed:@"searchCellDelete"]  forState:UIControlStateNormal];
    }
    return _deleteButton;
}
-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 60- 0.8, SCREEN_WIDTH-10, 0.8)];
        _lineView.backgroundColor = COLOR(c_f6f6f6);
    }
    return _lineView;
}




- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconImage];
        [self.contentView addSubview:self.searchLabel];
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

@end
