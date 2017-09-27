//
//  CMTPromptView.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/24.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTPromptView.h"

@implementation CMTPromptView

- (instancetype)initWithFrame:(CGRect)frame {
   
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self addSubview:self.mActivityView];
    [self addSubview:self.mLbContent];
}

- (UIActivityIndicatorView *)mActivityView
{
    if (_mActivityView == nil)
    {
        _mActivityView = [[UIActivityIndicatorView alloc]initWithFrame:self.frame];
        _mActivityView.center = self.center;
        
    }
    return _mActivityView;
}
- (UILabel *)mLbContent
{
    if (!_mLbContent)
    {
        _mLbContent = [[UILabel alloc]initWithFrame:self.frame];
        _mLbContent.center = self.center;
        _mLbContent.textAlignment = NSTextAlignmentCenter;
        _mLbContent.textColor = [UIColor whiteColor];
    }
    return _mLbContent;
}

- (void)setlbContent:(NSString *)content
{
    self.mLbContent.text = content;
}

@end
