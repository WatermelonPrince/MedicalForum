//
//  CMTIntegralToastView.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTIntegralToastView.h"

@implementation CMTIntegralToastView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.layer.borderWidth=1;
        self.layer.cornerRadius=5;
        [self addSubview:self.titlelable];
        [self addSubview:self.Content];
        self.backgroundColor = COLOR(c_5B5B5B);
        [self addSubview:self.netImageView];
    }
    return self;
}

- (UILabel *)Content
{
    if (!_Content)
    {
        _Content = [[UILabel alloc]initWithFrame:CGRectMake(0, 82+10, self.width, 40)];
        _Content.textColor = [UIColor whiteColor];
        _Content.textAlignment = NSTextAlignmentCenter;
        _Content.font = [UIFont systemFontOfSize:15];
    }
    return _Content;
}
- (UILabel *)titlelable
{
    if (!_titlelable)
    {
        _titlelable = [[UILabel alloc]initWithFrame:CGRectMake(0,92+50, self.width, 40)];
        _titlelable.textColor = [UIColor whiteColor];
        _titlelable.textAlignment = NSTextAlignmentCenter;
        _titlelable.font = [UIFont systemFontOfSize:15];
    }
    return _titlelable;
}

- (UIImageView *)netImageView
{
    if (!_netImageView)
    {
        _netImageView = [[UIImageView alloc]initWithImage:IMAGE(@"Prompt_pop-up")];
        _netImageView.frame = CGRectMake((self.width-45)/2, 20, 45, 62);
    }
    return _netImageView;
}

@end
