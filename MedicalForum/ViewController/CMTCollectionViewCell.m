//
//  CMTCollectionViewCell.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCollectionViewCell.h"

@implementation CMTCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.mImageView];
        [self addSubview:self.lbPostType];
        //self.backgroundColor = [UIColor greenColor];
    }
    return self;
}
- (UIImageView *)mImageView
{
    if (!_mImageView)
    {
        _mImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.width-53)/2, 0, 53, 53)];
        _mImageView.layer.masksToBounds = YES;
        _mImageView.layer.cornerRadius = _mImageView.frame.size.height/2;
        [_mImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_mImageView setClipsToBounds:YES];
        //_mImageView.center = CGPointMake(self.center.x, self.center.y - 15);
        //_mImageView.centerX = SCREEN_WIDTH/8;
    }
    return _mImageView;
}
- (UILabel *)lbPostType
{
    if (!_lbPostType)
    {
        _lbPostType = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width+1*RATIO, 30)];
        _lbPostType.font = [UIFont systemFontOfSize:15];
        _lbPostType.centerX = self.mImageView.centerX;
        _lbPostType.textAlignment = NSTextAlignmentCenter;
        _lbPostType.textColor = COLOR(c_838389);
    }
    return _lbPostType;
}


@end
