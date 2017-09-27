//
//  CMTListCollegeGuideView.m
//  MedicalForum
//
//  Created by zhaohuan on 16/10/14.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTListCollegeGuideView.h"

@implementation CMTListCollegeGuideView

- (UIButton *)guideButton{
    if (!_guideButton) {
        _guideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _guideButton.contentMode = UIViewContentModeScaleAspectFill;
//        _guideButton.backgroundColor = [UIColor cyanColor];
    }
    return _guideButton;
}

- (UILabel *)guideLabel{
    if (!_guideLabel) {
        _guideLabel = [[UILabel alloc]init];
        _guideLabel.font = FONT(13);
        _guideLabel.textColor = [UIColor colorWithHexString:@"7b7d81"];
    }
    return _guideLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor clearColor];
    }
    return _lineView;
}
- (UIView *)touchView{
    if (!_touchView) {
        _touchView = [[UIView alloc]init];
           }
    return _touchView;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.guideButton.size = CGSizeMake(100/3 * XXXRATIO, 100/3 * XXXRATIO);
        self.guideButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.guideButton.frame = CGRectMake(_guideButton.left, 40/3 * XXXRATIO, _guideButton.width ,_guideButton.height);
        self.guideLabel.frame = CGRectMake(0, _guideButton.bottom + 6 * XXXRATIO, frame.size.width - 1, 21 * XXXRATIO);
        self.lineView.frame = CGRectMake(frame.size.width - 1, 40 / 3 * XXXRATIO, 1, frame.size.height - 40 / 3 * XXXRATIO * 2);
        self.touchView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:self.guideLabel];
        [self addSubview:self.lineView];
        [self addSubview:self.guideButton];
        [self addSubview:self.touchView];


    }
    return self;
}

@end
