//
//  UITextField+CMTExtension.h
//  MedicalForum
//
//  Created by Bo Shen on 15/1/13.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (CMTExtension)

/**
 *  使用时只要调用此方法，加上一个长度(int)，就可以实现了字数限制,汉字不可以
 *
 *  @param length
 */
- (void)limitTextLength:(int)length;
/**
 *  uitextField 抖动效果
 */
- (void)shake;

@end
