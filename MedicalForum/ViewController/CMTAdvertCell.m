//
//  CMTAdvertCell.m
//  MedicalForum
//
//  Created by zhaohuan on 2017/2/28.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTAdvertCell.h"

@implementation CMTAdvertCell

- (UIImageView *)advertImageView{
    if (!_advertImageView) {
        _advertImageView = [[UIImageView alloc]init];
        _advertImageView.frame = CGRectMake(10 * XXXRATIO, 5 * XXXRATIO, SCREEN_WIDTH - 20 * XXXRATIO, (SCREEN_WIDTH - 20 * XXXRATIO)/4);
        _advertImageView.layer.masksToBounds = YES;
        _advertImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [_advertImageView addGestureRecognizer:tapGesture];
    }
    return _advertImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.advertImageView];
    }
    return self;
}

- (void)reloadCellWithModel:(CMTAdvert *)model{
    self.advert = model;
    self.advertImageView.frame = CGRectMake(10 * XXXRATIO, 5 * XXXRATIO, SCREEN_WIDTH - 20 * XXXRATIO, (SCREEN_WIDTH - 20 * XXXRATIO)/4);
    
    [self.advertImageView setImageURL:model.picUrl placeholderImage:IMAGE(@"Placeholderdefault") contentSize:CGSizeMake(self.advertImageView.width, self.advertImageView.height)];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, ((UIView *)[self.contentView subviews].firstObject).height+((UIView *)[self.contentView subviews].firstObject).top + 15 * XXXRATIO);
}


- (void)tapAction:(UITapGestureRecognizer *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAdvert:)]) {
        [self.delegate didSelectAdvert:self.advert];
    }
}

@end
