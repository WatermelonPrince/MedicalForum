//
//  CMTTextField.m
//  MedicalForum
//
//  Created by fenglei on 14/12/24.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTTextField.h"

@implementation CMTTextField

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    
    UIImage *leftViewImage = IMAGE(@"comment_Write");
    CGFloat leftViewImageWidth = leftViewImage.size.width;
    CGFloat leftViewImageHeight = leftViewImage.size.height;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.height-leftViewImageHeight)/2-5, leftViewImageWidth + 10, leftViewImageHeight + 2.0)];
    leftView.backgroundColor = COLOR(c_clear);
    UIImageView *leftViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, -1.0, leftViewImageWidth, leftViewImageHeight)];
    leftViewImageView.backgroundColor = COLOR(c_clear);
    leftViewImageView.image = leftViewImage;
    [leftView addSubview:leftViewImageView];
    
    self.leftView = leftView;
    
    // 1.8.5版本开始 不再显示leftView
    self.leftViewMode = UITextFieldViewModeAlways;
    
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    
    // PlaceholderColor
    UIColor *PlaceholderColor = COLOR(c_d2d2d2);
    
    // PlaceholderParagraphStyle
    NSMutableParagraphStyle *PlaceholderParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    PlaceholderParagraphStyle.alignment = self.textAlignment;
    PlaceholderParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    // PlaceholderAttributes
    NSDictionary *PlaceholderAttributes = @{
                                            NSFontAttributeName: self.font,
                                            NSParagraphStyleAttributeName: PlaceholderParagraphStyle,
                                            NSForegroundColorAttributeName: PlaceholderColor,
                                            NSBaselineOffsetAttributeName: @-10,
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
