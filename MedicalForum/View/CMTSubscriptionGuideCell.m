//
//  CMTSubscriptionGuideCell.m
//  MedicalForum
//
//  Created by fenglei on 15/3/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSubscriptionGuideCell.h"

static const CGFloat CMTSubscriptionGuideCellDefaultHeight = 50.0;

@interface CMTSubscriptionGuideCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *addSubButton;
@property (nonatomic, strong) UIButton *subscriptionButton;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation CMTSubscriptionGuideCell

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = COLOR(c_clear);
        _titleLabel.textColor = COLOR(c_424242);
        _titleLabel.font = FONT(17.0);
    }
    
    return _titleLabel;
}

- (UIButton *)addSubButton {
    if (_addSubButton == nil) {
        _addSubButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addSubButton.backgroundColor = COLOR(c_ffffff);
        [_addSubButton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        [_addSubButton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateHighlighted];
        [_addSubButton setTitle:@"+ 订阅" forState:UIControlStateNormal];
        _addSubButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _addSubButton.layer.masksToBounds = YES;
        _addSubButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
        _addSubButton.layer.borderWidth = PIXEL;
        _addSubButton.layer.cornerRadius = 5.0;
        _addSubButton.userInteractionEnabled = NO;
    }
    
    return _addSubButton;
}

- (UIButton *)subscriptionButton {
    if (_subscriptionButton == nil) {
        _subscriptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _subscriptionButton.backgroundColor = COLOR(c_32c7c2);
        [_subscriptionButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [_subscriptionButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateHighlighted];
        [_subscriptionButton setTitle:@"已订阅" forState:UIControlStateNormal];
        _subscriptionButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _subscriptionButton.layer.masksToBounds = YES;
        _subscriptionButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
        _subscriptionButton.layer.borderWidth = PIXEL;
        _subscriptionButton.layer.cornerRadius = 5.0;
        _subscriptionButton.userInteractionEnabled = NO;
    }
    
    return _subscriptionButton;
}

- (UIView *)separatorLine {
    if (_separatorLine == nil) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _separatorLine;
}

#pragma mark Initializers

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = COLOR(c_ffffff);
    self.backgroundView = background;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.addSubButton];
    [self.contentView addSubview:self.subscriptionButton];
    [self.contentView addSubview:self.separatorLine];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.subscriptionButton.hidden = YES;
    
    return self;
}

#pragma mark LifeCycle

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)reloadSubscription:(CMTConcern *)subscription tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    self.titleLabel.text = subscription.subject;
    if ([subscription.CMT_selected boolValue] == YES) {
        self.subscriptionButton.hidden = NO;
        self.addSubButton.hidden = YES;
    }
    else {
        self.subscriptionButton.hidden = YES;
        self.addSubButton.hidden = NO;
    }
    
    CGFloat cellWidth = tableView.width;
    [self layoutWithCellWidth:cellWidth cellHeight:CMTSubscriptionGuideCellDefaultHeight];
    
    
}

- (BOOL)layoutWithCellWidth:(CGFloat)cellWidth
                 cellHeight:(CGFloat)cellHeight {
    
    self.titleLabel.frame = CGRectMake(10.0*RATIO, 15.5, 200.0, 17.0);
    self.addSubButton.frame = CGRectMake(cellWidth - 15.0*RATIO - 71.0, 11.0, 71.0, 28.0);
    self.subscriptionButton.frame = CGRectMake(cellWidth - 15.0*RATIO - 71.0, 11.5, 71.0, 28.0);
    self.separatorLine.frame = CGRectMake(0, cellHeight - PIXEL, cellWidth, PIXEL);
    
    return YES;
}

@end
