//
//  CMTShareView.m
//  MedicalForum
//
//  Created by Bo Shen on 15/2/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//
#define WI  (self.frame.size.width-40*4)/8

#import "CMTShareView.h"

static CMTShareView *shareView = nil;

@implementation CMTShareView

+ (instancetype)shareView:(CGRect)frame
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shareView == nil)
        {
            shareView = [[self alloc]initWithFrame:frame];
        }
    });
    return shareView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.lbTitle.text = @"分享";
        self.lbTitle.textColor = [UIColor colorWithHexString:@"#424242"];
        [self addSubview:self.lbTitle];        
        [self addSubview:self.mBtnFriend];
        [self addSubview:self.mBtnSina];
        [self addSubview:self.mBtnWeix];
        [self addSubview:self.mBtnMail];
        [self addSubview:self.lbFriend];
        [self addSubview:self.lbSina];
        [self addSubview:self.lbWeix];
        [self addSubview:self.lbMail];
        [self addSubview:self.cancelBtn];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    
}
- (UILabel *)lbTitle
{
    if (!_lbTitle)
    {
        _lbTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 20,self.frame.size.width, 30)];
        _lbTitle.textColor = [UIColor grayColor];
        _lbTitle.font = [UIFont systemFontOfSize:15.0];
        _lbTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _lbTitle;
}

- (UIButton *)mBtnFriend
{
    if (!_mBtnFriend)
    {
        _mBtnFriend = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mBtnFriend setBackgroundImage:[UIImage imageNamed:@"friend"] forState:UIControlStateNormal];
        _mBtnFriend.frame = CGRectMake(WI, 230/3, 40, 40);
        _mBtnFriend.tag = 1111;
    }
    return _mBtnFriend;
}
- (UIButton *)mBtnWeix
{
    if (!_mBtnWeix)
    {
        _mBtnWeix = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mBtnWeix setBackgroundImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        [_mBtnWeix setFrame: CGRectMake(self.mBtnFriend.frame.origin.x+40+WI*2, 230/3, 40, 40)];
        _mBtnWeix.tag = 2222;
    }
    
    return _mBtnWeix;
}

- (UIButton *)mBtnSina
{
    if (!_mBtnSina)
    {
        _mBtnSina = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mBtnSina setBackgroundImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
        _mBtnSina.frame = CGRectMake(self.mBtnWeix.frame.origin.x+40+WI*2, 230/3, 40, 40);
        _mBtnSina.tag = 3333;
    }
    return _mBtnSina;
}

- (UIButton *)mBtnMail
{
    if (!_mBtnMail)
    {
        _mBtnMail = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mBtnMail setImage:[UIImage imageNamed:@"mail"] forState:UIControlStateNormal];
        [_mBtnMail setFrame:CGRectMake(self.frame.size.width-WI-40, 230/3, 40, 40)];
        _mBtnMail.tag = 4444;
    }
    return _mBtnMail;
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setFrame:CGRectMake((self.frame.size.width - 900/3)/2, 520/3, 900/3, 127/3)];
        if (self.frame.size.width > 1015/3) {
        [_cancelBtn setFrame:CGRectMake((self.frame.size.width - 1015/3)/2, 520/3, 1015/3, 127/3)];
        }
        
        _cancelBtn.backgroundColor = [UIColor colorWithHexString:@"#d7d7d7"];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelBtn.tag = 5555;
    }
    return _cancelBtn;
}

- (UILabel *)lbFriend
{
    if (!_lbFriend)
    {
        _lbFriend = [[UILabel alloc]initWithFrame:CGRectMake(0, 347/3, self.frame.size.width/4, 30)];
        _lbFriend.textColor = [UIColor colorWithHexString:@"#CFCFCF"];
        _lbFriend.textAlignment = NSTextAlignmentCenter;
        _lbFriend.font = [UIFont systemFontOfSize:12.0];
    }
    return _lbFriend;
}

- (UILabel *)lbWeix
{
    if (!_lbWeix)
    {
        _lbWeix = [[UILabel alloc]initWithFrame: CGRectMake(self.frame.size.width/4, 347/3, self.frame.size.width/4, 30)];
        _lbWeix.textColor = [UIColor colorWithHexString:@"#CFCFCF"];
        _lbWeix.textAlignment = NSTextAlignmentCenter;
        _lbWeix.font = [UIFont systemFontOfSize:12.0];
    }
    return _lbWeix;
}
- (UILabel *)lbSina
{
    if (!_lbSina)
    {
        _lbSina = [[UILabel alloc]initWithFrame: CGRectMake(self.frame.size.width/4*2, 347/3, self.frame.size.width/4, 30)];
        _lbSina.textColor = [UIColor colorWithHexString:@"#CFCFCF"];
        _lbSina.textAlignment = NSTextAlignmentCenter;
        _lbSina.font = [UIFont systemFontOfSize:12.0];
    }
    return _lbSina;
}

- (UILabel *)lbMail
{
    if (!_lbMail)
    {
        _lbMail = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/4*3, 347/3, self.frame.size.width/4, 30)];
        _lbMail.textColor = [UIColor colorWithHexString:@"#CFCFCF"];
        _lbMail.textAlignment = NSTextAlignmentCenter;
        _lbMail.font = [UIFont systemFontOfSize:12.0];
    }
    return _lbMail;
}


@end
