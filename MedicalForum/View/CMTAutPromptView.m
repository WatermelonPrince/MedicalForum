//
//  CMTAutPromptView.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTAutPromptView.h"

@implementation CMTAutPromptView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:234.0/255 green:103.0/255 blue:107.0/255 alpha:1.0];
        [self addSubview:self.mImageView];
        [self addSubview:self.mLbContent];
    }
    return self;
}


- (UIImageView *)mImageView
{
    if (!_mImageView)
    {
        _mImageView = [[UIImageView alloc]initWithImage:IMAGE(@"reminder")];
        [_mImageView setFrame:CGRectMake(23, 3, 30, 30)];
    }
    return _mImageView;
}

- (UILabel *)mLbContent
{
    if (!_mLbContent)
    {
        _mLbContent = [[UILabel alloc]initWithFrame:CGRectMake(59, 10, 250*RATIO, 15)];
        _mLbContent.textColor = [UIColor whiteColor];
    }
    return _mLbContent;
}

- (void)setContentText:(NSString *)str
{
    self.mLbContent.text = str;
}

@end
