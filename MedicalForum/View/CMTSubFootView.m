//
//  CMTSubFootView.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/28.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTSubFootView.h"

@implementation CMTSubFootView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.mBtnMoreAccount];
        [self addSubview:self.mBtnMoreImg];
    }
    return self;
}

- (CMTButton *)mBtnMoreAccount
{
    if (!_mBtnMoreAccount)
    {
        _mBtnMoreAccount = [CMTButton buttonWithType:UIButtonTypeCustom];
        [_mBtnMoreAccount setTitle:@"更多账号" forState:UIControlStateNormal];
        _mBtnMoreAccount.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_mBtnMoreAccount setTitleColor:[UIColor colorWithRed:55.0/255 green:81.0/255 blue:151.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_mBtnMoreAccount setFrame:CGRectMake(120*RATIO, 0, 56*RATIO, 35)];
    }
    return _mBtnMoreAccount;
}
- (CMTButton *)mBtnMoreImg
{
    if (!_mBtnMoreImg)
    {
        _mBtnMoreImg = [CMTButton buttonWithType:UIButtonTypeCustom];
        [_mBtnMoreImg setImage:IMAGE(@"more_acc") forState:UIControlStateNormal];
        [_mBtnMoreImg setFrame:CGRectMake(120*RATIO+56*RATIO+5, 13.5, 15, 8)];
    }
    return _mBtnMoreImg;
}

- (void)drawRect:(CGRect)rect
{
    
}

@end
