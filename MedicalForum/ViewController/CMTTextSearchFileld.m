//
//  CMTTextSearchFileld.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/14.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTTextSearchFileld.h"

@implementation CMTTextSearchFileld

- (void) drawPlaceholderInRect:(CGRect)rect {
    
    // PlaceholderColor
    UIColor *PlaceholderColor = COLOR(c_1515157F);
    
    // PlaceholderParagraphStyle
    NSMutableParagraphStyle *PlaceholderParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    PlaceholderParagraphStyle.alignment = self.textAlignment;
    PlaceholderParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    // PlaceholderAttributes
    NSDictionary *PlaceholderAttributes = @{
                                            NSFontAttributeName:[UIFont systemFontOfSize:13],
                                            NSParagraphStyleAttributeName: PlaceholderParagraphStyle,
                                            NSForegroundColorAttributeName: PlaceholderColor,
                                            NSBaselineOffsetAttributeName: @-8,
                                            };
    
    // AttributedPlaceholder
    NSAttributedString *AttributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:PlaceholderAttributes];
    
    // Draw
    CGRect AttributedPlaceholderRect = rect;
    AttributedPlaceholderRect.origin.x = 4.0;
    AttributedPlaceholderRect.size.width -= AttributedPlaceholderRect.origin.x;
    [AttributedPlaceholder drawInRect:AttributedPlaceholderRect];
}

@end
