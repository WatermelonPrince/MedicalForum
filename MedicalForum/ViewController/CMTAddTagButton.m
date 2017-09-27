//
//  CMTAddTagButton.m
//  MedicalForum
//
//  Created by CMT on 15/6/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTAddTagButton.h"

@implementation CMTAddTagButton
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, self.width, self.height) cornerRadius: 5];
    [[UIColor colorWithHexString:@"#D7D7DB"] setStroke];
    roundedRectanglePath.lineWidth = 2;
    CGFloat roundedRectanglePattern[] = {3, 3,3,3,3,3};
    [roundedRectanglePath setLineDash: roundedRectanglePattern count: 6 phase: 0];
    [roundedRectanglePath stroke];
}
@end
