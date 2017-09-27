//
//  CMTBarButtonItem.m
//  MedicalForum
//
//  Created by fenglei on 15/2/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTBarButtonItem.h"            // header file

@interface CMTBarButtonItem ()

/* output */

/// 点击按钮
@property (nonatomic, strong, readwrite) RACSignal *touchSignal;
/// 标记
@property (nonatomic, strong, readwrite) UIView *badge;

@end

@implementation CMTBarButtonItem

#pragma mark Initializers

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"BarButtonItem willDeallocSignal");
    }];
    
    return self;
}

+ (UIButton *)customButtonWithImage:(UIImage *)image imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [customButton setBackgroundColor:COLOR(c_clear)];
    [customButton setImage:image forState:UIControlStateNormal];
    [customButton setImage:image forState:UIControlStateHighlighted];
    [customButton setImageEdgeInsets:imageEdgeInsets];
    
    return customButton;
}

+ (instancetype)itemWithImage:(UIImage *)image imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    CMTLog(@"%s", __FUNCTION__);
    UIButton *customButton = [self customButtonWithImage:image imageEdgeInsets:imageEdgeInsets];
    CMTBarButtonItem *barButtonItem = [[CMTBarButtonItem alloc] initWithCustomView:customButton];
    barButtonItem.touchSignal = [customButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    return barButtonItem;
}

+ (instancetype)itemWithImage:(UIImage *)image badge:(UIView *)badge imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    CMTLog(@"%s", __FUNCTION__);
    UIButton *customButton = [self customButtonWithImage:image imageEdgeInsets:imageEdgeInsets];
    CMTBarButtonItem *barButtonItem = [[CMTBarButtonItem alloc] initWithCustomView:customButton];
    barButtonItem.touchSignal = [customButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    [customButton addSubview:badge];
    barButtonItem.badge = badge;
    
    return barButtonItem;
}
+ (instancetype)itemWithImage:(UIImage *)image badgeValue:(UILabel *)badgeValue imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    CMTLog(@"%s", __FUNCTION__);
    UIButton *customButton = [self customButtonWithImage:image imageEdgeInsets:imageEdgeInsets];
    CMTBarButtonItem *barButtonItem = [[CMTBarButtonItem alloc] initWithCustomView:customButton];
    barButtonItem.touchSignal = [customButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    [customButton addSubview:badgeValue];
    barButtonItem.badgeValue = badgeValue;
    
    return barButtonItem;
}

+ (instancetype)itemWithImage:(UIImage *)image badge:(UIView *)badge badgeValue:(UILabel *)badgeValue imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    CMTLog(@"%s", __FUNCTION__);
    UIButton *customButton = [self customButtonWithImage:image imageEdgeInsets:imageEdgeInsets];
    CMTBarButtonItem *barButtonItem = [[CMTBarButtonItem alloc] initWithCustomView:customButton];
    barButtonItem.touchSignal = [customButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    [customButton addSubview:badgeValue];
    [customButton addSubview:badge];
    barButtonItem.badgeValue = badgeValue;
    barButtonItem.badge=badge;
    barButtonItem.customButton = customButton;
    
    return barButtonItem;
}


@end
