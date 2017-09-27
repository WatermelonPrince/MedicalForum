//
//  CMTColledgeSearchField.m
//  MedicalForum
//
//  Created by zhaohuan on 16/11/1.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTColledgeSearchField.h"

@implementation CMTColledgeSearchField


- (void) drawPlaceholderInRect:(CGRect)rect {
    
    // PlaceholderColor
    UIColor *PlaceholderColor = [UIColor colorWithHexString:@"#95c6bc"];
    
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
