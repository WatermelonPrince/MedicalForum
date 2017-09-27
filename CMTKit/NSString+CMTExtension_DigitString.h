//
//  NSString+CMTExtension_DigitString.h
//  MedicalForum
//
//  Created by fenglei on 15/6/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CMTExtension_DigitString)

/* for DigitString instance */

/// 自身的整形值与digitString的整形值按位与运算
/// 如果运算结果等于digitString的整形值, 返回YES, 否则返回NO
- (BOOL)isComposeDigit:(NSString *)digitString;

/// 文章属性是否为PDF
- (BOOL)isPostAttrPDF;
/// 文章属性是否为问答
- (BOOL)isPostAttrAnswer;
/// 文章属性是否为投票
- (BOOL)isPostAttrVote;
/**
 *  文章是否有投票
 *
 *  @return
 */
- (BOOL)isPostAttrVideo;
- (BOOL)isPostAttrAudio;
- (BOOL)isPostAttrOnlyVideo;

/// 文章模块是为首页
- (BOOL)isPostModuleHome;
/// 文章模块是为病例
- (BOOL)isPostModuleCase;
/// 文章模块是为指南
- (BOOL)isPostModuleGuide;
/// 文章模块描述
- (NSString *)moduleString;

/// 是否为真 非零
- (BOOL)isTrue;
/// 是否为假 零
- (BOOL)isFalse;

@end
