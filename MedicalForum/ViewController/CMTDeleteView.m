//
//  CMTDeleteView.m
//  MedicalForum
//
//  Created by zhaohuan on 2017/2/15.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTDeleteView.h"

@implementation CMTDeleteView
- (UIButton *)checkAllButton{
    if (!_checkAllButton) {
        _checkAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkAllButton.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, 50);
        [_checkAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [_checkAllButton setTitle:@"取消全选" forState:UIControlStateSelected];
        [_checkAllButton setTitleColor:[UIColor colorWithHexString:@"e8b260"] forState:UIControlStateNormal];
        _checkAllButton.titleLabel.font = FONT(15);
        _checkAllButton.selected = NO;
    }
    return _checkAllButton;
}

- (UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 50);
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = FONT(15);
        [_deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    return _deleteButton;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
        self.checkAllButton.height = frame.size.height;
        self.deleteButton.height = frame.size.height;
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5,5 , 1, frame.size.height - 10)];
        lineView.backgroundColor = COLOR(c_eaeaea);
        [self addSubview:self.checkAllButton];
        [self addSubview:self.deleteButton];
        [self addSubview:lineView];
    }
    return self;
}

@end
