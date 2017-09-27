//
//  CMTTableSectionHeader.h
//  MedicalForum
//
//  Created by fenglei on 14/12/19.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTTableSectionHeader : UIView

+ (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight;
+ (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight inSection:(NSInteger)section;
+ (instancetype)headerWithHeaderWidth:(CGFloat)headerWidth headerHeight:(CGFloat)headerHeight isneedbuttomLine:(BOOL)isneed;

- (NSString *)title;
- (void)setTitle:(NSString *)title;

@end
