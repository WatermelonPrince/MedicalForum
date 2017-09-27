//
//  CMTReplyToolBar.m
//  MedicalForum
//
//  Created by fenglei on 15/9/6.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTReplyToolBar.h"

const CGFloat CMTReplyToolBarDefaultHeight = 38;
static const CGFloat CMTReplyToolBarItemIconWidth = 20.0;
static const CGFloat CMTReplyToolBarGap = 6.0;

@interface CMTReplyToolBarItem ()

// view
@property (nonatomic, strong, readwrite) UIButton *itemButton;
@property (nonatomic, strong, readwrite) UIImageView *itemIconImageView;
@property (nonatomic, strong, readwrite) UILabel *itemTitleLabel;

// output
@property (nonatomic, strong, readwrite) RACSignal *itemTouchSignal;

@end

@implementation CMTReplyToolBarItem

#pragma mark Initializers

- (UIButton *)itemButton {
    if (_itemButton == nil) {
        _itemButton = [[UIButton alloc] init];
        _itemButton.backgroundColor = COLOR(c_clear);
    }
    
    return _itemButton;
}

- (UIImageView *)itemIconImageView {
    if (_itemIconImageView == nil) {
        _itemIconImageView = [[UIImageView alloc] init];
        _itemIconImageView.backgroundColor = COLOR(c_clear);
        _itemIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _itemIconImageView;
}

- (UILabel *)itemTitleLabel {
    if (_itemTitleLabel == nil) {
        _itemTitleLabel = [[UILabel alloc] init];
        _itemTitleLabel.backgroundColor = COLOR(c_clear);
        _itemTitleLabel.textColor = COLOR(c_9e9e9e);
        _itemTitleLabel.font = FONT(13.0);
    }
    
    return _itemTitleLabel;
}

+ (instancetype)itemWithItemTitle:(NSString *)itemTitle
                         itemIcon:(NSString *)itemIcon {
    CMTReplyToolBarItem *item = [[self alloc] init];
    if (item == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    [item.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"ReplyToolBarItem willDeallocSignal");
    }];
    
    // subView
    [item addSubview:item.itemButton];
    [item addSubview:item.itemIconImageView];
    [item addSubview:item.itemTitleLabel];
    
    // data
    item.itemIconImageView.image = IMAGE(itemIcon);
    item.itemTitleLabel.text = itemTitle ?: @"";
    item.itemTouchSignal = [item.itemButton rac_signalForControlEvents:UIControlEventTouchUpInside];
   
    return item;
}

- (void)layoutSubviews {
    self.itemButton.frame = self.bounds;
    CGFloat toolBarGap = CMTReplyToolBarGap*RATIO;
    self.itemIconImageView.frame = CGRectMake(self.width/2.0 - toolBarGap - CMTReplyToolBarItemIconWidth,
                                              (self.height - CMTReplyToolBarItemIconWidth)/2.0,
                                              CMTReplyToolBarItemIconWidth,
                                              CMTReplyToolBarItemIconWidth);
    self.itemTitleLabel.frame = CGRectMake(self.width/2.0,
                                           0.0,
                                           self.width/2.0 - toolBarGap,
                                           self.height);
}

@end

@interface CMTReplyToolBar ()

// data
@property (nonatomic, copy) NSArray *toolBarItems;

@end

@implementation CMTReplyToolBar

#pragma mark Initializers

- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray *)items {
    if (items.count == 0) {
        CMTLogError(@"ReplyToolBar Empty Items");
        return nil;
    }
    
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    @weakify(self);
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"ReplyToolBar willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_f6f6f6);
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, PIXEL)];
    topLine.backgroundColor = COLOR(c_dddddd);
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.height - PIXEL, self.width, PIXEL)];
    bottomLine.backgroundColor = COLOR(c_dddddd);
    [self addSubview:topLine];
    [self addSubview:bottomLine];
    
    self.toolBarItems = items;
    CGFloat itemWidth = self.width/self.toolBarItems.count;
    [self.toolBarItems enumerateObjectsUsingBlock:^(CMTReplyToolBarItem *toolBarItem, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        if ([toolBarItem isKindOfClass:[CMTReplyToolBarItem class]]) {
            if (idx != 0) {
                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(itemWidth*idx, 0.0, PIXEL, self.height)];
                separator.backgroundColor = COLOR(c_dddddd);
                [self addSubview:separator];
            }
            
            toolBarItem.frame = CGRectMake(itemWidth*idx, 0.0, itemWidth, self.height);
            [self addSubview:toolBarItem];
        }
    }];
    
    return self;
}

- (CMTReplyToolBarItem *)itemAtIndex:(NSInteger)index {
    if (index < self.toolBarItems.count) {
        return self.toolBarItems[index];
    }
    else {
        return nil;
    }
}


@end
