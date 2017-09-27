//
//  CMTGetWith.m
//  MedicalForum
//
//  Created by CMT on 15/6/2.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTGetStringWith_Height.h"

@implementation CMTGetStringWith_Height : NSObject
+(float)CMTGetLableTitleWith:(NSString*)titleString fontSize:(float)fontSize{
    UIFont *font=FONT(fontSize);
    CGSize titleSize = [titleString boundingRectWithSize:CGSizeMake(MAXFLOAT,40)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                              attributes:@{NSFontAttributeName:font}
                                                 context:nil].size;
    return titleSize.width;
}
+(float)getTextheight:(NSString*)text fontsize:(float)size width:(float) width{
    
    CGSize titleSize = [text boundingRectWithSize:CGSizeMake(width,MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingTruncatesLastVisibleLine
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]}
                                          context:nil].size;
    return ceil(titleSize.height);


}


@end
