//
//  UITableView+CMTExtension_PlaceholderView.m
//  MedicalForum
//
//  Created by fenglei on 15/6/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "UITableView+CMTExtension_PlaceholderView.h"
#import <objc/runtime.h>

static const NSString *CMTUITableViewPlaceholderViewAssociatedKey = @"CMTUITableViewPlaceholderViewAssociatedKey";
static const NSString *CMTUITableViewPlaceholderViewOffsetAssociatedKey = @"CMTUITableViewPlaceholderViewOffsetAssociatedKey";

@implementation UITableView (CMTExtension_PlaceholderView)

#pragma mark PlaceholderView

- (UIView *)placeholderView {
    return objc_getAssociatedObject(self, &CMTUITableViewPlaceholderViewAssociatedKey);
}

- (void)setPlaceholderView:(UIView *)placeholderView {
    if (self.placeholderView != nil) {
        [self.placeholderView removeFromSuperview];
    }
    objc_setAssociatedObject(self, &CMTUITableViewPlaceholderViewAssociatedKey, placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updatePlaceholderView];
}

- (NSValue *)placeholderViewOffset {
    return objc_getAssociatedObject(self, &CMTUITableViewPlaceholderViewOffsetAssociatedKey);
}

- (void)setPlaceholderViewOffset:(NSValue *)placeholderViewOffset {
    if ([self.placeholderViewOffset isEqual:placeholderViewOffset]) {
        return;
    }
    
    objc_setAssociatedObject(self, &CMTUITableViewPlaceholderViewOffsetAssociatedKey, placeholderViewOffset, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self updatePlaceholderView];
}

#pragma mark Swizzle

+ (void)load {
    CMTSwizzleMethod([UITableView class], @selector(reloadData), @selector(CMT_reloadData));
}
- (void)CMT_reloadData {
    [self CMT_reloadData];
    [self updatePlaceholderView];
}

#pragma mark Layout

- (void)updatePlaceholderView {
    // +load 方法会使所有tableView的-reloadData及-layoutSubviews方法被替换
    // 此处根据placeholderView是否为nil来判断该tableView是否需要执行-updatePlaceholderView方法
    if (self.placeholderView == nil) {
        return;
    }
    
    if (self.placeholderView.superview != self) {
        [self addSubview:self.placeholderView];
    }
    
    self.placeholderView.frame = ({
        CGRect rect = self.bounds;
        rect.origin = (CGPoint){0, 0};
        rect = UIEdgeInsetsInsetRect(rect, (UIEdgeInsets){.top = CGRectGetHeight(self.tableHeaderView.frame)});
        rect.size.height -= self.contentInset.top;
        rect;
    });
    
    self.placeholderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.placeholderView.hidden = ![self isTableViewEmpty];
    
    CGRect bounds = self.placeholderView.bounds;
    bounds.origin = self.placeholderViewOffset.CGPointValue;
    self.placeholderView.bounds = bounds;
    [self bringSubviewToFront:self.placeholderView];
}

#pragma mark TableView Count

- (BOOL)isTableViewEmpty {
    NSUInteger rowCount = 0;
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        rowCount += [self numberOfRowsInSection:section];
    }
    return rowCount == 0;
}

@end
