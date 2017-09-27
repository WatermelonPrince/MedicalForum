//
//  CMTToastView.m
//  MedicalForum
//
//  Created by Bo Shen on 15/2/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//


#import "CMTToastView.h"

@implementation CMTToastView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.mLbContent];
        self.backgroundColor = COLOR(c_fbc36b);
        [self addSubview:self.netImageView];
        self.netImageView.hidden = YES;
    }
    return self;
}

- (UILabel *)mLbContent
{
    if (!_mLbContent)
    {
        _mLbContent = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _mLbContent.textColor = [UIColor whiteColor];
        _mLbContent.textAlignment = NSTextAlignmentCenter;
        _mLbContent.font = [UIFont systemFontOfSize:13.0];
    }
    return _mLbContent;
}
- (UIImageView *)netImageView
{
    if (!_netImageView)
    {
        _netImageView = [[UIImageView alloc]initWithImage:IMAGE(@"netHit")];
        _netImageView.frame = CGRectMake(48*RATIO, 7.5, 15, 15);
    }
    return _netImageView;
}

@end
