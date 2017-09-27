//
//  CMTTableSectionHeader.m
//  MedicalForum
//
//  Created by fenglei on 14/12/19.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTTableSectionHeader.h"

@interface CMTTableSectionHeader ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation CMTTableSectionHeader

+ (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight {
    
    return [[[CMTTableSectionHeader alloc] init] headerWithHeaderWidth:headerWidth headerHeight:headerHeight];
}
+ (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight inSection:(NSInteger)section{
    return [[[CMTTableSectionHeader alloc]init]headerWithHeaderWidth:headerWidth headerHeight:headerHeight inSection:section];
}
+ (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight inSection:(NSInteger)section isneedButtomLine:(BOOL)isneed{
    return [[[CMTTableSectionHeader alloc]init]headerWithHeaderWidth:headerWidth headerHeight:headerHeight inSection:section];

}
+ (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight isneedbuttomLine:(BOOL)isneed{
    return [[[CMTTableSectionHeader alloc] init] headerWithHeaderWidth:headerWidth headerHeight:headerHeight isneedbuttomLine:isneed];
}
- (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight isneedbuttomLine:(BOOL)isneed  {
    self.backgroundColor = COLOR(c_efeff4);
    self.titleLabel.frame = CGRectMake(13.0, 0.0, headerWidth, headerHeight);
    self.titleLabel.font = FONT(13.0);
    self.titleLabel.textColor = COLOR(c_9e9e9e);
    [self addSubview:self.titleLabel];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, headerHeight - PIXEL, headerWidth, PIXEL)];
     bottomLine.hidden=!isneed;
    bottomLine.backgroundColor = COLOR(c_9e9e9e);
    [self addSubview:bottomLine];
    
    //    UIView *headerLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerWidth, PIXEL)];
    //    headerLine.backgroundColor = COLOR(c_9e9e9e);
    //    [self addSubview:headerLine];
    
    return self;
}


- (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight {
    self.backgroundColor = COLOR(c_efeff4);
    self.titleLabel.frame = CGRectMake(13.0, 0.0, headerWidth, headerHeight);
    self.titleLabel.font = FONT(13.0);
    self.titleLabel.textColor = COLOR(c_9e9e9e);
    [self addSubview:self.titleLabel];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, headerHeight - PIXEL, headerWidth, PIXEL)];
    bottomLine.backgroundColor = COLOR(c_9e9e9e);
    [self addSubview:bottomLine];
    
//    UIView *headerLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerWidth, PIXEL)];
//    headerLine.backgroundColor = COLOR(c_9e9e9e);
//    [self addSubview:headerLine];
    
    return self;
}
- (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight inSection:(NSInteger)section {
    self.backgroundColor = COLOR(c_efeff4);
    self.titleLabel.frame = CGRectMake(13.0, 0.0, headerWidth, headerHeight);
    self.titleLabel.font = FONT(13.0);
    self.titleLabel.textColor = COLOR(c_9e9e9e);
    [self addSubview:self.titleLabel];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, headerHeight - PIXEL, headerWidth, PIXEL)];
    bottomLine.backgroundColor = COLOR(c_9e9e9e);
    [self addSubview:bottomLine];
    
    if (section != 0) {
        UIView *headerLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerWidth, PIXEL)];
        headerLine.backgroundColor = COLOR(c_9e9e9e);
        [self addSubview:headerLine];
    }
    
    
    return self;
}


- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = COLOR(c_clear);
    }
    
    return _titleLabel;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end
