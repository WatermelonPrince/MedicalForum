//
//  CMTReplyToolBar.h
//  MedicalForum
//
//  Created by fenglei on 15/9/6.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTFloatView.h"

FOUNDATION_EXPORT const CGFloat CMTReplyToolBarDefaultHeight;

/// 回复工具条按钮
@interface CMTReplyToolBarItem : UIView

/* init */

+ (instancetype)itemWithItemTitle:(NSString *)itemTitle
                         itemIcon:(NSString *)itemIcon;

/* output */

@property (nonatomic, strong, readonly) UIImageView *itemIconImageView;
@property (nonatomic, strong, readonly) UILabel *itemTitleLabel;

/// 点击回复工具条按钮
@property (nonatomic, strong, readonly) RACSignal *itemTouchSignal;

@end

/// 回复工具条
@interface CMTReplyToolBar : CMTFloatView

/* init */

- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray *)items;

/* output */

- (CMTReplyToolBarItem *)itemAtIndex:(NSInteger)index;

@end
