//
//  NSString+CMTExtension_HTMLString.h
//  MedicalForum
//
//  Created by fenglei on 15/6/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

/* HTMLTemplate */

// HTMLTemplate
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplate_fileName;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplate_caseDetail_fileName;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplate_fileType;

// HTMLTemplateDefaultImage
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplateDefaultImage_fileName;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplateDefaultImage_fileType;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplateDefaultAuthorImage;

// HTMLTemplateMark
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplateMark_PDF;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplateMark_Answer;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplateMark_Vote;

// HTMLTemplateClassName
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplateClassName_on;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTemplateClassName_on_red;

@interface NSString (CMTExtension_HTMLString)

/* HTMLTemplate <body> */

+ (NSString *)caseDetailHTMLStringWithPostDetail:(CMTPost *)postDetail
                                        authorId:(NSString *)authorId
                                          author:(NSString *)author
                        imageRequestURLPairArray:(NSMutableArray *)imageRequestURLPairArray;


/// 文章详情HTML
/// imageRequestURLPairArray传入空的NSMutableArray
/// 用于获取需求请求的图片的URL 数组元素为字典 {原始图片URLString: 替换为默认图片并添加动作标签后的URLString}
+ (NSString *)postDetailHTMLStringWithTitle:(NSString *)title
                                       date:(NSString *)date
                                   authorId:(NSString *)authorId
                                     author:(NSString *)author
                                 postTypeId:(NSString *)postTypeId
                                   postType:(NSString *)postType
                                   postAttr:(NSString *)postAttr
                                     module:(NSString *)module
                             customFontSize:(NSString *)customFontSize
                                     postId:(NSString *)postId
                                    themeId:(NSString *)themeId
                                      theme:(NSString *)theme
                              diseaseTagArr:(NSArray *)diseaseTagArr
                                 postTagArr:(NSArray *)postTagArr
                          contentHTMLString:(NSString *)contentHTMLString
                   imageRequestURLPairArray:(NSMutableArray *)imageRequestURLPairArray;
/// 简单文章详情HTML
+ (NSString *)simplePostDetailHTMLStringWithTitle:(NSString *)title
                                             date:(NSString *)date
                                         authorId:(NSString *)authorId
                                           author:(NSString *)author
                                       postTypeId:(NSString *)postTypeId
                                         postType:(NSString *)postType
                                         postAttr:(NSString *)postAttr
                                           module:(NSString *)module
                                   customFontSize:(NSString *)customFontSize;

/* HTMLTemplate <img> */

/// 用图片路径'imagePath'替换<img>的src属性'self', 并添加一个带静态文章'图片'动作标签的onclick事件
- (NSString *)CMT_HTMLImgSrc_ByPlacedWithImagePath:(NSString *)imagePath
                                        imageIndex:(NSString *)imageIndex;
/// 用默认图片路径'defaultImagePath'替换<img>的src属性'self', 并添加ori-src属性和一个带静态文章'图片'动作标签的onclick事件
- (NSString *)CMT_HTMLImgSrc_ByPlacedWithDefaultImagePath:(NSString *)defaultImagePath
                                               imageIndex:(NSString *)imageIndex;

/* HTMLTemplate <a> */

/// 普通<a>, 以className为class, 以HTMLTag为超链接
+ (NSString *)CMT_HTMLLabel_withText:(NSString *)text
                           className:(NSString *)className
                             HTMLTag:(NSString *)HTMLTag;
/// <span><a>, 以className为class, 以HTMLTag为超链接
+ (NSString *)CMT_HTMLLabelSpan_withText:(NSString *)text
                               className:(NSString *)className
                                 HTMLTag:(NSString *)HTMLTag;
#pragma mark处理@提醒某人
+(NSString*)replacedremindPeople:(NSString*)atuser;

/* HTMLEscape */

/// HTMLEscape
- (NSString *)HTMLEscapedString;
/// HTMLUnEscape
- (NSString *)HTMLUnEscapedString;
//
-(NSString *)encodeToPercentEscapeString;
- (NSString *)decodeFromPercentEscapeString;
- (NSString *)URLDecodedString:(NSString *)str;

@end
