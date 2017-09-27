//
//  CMTGetWith.h
//  MedicalForum
//
//  Created by CMT on 15/6/2.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMTGetStringWith_Height: NSObject
//获取文字宽度
+(float)CMTGetLableTitleWith:(NSString*)titleString fontSize:(float)fontSize;
//获取文字高度
+(float)getTextheight:(NSString*)text fontsize:(float)size width:(float) width;
@end
